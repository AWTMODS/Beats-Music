import 'package:isar_community/isar.dart';

part 'play_history.g.dart';

/// Tracks individual play events for statistics
@collection
class PlayHistoryDB {
  Id id = Isar.autoIncrement;
  
  /// Unique song identifier (permaURL)
  @Index()
  String songId;
  
  /// Song title
  String songTitle;
  
  /// Artist name
  String artist;
  
  /// Genre (if available)
  String? genre;
  
  /// When the song was played
  @Index()
  DateTime playedAt;
  
  /// Duration listened in seconds
  int durationListened;
  
  /// Whether the song was completed (>80% listened)
  bool wasCompleted;
  
  PlayHistoryDB({
    required this.songId,
    required this.songTitle,
    required this.artist,
    this.genre,
    required this.playedAt,
    required this.durationListened,
    this.wasCompleted = false,
  });
}
