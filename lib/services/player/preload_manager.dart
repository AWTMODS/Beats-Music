import 'dart:io';
import 'dart:developer';
import 'package:flutter/foundation.dart';
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
  AudioPlayer? _preloadPlayerNext3;
  String? _preloadedNext3MediaId;
  
  bool _isPreloadingNext = false;
  bool _isPreloadingNext2 = false;
  bool _isPreloadingNext3 = false;
  
  // Desktop-specific URL pre-fetching (to avoid multiple player crashes)
  final Map<String, dynamic> _desktopPreloadCache = {};
  
  // Callbacks
  Future<void> Function(MediaItem)? onPrepareSource;
  Future<AudioSource> Function(MediaItem)? onGetAudioSource;
  
  /// Check if we should preload and do so if needed
  Future<void> checkAndPreload({
    required MediaItem? currentMedia,
    required MediaItem? nextMedia,
    required MediaItem? next2Media,
    required MediaItem? next3Media,
    required Duration currentPosition,
    required Duration? totalDuration,
  }) async {
    if (totalDuration == null || totalDuration.inSeconds == 0) return;

    // Aggressive preloading: Earlier triggers and more songs
    final percentComplete = currentPosition.inSeconds / totalDuration.inSeconds;
    
    // 1. Preload NEXT song very early (at 10%)
    if (percentComplete >= 0.1 && 
        nextMedia != null && 
        !_isPreloadingNext &&
        _preloadedNextMediaId != nextMedia.id) {
      if (Platform.isWindows || Platform.isLinux) {
        _preloadURL(nextMedia);
      } else {
        _preloadNext(nextMedia);
      }
    }
    
    // 2. Preload 2nd next song at 20%
    if (percentComplete >= 0.2 && 
        next2Media != null && 
        !_isPreloadingNext2 &&
        _preloadedNext2MediaId != next2Media.id) {
      if (Platform.isWindows || Platform.isLinux) {
        _preloadURL(next2Media, isNext2: true);
      } else {
        _preloadNext2(next2Media);
      }
    }

    // 3. Preload 3rd next song at 30%
    if (percentComplete >= 0.3 && 
        next3Media != null && 
        !_isPreloadingNext3 &&
        _preloadedNext3MediaId != next3Media.id) {
       if (Platform.isWindows || Platform.isLinux) {
         _preloadURL(next3Media, isNext3: true);
       } else {
         _preloadNext3(next3Media);
       }
    }
  }

  /// Manually preload a specific song (e.g. from trending list)
  Future<void> preloadSong(MediaItem mediaItem) async {
    // If already preloading this song, skip
    if (_preloadedNextMediaId == mediaItem.id || 
        _preloadedNext2MediaId == mediaItem.id ||
        _preloadedNext3MediaId == mediaItem.id) {
      return;
    }

    if (Platform.isWindows || Platform.isLinux) {
      await _preloadURL(mediaItem);
      return;
    }
    
    // Use the secondary/tertiary preload players for manual preloads
    if (!_isPreloadingNext3) {
      await _preloadNext3(mediaItem);
    } else if (!_isPreloadingNext2) {
      await _preloadNext2(mediaItem);
    } else if (!_isPreloadingNext) {
      await _preloadNext(mediaItem);
    }
  }

  /// Specialized pre-fetcher for Desktop to avoid native crashes
  Future<void> _preloadURL(MediaItem mediaItem, {bool isNext2 = false, bool isNext3 = false}) async {
    if (onPrepareSource == null) return;
    if (isNext3) {
      _isPreloadingNext3 = true;
    } else if (isNext2) {
      _isPreloadingNext2 = true; 
    } else {
      _isPreloadingNext = true;
    }
    
    debugPrint('Pre-fetching URL for Desktop: ${mediaItem.title}');
    try {
      await onPrepareSource!(mediaItem);

      if (isNext3) {
        _preloadedNext3MediaId = mediaItem.id;
      } else if (isNext2) {
        _preloadedNext2MediaId = mediaItem.id;
      } else {
        _preloadedNextMediaId = mediaItem.id;
      }
      debugPrint('Successfully pre-fetched URL: ${mediaItem.title}');
    } catch (e) {
      log('Failed to pre-fetch URL for ${mediaItem.title}: $e', name: 'PreloadManager');
    } finally {
      if (isNext3) {
        _isPreloadingNext3 = false;
      } else if (isNext2) {
        _isPreloadingNext2 = false; 
      } else {
        _isPreloadingNext = false;
      }
    }
  }
  
  Future<void> _preloadNext(MediaItem mediaItem) async {
    if (onGetAudioSource == null) return;
    
    _isPreloadingNext = true;
    debugPrint('Preloading next song: ${mediaItem.title}');
    
    try {
      _preloadPlayerNext ??= AudioPlayer();

      try {
        await _preloadPlayerNext!.stop();
      } catch (_) {}
      
      final audioSource = await onGetAudioSource!(mediaItem);
      await _preloadPlayerNext!.setVolume(0);
      await _preloadPlayerNext!.setAudioSource(audioSource);
      
      _preloadedNextMediaId = mediaItem.id;
      debugPrint('Successfully preloaded & buffered: ${mediaItem.title}');
    } catch (e) {
      log('Failed to preload ${mediaItem.title}: $e', name: 'PreloadManager');
      _preloadedNextMediaId = null;
    } finally {
      _isPreloadingNext = false;
    }
  }
  
  Future<void> _preloadNext2(MediaItem mediaItem) async {
    if (onGetAudioSource == null) return;
    
    _isPreloadingNext2 = true;
    debugPrint('Preloading 2nd next song: ${mediaItem.title}');
    
    try {
      _preloadPlayerNext2 ??= AudioPlayer();

      try {
        await _preloadPlayerNext2!.stop();
      } catch (_) {}
      
      final audioSource = await onGetAudioSource!(mediaItem);
      await _preloadPlayerNext2!.setVolume(0);
      await _preloadPlayerNext2!.setAudioSource(audioSource);
      
      _preloadedNext2MediaId = mediaItem.id;
      debugPrint('Successfully preloaded & buffered 2nd: ${mediaItem.title}');
    } catch (e) {
      log('Failed to preload 2nd ${mediaItem.title}: $e', name: 'PreloadManager');
      _preloadedNext2MediaId = null;
    } finally {
      _isPreloadingNext2 = false;
    }
  }

  Future<void> _preloadNext3(MediaItem mediaItem) async {
    if (onGetAudioSource == null) return;
    
    _isPreloadingNext3 = true;
    debugPrint('Preloading 3rd next song: ${mediaItem.title}');
    
    try {
      _preloadPlayerNext3 ??= AudioPlayer();

      try {
        await _preloadPlayerNext3!.stop();
      } catch (_) {}
      
      final audioSource = await onGetAudioSource!(mediaItem);
      await _preloadPlayerNext3!.setVolume(0);
      await _preloadPlayerNext3!.setAudioSource(audioSource);
      
      _preloadedNext3MediaId = mediaItem.id;
      debugPrint('Successfully preloaded & buffered 3rd: ${mediaItem.title}');
    } catch (e) {
      log('Failed to preload 3rd ${mediaItem.title}: $e', name: 'PreloadManager');
      _preloadedNext3MediaId = null;
    } finally {
      _isPreloadingNext3 = false;
    }
  }
  
  /// Get preloaded audio source if available
  AudioSource? getPreloadedSource(String mediaId) {
    if (_preloadedNextMediaId == mediaId && _preloadPlayerNext != null) {
      try {
        final source = _preloadPlayerNext!.audioSource;
        debugPrint('Using preloaded source for: $mediaId');
        return source;
      } catch (e) {
        debugPrint('Error getting preloaded source: $e');
        return null;
      }
    }
    
    if (_preloadedNext2MediaId == mediaId && _preloadPlayerNext2 != null) {
      try {
        final source = _preloadPlayerNext2!.audioSource;
        log('Using preloaded 2nd source for: $mediaId', name: 'PreloadManager');
        
        // RECYCLE: Move player2 to player1, player3 to player2
        final tempPlayer1 = _preloadPlayerNext;
        _preloadPlayerNext = _preloadPlayerNext2;
        _preloadPlayerNext2 = _preloadPlayerNext3;
        _preloadPlayerNext3 = tempPlayer1; // Recycling oldest

        if (_preloadPlayerNext3 != null) {
           _preloadPlayerNext3!.stop().catchError((_) {});
        }

        _preloadedNextMediaId = _preloadedNext2MediaId;
        _preloadedNext2MediaId = _preloadedNext3MediaId;
        _preloadedNext3MediaId = null;
        
        return source;
      } catch (e) {
        debugPrint('Error getting preloaded 2nd source: $e');
        return null;
      }
    }

    if (_preloadedNext3MediaId == mediaId && _preloadPlayerNext3 != null) {
      try {
        final source = _preloadPlayerNext3!.audioSource;
        log('Using preloaded 3rd source for: $mediaId', name: 'PreloadManager');
        
        // Move player3 to player1
        final tempPlayer1 = _preloadPlayerNext;
        _preloadPlayerNext = _preloadPlayerNext3;
        _preloadPlayerNext3 = tempPlayer1;

        if (_preloadPlayerNext3 != null) {
           _preloadPlayerNext3!.stop().catchError((_) {});
        }

        _preloadedNextMediaId = _preloadedNext3MediaId;
        _preloadedNext3MediaId = null;
        
        return source;
      } catch (e) {
        debugPrint('Error getting preloaded 3rd source: $e');
        return null;
      }
    }
    
    return null;
  }
  
  /// Clear all preloaded sources
  Future<void> clearPreload() async {
    debugPrint('Clearing all preloaded sources');
    try {
        await _preloadPlayerNext?.stop();
    } catch (_) {}
    _preloadedNextMediaId = null;

    try {
        await _preloadPlayerNext2?.stop();
    } catch (_) {}
    _preloadedNext2MediaId = null;

    try {
        await _preloadPlayerNext3?.stop();
    } catch (_) {}
    _preloadedNext3MediaId = null;
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
    await _preloadPlayerNext3?.dispose();
  }
}
