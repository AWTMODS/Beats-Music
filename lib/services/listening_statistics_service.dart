import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:beats_music/model/statistics/play_history.dart';
import 'package:beats_music/model/statistics/song_statistics.dart';
import 'package:beats_music/model/statistics/artist_statistics.dart';
import 'package:beats_music/services/db/db_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

/// Service to track and analyze listening statistics
class ListeningStatisticsService {
  // Singleton pattern
  static final ListeningStatisticsService _instance = ListeningStatisticsService._internal();
  factory ListeningStatisticsService() => _instance;
  ListeningStatisticsService._internal();
  
  DateTime? _currentSongStartTime;
  MediaItem? _currentMediaItem;
  
  /// Record a play event when a song completes or is skipped (after threshold)
  Future<void> recordPlay({
    required MediaItem mediaItem,
    required int durationListened, // seconds
    required bool wasCompleted,
  }) async {
    try {
      final isar = await DBProvider.db;
      final now = DateTime.now();
      
      // Extract metadata
      final songId = mediaItem.id;
      final songTitle = mediaItem.title;
      final artist = mediaItem.artist ?? 'Unknown Artist';
      final genre = mediaItem.genre;
      
      await isar.writeTxn(() async {
        // 1. Record play history
        await isar.collection<PlayHistoryDB>().put(PlayHistoryDB(
          songId: songId,
          songTitle: songTitle,
          artist: artist,
          genre: genre,
          playedAt: now,
          durationListened: durationListened,
          wasCompleted: wasCompleted,
        ));
        
        // 2. Update song statistics
        await _updateSongStatistics(
          isar,
          songId: songId,
          songTitle: songTitle,
          artist: artist,
          genre: genre,
          durationListened: durationListened,
          wasCompleted: wasCompleted,
          playedAt: now,
        );
        
        // 3. Update artist statistics
        await _updateArtistStatistics(
          isar,
          artist: artist,
          songId: songId,
          genre: genre,
          durationListened: durationListened,
          playedAt: now,
        );
      });
      
      debugPrint('Statistics: Recorded play for "$songTitle" by $artist');
    } catch (e) {
      debugPrint('Error recording play statistics: $e');
    }
  }
  
  /// Update song statistics
  Future<void> _updateSongStatistics(
    Isar isar, {
    required String songId,
    required String songTitle,
    required String artist,
    String? genre,
    required int durationListened,
    required bool wasCompleted,
    required DateTime playedAt,
  }) async {
    // Find existing statistics
    SongStatisticsDB? stats = await isar.collection<SongStatisticsDB>()
        .where()
        .songIdEqualTo(songId)
        .findFirst();
    
    if (stats == null) {
      // Create new statistics
      stats = SongStatisticsDB(
        songId: songId,
        songTitle: songTitle,
        artist: artist,
        genre: genre,
        playCount: 1,
        totalListeningTime: durationListened,
        lastPlayed: playedAt,
        firstPlayed: playedAt,
        avgListeningPercentage: wasCompleted ? 100.0 : 0.0,
      );
    } else {
      // Update existing statistics
      stats.playCount++;
      stats.totalListeningTime += durationListened;
      stats.lastPlayed = playedAt;
      
      // Update average listening percentage
      final totalPlays = stats.playCount;
      final currentAvg = stats.avgListeningPercentage;
      final newPercentage = wasCompleted ? 100.0 : 50.0; // Estimate 50% if not completed
      stats.avgListeningPercentage = ((currentAvg * (totalPlays - 1)) + newPercentage) / totalPlays;
    }
    
    await isar.collection<SongStatisticsDB>().put(stats);
  }
  
  /// Update artist statistics
  Future<void> _updateArtistStatistics(
    Isar isar, {
    required String artist,
    required String songId,
    String? genre,
    required int durationListened,
    required DateTime playedAt,
  }) async {
    // Find existing statistics
    ArtistStatisticsDB? stats = await isar.collection<ArtistStatisticsDB>()
        .where()
        .artistNameEqualTo(artist)
        .findFirst();
    
    if (stats == null) {
      // Create new statistics
      stats = ArtistStatisticsDB(
        artistName: artist,
        playCount: 1,
        totalListeningTime: durationListened,
        topSongIds: [songId],
        lastPlayed: playedAt,
        firstPlayed: playedAt,
        primaryGenre: genre,
      );
    } else {
      // Update existing statistics
      stats.playCount++;
      stats.totalListeningTime += durationListened;
      stats.lastPlayed = playedAt;
      
      // Update top songs list (keep top 10)
      if (!stats.topSongIds.contains(songId)) {
        final updatedList = List<String>.from(stats.topSongIds);
        updatedList.add(songId);
        if (updatedList.length > 10) {
          updatedList.removeAt(0);
        }
        stats.topSongIds = updatedList;
      }
      
      // Update genre if not set
      if (stats.primaryGenre == null && genre != null) {
        stats.primaryGenre = genre;
      }
    }
    
    await isar.collection<ArtistStatisticsDB>().put(stats);
  }
  
