import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:beats_music/services/listening_statistics_service.dart';
import 'package:beats_music/services/db/beats_music_db_service.dart';
import 'package:beats_music/services/debug_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';

class CloudSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ListeningStatisticsService _statsService = ListeningStatisticsService();

  // Singleton pattern
  static final CloudSyncService _instance = CloudSyncService._internal();
  factory CloudSyncService() => _instance;
  CloudSyncService._internal();

  /// Uploads local statistics to Firestore (Backup)
  /// Overwrites cloud data with current local data.
  Future<void> uploadStats() async {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint("CloudSync: No user logged in. Skipping upload.");
      return;
    }

    try {
      debugPrint("CloudSync: Starting upload for user ${user.uid}...");
      
      // 1. Get Local Data
      final topArtists = await _statsService.getTopArtists();
      final topSongs = await _statsService.getTopSongs();
      final topGenres = await _statsService.getTopGenres(); // Need to implement this getter if missing, or derive
      final totalStats = await _statsService.getTotalListeningStats();

      // 2. Prepare JSON Payload
      String deviceName = 'Unknown Device';
      try {
        final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        if (defaultTargetPlatform == TargetPlatform.android) {
          final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
          deviceName = '${androidInfo.brand} ${androidInfo.model}';
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
          deviceName = iosInfo.utsname.machine;
        } else if (defaultTargetPlatform == TargetPlatform.windows) {
          final WindowsDeviceInfo windowsInfo = await deviceInfo.windowsInfo;
          deviceName = windowsInfo.computerName;
        }
      } catch (e) {
        debugPrint('CloudSync: Failed to get device info: $e');
      }

      final Map<String, dynamic> statsData = {
        'lastUpdated': FieldValue.serverTimestamp(),
        'totalListeningSeconds': totalStats['totalSeconds'] ?? 0,
        'totalSongsPlayed': totalStats['totalSongs'] ?? 0,
        'deviceName': deviceName,
        
        // Serialize Lists (Limit to top 50 to avoid doc size limits if huge, though 50 is small)
        'topArtists': topArtists.take(100).map((a) => {
          'artistName': a.artistName,
          'playCount': a.playCount,
          'totalListeningTime': a.totalListeningTime,
        }).toList(),
        
        'topSongs': topSongs.take(100).map((s) => {
          'songId': s.songId,
          'title': s.songTitle,
          'artist': s.artist,
          'playCount': s.playCount,
          'totalListeningTime': s.totalListeningTime,
        }).toList(),
      };

      // 3. Write to Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('data')
          .doc('statistics')
          .set(statsData);
          
      debugPrint("CloudSync: Upload successful.");
      
    } catch (e) {
      debugPrint("CloudSync: Upload failed - $e");
      rethrow;
    }
  }

  /// Downloads statistics from Firestore and updates local DB (Restore)
  /// Merges or Overwrites local data? 
  /// For this implementation: OVERWRITES local counts with Cloud > Local, 
  /// or simply adds them if we treat them as separate sessions?
  /// SAFE APPROACH: "Restore" implies bringing back lost data. 
  /// We will attempt to merge: values = max(local, cloud).
  Future<void> downloadStats() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      debugPrint("CloudSync: Starting download...");
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('data')
          .doc('statistics')
          .get();

      if (!doc.exists || doc.data() == null) {
        debugPrint("CloudSync: No cloud data found.");
        return;
      }

      final data = doc.data()!;
      
      // Restoration Logic
      // This is tricky without exposing specific 'set' methods in ListeningStatisticsService.
      // We might need to add a method in ListeningStatisticsService to "Import" stats.
      
      // For now, let's just log what we found.
      // To implement this, I need to add 'importStatistics' to ListeningStatisticsService.
      debugPrint("CloudSync: Downloaded data. Parsing...");
      
      List<dynamic> artists = data['topArtists'] ?? [];
      List<dynamic> songs = data['topSongs'] ?? [];
      
      await _statsService.importStatistics(artists: artists, songs: songs);
      
      debugPrint("CloudSync: Download complete (Data Restored/Merged).");

    } catch (e) {
      debugPrint("CloudSync: Download failed - $e");
    }
  }

  /// Uploads user playlists to Firestore (Backup)
  /// Overwrites cloud playlist data with current local data.
  Future<void> uploadPlaylists() async {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint("CloudSync: No user logged in. Skipping playlist upload.");
      return;
    }

    try {
      debugPrint("CloudSync: Starting playlist upload for user ${user.uid}...");
      
      // Get playlists from DB
      final playlistsData = await BeatsMusicDBService.exportUserPlaylists();
      
      if (playlistsData.isEmpty) {
        debugPrint("CloudSync: No user playlists to upload.");
        return;
      }

      // Write to Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('data')
          .doc('playlists')
          .set({
            'lastUpdated': FieldValue.serverTimestamp(),
            'playlists': playlistsData,
          });
          
      debugPrint("CloudSync: Uploaded ${playlistsData.length} playlists successfully.");
      
    } catch (e) {
      debugPrint("CloudSync: Playlist upload failed - $e");
      rethrow;
    }
  }

  /// Downloads playlists from Firestore and updates local DB (Restore)
  Future<void> downloadPlaylists() async {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint("CloudSync: ❌ No user logged in for playlist download");
      return;
    }

    try {
      var msg = "CloudSync: 🔽 Starting playlist download for user ${user.uid}...";
      debugPrint(msg);
      DebugLogger().log(msg);
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('data')
          .doc('playlists')
          .get();

      if (!doc.exists || doc.data() == null) {
        final msg = "CloudSync: ⚠️ No cloud playlists found (document doesn't exist)";
        debugPrint(msg);
        DebugLogger().log(msg);
        return;
      }

      final data = doc.data()!;
      msg = "CloudSync: 📄 Received document with keys: ${data.keys.toList()}";
      debugPrint(msg);
      DebugLogger().log(msg);
      
      final playlists = data['playlists'] as List<dynamic>? ?? [];
      msg = "CloudSync: 📦 Found ${playlists.length} playlists in Firebase";
      debugPrint(msg);
      DebugLogger().log(msg);
      
      if (playlists.isEmpty) {
        msg = "CloudSync: ⚠️ Playlists array is empty";
        debugPrint(msg);
        DebugLogger().log(msg);
        return;
      }

      // Convert to proper type
      final playlistsData = playlists.cast<Map<String, dynamic>>();
      
      // Log each playlist
      for (var i = 0; i < playlistsData.length; i++) {
        final pl = playlistsData[i];
        final name = pl['playlistName'] ?? 'Unknown';
        final songs = pl['songs'] as List<dynamic>? ?? [];
        msg = "CloudSync:   [$i] $name (${songs.length} songs)";
        debugPrint(msg);
        DebugLogger().log(msg);
      }
      
      msg = "CloudSync: 💾 Calling BeatsMusicDBService.importPlaylists()...";
      debugPrint(msg);
      DebugLogger().log(msg);
      await BeatsMusicDBService.importPlaylists(playlistsData);
      
      msg = "CloudSync: ✅ Downloaded ${playlistsData.length} playlists successfully.";
      debugPrint(msg);
      DebugLogger().log(msg);

    } catch (e, stackTrace) {
      var msg = "CloudSync: ❌ Playlist download failed - $e";
      debugPrint(msg);
      DebugLogger().log(msg);
      DebugLogger().log("CloudSync: Stack trace: $stackTrace");
      debugPrint("CloudSync: Stack trace: $stackTrace");
    }
  }

  /// Upload Liked Songs to Firestore
  Future<void> uploadLikedSongs() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      debugPrint("CloudSync: Uploading liked songs...");
      final likedSongs = await BeatsMusicDBService.exportLikedSongs();
      
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('data')
          .doc('liked_songs')
          .set({
            'lastUpdated': FieldValue.serverTimestamp(),
            'songs': likedSongs,
          });
          
      debugPrint("CloudSync: Uploaded ${likedSongs.length} liked songs.");
    } catch (e) {
      debugPrint("CloudSync: Liked songs upload failed - $e");
    }
  }

  /// Download Liked Songs from Firestore
  Future<void> downloadLikedSongs() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      debugPrint("CloudSync: Downloading liked songs...");
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('data')
          .doc('liked_songs')
          .get();

      if (doc.exists && doc.data() != null) {
        final songs = (doc.data()!['songs'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
        await BeatsMusicDBService.importLikedSongs(songs);
        debugPrint("CloudSync: Downloaded ${songs.length} liked songs.");
      }
    } catch (e) {
      debugPrint("CloudSync: Liked songs download failed - $e");
    }
  }

  /// Upload Recently Played to Firestore
  Future<void> uploadRecentlyPlayed() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      debugPrint("CloudSync: Uploading recently played...");
      final recentlyPlayed = await BeatsMusicDBService.exportRecentlyPlayed();
      
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('data')
          .doc('recently_played')
          .set({
            'lastUpdated': FieldValue.serverTimestamp(),
            'tracks': recentlyPlayed,
          });
          
      debugPrint("CloudSync: Uploaded ${recentlyPlayed.length} recently played tracks.");
    } catch (e) {
      debugPrint("CloudSync: Recently played upload failed - $e");
    }
  }

  /// Download Recently Played from Firestore
  Future<void> downloadRecentlyPlayed() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      debugPrint("CloudSync: Downloading recently played...");
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('data')
          .doc('recently_played')
          .get();

      if (doc.exists && doc.data() != null) {
        final tracks = (doc.data()!['tracks'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
        await BeatsMusicDBService.importRecentlyPlayed(tracks);
        debugPrint("CloudSync: Downloaded ${tracks.length} recently played tracks.");
      }
    } catch (e) {
      debugPrint("CloudSync: Recently played download failed - $e");
    }
  }

  /// Upload Downloads list to Firestore (metadata only)
  Future<void> uploadDownloadsList() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      debugPrint("CloudSync: Uploading downloads list...");
      final downloads = await BeatsMusicDBService.exportDownloadsList();
      
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('data')
          .doc('downloads')
          .set({
            'lastUpdated': FieldValue.serverTimestamp(),
            'downloads': downloads,
          });
          
      debugPrint("CloudSync: Uploaded ${downloads.length} download entries.");
    } catch (e) {
      debugPrint("CloudSync: Downloads upload failed - $e");
    }
  }

  /// Download Downloads list from Firestore (metadata only)
  Future<void> downloadDownloadsList() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      debugPrint("CloudSync: Downloading downloads list...");
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('data')
          .doc('downloads')
          .get();

      if (doc.exists && doc.data() != null) {
        final downloads = (doc.data()!['downloads'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
        await BeatsMusicDBService.importDownloadsList(downloads);
        debugPrint("CloudSync: Downloaded ${downloads.length} download entries.");
      }
    } catch (e) {
      debugPrint("CloudSync: Downloads download failed - $e");
    }
  }
}
