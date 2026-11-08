import 'package:beats_music/services/db/global_db.dart';
import 'package:beats_music/model/statistics/artist_statistics.dart';
import 'package:beats_music/model/statistics/play_history.dart';
import 'package:beats_music/model/statistics/song_statistics.dart';
import 'package:isar_community/isar.dart';

/// Shared by the live connection and short-lived backup worker connections.
const List<CollectionSchema<dynamic>> databaseSchemas = [
  TrackDBSchema,
  SearchHistoryDBSchema,
  PlaylistEntryDBSchema,
  LyricsDBSchema,
  PlaylistDBSchema,
  NotificationsDBSchema,
  PlaybackHistoryDBSchema,
  AppSettingsBoolDBSchema,
  AppSettingsStrDBSchema,
  DownloadDBSchema,
  CacheEntryDBSchema,
  PluginStorageEntitySchema,
  PlayHistoryDBSchema,
  SongStatisticsDBSchema,
  ArtistStatisticsDBSchema,
];