  /// Get top songs (most played)
  Future<List<SongStatisticsDB>> getTopSongs({int limit = 50}) async {
    final isar = await DBProvider.db;
    return await isar.collection<SongStatisticsDB>()
        .where()
        .sortByPlayCountDesc()
        .limit(limit)
        .findAll();
  }
  
  /// Get top artists (most played)
  Future<List<ArtistStatisticsDB>> getTopArtists({int limit = 20}) async {
    final isar = await DBProvider.db;
    return await isar.collection<ArtistStatisticsDB>()
        .where()
        .sortByPlayCountDesc()
        .limit(limit)
        .findAll();
  }
  
  /// Get recently played songs (from history)
  Future<List<PlayHistoryDB>> getRecentlyPlayed({int limit = 50}) async {
    final isar = await DBProvider.db;
    return await isar.collection<PlayHistoryDB>()
        .where()
        .sortByPlayedAtDesc()
        .limit(limit)
        .findAll();
  }
  
  /// Get total listening time (in seconds)
  Future<int> getTotalListeningTime() async {
    final isar = await DBProvider.db;
    final allStats = await isar.collection<SongStatisticsDB>().where().findAll();
    return allStats.fold<int>(0, (sum, stat) => sum + stat.totalListeningTime);
  }
  
  /// Get top genres based on listening time
  Future<Map<String, int>> getTopGenres({int limit = 10}) async {
    final isar = await DBProvider.db;
    final allStats = await isar.collection<SongStatisticsDB>().where().findAll();
    
    final genreMap = <String, int>{};
    for (var stat in allStats) {
      if (stat.genre != null && stat.genre!.isNotEmpty) {
        genreMap[stat.genre!] = (genreMap[stat.genre!] ?? 0) + stat.totalListeningTime;
      }
    }
    
    // Sort by listening time and return top genres
    final sortedGenres = genreMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Map.fromEntries(sortedGenres.take(limit));
  }
  
  /// Track song start (call when song starts playing)
  void trackSongStart(MediaItem mediaItem) {
    _currentMediaItem = mediaItem;
    _currentSongStartTime = DateTime.now();
  }
  
  /// Track song end (call when song ends/skips)
  /// Track song end (call when song ends/skips)
  Future<void> trackSongEnd({bool wasCompleted = false, int? durationOverride}) async {
    if (_currentMediaItem == null || _currentSongStartTime == null) {
      debugPrint('Statistics: Cannot track end - no current song or start time');
      return;
    }
    
    // CRITICAL FIX: Use durationOverride (player position) if available.
    // Wall-clock time (difference) counts PAUSED time as listening time, leading to huge stats (e.g. 3.7 hrs for 10 songs).
    // durationOverride comes from audioPlayer.position, which only advances when playing.
    int durationListened;
    
    if (durationOverride != null) {
      durationListened = durationOverride;
    } else {
      // Fallback only if strictly necessary (e.g. natural complete without override)
      // But for 'wasCompleted', we should arguably use the song's total duration or just trust the wall clock if no pause?
      // Better to trust override if passed.
      durationListened = DateTime.now().difference(_currentSongStartTime!).inSeconds;
    }
    
    // Sanitize Artist Name (remove "• 12M views", "• 4:32" etc)
    String artistName = _currentMediaItem!.artist ?? 'Unknown Artist';
    if (artistName.contains('•')) {
       // Simple heuristic: "Arijit Singh • 156M views" -> "Arijit Singh"
       // But "Dec 19 • Vishal" -> "Dec 19". Use last part if first looks like date? 
       // For now, let's just strip known garbage suffixes or split.
       // Taking the longest part might be safer? Or just splitting.
       // Let's split and filter out parts with "views", "mins", digits-only.
       final parts = artistName.split('•');
       // Strategy: Find the part that looks most like a name (no numbers preferred?)
       // Fallback: take first. 
       // For "Dec 19... • Vishal", the second part is name.
       // Let's just take the part that DOESN'T have digits if possible.
       final cleanPart = parts.firstWhere(
         (p) => !p.contains(RegExp(r'\d')), 
         orElse: () => parts.first
       );
       artistName = cleanPart.trim();
    }
    
    debugPrint('Statistics: Track end for "$artistName" (raw: ${_currentMediaItem!.artist}). Duration: ${durationListened}s. Completed: $wasCompleted');
    
    // Create new temporary item with cleaned artist for recording
    final cleanMediaItem = _currentMediaItem!.copyWith(artist: artistName);
    
    // Only record if listened for at least 30 seconds
    if (durationListened >= 30) {
      await recordPlay(
        mediaItem: cleanMediaItem,
        durationListened: durationListened,
        wasCompleted: wasCompleted,
      );
    } else {
      debugPrint('Statistics: Ignored play (less than 30s)');
    }
    
    // Reset tracking
    _currentMediaItem = null;
    _currentSongStartTime = null;
  }
  
