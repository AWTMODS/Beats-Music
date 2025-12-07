import 'dart:developer';
import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:beats_music/services/db/beats_music_db_service.dart';
import 'package:beats_music/routes_and_consts/global_str_consts.dart';

class PreloadManager {
  // Hidden audio players for preloading
  // REUSE strategy: keep them alive to prevent native crash
  AudioPlayer? _preloadPlayerNext;
  String? _preloadedNextMediaId;
  AudioPlayer? _preloadPlayerNext2;
  String? _preloadedNext2MediaId;
  
  bool _isPreloadingNext = false;
  bool _isPreloadingNext2 = false;
  
  // Callbacks
  Future<AudioSource> Function(MediaItem)? onGetAudioSource;
  
  /// Check if we should preload and do so if needed
  Future<void> checkAndPreload({
    required MediaItem? currentMedia,
    required MediaItem? nextMedia,
    required MediaItem? next2Media,
    required Duration currentPosition,
    required Duration? totalDuration,
  }) async {
    if (totalDuration == null || totalDuration.inSeconds == 0) return;

    // STABILITY FIX: Disable preloading on Desktop (Windows/Linux)
    // The native MPV player crashes when handling concurrent streams/players.
    // We must disable preloading to ensure the app doesn't crash mid-song.
    if (Platform.isWindows || Platform.isLinux) return;
    
    // Get aggressive preloading setting
    final aggressivePreload = await BeatsMusicDBService.getSettingBool(
      GlobalStrConsts.aggressivePreload,
    ) ?? false;
    
    final percentComplete = currentPosition.inSeconds / totalDuration.inSeconds;
    
    // Preload next song at 60-70% (or 50% if aggressive)
    final nextThreshold = aggressivePreload ? 0.5 : 0.6;
    if (percentComplete >= nextThreshold && 
        nextMedia != null && 
        !_isPreloadingNext &&
        _preloadedNextMediaId != nextMedia.id) {
      _preloadNext(nextMedia);
    }
    
    // Aggressive mode: preload 2nd next song at 80%
    if (aggressivePreload &&
        percentComplete >= 0.8 && 
        next2Media != null && 
        !_isPreloadingNext2 &&
        _preloadedNext2MediaId != next2Media.id) {
      _preloadNext2(next2Media);
    }
  }

  /// Manually preload a specific song (e.g. from trending list)
  Future<void> preloadSong(MediaItem mediaItem) async {
    // If already preloading this song, skip
    if (_preloadedNextMediaId == mediaItem.id || _preloadedNext2MediaId == mediaItem.id) {
      return;
    }
    
    // Use the secondary preload player for manual preloads to avoid interfering 
    // with the primary "next song" preloader if possible
    if (!_isPreloadingNext2) {
      await _preloadNext2(mediaItem);
    } else if (!_isPreloadingNext) {
      await _preloadNext(mediaItem);
    }
  }
  
  Future<void> _preloadNext(MediaItem mediaItem) async {
    if (onGetAudioSource == null) return;
    
    _isPreloadingNext = true;
    log('Preloading next song: ${mediaItem.title}', name: 'PreloadManager');
    
    try {
      // REUSE: Initialize once if null
      _preloadPlayerNext ??= AudioPlayer();

      // Stop before loading new source (instead of dispose)
      try {
        await _preloadPlayerNext!.stop();
      } catch (_) {}
      
      // Get audio source
      final audioSource = await onGetAudioSource!(mediaItem);
      
      // Set volume to 0 BEFORE loading
      await _preloadPlayerNext!.setVolume(0);
      
      // Load and buffer the audio
      await _preloadPlayerNext!.setAudioSource(audioSource);
      
      _preloadedNextMediaId = mediaItem.id;
      log('Successfully preloaded & buffered: ${mediaItem.title}', name: 'PreloadManager');
    } catch (e) {
      log('Failed to preload ${mediaItem.title}: $e', name: 'PreloadManager');
      // Do NOT dispose on error, just clear state
      _preloadedNextMediaId = null;
    } finally {
      _isPreloadingNext = false;
    }
  }
  
  Future<void> _preloadNext2(MediaItem mediaItem) async {
    if (onGetAudioSource == null) return;
    
    _isPreloadingNext2 = true;
    log('Preloading 2nd next song: ${mediaItem.title}', name: 'PreloadManager');
    
    try {
      // REUSE: Initialize once if null
      _preloadPlayerNext2 ??= AudioPlayer();

      // Stop before loading new source
      try {
        await _preloadPlayerNext2!.stop();
      } catch (_) {}
      
      // Get audio source
      final audioSource = await onGetAudioSource!(mediaItem);
      
      // Set volume to 0 BEFORE loading
      await _preloadPlayerNext2!.setVolume(0);
      
      // Load and buffer the audio
      await _preloadPlayerNext2!.setAudioSource(audioSource);
      
      _preloadedNext2MediaId = mediaItem.id;
      log('Successfully preloaded & buffered 2nd: ${mediaItem.title}', name: 'PreloadManager');
    } catch (e) {
      log('Failed to preload 2nd ${mediaItem.title}: $e', name: 'PreloadManager');
      // Do NOT dispose on error
      _preloadedNext2MediaId = null;
    } finally {
      _isPreloadingNext2 = false;
    }
  }
  
  /// Get preloaded audio source if available
  /// Returns the AudioSource from the preloaded player
  AudioSource? getPreloadedSource(String mediaId) {
    if (_preloadedNextMediaId == mediaId && _preloadPlayerNext != null) {
      try {
        final source = _preloadPlayerNext!.audioSource;
        log('Using preloaded source for: $mediaId', name: 'PreloadManager');
        return source;
      } catch (e) {
        log('Error getting preloaded source: $e', name: 'PreloadManager');
        return null;
      }
    }
    
    if (_preloadedNext2MediaId == mediaId && _preloadPlayerNext2 != null) {
      try {
        final source = _preloadPlayerNext2!.audioSource;
        log('Using preloaded 2nd source for: $mediaId', name: 'PreloadManager');
        
        // SWAP PLAYERS: Move player2 to player1 to keep the chain going
        // This is safe because we just pass references, no disposal
        final tempPlayer = _preloadPlayerNext;
        _preloadPlayerNext = _preloadPlayerNext2;
        _preloadPlayerNext2 = tempPlayer; // Move old player1 to player2 (recycling)

        // Stop the "new" player2 (which was old player1) to reset it
        if (_preloadPlayerNext2 != null) {
           _preloadPlayerNext2!.stop().catchError((_) {});
        }

        _preloadedNextMediaId = _preloadedNext2MediaId;
        _preloadedNext2MediaId = null;
        
        return source;
      } catch (e) {
        log('Error getting preloaded 2nd source: $e', name: 'PreloadManager');
        return null;
      }
    }
    
    return null;
  }
  
  /// Clear all preloaded sources
  Future<void> clearPreload() async {
    log('Clearing all preloaded sources', name: 'PreloadManager');
    try {
        await _preloadPlayerNext?.stop();
    } catch (_) {}
    _preloadedNextMediaId = null;

    try {
        await _preloadPlayerNext2?.stop();
    } catch (_) {}
    _preloadedNext2MediaId = null;
  }
  
  /// Clear only the next preload (called after it's used)
  Future<void> clearNextPreload() async {
    try {
        await _preloadPlayerNext?.stop();
    } catch (_) {}
    _preloadedNextMediaId = null;
  }
  
  /// Only call this when APP CLOSES
  Future<void> dispose() async {
    await clearPreload();
    await _preloadPlayerNext?.dispose();
    await _preloadPlayerNext2?.dispose();
  }
}
