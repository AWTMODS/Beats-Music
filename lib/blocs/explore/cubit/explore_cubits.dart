// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:isolate';
import 'package:beats_music/repository/Youtube/yt_music_home.dart';
import 'package:beats_music/repository/Youtube/yt_malayalam_songs.dart'
    as malayalam_repo;
import 'package:beats_music/repository/Youtube/yt_hindi_songs.dart'
    as hindi_repo;
import 'package:beats_music/repository/Youtube/yt_tamil_songs.dart'
    as tamil_repo;
import 'package:beats_music/services/db/GlobalDB.dart';
import 'package:beats_music/utils/country_info.dart';
import 'package:beats_music/model/MediaPlaylistModel.dart';
import 'package:beats_music/model/chart_model.dart';
import 'package:beats_music/plugins/ext_charts/chart_defines.dart';
import 'package:beats_music/repository/Youtube/yt_charts_home.dart';
import 'package:beats_music/screens/screen/chart/show_charts.dart';
import 'package:beats_music/services/db/beats_music_db_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
part 'explore_states.dart';

class TrendingCubit extends Cubit<TrendingCubitState> {
  bool isLatest = false;
  TrendingCubit() : super(TrendingCubitInitial()) {
    getTrendingVideosFromDB();
    getTrendingVideos();
  }

  void getTrendingVideos() async {
    List<ChartModel> ytCharts = await fetchTrendingVideos();
    ChartModel chart = ytCharts[0]
      ..chartItems = getFirstElements(ytCharts[0].chartItems!, 16);
    emit(state.copyWith(ytCharts: [chart]));
    isLatest = true;
  }

  List<ChartItemModel> getFirstElements(List<ChartItemModel> list, int count) {
    return list.length > count ? list.sublist(0, count) : list;
  }

  void getTrendingVideosFromDB() async {
    ChartModel? ytChart = await BeatsMusicDBService.getChart("Trending Videos");
    if ((!isLatest) &&
        ytChart != null &&
        (ytChart.chartItems?.isNotEmpty ?? false)) {
      ChartModel chart = ytChart
        ..chartItems = getFirstElements(ytChart.chartItems!, 16);
      emit(state.copyWith(ytCharts: [chart]));
    }
  }
}

class RecentlyCubit extends Cubit<RecentlyCubitState> {
  StreamSubscription<void>? watcher;
  RecentlyCubit() : super(RecentlyCubitInitial()) {
    getRecentlyPlayed();
    watchRecentlyPlayed();
  }

  Future<void> watchRecentlyPlayed() async {
    watcher = (await BeatsMusicDBService.watchRecentlyPlayed()).listen((event) {
      getRecentlyPlayed();
      log("Recently Played Updated");
    });
  }

  @override
  Future<void> close() {
    watcher?.cancel();
    return super.close();
  }

  void getRecentlyPlayed() async {
    final mediaPlaylist = await BeatsMusicDBService.getRecentlyPlayed(limit: 15);
    emit(state.copyWith(mediaPlaylist: mediaPlaylist));
  }
}

class ChartCubit extends Cubit<ChartState> {
  ChartInfo chartInfo;
  StreamSubscription? strm;
  FetchChartCubit fetchChartCubit;
  ChartCubit(
    this.chartInfo,
    this.fetchChartCubit,
  ) : super(ChartInitial()) {
    getChartFromDB();
    initListener();
  }
  void initListener() {
    strm = fetchChartCubit.stream.listen((state) {
      if (state.isFetched) {
        log("Chart Fetched from Isolate - ${chartInfo.title}",
            name: "Isolate Fetched");
        getChartFromDB();
      }
    });
  }

  Future<void> getChartFromDB() async {
    final chart = await BeatsMusicDBService.getChart(chartInfo.title);
    if (chart != null) {
      emit(state.copyWith(
          chart: chart, coverImg: chart.chartItems?.first.imageUrl));
    }
  }

  @override
  Future<void> close() {
    fetchChartCubit.close();
    strm?.cancel();
    return super.close();
  }
}

Map<String, List<dynamic>> parseYTMusicData(String source) {
  final dynamicMap = jsonDecode(source);

  Map<String, List<dynamic>> listDynamicMap;
  if (dynamicMap is Map) {
    listDynamicMap = dynamicMap.map((key, value) {
      List<dynamic> list = [];
      if (value is List) {
        list = value;
      }
      return MapEntry(key, list);
    });
  } else {
    listDynamicMap = {};
  }
  return listDynamicMap;
}

