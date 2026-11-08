import 'dart:async';
import 'package:beats_music/services/cloud_sync_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for automatic real-time cloud synchronization
/// Monitors playlist changes and syncs to cloud automatically
class AutoSyncService {
  static final AutoSyncService _instance = AutoSyncService._internal();
  factory AutoSyncService() => _instance;
  AutoSyncService._internal();

  static const String _autoSyncEnabledKey = 'auto_sync_enabled';
  static const String _lastSyncTimeKey = 'last_auto_sync_time';
  
  final CloudSyncService _cloudSync = CloudSyncService();
  FirebaseAuth get _auth => FirebaseAuth.instance;

  User? get _currentUser {
    try {
      if (Firebase.apps.isNotEmpty) return _auth.currentUser;
    } catch (_) {}
    return null;
  }
  
  Timer? _syncTimer;
  bool _isSyncing = false;
  
  /// Check if auto-sync is enabled
  Future<bool> isAutoSyncEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoSyncEnabledKey) ?? true; // Default: enabled
  }
  
  /// Enable or disable auto-sync
  Future<void> setAutoSyncEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoSyncEnabledKey, enabled);
    
    if (enabled) {
      startAutoSync();
    } else {
      stopAutoSync();
    }
    
    debugPrint('AutoSync: ${enabled ? "Enabled" : "Disabled"}');
  }
  
  /// Start automatic sync timer (runs every 5 minutes)
  void startAutoSync() {
    final user = _currentUser;
    if (user == null || user.isAnonymous) {
      debugPrint('AutoSync: Skipped (not logged in or guest mode)');
      return;
    }
    
    // Trigger an initial sync immediately on startup / login
    unawaited(() async {
      final enabled = await isAutoSyncEnabled();
      if (enabled) {
        await _performSync();
      }
    }());

    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      final enabled = await isAutoSyncEnabled();
      if (enabled) {
        await _performSync();
      }
    });
    
    debugPrint('AutoSync: Started (syncs every 5 minutes)');
  }
  
  /// Stop automatic sync
  void stopAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
    debugPrint('AutoSync: Stopped');
  }
  
  /// Manually trigger sync (called when playlist is created/modified or pulled to refresh)
  Future<void> syncNow() async {
    final enabled = await isAutoSyncEnabled();
    if (!enabled) {
      debugPrint('AutoSync: Sync skipped (disabled in settings)');
      return;
    }
    
    final user = _currentUser;
    if (user == null || user.isAnonymous) {
      debugPrint('AutoSync: Sync skipped (not logged in)');
      return;
    }
    
    await _performSync();
  }
  
  /// Internal sync method
  Future<void> _performSync() async {
    if (_isSyncing) {
      debugPrint('AutoSync: Sync already in progress, skipping');
      return;
    }
    
    _isSyncing = true;
    
    try {
      debugPrint('AutoSync: Starting background sync...');
      final startTime = DateTime.now();
      
      // 1. Download all data types (Sync Down / Restore) FIRST!
      // Must be executed sequentially to prevent Isar write transaction collisions:
      // "IsarError: An async write transaction is already in progress in this isolate."
      try {
        await _cloudSync.downloadPlaylists();
      } catch (e) {
        debugPrint('AutoSync: downloadPlaylists error: $e');
      }
      try {
        await _cloudSync.downloadLikedSongs();
      } catch (e) {
        debugPrint('AutoSync: downloadLikedSongs error: $e');
      }
      try {
        await _cloudSync.downloadRecentlyPlayed();
      } catch (e) {
        debugPrint('AutoSync: downloadRecentlyPlayed error: $e');
      }
      try {
        await _cloudSync.downloadDownloadsList();
      } catch (e) {
        debugPrint('AutoSync: downloadDownloadsList error: $e');
      }
      try {
        await _cloudSync.downloadStats();
      } catch (e) {
        debugPrint('AutoSync: downloadStats error: $e');
      }

      // 2. Upload all data types (Sync Up / Backup) after local DB has merged cloud data
      try {
        await _cloudSync.uploadPlaylists();
      } catch (e) {
        debugPrint('AutoSync: uploadPlaylists error: $e');
      }
      try {
        await _cloudSync.uploadLikedSongs();
      } catch (e) {
        debugPrint('AutoSync: uploadLikedSongs error: $e');
      }
      try {
        await _cloudSync.uploadRecentlyPlayed();
      } catch (e) {
        debugPrint('AutoSync: uploadRecentlyPlayed error: $e');
      }
      try {
        await _cloudSync.uploadDownloadsList();
      } catch (e) {
        debugPrint('AutoSync: uploadDownloadsList error: $e');
      }
      try {
        await _cloudSync.uploadStats();
      } catch (e) {
        debugPrint('AutoSync: uploadStats error: $e');
      }
      
      final duration = DateTime.now().difference(startTime);
      
      // Save last sync time
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastSyncTimeKey, DateTime.now().millisecondsSinceEpoch);
      
      debugPrint('AutoSync: ✅ Sync completed in ${duration.inSeconds}s');
      
    } catch (e) {
      debugPrint('AutoSync: ❌ Sync failed - $e');
    } finally {
      _isSyncing = false;
    }
  }
  
  /// Get last sync time
  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastSyncTimeKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }
  
  /// Check if sync is currently running
  bool get isSyncing => _isSyncing;
}
