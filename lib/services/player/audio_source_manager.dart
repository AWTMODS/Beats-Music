import 'package:flutter/foundation.dart';
import 'package:beats_music/model/songModel.dart';
import 'package:beats_music/model/saavnModel.dart';
import 'package:beats_music/routes_and_consts/global_str_consts.dart';
import 'package:beats_music/screens/widgets/snackbar.dart';
import 'package:beats_music/services/db/beats_music_db_service.dart';
import 'package:beats_music/utils/ytstream_source.dart';
import 'package:beats_music/repository/Spotify/spotify_downloader_api.dart';
import 'package:beats_music/repository/Spotify/aswin_sparky_api.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

class AudioSourceManager {
  // Cache for audio sources to prevent redundant fetching
  final Map<String, AudioSource> _audioSourceCache = {};
  
  // Method to clear cache for a specific song ID (useful if playback fails)
  void clearCachedSource(String mediaId) {
    _audioSourceCache.remove(mediaId);
    debugPrint('Cleared audio source cache for: $mediaId');
  }

  // Clear entire cache
  void clearAllCache() {
    _audioSourceCache.clear();
    debugPrint('Cleared all audio source cache');
  }

  Future<AudioSource> getAudioSource(MediaItem mediaItem,
      {required bool isConnected}) async {
    try {
      // Check for offline version first
      final _down = await BeatsMusicDBService.getDownloadDB(
          mediaItem2MediaItemModel(mediaItem));
      if (_down != null) {
        debugPrint("Playing Offline: ${mediaItem.title}");
        SnackbarService.showMessage("Playing Offline",
            duration: const Duration(seconds: 1));

        final audioSource = AudioSource.uri(
            Uri.file('${_down.filePath}/${_down.fileName}'),
            tag: mediaItem);
        return audioSource;
      }
      
      // Check cache for online sources
      if (_audioSourceCache.containsKey(mediaItem.id)) {
        debugPrint("Returning cached audio source for: ${mediaItem.title}");
        return _audioSourceCache[mediaItem.id]!;
      }

      // Check network connectivity before attempting online playback
      if (!isConnected) {
        throw Exception('No network connection available');
      }

      AudioSource audioSource;

      // Check if this is a Spotify Aswin track that needs URL fetching
      if (mediaItem.extras?["needs_url_fetch"] == 'true' && 
          mediaItem.extras?["spotify_link"] != null) {
        try {
          debugPrint("Fetching Spotify download URL for: ${mediaItem.title}");
          
          // Fetch download URL from Aswin Sparky API
          final trackData = await AswinSparkyAPI().getTrackFromUrl(
              mediaItem.extras!["spotify_link"]);
          
          if (trackData != null && trackData['download'] != null) {
            final downloadUrl = trackData['download'];
            debugPrint('Got Spotify download URL, playing: ${mediaItem.title}');
            
            audioSource = await _wrapWithCache(Uri.parse(downloadUrl), mediaItem);
            // Cache the result
            _audioSourceCache[mediaItem.id] = audioSource;
            return audioSource;
          } else {
            debugPrint('Failed to get Spotify download URL');
            throw Exception('Failed to get Spotify download URL');
          }
        } catch (e) {
          debugPrint('Error fetching Spotify URL: $e');
          throw Exception('Failed to fetch Spotify audio: $e');
        }
      }

      // Try Spotify first if available (old implementation)
      if (mediaItem.extras?["spotifyId"] != null) {
        try {
          debugPrint("Attempting Spotify playback for: ${mediaItem.title}");
          
          final spotifyUrl = await SpotifyDownloaderAPI.getDirectDownloadUrl(
              mediaItem.extras!["spotifyId"]);
          
          if (spotifyUrl != null && spotifyUrl.isNotEmpty) {
            debugPrint('Playing from Spotify: ${mediaItem.title}');
            SnackbarService.showMessage("Playing from Spotify",
                duration: const Duration(seconds: 1));
            
            audioSource = await _wrapWithCache(Uri.parse(spotifyUrl), mediaItem);
            // Cache the result
            _audioSourceCache[mediaItem.id] = audioSource;
            return audioSource;
          } else {
            debugPrint('Spotify URL not available, falling back to other sources');
          }
        } catch (e) {
          debugPrint('Spotify playback failed, falling back: $e');
        }
      }

      // Fallback to YouTube or JioSaavn
      if (mediaItem.extras?["source"] == "youtube") {
        String? quality =
            await BeatsMusicDBService.getSettingStr(GlobalStrConsts.ytStrmQuality);
        quality = quality ?? "high";
        quality = quality.toLowerCase();
        final id = mediaItem.id.replaceAll("youtube", '');

        // Resolve URL first to enable LockCachingAudioSource
        try {
          final ytSource = YouTubeAudioSource(videoId: id, quality: quality, tag: mediaItem);
          final streamInfo = await ytSource.getStreamInfo();
          audioSource = await _wrapWithCache(streamInfo.url, mediaItem);
        } catch (e) {
          debugPrint('Failed to resolve YouTube URL for caching, using direct source: $e');
          audioSource = YouTubeAudioSource(videoId: id, quality: quality, tag: mediaItem);
        }
            
        // Note: YouTubeAudioSource handles its own stream extraction and caching internally usually,
        // but we can cache the object wrapper.
        _audioSourceCache[mediaItem.id] = audioSource;
      } else {
         String? kurl;
         // Optimization: If URL is already provided in extras and looks valid, use it
         if (mediaItem.extras?["url"] != null && 
             mediaItem.extras!["url"].toString().startsWith('http')) {
             // For some sources, the URL in extras IS the stream URL
             // But usually it's a page URL that needs scraping
             // We'll proceed with getJsQualityURL to be safe unless we are sure
         }
         
        kurl = await getJsQualityURL(mediaItem.extras?["url"]);
        if (kurl == null || kurl.isEmpty) {
          throw Exception('Failed to get stream URL');
        }

        debugPrint('Playing: $kurl');
        audioSource = await _wrapWithCache(Uri.parse(kurl), mediaItem);
        // Cache the result
        _audioSourceCache[mediaItem.id] = audioSource;
      }

      return audioSource;
    } catch (e) {
      debugPrint('Error getting audio source for ${mediaItem.title}: $e');
      // Clear cache if we failed and maybe had a bad cached entry (though we check cache first)
      clearCachedSource(mediaItem.id);
      rethrow;
    }
  }

