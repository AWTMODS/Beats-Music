import 'dart:convert';
import 'dart:developer';
import 'package:beats_music/core/constants/setting_keys.dart';
import 'package:beats_music/core/constants/cache_keys.dart';
import 'package:beats_music/repository/Beats/settings_repository.dart';
import 'package:beats_music/services/player/stream_quality_selector.dart';
import 'package:beats_music/services/db/db_provider.dart';
import 'package:beats_music/utils/country_info.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _settingsRepo;

  SettingsCubit(this._settingsRepo) : super(SettingsInitial()) {
    _initSettings();
    autoUpdate();
  }

  // Initialize the settings from the database with a single consolidated state update
  Future<void> _initSettings() async {
    final autoUpdateNotifyFuture = _settingsRepo.getSettingBool(SettingKeys.autoUpdateNotify);
    final autoSlideChartsFuture = _settingsRepo.getSettingBool(SettingKeys.autoSlideCharts);
    final downPathFuture = _settingsRepo.getSettingStr(SettingKeys.downPathSetting);
    final downQualityFuture = _settingsRepo.getSettingStr(
      SettingKeys.downQuality,
      defaultValue: AudioStreamQualityPreference.medium.label,
    );
    final strmQualityFuture = _settingsRepo.getSettingStr(SettingKeys.strmQuality);
    final historyClearTimeFuture = _settingsRepo.getSettingStr(SettingKeys.historyClearTime);
    final lastFMScrobbleFuture = _settingsRepo.getSettingBool(CacheKeys.lFMScrobbleSetting);
    final autoPlayFuture = _settingsRepo.getSettingBool(SettingKeys.autoPlay);
    final autoResolveUnavailableTracksFuture = _settingsRepo.getSettingBool(SettingKeys.autoResolveUnavailableTracks);
    final lFMPicksFuture = _settingsRepo.getSettingBool(CacheKeys.lFMUIPicks);
    final backupPathFuture = _settingsRepo.getSettingStr(SettingKeys.backupPath);
    final autoBackupFuture = _settingsRepo.getSettingBool(SettingKeys.autoBackup);
    final autoGetCountryFuture = _settingsRepo.getSettingBool(SettingKeys.autoGetCountry);
    final languageCodeFuture = _settingsRepo.getSettingStr(SettingKeys.languageCode);
    final countryCodeFuture = _settingsRepo.getSettingStr(SettingKeys.countryCode);
    final autoSaveLyricsFuture = _settingsRepo.getSettingBool(SettingKeys.autoSaveLyrics);
    final chartShowMapFuture = _settingsRepo.getSettingStr(SettingKeys.chartShowMap);
    final crossfadeDurationFuture = _settingsRepo.getSettingStr(SettingKeys.crossfadeDuration);
    final eqEnabledFuture = _settingsRepo.getSettingBool(SettingKeys.eqEnabled);
    final eqBandGainsFuture = _settingsRepo.getSettingStr(SettingKeys.eqBandGains);
    final eqPresetFuture = _settingsRepo.getSettingStr(SettingKeys.eqPreset, defaultValue: 'Flat');
    final homePluginIdFuture = _settingsRepo.getSettingStr(SettingKeys.homePluginId, defaultValue: '');
    final searchPluginIdFuture = _settingsRepo.getSettingStr(SettingKeys.searchPluginId, defaultValue: '');
    final resolverPriorityFuture = _settingsRepo.getSettingStr(SettingKeys.resolverPriority, defaultValue: '[]');
    final lyricsPriorityFuture = _settingsRepo.getSettingStr(SettingKeys.lyricsPriority, defaultValue: '[]');
    final suggestionPluginIdFuture = _settingsRepo.getSettingStr(SettingKeys.suggestionPluginId, defaultValue: '');

    await Future.wait([
      autoUpdateNotifyFuture,
      autoSlideChartsFuture,
      downPathFuture,
      downQualityFuture,
      strmQualityFuture,
      historyClearTimeFuture,
      lastFMScrobbleFuture,
      autoPlayFuture,
      autoResolveUnavailableTracksFuture,
      lFMPicksFuture,
      backupPathFuture,
      autoBackupFuture,
      autoGetCountryFuture,
      languageCodeFuture,
      countryCodeFuture,
      autoSaveLyricsFuture,
      chartShowMapFuture,
      crossfadeDurationFuture,
      eqEnabledFuture,
      eqBandGainsFuture,
      eqPresetFuture,
      homePluginIdFuture,
      searchPluginIdFuture,
      resolverPriorityFuture,
      lyricsPriorityFuture,
      suggestionPluginIdFuture,
    ]);

    String resolvedDownPath;
    final rawDownPath = await downPathFuture;
    if (rawDownPath != null) {
      resolvedDownPath = rawDownPath;
    } else {
      resolvedDownPath = ((await getDownloadsDirectory()) ??
              (await getApplicationDocumentsDirectory()))
          .path;
      setDownPath(resolvedDownPath);
      log("Download path set to: $resolvedDownPath", name: 'SettingsCubit');
    }

    final rawDownQuality = await downQualityFuture;
    final normalizedDownQuality = normalizeStoredStreamQualityLabel(
      rawDownQuality,
      fallback: AudioStreamQualityPreference.medium.label,
    );
    if (rawDownQuality != normalizedDownQuality) {
      _settingsRepo.putSettingStr(SettingKeys.downQuality, normalizedDownQuality);
    }

    final rawStrmQuality = await strmQualityFuture;
    final normalizedStrmQuality = normalizeStoredStreamQualityLabel(
      rawStrmQuality,
      fallback: AudioStreamQualityPreference.high.label,
    );
    if (rawStrmQuality != normalizedStrmQuality) {
      _settingsRepo.putSettingStr(SettingKeys.strmQuality, normalizedStrmQuality);
    }

    final defaultBackUpDir = await DBProvider.getDbBackupFilePath();
    await _settingsRepo.putSettingStr(SettingKeys.backupPath, defaultBackUpDir);

    final rawCountry = await countryCodeFuture;
    final normalizedCountry = CountryInfoService.normalizeCountryCode(rawCountry);
    final resolvedCountry = normalizedCountry.isNotEmpty
        ? normalizedCountry
        : CountryInfoService.defaultCountryCode;

    final rawChartMap = await chartShowMapFuture;
    Map chartMap = Map.from(state.chartMap);
    if (rawChartMap != null) {
      try {
        chartMap = jsonDecode(rawChartMap);
      } catch (_) {}
    }

    final rawCrossfade = await crossfadeDurationFuture;
    final parsedCrossfade = int.tryParse((rawCrossfade ?? '').trim());
    final crossfadeSeconds = parsedCrossfade ?? 2;
    if (rawCrossfade != crossfadeSeconds.toString()) {
      _settingsRepo.putSettingStr(
        SettingKeys.crossfadeDuration,
        crossfadeSeconds.toString(),
      );
    }

    List<double> eqGains = state.eqBandGains;
    final rawEqGains = await eqBandGainsFuture;
    if (rawEqGains != null) {
      try {
        final decoded = jsonDecode(rawEqGains) as List;
        final gains = decoded.map((e) => (e as num).toDouble()).toList();
        if (gains.length == 10) {
          eqGains = gains;
        }
      } catch (e) {
        log('Failed to decode EQ gains: $e', name: 'SettingsCubit');
      }
    }

    List<String> resolverPriority = const [];
    final rawResolverPriority = await resolverPriorityFuture;
    if (rawResolverPriority != null && rawResolverPriority.isNotEmpty) {
      try {
        resolverPriority = (jsonDecode(rawResolverPriority) as List).cast<String>();
      } catch (e) {
        log('Failed to decode resolver priority: $e', name: 'SettingsCubit');
      }
    }

    List<String> lyricsPriority = const [];
    final rawLyricsPriority = await lyricsPriorityFuture;
    if (rawLyricsPriority != null && rawLyricsPriority.isNotEmpty) {
      try {
        lyricsPriority = (jsonDecode(rawLyricsPriority) as List).cast<String>();
      } catch (e) {
        log('Failed to decode lyrics priority: $e', name: 'SettingsCubit');
      }
    }

    emit(state.copyWith(
      autoUpdateNotify: (await autoUpdateNotifyFuture) ?? false,
      autoSlideCharts: (await autoSlideChartsFuture) ?? true,
      downPath: resolvedDownPath,
      downQuality: normalizedDownQuality,
      strmQuality: normalizedStrmQuality,
      historyClearTime: (await historyClearTimeFuture) ?? "30",
      lastFMScrobble: (await lastFMScrobbleFuture) ?? false,
      autoPlay: (await autoPlayFuture) ?? true,
      autoResolveUnavailableTracks: (await autoResolveUnavailableTracksFuture) ?? true,
      lFMPicks: (await lFMPicksFuture) ?? false,
      backupPath: defaultBackUpDir,
      autoBackup: (await autoBackupFuture) ?? false,
      autoGetCountry: (await autoGetCountryFuture) ?? true,
      languageCode: (await languageCodeFuture) ?? '',
      countryCode: resolvedCountry,
      autoSaveLyrics: (await autoSaveLyricsFuture) ?? false,
      chartMap: Map.from(chartMap),
      crossfadeDuration: crossfadeSeconds,
      eqEnabled: (await eqEnabledFuture) ?? false,
      eqBandGains: eqGains,
      eqPreset: (await eqPresetFuture) ?? 'Flat',
      homePluginId: (await homePluginIdFuture) ?? '',
      searchPluginId: (await searchPluginIdFuture) ?? '',
      resolverPriority: resolverPriority,
      lyricsPriority: lyricsPriority,
      suggestionPluginId: (await suggestionPluginIdFuture) ?? '',
      settingsReady: true,
    ));
  }

  void setChartShow(String title, bool value) {
    Map chartMap = Map.from(state.chartMap);
    chartMap[title] = value;
    _settingsRepo.putSettingStr(SettingKeys.chartShowMap, jsonEncode(chartMap));
    emit(state.copyWith(chartMap: Map.from(chartMap)));
  }

  Future<void> setAutoPlay(bool value) async {
    await _settingsRepo.putSettingBool(SettingKeys.autoPlay, value);
    emit(state.copyWith(autoPlay: value));
  }

  Future<void> setAutoResolveUnavailableTracks(bool value) async {
    await _settingsRepo.putSettingBool(
      SettingKeys.autoResolveUnavailableTracks,
      value,
    );
    emit(state.copyWith(autoResolveUnavailableTracks: value));
  }

  void autoUpdate() {
    _settingsRepo.getSettingBool(SettingKeys.autoBackup).then((value) {
      if (value == true) {
        DBProvider.createBackUp();
      }
    });
  }

  void setCountryCode(String value) {
    _settingsRepo.putSettingStr(SettingKeys.countryCode, value);
    emit(state.copyWith(countryCode: value));
  }

  void setLanguageCode(String value) {
    _settingsRepo.putSettingStr(SettingKeys.languageCode, value);
    emit(state.copyWith(languageCode: value));
  }

  void setAutoSaveLyrics(bool value) {
    _settingsRepo.putSettingBool(SettingKeys.autoSaveLyrics, value);
    emit(state.copyWith(autoSaveLyrics: value));
  }

  void setLastFMScrobble(bool value) {
    _settingsRepo.putSettingBool(CacheKeys.lFMScrobbleSetting, value);
    emit(state.copyWith(lastFMScrobble: value));
  }

  void setLastFMExpore(bool value) {
    _settingsRepo.putSettingBool(CacheKeys.lFMUIPicks, value);
    emit(state.copyWith(lFMPicks: value));
  }

  void setAutoGetCountry(bool value) {
    _settingsRepo.putSettingBool(SettingKeys.autoGetCountry, value);
    emit(state.copyWith(autoGetCountry: value));
  }

  void setAutoUpdateNotify(bool value) {
    _settingsRepo.putSettingBool(SettingKeys.autoUpdateNotify, value);
    emit(state.copyWith(autoUpdateNotify: value));
  }

  void setAutoSlideCharts(bool value) {
    _settingsRepo.putSettingBool(SettingKeys.autoSlideCharts, value);
    emit(state.copyWith(autoSlideCharts: value));
  }

  void setDownPath(String value) {
    _settingsRepo.putSettingStr(SettingKeys.downPathSetting, value);
    emit(state.copyWith(downPath: value));
  }

  void setDownQuality(String value) {
    final normalized = normalizeStoredStreamQualityLabel(
      value,
      fallback: AudioStreamQualityPreference.medium.label,
    );
    _settingsRepo.putSettingStr(SettingKeys.downQuality, normalized);
    emit(state.copyWith(downQuality: normalized));
  }

  void setStrmQuality(String value) {
    final normalized = normalizeStoredStreamQualityLabel(
      value,
      fallback: AudioStreamQualityPreference.medium.label,
    );
    _settingsRepo.putSettingStr(SettingKeys.strmQuality, normalized);
    emit(state.copyWith(strmQuality: normalized));
  }

  void setBackupPath(String value) {
    _settingsRepo.putSettingStr(SettingKeys.backupPath, value);
    emit(state.copyWith(backupPath: value));
  }

  void setAutoBackup(bool value) {
    _settingsRepo.putSettingBool(SettingKeys.autoBackup, value);
    emit(state.copyWith(autoBackup: value));
  }

  void setHistoryClearTime(String value) {
    _settingsRepo.putSettingStr(SettingKeys.historyClearTime, value);
    emit(state.copyWith(historyClearTime: value));
  }

  // ── Crossfade ────────────────────────────────────────────────────────────

  void setCrossfadeDuration(int seconds) {
    _settingsRepo.putSettingStr(
        SettingKeys.crossfadeDuration, seconds.toString());
    emit(state.copyWith(crossfadeDuration: seconds));
  }

  // ── Equalizer persistence ───────────────────────────────────────────────

  void setEqEnabled(bool value) {
    _settingsRepo.putSettingBool(SettingKeys.eqEnabled, value);
    emit(state.copyWith(eqEnabled: value));
  }

  void setEqBandGains(List<double> gains) {
    _settingsRepo.putSettingStr(SettingKeys.eqBandGains, jsonEncode(gains));
    emit(state.copyWith(eqBandGains: gains));
  }

  void setEqPreset(String preset) {
    _settingsRepo.putSettingStr(SettingKeys.eqPreset, preset);
    emit(state.copyWith(eqPreset: preset));
  }

  void setHomePluginId(String pluginId) {
    _settingsRepo.putSettingStr(SettingKeys.homePluginId, pluginId);
    emit(state.copyWith(homePluginId: pluginId));
  }

  void setSearchPluginId(String pluginId) {
    _settingsRepo.putSettingStr(SettingKeys.searchPluginId, pluginId);
    emit(state.copyWith(searchPluginId: pluginId));
  }

  void setResolverPriority(List<String> priority) {
    _settingsRepo.putSettingStr(
        SettingKeys.resolverPriority, jsonEncode(priority));
    emit(state.copyWith(resolverPriority: priority));
  }

  void setLyricsPriority(List<String> priority) {
    _settingsRepo.putSettingStr(
        SettingKeys.lyricsPriority, jsonEncode(priority));
    emit(state.copyWith(lyricsPriority: priority));
  }

  void setSuggestionPluginId(String pluginId) {
    _settingsRepo.putSettingStr(SettingKeys.suggestionPluginId, pluginId);
    emit(state.copyWith(suggestionPluginId: pluginId));
  }

  Future<void> resetDownPath() async {
    String path;
    path = ((await getDownloadsDirectory()) ??
            (await getApplicationDocumentsDirectory()))
        .path;

    setDownPath(path);
    log("Download path reset to: $path", name: 'SettingsCubit');
  }

  /// Generic setting write — for one-off setting updates from UI.
  Future<void> putSettingStr(String key, String value) async {
    await _settingsRepo.putSettingStr(key, value);
  }
}


