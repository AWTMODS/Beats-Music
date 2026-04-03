import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:beats_music/services/db/sync_adapter.dart';
import 'package:beats_music/services/listening_statistics_service.dart';

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
        
        // Serialize Lists (Limit to top 100)
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
  Future<void> uploadPlaylists() async {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint("CloudSync: No user logged in. Skipping playlist upload.");
      return;
    }

    try {
      debugPrint("CloudSync: Starting playlist upload for user ${user.uid}...");
      
      // Get playlists from DB via SyncAdapter
      final playlistsData = await SyncAdapter.exportUserPlaylists();
      
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
    if (user == null) return;

    try {
      debugPrint("CloudSync: Starting playlist download for user ${user.uid}...");

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('data')
          .doc('playlists')
          .get();

      if (!doc.exists || doc.data() == null) {
        debugPrint("CloudSync: No cloud playlists found.");
        return;
      }

      final data = doc.data()!;
      final playlists = data['playlists'] as List<dynamic>? ?? [];
      
      if (playlists.isEmpty) return;

      // Convert and import via SyncAdapter
      final playlistsData = playlists.cast<Map<String, dynamic>>();
      await SyncAdapter.importPlaylists(playlistsData);
      
      debugPrint("CloudSync: Downloaded ${playlistsData.length} playlists successfully.");

    } catch (e, stackTrace) {
      debugPrint("CloudSync: Playlist download failed - $e");
      debugPrint("StackTrace: $stackTrace");
    }
  }

  /// Upload Liked Songs to Firestore
  Future<void> uploadLikedSongs() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      debugPrint("CloudSync: Uploading liked songs...");
      final likedSongs = await SyncAdapter.exportLikedSongs();
      
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
        await SyncAdapter.importLikedSongs(songs);
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
      final recentlyPlayed = await SyncAdapter.exportRecentlyPlayed();
      
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
        await SyncAdapter.importRecentlyPlayed(tracks);
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
      final downloads = await SyncAdapter.exportDownloadsList();
      
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
        await SyncAdapter.importDownloadsList(downloads);
        debugPrint("CloudSync: Downloaded ${downloads.length} download entries.");
      }
    } catch (e) {
      debugPrint("CloudSync: Downloads download failed - $e");
    }
  }

  /// Save users preference languages and artists
  Future<void> saveUserPreferences({
    required List<String> languages,
    required List<String> artists,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('data')
          .doc('preferences')
          .set({
        'lastUpdated': FieldValue.serverTimestamp(),
        'languages': languages,
        'artists': artists,
      });
      debugPrint("CloudSync: Saved user preferences.");
    } catch (e) {
      debugPrint("CloudSync: Preferences save failed - $e");
    }
  }

  /// Get users preference languages and artists
  Future<Map<String, List<String>>> getUserPreferences() async {
    final user = _auth.currentUser;
    if (user == null) return {'languages': [], 'artists': []};

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('data')
          .doc('preferences')
          .get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return {
          'languages':
              (data['languages'] as List<dynamic>?)?.cast<String>() ?? [],
          'artists': (data['artists'] as List<dynamic>?)?.cast<String>() ?? [],
        };
      }
    } catch (e) {
      debugPrint("CloudSync: Preferences download failed - $e");
    }
    return {'languages': [], 'artists': []};
  }

  /// Saves a "Wrapped" snapshot for a specific month (e.g., "2026-04")
  Future<void> saveWrappedSnapshot({
    required String monthId,
    required Map<String, dynamic> stats,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('wrapped_history')
          .doc(monthId)
          .set({
        'month': monthId,
        'stats': stats,
        'timestamp': FieldValue.serverTimestamp(),
      });
      debugPrint("CloudSync: Saved Wrapped snapshot for $monthId");
    } catch (e) {
      debugPrint("CloudSync: Wrapped save failed - $e");
    }
  }

  /// Retrieves all historical Wrapped snapshots
  Future<List<Map<String, dynamic>>> getWrappedHistory() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final query = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('wrapped_history')
          .orderBy('timestamp', descending: true)
          .get();

      return query.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint("CloudSync: Wrapped history download failed - $e");
      return [];
    }
  }
}