  /// Get statistics for a specific song
  Future<SongStatisticsDB?> getSongStatistics(String songId) async {
    final isar = await DBProvider.db;
    return await isar.collection<SongStatisticsDB>()
        .where()
        .songIdEqualTo(songId)
        .findFirst();
  }
  
  /// Get statistics for a specific artist
  Future<ArtistStatisticsDB?> getArtistStatistics(String artistName) async {
    final isar = await DBProvider.db;
    return await isar.collection<ArtistStatisticsDB>()
        .where()
        .artistNameEqualTo(artistName)
        .findFirst();
  }
  
  /// Get total listening stats (time and song count)
  Future<Map<String, dynamic>> getTotalListeningStats() async {
    final isar = await DBProvider.db;
    final totalSeconds = await getTotalListeningTime();
    final allSongs = await isar.collection<SongStatisticsDB>().where().findAll();
    final totalSongs = allSongs.fold<int>(0, (sum, stat) => sum + stat.playCount);
    
    return {
      'totalSeconds': totalSeconds,
      'totalSongs': totalSongs,
    };
  }

  /// Import statistics from Cloud (Merges data, taking the higher value)
  Future<void> importStatistics({
    required List<dynamic> artists,
    required List<dynamic> songs,
  }) async {
    final isar = await DBProvider.db;
    await isar.writeTxn(() async {
      debugPrint('Statistics: Importing ${artists.length} artists and ${songs.length} songs from cloud...');
      
      // 1. Import Artists
      for (var artistData in artists) {
         final name = artistData['artistName'];
         if (name == null) continue;
         
         ArtistStatisticsDB? stats = await isar.collection<ArtistStatisticsDB>()
             .where()
             .artistNameEqualTo(name)
             .findFirst();
             
         final cloudPlayCount = (artistData['playCount'] as num?)?.toInt() ?? 0;
         final cloudListeningTime = (artistData['totalListeningTime'] as num?)?.toInt() ?? 0;

         if (stats == null) {
            stats = ArtistStatisticsDB(
                artistName: name,
                playCount: cloudPlayCount,
                totalListeningTime: cloudListeningTime,
                topSongIds: [], // Cannot easily reconstruct
                lastPlayed: DateTime.now(), // Fallback
                firstPlayed: DateTime.now(),
            );
         } else {
            // Merge: If cloud has more data, update local. 
            // Ideally we sum, but that risks double counting if we synced back and forth.
            // "High Water Mark" strategy: Take the larger value.
            // This prevents data loss but might undercount concurrent listening on multiple devices.
            // A non-delta sync architecture necessitates this trade-off to avoid infinite growth on re-syncs.
            if (cloudPlayCount > stats.playCount) {
                stats.playCount = cloudPlayCount;
                stats.totalListeningTime = cloudListeningTime;
            }
         }
         await isar.collection<ArtistStatisticsDB>().put(stats);
      }
      
      // 2. Import Songs
      for (var songData in songs) {
         final id = songData['songId'];
         if (id == null) continue;
         
         SongStatisticsDB? stats = await isar.collection<SongStatisticsDB>()
             .where()
             .songIdEqualTo(id)
             .findFirst();

         final cloudPlayCount = (songData['playCount'] as num?)?.toInt() ?? 0;
         final cloudListeningTime = (songData['totalListeningTime'] as num?)?.toInt() ?? 0;

         if (stats == null) {
             stats = SongStatisticsDB(
                songId: id,
                songTitle: songData['title'] ?? 'Unknown',
                artist: songData['artist'] ?? 'Unknown',
                playCount: cloudPlayCount,
                totalListeningTime: cloudListeningTime,
                lastPlayed: DateTime.now(),
                firstPlayed: DateTime.now(),
                avgListeningPercentage: 100.0,
             );
         } else {
             if (cloudPlayCount > stats.playCount) {
                 stats.playCount = cloudPlayCount;
                 stats.totalListeningTime = cloudListeningTime;
             }
         }
         await isar.collection<SongStatisticsDB>().put(stats);
      }
      debugPrint('Statistics: Import complete.');
    });
  }

  /// Clear all statistics (for testing or reset)
  Future<void> clearAllStatistics() async {
    final isar = await DBProvider.db;
    await isar.writeTxn(() async {
      await isar.collection<PlayHistoryDB>().clear();
      await isar.collection<SongStatisticsDB>().clear();
      await isar.collection<ArtistStatisticsDB>().clear();
    });
    debugPrint('Statistics: All statistics cleared');
  }
}
