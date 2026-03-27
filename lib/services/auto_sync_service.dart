import 'dart:async';
import 'package:beats_music/services/cloud_sync_service.dart';
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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
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
    if (_auth.currentUser == null || _auth.currentUser!.isAnonymous) {
      debugPrint('AutoSync: Skipped (not logged in or guest mode)');
      return;
    }
    
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
  
  /// Manually trigger sync (called when playlist is created/modified)
  Future<void> syncNow() async {
    final enabled = await isAutoSyncEnabled();
    if (!enabled) {
      debugPrint('AutoSync: Sync skipped (disabled in settings)');
      return;
    }
    
    if (_auth.currentUser == null || _auth.currentUser!.isAnonymous) {
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
      
      // Upload all data types
      await Future.wait([
        _cloudSync.uploadPlaylists(),
        _cloudSync.uploadLikedSongs(),
        _cloudSync.uploadRecentlyPlayed(),
        _cloudSync.uploadDownloadsList(),
        _cloudSync.uploadStats(),
      ]);

      // Download all data types (Sync Down)
      // We do this sequentially after upload to ensure we have the latest merged state
      // or parallel? Parallel is faster. DB service handles transactions safely.
      await Future.wait([
        _cloudSync.downloadPlaylists(),
        _cloudSync.downloadLikedSongs(),
        _cloudSync.downloadRecentlyPlayed(),
        _cloudSync.downloadDownloadsList(),
        _cloudSync.downloadStats(),
      ]);
      
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
