import 'package:isar_community/isar.dart';

part 'song_statistics.g.dart';

/// Aggregated statistics for individual songs
@collection
class SongStatisticsDB {
  Id id = Isar.autoIncrement;
  
  /// Unique song identifier (permaURL)
  @Index(unique: true)
  String songId;
  
  /// Song title
  String songTitle;
  
  /// Artist name
  String artist;
  
  /// Genre (if available)
  String? genre;
  
  /// Total number of plays
  @Index()
  int playCount;
  
  /// Total listening time in seconds
  int totalListeningTime;
  
  /// Last time this song was played
  @Index()
  DateTime lastPlayed;
  
  /// First time this song was played
  DateTime firstPlayed;
  
  /// Average listening percentage (0-100)
  double avgListeningPercentage;

  /// Album art URL
  String? thumbnailUrl;

  SongStatisticsDB({
    required this.songId,
    required this.songTitle,
    required this.artist,
    this.genre,
    this.playCount = 0,
    this.totalListeningTime = 0,
    required this.lastPlayed,
    required this.firstPlayed,
    this.avgListeningPercentage = 0.0,
    this.thumbnailUrl,
  });
}