  /// Trigger stream resolution and caching without returning the source
  /// Useful for pre-fetching URLs in the background.
  Future<void> ensureSourcePrepared(MediaItem mediaItem,
      {required bool isConnected}) async {
    try {
      final source = await getAudioSource(mediaItem, isConnected: isConnected);
      if (source is YouTubeAudioSource) {
        debugPrint('Pre-resolving YouTube stream for: ${mediaItem.title}');
        await source.getStreamInfo();
      }
      // For LockCachingAudioSource, we don't need to do extra work here 
      // as it buffers when the player starts loading it.
    } catch (e) {
      debugPrint('Failed to prepare source for ${mediaItem.title}: $e');
    }
  }

  /// Helper to wrap a URI with LockCachingAudioSource for local stream caching
  Future<AudioSource> _wrapWithCache(Uri uri, MediaItem tag) async {
    try {
      final cacheDir = await getTemporaryDirectory();
      // Use mediaId to create a unique cache file
      final cachePath = p.join(cacheDir.path, 'audio_cache', '${tag.id}.cache');
      
      final cacheFile = File(cachePath);
      if (!await cacheFile.parent.exists()) {
        await cacheFile.parent.create(recursive: true);
      }

      debugPrint('Using LockCachingAudioSource for: ${tag.title}');
      return LockCachingAudioSource(uri, cacheFile: cacheFile, tag: tag);
    } catch (e) {
      debugPrint('Error creating LockCachingAudioSource: $e. Falling back to normal UriSource.');
      return AudioSource.uri(uri, tag: tag);
    }
  }
}
