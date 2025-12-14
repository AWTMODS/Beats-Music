import 'package:isar_community/isar.dart';

part 'artist_statistics.g.dart';

/// Aggregated statistics for artists
@collection
class ArtistStatisticsDB {
  Id id = Isar.autoIncrement;
  
  /// Artist name
  @Index(unique: true)
  String artistName;
  
  /// Total number of plays across all songs
  @Index()
  int playCount;
  
  /// Total listening time in seconds
  int totalListeningTime;
  
  /// List of top song IDs by this artist
  List<String> topSongIds;
  
  /// Last time any song by this artist was played
  @Index()
  DateTime lastPlayed;
  
  /// First time any song by this artist was played
  DateTime firstPlayed;
  
  /// Primary genre associated with this artist
  String? primaryGenre;
  
  ArtistStatisticsDB({
    required this.artistName,
    this.playCount = 0,
    this.totalListeningTime = 0,
    this.topSongIds = const [],
    required this.lastPlayed,
    required this.firstPlayed,
    this.primaryGenre,
  });
}
