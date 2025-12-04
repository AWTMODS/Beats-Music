import 'dart:developer';
import 'package:beats_music/model/saavnModel.dart';
import 'package:beats_music/model/yt_music_model.dart';
import 'package:beats_music/repository/Saavn/saavn_api.dart';
import 'package:beats_music/repository/Youtube/ytm/ytmusic.dart';
import 'package:beats_music/routes_and_consts/global_str_consts.dart';
import 'package:beats_music/services/db/beats_music_db_service.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
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
    log("Checking for related songs: queue.length=${queue.length}, currentIdx=$currentPlayingIdx, remaining=${queue.length - currentPlayingIdx}",
        name: "RelatedSongsManager");

    final autoPlay =
        await BeatsMusicDBService.getSettingBool(GlobalStrConsts.autoPlay);
    log("AutoPlay setting: $autoPlay", name: "RelatedSongsManager");
    // Default to true if null (not set by user yet)
    final isAutoPlayEnabled = autoPlay ?? true;
    if (!isAutoPlayEnabled) {
      log("AutoPlay is disabled, skipping related songs", name: "RelatedSongsManager");
      return;
    }

    if (queue.isNotEmpty &&
        (queue.length - currentPlayingIdx) < 2 &&
        loopMode != LoopMode.all) {
      log("Condition met for fetching related songs. Source: ${currentMedia.extras?["source"]}", name: "RelatedSongsManager");
      if (currentMedia.extras?["source"] == "saavn") {
        log("Fetching JioSaavn related songs for: ${currentMedia.title} (${currentMedia.id})", name: "RelatedSongsManager");
        final songs = await compute(_getRelatedSongs, currentMedia.id);
        log("JioSaavn API response: total=${songs['total']}", name: "RelatedSongsManager");
        if (songs['total'] > 0) {
          final List<MediaItem> temp =
              fromSaavnSongMapList2MediaItemList(songs['songs']);
          relatedSongs.add(temp.sublist(1));
          log("Added ${temp.length - 1} JioSaavn related songs to stream", name: "RelatedSongsManager");
        } else {
          // Fallback: Try to get songs from the same artist
          final artist = currentMedia.artist;
          if (artist != null && artist.isNotEmpty && artist != 'Unknown') {
            log("No related songs found, trying artist fallback: $artist", name: "RelatedSongsManager");
            try {
              final artistSongs = await SaavnAPI().fetchSongSearchResults(searchQuery: artist, count: 10);
              if (artistSongs['songs'] != null && (artistSongs['songs'] as List).isNotEmpty) {
                final List<MediaItem> temp = fromSaavnSongMapList2MediaItemList(artistSongs['songs']);
                // Filter out the current song and add the rest
                final filteredSongs = temp.where((song) => song.id != currentMedia.id).toList();
                if (filteredSongs.isNotEmpty) {
                  relatedSongs.add(filteredSongs);
                  log("Added ${filteredSongs.length} songs from artist '$artist' as fallback", name: "RelatedSongsManager");
                } else {
                  log("No different songs found from artist", name: "RelatedSongsManager");
                }
              } else {
                log("Artist fallback also returned no results", name: "RelatedSongsManager");
              }
            } catch (e) {
              log("Error in artist fallback: $e", name: "RelatedSongsManager");
            }
          } else {
            log("No related songs found and artist is unknown/empty", name: "RelatedSongsManager");
          }
        }
      } else if (currentMedia.extras?["source"].contains("youtube") ?? false) {
        log("Fetching YouTube related songs for: ${currentMedia.title}", name: "RelatedSongsManager");
        final songs = await YTMusic()
            .getRelatedSongs(currentMedia.id.replaceAll('youtube', ''));
        if (songs.isNotEmpty) {
          final List<MediaItem> temp = ytmMapList2MediaItemList(songs);
          relatedSongs.add(temp.sublist(1));
          log("Added ${temp.length - 1} YouTube related songs to stream", name: "RelatedSongsManager");
        } else {
          log("No related songs found from YouTube API", name: "RelatedSongsManager");
        }
      } else {
        log("Unknown source type, cannot fetch related songs", name: "RelatedSongsManager");
      }
    } else {
      log("Condition NOT met: queue.isEmpty=${queue.isEmpty}, remaining=${queue.length - currentPlayingIdx}, loopMode=$loopMode", name: "RelatedSongsManager");
    }
    await loadRelatedSongs(
        queue: queue, currentPlayingIdx: currentPlayingIdx, loopMode: loopMode);
  }

  Future<void> loadRelatedSongs({
    required List<MediaItem> queue,
    required int currentPlayingIdx,
    required LoopMode loopMode,
  }) async {
    log("loadRelatedSongs: relatedSongs.count=${relatedSongs.value.length}, remaining=${queue.length - currentPlayingIdx}", name: "RelatedSongsManager");
    if (relatedSongs.value.isNotEmpty &&
        (queue.length - currentPlayingIdx) < 3 &&
        loopMode != LoopMode.all) {
      log("Adding ${relatedSongs.value.length} related songs to queue", name: "RelatedSongsManager");
      onAddQueueItems?.call(relatedSongs.value, atLast: true);
      relatedSongs.add([]);
      log("Related songs added to queue and stream cleared", name: "RelatedSongsManager");
    } else {
      log("NOT adding related songs: isEmpty=${relatedSongs.value.isEmpty}, remaining=${queue.length - currentPlayingIdx}, loopMode=$loopMode", name: "RelatedSongsManager");
    }
  }

  void clearRelatedSongs() {
    relatedSongs.add([]);
  }

  void dispose() {
    relatedSongs.close();
  }
}
