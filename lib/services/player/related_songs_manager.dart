import 'package:beats_music/model/saavnModel.dart';
import 'package:beats_music/model/yt_music_model.dart';
import 'package:beats_music/repository/Saavn/saavn_api.dart';
import 'package:beats_music/repository/Youtube/ytm/ytmusic.dart';
import 'package:beats_music/routes_and_consts/global_str_consts.dart';
import 'package:beats_music/services/db/beats_music_db_service.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

// Static method for compute operation
Future<Map> _getRelatedSongs(String songId) async {
  return await SaavnAPI().getRelated(songId);
}

class RelatedSongsManager {
  final BehaviorSubject<List<MediaItem>> relatedSongs =
      BehaviorSubject<List<MediaItem>>.seeded([]);

  // Callbacks
  Function(List<MediaItem> items, {bool atLast})? onAddQueueItems;

  Future<void> checkForRelatedSongs({
    required MediaItem currentMedia,
    required List<MediaItem> queue,
    required int currentPlayingIdx,
    required LoopMode loopMode,
  }) async {
    final autoPlay =
        await BeatsMusicDBService.getSettingBool(GlobalStrConsts.autoPlay);
    // Default to true if null (not set by user yet)
    final isAutoPlayEnabled = autoPlay ?? true;
    if (!isAutoPlayEnabled) {
      return;
    }

    if (queue.isNotEmpty &&
        (queue.length - currentPlayingIdx) < 2 &&
        loopMode != LoopMode.all) {
      if (currentMedia.extras?["source"] == "saavn") {
        final songs = await compute(_getRelatedSongs, currentMedia.id);
        if (songs['total'] > 0) {
          final List<MediaItem> temp =
              fromSaavnSongMapList2MediaItemList(songs['songs']);
          // Filter out existing songs in queue
          final Set<String> queueIds = queue.map((e) => e.id).toSet();
          final filtered = temp.where((s) => !queueIds.contains(s.id)).toList();
          
          if (filtered.isNotEmpty) {
             relatedSongs.add(filtered);
          }
        } else {
          // Fallback: Try to get songs from the same artist
          final artist = currentMedia.artist;
          if (artist != null && artist.isNotEmpty && artist != 'Unknown') {
            try {
              final artistSongs = await SaavnAPI().fetchSongSearchResults(searchQuery: artist, count: 10);
              if (artistSongs['songs'] != null && (artistSongs['songs'] as List).isNotEmpty) {
                final List<MediaItem> temp = fromSaavnSongMapList2MediaItemList(artistSongs['songs']);
                // Filter out the current song and existing songs in queue
                final Set<String> queueIds = queue.map((e) => e.id).toSet();
                final filteredSongs = temp.where((song) => song.id != currentMedia.id && !queueIds.contains(song.id)).toList();
                if (filteredSongs.isNotEmpty) {
                  relatedSongs.add(filteredSongs);
                }
              }
            } catch (e) {
              debugPrint("Error in artist fallback: $e");
            }
          }
        }
      } else if (currentMedia.extras?["source"].contains("youtube") ?? false) {
        final songs = await YTMusic()
            .getRelatedSongs(currentMedia.id.replaceAll('youtube', ''));
        if (songs.isNotEmpty) {
          final List<MediaItem> temp = ytmMapList2MediaItemList(songs);
          // Filter out existing songs in queue (including current)
          final Set<String> queueIds = queue.map((e) => e.id).toSet();
          final filtered = temp.where((s) => !queueIds.contains(s.id)).toList();
          
          if (filtered.isNotEmpty) {
            relatedSongs.add(filtered);
          }
        }
      }
    }
    await loadRelatedSongs(
        queue: queue, currentPlayingIdx: currentPlayingIdx, loopMode: loopMode);
  }

  Future<void> loadRelatedSongs({
    required List<MediaItem> queue,
    required int currentPlayingIdx,
    required LoopMode loopMode,
  }) async {
    if (relatedSongs.value.isNotEmpty &&
        (queue.length - currentPlayingIdx) < 3 &&
        loopMode != LoopMode.all) {
      onAddQueueItems?.call(relatedSongs.value, atLast: true);
      relatedSongs.add([]);
    }
  }

  void clearRelatedSongs() {
    relatedSongs.add([]);
  }

  void dispose() {
    relatedSongs.close();
  }
}
