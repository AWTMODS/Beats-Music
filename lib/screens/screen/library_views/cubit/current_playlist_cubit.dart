// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:beats_music/services/db/beats_music_db_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:beats_music/model/MediaPlaylistModel.dart';
import 'package:beats_music/model/songModel.dart';
import 'package:beats_music/services/db/GlobalDB.dart';
import 'package:beats_music/services/db/cubit/beats_music_db_cubit.dart';
import 'package:beats_music/utils/pallete_generator.dart';
import 'package:beats_music/repository/Youtube/ytm/ytmusic.dart';
import 'package:beats_music/model/yt_music_model.dart';
import 'package:beats_music/services/discovery_service.dart';
import 'package:beats_music/services/listening_statistics_service.dart';
import 'dart:developer';
part 'current_playlist_state.dart';

class CurrentPlaylistCubit extends Cubit<CurrentPlaylistState> {
  MediaPlaylist? mediaPlaylist;
  PaletteGenerator? paletteGenerator;
  late BeatsMusicDBCubit beatsMusicDBCubit;
  CurrentPlaylistCubit({
    this.mediaPlaylist,
    required this.beatsMusicDBCubit,
  }) : super(CurrentPlaylistInitial()) {}

  // Static cache to store special mixes across cubit instances/navigations
  static final Map<String, MediaPlaylist> _mixCache = {};

  Future<void> setupPlaylist(String playlistName) async {
    emit(CurrentPlaylistLoading());

    // Handle special online mix sections
    if (_isSpecialMix(playlistName)) {
      // Check cache first
      if (_mixCache.containsKey(playlistName)) {
        mediaPlaylist = _mixCache[playlistName];
         if (mediaPlaylist?.mediaItems.isNotEmpty ?? false) {
           // We might need to regenerate palette if not cached, 
           // but normally we can just use the cached playlist data.
           // Ideally we should cache the palette logic too or re-run it quickly.
           paletteGenerator = await getPalleteFromImage(
              mediaPlaylist!.mediaItems[0].artUri.toString());
        }
        
        emit(state.copyWith(
          playlistName: mediaPlaylist?.playlistName,
          isFetched: true,
          mediaPlaylist: mediaPlaylist,
          mediaItem: List<MediaItemModel>.from(mediaPlaylist!.mediaItems)
        ));
        return;
      }

      await _fetchAndSetupOnlineMix(playlistName);
      return;
    }

    mediaPlaylist = await beatsMusicDBCubit
        .getPlaylistItems(MediaPlaylistDB(playlistName: playlistName));

    if (mediaPlaylist?.mediaItems.isNotEmpty ?? false) {
      paletteGenerator = await getPalleteFromImage(
          mediaPlaylist!.mediaItems[0].artUri.toString());
    }
    // log(paletteGenerator.toString());
    emit(state.copyWith(
        playlistName: mediaPlaylist?.playlistName,
        isFetched: true,
        mediaPlaylist: mediaPlaylist,
        mediaItem: List<MediaItemModel>.from(mediaPlaylist!.mediaItems)));
  }

  bool _isSpecialMix(String id) {
    return const [
      'your_top_mix',
      'discover_weekly',
      'release_radar',
      'daily_mix_1'
    ].contains(id);
  }

