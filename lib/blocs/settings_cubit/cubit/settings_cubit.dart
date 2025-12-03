import 'dart:convert';
import 'dart:developer';
import 'package:beats_music/model/source_engines.dart';
import 'package:beats_music/routes_and_consts/global_str_consts.dart';
import 'package:beats_music/services/db/beats_music_db_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsInitial()) {
    initSettings();
    autoUpdate();
  }

// Initialize the settings from the database
  void initSettings() {
    BeatsMusicDBService.getSettingBool(GlobalStrConsts.autoUpdateNotify)
        .then((value) {
      emit(state.copyWith(autoUpdateNotify: value ?? false));
    });

    BeatsMusicDBService.getSettingBool(GlobalStrConsts.autoSlideCharts)
        .then((value) {
      emit(state.copyWith(autoSlideCharts: value ?? true));
    });

    BeatsMusicDBService.getSettingStr(GlobalStrConsts.downPathSetting)
        .then((value) async {
      String path;
      if (value != null) {
        path = value;
      } else {
        path = ((await getDownloadsDirectory()) ??
                (await getApplicationDocumentsDirectory()))
            .path;
        setDownPath(path);
        log("Download path set to: $path", name: 'SettingsCubit');
      }
      emit(state.copyWith(downPath: path));
    });

    BeatsMusicDBService.getSettingStr(GlobalStrConsts.downQuality,
            defaultValue: '320 kbps')
        .then((value) {
      emit(state.copyWith(downQuality: value ?? "320 kbps"));
    });

    BeatsMusicDBService.getSettingStr(GlobalStrConsts.ytDownQuality).then((value) {
      emit(state.copyWith(ytDownQuality: value ?? "High"));
    });

    BeatsMusicDBService.getSettingStr(
      GlobalStrConsts.strmQuality,
    ).then((value) {
      emit(state.copyWith(strmQuality: value ?? "96 kbps"));
    });

    BeatsMusicDBService.getSettingStr(GlobalStrConsts.ytStrmQuality).then((value) {
      if (value == "High" || value == "Low") {
        emit(state.copyWith(ytStrmQuality: value ?? "Low"));
      } else {
        BeatsMusicDBService.putSettingStr(GlobalStrConsts.ytStrmQuality, "Low");
        emit(state.copyWith(ytStrmQuality: "Low"));
      }
    });

    BeatsMusicDBService.getSettingStr(GlobalStrConsts.historyClearTime)
        .then((value) {
      emit(state.copyWith(historyClearTime: value ?? "30"));
    });

    BeatsMusicDBService.getSettingBool(GlobalStrConsts.lFMScrobbleSetting)
        .then((value) {
      emit(state.copyWith(lastFMScrobble: value ?? false));
    });

    BeatsMusicDBService.getSettingBool(
      GlobalStrConsts.autoPlay,
    ).then((value) {
      emit(state.copyWith(autoPlay: value ?? true));
    });

    BeatsMusicDBService.getSettingBool(
      GlobalStrConsts.aggressivePreload,
    ).then((value) {
      emit(state.copyWith(aggressivePreload: value ?? false));
    });

    BeatsMusicDBService.getSettingBool(
      GlobalStrConsts.useSpotifySearch,
    ).then((value) {
      emit(state.copyWith(useSpotifySearch: value ?? false));
    });

    BeatsMusicDBService.getSettingBool(
      GlobalStrConsts.enableCrossfade,
    ).then((value) {
      emit(state.copyWith(enableCrossfade: value ?? false));
    });

    BeatsMusicDBService.getSettingBool(
      GlobalStrConsts.wifiOnlyDownload,
    ).then((value) {
      emit(state.copyWith(wifiOnlyDownload: value ?? true));
    });

    BeatsMusicDBService.getSettingBool(GlobalStrConsts.lFMUIPicks).then((value) {
      emit(state.copyWith(lFMPicks: value ?? false));
    });

    BeatsMusicDBService.getSettingStr(GlobalStrConsts.backupPath)
        .then((value) async {
      final defaultBackUpDir = await BeatsMusicDBService.getDbBackupFilePath();

      await BeatsMusicDBService.putSettingStr(
          GlobalStrConsts.backupPath, defaultBackUpDir);
      emit(state.copyWith(backupPath: defaultBackUpDir));
    });

    BeatsMusicDBService.getSettingBool(GlobalStrConsts.autoBackup).then((value) {
      emit(state.copyWith(autoBackup: value ?? false));
    });

    BeatsMusicDBService.getSettingBool(GlobalStrConsts.autoGetCountry)
        .then((value) {
      emit(state.copyWith(autoGetCountry: value ?? false));
    });

    BeatsMusicDBService.getSettingStr(GlobalStrConsts.countryCode).then((value) {
      emit(state.copyWith(countryCode: value ?? "IN"));
    });

    // Initialize Language Code
    BeatsMusicDBService.getSettingStr("languageCode").then((value) {
      emit(state.copyWith(languageCode: value ?? "en"));
    });

    BeatsMusicDBService.getSettingBool(GlobalStrConsts.autoSaveLyrics)
        .then((value) {
      emit(state.copyWith(autoSaveLyrics: value ?? false));
    });

    for (var eg in SourceEngine.values) {
      BeatsMusicDBService.getSettingBool(eg.value).then((value) {
        List<bool> switches = List.from(state.sourceEngineSwitches);
        switches[SourceEngine.values.indexOf(eg)] = value ?? true;
        emit(state.copyWith(sourceEngineSwitches: switches));
        log(switches.toString(), name: 'SettingsCubit');
      });
    }

    Map chartMap = Map.from(state.chartMap);
    BeatsMusicDBService.getSettingStr(GlobalStrConsts.chartShowMap).then((value) {
      if (value != null) {
        chartMap = jsonDecode(value);
      }
      emit(state.copyWith(chartMap: Map.from(chartMap)));
    });

    BeatsMusicDBService.getSettingBool("showMalayalamTrending").then((value) {
      emit(state.copyWith(showMalayalamTrending: value ?? true));
    });

    BeatsMusicDBService.getSettingBool("showHindiTrending").then((value) {
      emit(state.copyWith(showHindiTrending: value ?? true));
    });

    BeatsMusicDBService.getSettingBool("showTamilTrending").then((value) {
      emit(state.copyWith(showTamilTrending: value ?? true));
    });
  }

  void setChartShow(String title, bool value) {
    Map chartMap = Map.from(state.chartMap);
    chartMap[title] = value;
    BeatsMusicDBService.putSettingStr(
        GlobalStrConsts.chartShowMap, jsonEncode(chartMap));
    emit(state.copyWith(chartMap: Map.from(chartMap)));
  }

  Future<void> setAutoPlay(bool value) async {
    await BeatsMusicDBService.putSettingBool(GlobalStrConsts.autoPlay, value);
    emit(state.copyWith(autoPlay: value));
  }

  Future<void> setAggressivePreload(bool value) async {
    await BeatsMusicDBService.putSettingBool(GlobalStrConsts.aggressivePreload, value);
    emit(state.copyWith(aggressivePreload: value));
  }

  Future<void> setUseSpotifySearch(bool value) async {
    await BeatsMusicDBService.putSettingBool(GlobalStrConsts.useSpotifySearch, value);
    emit(state.copyWith(useSpotifySearch: value));
  }

  Future<void> setEnableCrossfade(bool value) async {
    await BeatsMusicDBService.putSettingBool(GlobalStrConsts.enableCrossfade, value);
    emit(state.copyWith(enableCrossfade: value));
  }

  Future<void> setWifiOnlyDownload(bool value) async {
    await BeatsMusicDBService.putSettingBool(GlobalStrConsts.wifiOnlyDownload, value);
    emit(state.copyWith(wifiOnlyDownload: value));
  }

  void autoUpdate() {
    BeatsMusicDBService.getSettingBool(GlobalStrConsts.autoBackup).then((value) {
      if (value != null || value == true) {
        BeatsMusicDBService.createBackUp();
      }
    });
  }

  void setCountryCode(String value) {
    BeatsMusicDBService.putSettingStr(GlobalStrConsts.countryCode, value);
    emit(state.copyWith(countryCode: value));
  }

  void setLanguageCode(String value) {
    BeatsMusicDBService.putSettingStr("languageCode", value);
    emit(state.copyWith(languageCode: value));
  }

  void setAutoSaveLyrics(bool value) {
    BeatsMusicDBService.putSettingBool(GlobalStrConsts.autoSaveLyrics, value);
    emit(state.copyWith(autoSaveLyrics: value));
  }

  void setLastFMScrobble(bool value) {
    BeatsMusicDBService.putSettingBool(GlobalStrConsts.lFMScrobbleSetting, value);
    emit(state.copyWith(lastFMScrobble: value));
  }

  void setLastFMExpore(bool value) {
    BeatsMusicDBService.putSettingBool(GlobalStrConsts.lFMUIPicks, value);
    emit(state.copyWith(lFMPicks: value));
  }

  void setAutoGetCountry(bool value) {
    BeatsMusicDBService.putSettingBool(GlobalStrConsts.autoGetCountry, value);
    emit(state.copyWith(autoGetCountry: value));
  }

  void setAutoUpdateNotify(bool value) {
    BeatsMusicDBService.putSettingBool(GlobalStrConsts.autoUpdateNotify, value);
    emit(state.copyWith(autoUpdateNotify: value));
  }

  void setAutoSlideCharts(bool value) {
    BeatsMusicDBService.putSettingBool(GlobalStrConsts.autoSlideCharts, value);
    emit(state.copyWith(autoSlideCharts: value));
  }

  void setDownPath(String value) {
    BeatsMusicDBService.putSettingStr(GlobalStrConsts.downPathSetting, value);
    emit(state.copyWith(downPath: value));
  }

  void setDownQuality(String value) {
    BeatsMusicDBService.putSettingStr(GlobalStrConsts.downQuality, value);
    emit(state.copyWith(downQuality: value));
  }

  void setYtDownQuality(String value) {
    BeatsMusicDBService.putSettingStr(GlobalStrConsts.ytDownQuality, value);
    emit(state.copyWith(ytDownQuality: value));
  }

  void setStrmQuality(String value) {
    BeatsMusicDBService.putSettingStr(GlobalStrConsts.strmQuality, value);
    emit(state.copyWith(strmQuality: value));
  }

  void setYtStrmQuality(String value) {
    BeatsMusicDBService.putSettingStr(GlobalStrConsts.ytStrmQuality, value);
    emit(state.copyWith(ytStrmQuality: value));
  }

  void setBackupPath(String value) {
    BeatsMusicDBService.putSettingStr(GlobalStrConsts.backupPath, value);
    emit(state.copyWith(backupPath: value));
  }

  void setAutoBackup(bool value) {
    BeatsMusicDBService.putSettingBool(GlobalStrConsts.autoBackup, value);
    emit(state.copyWith(autoBackup: value));
  }

  void setHistoryClearTime(String value) {
    BeatsMusicDBService.putSettingStr(GlobalStrConsts.historyClearTime, value);
    emit(state.copyWith(historyClearTime: value));
  }

  void setSourceEngineSwitches(int index, bool value) {
    List<bool> switches = List.from(state.sourceEngineSwitches);
    switches[index] = value;
    BeatsMusicDBService.putSettingBool(SourceEngine.values[index].value, value);
    emit(state.copyWith(sourceEngineSwitches: List.from(switches)));
  }

  Future<void> resetDownPath() async {
    String path;
    path = ((await getDownloadsDirectory()) ??
            (await getApplicationDocumentsDirectory()))
        .path;

    setDownPath(path);
    log("Download path reset to: $path", name: 'SettingsCubit');
  }

  void setShowMalayalamTrending(bool value) {
    BeatsMusicDBService.putSettingBool("showMalayalamTrending", value);
    emit(state.copyWith(showMalayalamTrending: value));
  }

  void setShowHindiTrending(bool value) {
    BeatsMusicDBService.putSettingBool("showHindiTrending", value);
    emit(state.copyWith(showHindiTrending: value));
  }

  void setShowTamilTrending(bool value) {
    BeatsMusicDBService.putSettingBool("showTamilTrending", value);
    emit(state.copyWith(showTamilTrending: value));
  }
}