class FetchChartCubit extends Cubit<FetchChartState> {
  FetchChartCubit() : super(FetchChartInitial()) {
    fetchCharts();
  }

  Future<void> fetchCharts() async {
    String _path = (await getApplicationSupportDirectory()).path;
    BackgroundIsolateBinaryMessenger.ensureInitialized(
      ServicesBinding.rootIsolateToken!,
    );
    await BeatsMusicDBService.db;
    final chartList = await Isolate.run<List<ChartModel>>(() async {
      log(_path, name: "Isolate Path");
      List<ChartModel> _chartList = List.empty(growable: true);
      ChartModel chart;
      final db = await Isar.open(
        [
          ChartsCacheDBSchema,
        ],
        directory: _path,
      );
      for (var i in chartInfoList) {
        final chartCacheDB = db.chartsCacheDBs
            .where()
            .filter()
            .chartNameEqualTo(i.title)
            .findFirstSync();
        bool _shouldFetch = (chartCacheDB?.lastUpdated
                    .difference(DateTime.now())
                    .inHours
                    .abs() ??
                80) >
            16;
        log("Last Updated - ${(chartCacheDB?.lastUpdated.difference(DateTime.now()).inHours)?.abs()} Hours before ",
            name: "Isolate");

        if (_shouldFetch) {
          chart = await i.chartFunction(i.url);
          if ((chart.chartItems?.isNotEmpty) ?? false) {
            db.writeTxnSync(() =>
                db.chartsCacheDBs.putSync(chartModelToChartCacheDB(chart)));
          }
          log("Chart Fetched - ${chart.chartName}", name: "Isolate");
          _chartList.add(chart);
        }
      }
      db.close();
      return _chartList;
    });

    if (chartList.isNotEmpty) {
      emit(state.copyWith(isFetched: true));
    }
  }
}

class YTMusicCubit extends Cubit<YTMusicCubitState> {
  YTMusicCubit() : super(YTMusicCubitInitial()) {
    fetchYTMusicDB();
    fetchYTMusic();
  }

  void fetchYTMusicDB() async {
    final data = await BeatsMusicDBService.getAPICache("YTMusic");
    if (data != null) {
      final ytmData = await compute(parseYTMusicData, data);
      if (ytmData.isNotEmpty) {
        emit(state.copyWith(ytmData: ytmData));
      }
    }
  }

  Future<void> fetchYTMusic() async {
    String countryCode = await getCountry();
    final ytCharts =
        await Isolate.run(() => getMusicHome(countryCode: countryCode));
    if (ytCharts.isNotEmpty) {
      emit(state.copyWith(ytmData: Map<String, List<dynamic>>.from(ytCharts)));
      final ytChartsJson = await compute(jsonEncode, ytCharts);
      BeatsMusicDBService.putAPICache("YTMusic", ytChartsJson);
      log("YTMusic Fetched", name: "YTMusic");
    }
  }
}

class MalayalamSongsCubit extends Cubit<MalayalamSongsState> {
  MalayalamSongsCubit() : super(MalayalamSongsInitial()) {
    _clearOldCache();
    fetchMalayalamSongsFromDB();
    fetchMalayalamSongs();
  }

  // Clear old cache to force refresh with high-quality images
  Future<void> _clearOldCache() async {
    final cacheVersion = await BeatsMusicDBService.getAPICache("MalayalamSongs_v2");
    if (cacheVersion == null) {
      // Clear old cache
      await BeatsMusicDBService.putAPICache("MalayalamSongs", "");
      await BeatsMusicDBService.putAPICache("MalayalamSongs_v2", "1");
      log("Cleared old Malayalam songs cache", name: "MalayalamSongs");
    }
  }

  void fetchMalayalamSongsFromDB() async {
    final data = await BeatsMusicDBService.getAPICache("MalayalamSongs");
    if (data != null) {
      try {
        final List<dynamic> decoded = jsonDecode(data);
        final List<Map<String, dynamic>> songs =
            decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        if (songs.isNotEmpty) {
          emit(state.copyWith(songs: songs, isLoading: false));
        }
      } catch (e) {
        log("Error loading Malayalam songs from cache: $e",
            name: "MalayalamSongs");
      }
    }
  }

