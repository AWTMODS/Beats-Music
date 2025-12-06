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
  // AudioSourceManager without audio source caching

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
      } else {
        String? kurl = await getJsQualityURL(mediaItem.extras?["url"]);
        if (kurl == null || kurl.isEmpty) {
          throw Exception('Failed to get stream URL');
        }

        log('Playing: $kurl', name: "AudioSourceManager");
        audioSource = AudioSource.uri(Uri.parse(kurl), tag: mediaItem);
      }

      return audioSource;
    } catch (e) {
      log('Error getting audio source for ${mediaItem.title}: $e',
          name: "AudioSourceManager");
      rethrow;
    }
  }

  // Cache-related getters removed
}