  Future<void> _fetchAndSetupOnlineMix(String id) async {
    try {
      final discoveryService = DiscoveryService();
      final statisticsService = ListeningStatisticsService();
      
      List<MediaItemModel> songs = [];
      String displayTitle = "";
      String description = "Personalized for you";

      switch (id) {
        case 'your_top_mix':
          displayTitle = "Your Top Mix";
          description = "Your most played songs";
          final topStats = await statisticsService.getTopSongs(limit: 50);
          songs = topStats.map((s) => MediaItemModel(
            id: s.songId,
            title: s.songTitle,
            artist: s.artist,
            artUri: Uri.parse(""), // We might need to fetch/store art
            extras: {'url': s.songId}, // Assuming songId is permaURL or we need to resolve it
          )).toList();
          
          // We need to fetch full details (art, url) for these songs since stats might not have everything
          // Or we can modify stats to store artUri, or just fetch from YTM if missing.
          // For now, let's assume we need to re-fetch or use what we have.
          // Actually, let's stick to the current Flow for Top Mix: generic search if stats empty?
          if (songs.isEmpty) {
             // Fallback to generic search if no stats
             await _fetchGenericMix("My Supermix", "Your Top Mix");
             return;
          }
          break;

        case 'discover_weekly':
          displayTitle = "Discover Weekly";
          description = "New music updated every week";
          songs = await discoveryService.generateDiscoverWeekly();
          if (songs.isEmpty) {
             await _fetchGenericMix("Discover Mix", "Discover Weekly");
             return;
          }
          break;

        case 'release_radar':
          displayTitle = "Release Radar";
          // formatting generic search as fallback
          await _fetchGenericMix("New Release Mix", "Release Radar");
          return;

        case 'daily_mix_1':
          displayTitle = "Daily Mix 1";
          description = "Your daily music mix";
          final mixes = await discoveryService.generateDailyMixes();
          if (mixes.isNotEmpty) {
            songs = mixes[0];
          } else {
             await _fetchGenericMix("My Daily Mix 1", "Daily Mix 1");
             return;
          }
          break;
      }

      mediaPlaylist = MediaPlaylist(
        playlistName: displayTitle,
        mediaItems: songs,
        description: description,
      );
      
      // Cache the result
      _mixCache[id] = mediaPlaylist!;

      if (mediaPlaylist?.mediaItems.isNotEmpty ?? false) {
        paletteGenerator = await getPalleteFromImage(
            mediaPlaylist!.mediaItems[0].artUri.toString());
      }

      emit(state.copyWith(
          playlistName: displayTitle,
          isFetched: true,
          mediaPlaylist: mediaPlaylist,
          mediaItem: songs));

    } catch (e) {
      log('Error fetching online mix: $e', name: "CurrentPlaylistCubit");
      mediaPlaylist = MediaPlaylist(playlistName: "Error loading mix", mediaItems: []);
      emit(state.copyWith(
          playlistName: "Error", isFetched: true, mediaPlaylist: mediaPlaylist));
    }
  }

  Future<void> _fetchGenericMix(String query, String displayTitle) async {
      // Search for the playlist on YTM
      final searchRes = await YTMusic().searchYtm(query, type: "playlists");
      if (searchRes != null &&
          searchRes['playlists'] != null &&
          (searchRes['playlists'] as List).isNotEmpty) {
        final firstPlaylist = searchRes['playlists'][0];
        final playlistId = firstPlaylist['playlistId'];

        // Get full playlist details
        final fullPlaylist = await YTMusic().getPlaylistFull(playlistId);

        if (fullPlaylist != null && fullPlaylist['songs'] != null) {
          final List<MediaItemModel> songs =
              ytmMapList2MediaItemList(fullPlaylist['songs']);

          mediaPlaylist = MediaPlaylist(
            playlistName: displayTitle,
            mediaItems: songs,
            description: "Curated from YouTube Music",
          );
          
          if (mediaPlaylist?.mediaItems.isNotEmpty ?? false) {
            paletteGenerator = await getPalleteFromImage(
                mediaPlaylist!.mediaItems[0].artUri.toString());
          }

          emit(state.copyWith(
              playlistName: displayTitle,
              isFetched: true,
              mediaPlaylist: mediaPlaylist,
              mediaItem: songs));
          return;
        }
      }
      
      // Fallback if not found
      mediaPlaylist = MediaPlaylist(playlistName: displayTitle, mediaItems: []);
      emit(state.copyWith(
          playlistName: displayTitle, isFetched: true, mediaPlaylist: mediaPlaylist));
  }

  Future<List<int>> getItemOrder() async {
    return await BeatsMusicDBService.getPlaylistItemsRankByName(
        mediaPlaylist!.playlistName);
  }

  String getTitle() {
    return state.mediaPlaylist.playlistName;
  }

  Future<void> updatePlaylist(List<int> newOrder) async {
    final oldOrder = await getItemOrder();
    if (!listEquals(newOrder, oldOrder) &&
        mediaPlaylist != null &&
        newOrder.length >= mediaPlaylist!.mediaItems.length) {
      await BeatsMusicDBService.updatePltItemsRankByName(
          mediaPlaylist!.playlistName, newOrder);
      final playlist = await beatsMusicDBCubit.getPlaylistItems(
          MediaPlaylistDB(playlistName: mediaPlaylist!.playlistName));
      setupPlaylist(playlist.playlistName);
    }
  }

  int getPlaylistLength() {
    if (mediaPlaylist != null) {
      return mediaPlaylist?.mediaItems.length ?? 0;
    } else {
      return 0;
    }
  }

  String? getPlaylistCoverArt() {
    if (mediaPlaylist?.mediaItems.isNotEmpty ?? false) {
      return mediaPlaylist?.mediaItems[0].artUri.toString();
    } else {
      return "";
    }
  }

  PaletteGenerator? getCurrentPlaylistPallete() {
    return paletteGenerator;
  }
}