  Future<void> fetchMalayalamSongs() async {
    try {
      final songs = await malayalam_repo.fetchMalayalamSongs();
      if (songs.isNotEmpty) {
        emit(state.copyWith(songs: songs, isLoading: false, error: null));
        final songsJson = await compute(jsonEncode, songs);
        BeatsMusicDBService.putAPICache("MalayalamSongs", songsJson);
        log("Malayalam Songs Fetched: ${songs.length}", name: "MalayalamSongs");
      } else {
        emit(state.copyWith(isLoading: false));
      }
    } catch (e) {
      log("Error fetching Malayalam songs: $e", name: "MalayalamSongs");
      emit(state.copyWith(
          isLoading: false, error: "Failed to load Malayalam songs"));
    }
  }
}

class HindiSongsCubit extends Cubit<HindiSongsState> {
  HindiSongsCubit() : super(HindiSongsInitial()) {
    _clearOldCache();
    fetchHindiSongsFromDB();
    fetchHindiSongs();
  }

  // Clear old cache to force refresh with high-quality images
  Future<void> _clearOldCache() async {
    final cacheVersion = await BeatsMusicDBService.getAPICache("HindiSongs_v2");
    if (cacheVersion == null) {
      // Clear old cache
      await BeatsMusicDBService.putAPICache("HindiSongs", "");
      await BeatsMusicDBService.putAPICache("HindiSongs_v2", "1");
      log("Cleared old Hindi songs cache", name: "HindiSongs");
    }
  }

  void fetchHindiSongsFromDB() async {
    final data = await BeatsMusicDBService.getAPICache("HindiSongs");
    if (data != null) {
      try {
        final List<dynamic> decoded = jsonDecode(data);
        final List<Map<String, dynamic>> songs =
            decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        if (songs.isNotEmpty) {
          emit(state.copyWith(songs: songs, isLoading: false));
        }
      } catch (e) {
        log("Error loading Hindi songs from cache: $e", name: "HindiSongs");
      }
    }
  }

  Future<void> fetchHindiSongs() async {
    try {
      final songs = await hindi_repo.fetchHindiSongs();
      if (songs.isNotEmpty) {
        emit(state.copyWith(songs: songs, isLoading: false, error: null));
        final songsJson = await compute(jsonEncode, songs);
        BeatsMusicDBService.putAPICache("HindiSongs", songsJson);
        log("Hindi Songs Fetched: ${songs.length}", name: "HindiSongs");
      } else {
        emit(state.copyWith(isLoading: false));
      }
    } catch (e) {
      log("Error fetching Hindi songs: $e", name: "HindiSongs");
      emit(state.copyWith(
          isLoading: false, error: "Failed to load Hindi songs"));
    }
  }
}

class TamilSongsCubit extends Cubit<TamilSongsState> {
  TamilSongsCubit() : super(TamilSongsInitial()) {
    _clearOldCache();
    fetchTamilSongsFromDB();
    fetchTamilSongs();
  }

  // Clear old cache to force refresh with high-quality images
  Future<void> _clearOldCache() async {
    final cacheVersion = await BeatsMusicDBService.getAPICache("TamilSongs_v2");
    if (cacheVersion == null) {
      // Clear old cache
      await BeatsMusicDBService.putAPICache("TamilSongs", "");
      await BeatsMusicDBService.putAPICache("TamilSongs_v2", "1");
      log("Cleared old Tamil songs cache", name: "TamilSongs");
    }
  }

  void fetchTamilSongsFromDB() async {
    final data = await BeatsMusicDBService.getAPICache("TamilSongs");
    if (data != null) {
      try {
        final List<dynamic> decoded = jsonDecode(data);
        final List<Map<String, dynamic>> songs =
            decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        if (songs.isNotEmpty) {
          emit(state.copyWith(songs: songs, isLoading: false));
        }
      } catch (e) {
        log("Error loading Tamil songs from cache: $e", name: "TamilSongs");
      }
    }
  }

  Future<void> fetchTamilSongs() async {
    try {
      final songs = await tamil_repo.fetchTamilSongs();
      if (songs.isNotEmpty) {
        emit(state.copyWith(songs: songs, isLoading: false, error: null));
        final songsJson = await compute(jsonEncode, songs);
        BeatsMusicDBService.putAPICache("TamilSongs", songsJson);
        log("Tamil Songs Fetched: ${songs.length}", name: "TamilSongs");
      } else {
        emit(state.copyWith(isLoading: false));
      }
    } catch (e) {
      log("Error fetching Tamil songs: $e", name: "TamilSongs");
      emit(state.copyWith(
          isLoading: false, error: "Failed to load Tamil songs"));
    }
  }
}

