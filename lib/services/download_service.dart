
import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:beats_music/model/songModel.dart';
import 'package:beats_music/repository/Spotify/spotify_downloader_api.dart';
import 'package:beats_music/repository/Spotify/aswin_sparky_api.dart';
import 'package:beats_music/services/db/beats_music_db_service.dart';
import 'package:beats_music/services/db/GlobalDB.dart';
import 'package:beats_music/utils/audio_tagger.dart';
import 'package:beats_music/utils/ytstream_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:beats_music/model/saavnModel.dart';
import 'package:path_provider/path_provider.dart';

class DownloadService {
  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;
  DownloadService._internal();

  final Dio _dio = Dio();

  /// Downloads a song to local storage
  Future<bool> downloadSong(MediaItem mediaItem) async {
    try {
      debugPrint('DownloadService: Starting download for ${mediaItem.title}');
      
      // 1. Get Download URL
      String? downloadUrl;
      
      // Try Spotify first
      if (mediaItem.extras?['spotifyId'] != null) {
        downloadUrl = await SpotifyDownloaderAPI.getDirectDownloadUrl(mediaItem.extras!['spotifyId']);
      } else if (mediaItem.extras?['spotify_link'] != null) {
         final trackData = await AswinSparkyAPI().getTrackFromUrl(mediaItem.extras!['spotify_link']);
         if (trackData != null) {
           downloadUrl = trackData['download'];
         }
      }
      
      // Fallback to YouTube logic (simplified for now as ytstream_source returns AudioSource, not URL directly mostly)
      if (downloadUrl == null && mediaItem.extras?['source'] == 'youtube') {
         // This is harder because YouTubeAudioSource manages stream internally.
         // We might need to extract the stream URL similar to AudioSourceManager.
         final id = mediaItem.id.replaceAll("youtube", '');
         // Assuming getJsQualityURL logic is accessible or similar
         downloadUrl = await getJsQualityURL(mediaItem.extras?["url"]); 
      }

      if (downloadUrl == null) {
        debugPrint('DownloadService: Could not find download URL');
        return false;
      }

      // 2. Prepare File Path
      final dir = await getApplicationDocumentsDirectory();
      final musicDir = Directory('${dir.path}/music');
      if (!await musicDir.exists()) {
        await musicDir.create(recursive: true);
      }
      
      // Sanitize filename
      final fileName = '${mediaItem.id.replaceAll(RegExp(r'[^\w\s]+'), '')}.mp3';
      final savePath = '${musicDir.path}/$fileName';

      // 3. Download File
      await _dio.download(downloadUrl, savePath);

      // 4. Register in DB
      final downloadDB = DownloadDB(
         mediaId: mediaItem.id,
         fileName: fileName,
         filePath: musicDir.path,
         lastDownloaded: DateTime.now(),
      );
      
      final isar = await BeatsMusicDBService.db;
      await isar.writeTxn(() async {
        await isar.downloadDBs.put(downloadDB);
      });

      // 5. Tag Audio (Optional/Best Effort)
      try {
        await AudioTagger.writeTags(savePath, AudioMetadata(
          title: mediaItem.title,
          artist: mediaItem.artist ?? 'Unknown',
          album: mediaItem.album ?? 'Unknown',
          artworkUrl: mediaItem.artUri?.toString() ?? '',
          duration: mediaItem.duration
        ));
      } catch (e) {
        debugPrint('DownloadService: Tagging failed (non-fatal): $e');
      }

      debugPrint('DownloadService: Download complete: $savePath');
      return true;

    } catch (e) {
      debugPrint('DownloadService: Download failed: $e');
      return false;
    }
  }
}
