import 'dart:developer';
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

class AudioSourceManager {
  // Cache for audio sources to prevent redundant fetching
  final Map<String, AudioSource> _audioSourceCache = {};
  
  // Method to clear cache for a specific song ID (useful if playback fails)
  void clearCachedSource(String mediaId) {
    if (_audioSourceCache.containsKey(mediaId)) {
      _audioSourceCache.remove(mediaId);
      log('Cleared cached source for: $mediaId', name: "AudioSourceManager");
    }
  }

  // Clear entire cache
  void clearAllCache() {
    _audioSourceCache.clear();
    log('Cleared all audio source cache', name: "AudioSourceManager");
  }

  Future<AudioSource> getAudioSource(MediaItem mediaItem,
      {required bool isConnected}) async {
    try {
      // Check for offline version first
      final _down = await BeatsMusicDBService.getDownloadDB(
          mediaItem2MediaItemModel(mediaItem));
      if (_down != null) {
        log("Playing Offline: ${mediaItem.title}", name: "AudioSourceManager");
        SnackbarService.showMessage("Playing Offline",
            duration: const Duration(seconds: 1));

        final audioSource = AudioSource.uri(
            Uri.file('${_down.filePath}/${_down.fileName}'),
            tag: mediaItem);
        return audioSource;
      }
      
      // Check cache for online sources
      if (_audioSourceCache.containsKey(mediaItem.id)) {
        log("Returning cached audio source for: ${mediaItem.title}", 
            name: "AudioSourceManager");
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
          log("Fetching Spotify download URL for: ${mediaItem.title}", 
              name: "AudioSourceManager");
          
          // Fetch download URL from Aswin Sparky API
          final trackData = await AswinSparkyAPI().getTrackFromUrl(
              mediaItem.extras!["spotify_link"]);
          
          if (trackData != null && trackData['download'] != null) {
            final downloadUrl = trackData['download'];
            log('Got Spotify download URL, playing: ${mediaItem.title}', 
                name: "AudioSourceManager");
            
            audioSource = AudioSource.uri(Uri.parse(downloadUrl), tag: mediaItem);
            // Cache the result
            _audioSourceCache[mediaItem.id] = audioSource;
            return audioSource;
          } else {
            log('Failed to get Spotify download URL', name: "AudioSourceManager");
            throw Exception('Failed to get Spotify download URL');
          }
        } catch (e) {
          log('Error fetching Spotify URL: $e', name: "AudioSourceManager");
          throw Exception('Failed to fetch Spotify audio: $e');
        }
      }

      // Try Spotify first if available (old implementation)
      if (mediaItem.extras?["spotifyId"] != null) {
        try {
          log("Attempting Spotify playback for: ${mediaItem.title}", 
              name: "AudioSourceManager");
          
          final spotifyUrl = await SpotifyDownloaderAPI.getDirectDownloadUrl(
              mediaItem.extras!["spotifyId"]);
          
          if (spotifyUrl != null && spotifyUrl.isNotEmpty) {
            log('Playing from Spotify: ${mediaItem.title}', 
                name: "AudioSourceManager");
            SnackbarService.showMessage("Playing from Spotify",
                duration: const Duration(seconds: 1));
            
            audioSource = AudioSource.uri(Uri.parse(spotifyUrl), tag: mediaItem);
            // Cache the result
            _audioSourceCache[mediaItem.id] = audioSource;
            return audioSource;
          } else {
            log('Spotify URL not available, falling back to other sources', 
                name: "AudioSourceManager");
          }
        } catch (e) {
          log('Spotify playback failed, falling back: $e', 
              name: "AudioSourceManager");
        }
      }

      // Fallback to YouTube or JioSaavn
      if (mediaItem.extras?["source"] == "youtube") {
        String? quality =
            await BeatsMusicDBService.getSettingStr(GlobalStrConsts.ytStrmQuality);
        quality = quality ?? "high";
        quality = quality.toLowerCase();
        final id = mediaItem.id.replaceAll("youtube", '');

        audioSource =
            YouTubeAudioSource(videoId: id, quality: quality, tag: mediaItem);
            
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

        log('Playing: $kurl', name: "AudioSourceManager");
        audioSource = AudioSource.uri(Uri.parse(kurl), tag: mediaItem);
        // Cache the result
        _audioSourceCache[mediaItem.id] = audioSource;
      }

      return audioSource;
    } catch (e) {
      log('Error getting audio source for ${mediaItem.title}: $e',
          name: "AudioSourceManager");
      // Clear cache if we failed and maybe had a bad cached entry (though we check cache first)
      clearCachedSource(mediaItem.id);
      rethrow;
    }
  }
}
