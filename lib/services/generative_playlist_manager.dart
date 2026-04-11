import 'dart:developer';

import 'package:beats_music/services/generative_ai_service.dart';
import 'package:beats_music/services/meta_resolver/cross_plugin_resolver.dart';
import 'package:beats_music/services/plugin/plugin_service.dart';
import 'package:beats_music/services/db/dao/playlist_dao.dart';
import 'package:beats_music/src/rust/api/plugin/models.dart';
import 'package:beats_music/services/db/db_provider.dart';
import 'package:beats_music/services/db/dao/track_dao.dart';

class GenerativePlaylistManager {
  final GenerativeAiService _aiService;
  final PluginService _pluginService;
  final CrossPluginResolver _resolver;
  late final PlaylistDAO _playlistDao;

  GenerativePlaylistManager({
    required GenerativeAiService aiService,
    required PluginService pluginService,
    required CrossPluginResolver resolver,
  })  : _aiService = aiService,
        _pluginService = pluginService,
        _resolver = resolver {
    final trackDAO = TrackDAO(DBProvider.db);
    _playlistDao = PlaylistDAO(DBProvider.db, trackDAO);
  }

  Future<int?> createFromPrompt(String prompt, {int count = 20, Function(double)? onProgress}) async {
    try {
      // 1. Generate Tracks JSON from AI
      log('Requesting AI to generate $count tracks for: $prompt', name: 'GenerativePlaylistManager');
      final tracklist = await _aiService.generateTracklist(prompt, count: count);
      if (tracklist.isEmpty) return null;

      log('AI generated ${tracklist.length} tracks.', name: 'GenerativePlaylistManager');
      if (onProgress != null) onProgress(0.1); // 10% for AI response

      // 2. Fetch active plugins
      final loadedPlugins = _pluginService.getLoadedPlugins();
      if (loadedPlugins.isEmpty) {
        throw Exception('No plugins are active. Please enable a plugin like YouTube to search for tracks.');
      }

      // 3. Resolve each track in parallel
      log('Resolving ${tracklist.length} tracks in parallel...', name: 'GenerativePlaylistManager');
      
      int completed = 0;
      final totalToResolve = tracklist.length;

      final List<Track?> resolvedList = await Future.wait(
        tracklist.map((item) async {
          final title = item['title'] ?? '';
          final artist = item['artist'] ?? '';
          if (title.isEmpty) {
            completed++;
            return null;
          }

          final target = TrackMatchTarget.fromImport(
            title: title,
            artists: [artist],
          );

          try {
            final candidates = await _resolver.resolveTrack(
              target: target,
              pluginIds: loadedPlugins,
              limit: 1, 
              minConfidence: 0.35, 
              sequential: false,
            );

            completed++;
            // Calculate progress: 10% (AI) + up to 90% (Resolution)
            if (onProgress != null) {
              onProgress(0.1 + (0.9 * (completed / totalToResolve)));
            }
            
            return candidates.isNotEmpty ? candidates.first.track : null;
          } catch (e) {
            log('Failed to resolve track "$title": $e', name: 'GenerativePlaylistManager');
            completed++;
            return null;
          }
        }),
      );

      final List<Track> resolvedTracks = resolvedList.whereType<Track>().toList();

      log('Resolved ${resolvedTracks.length} out of ${tracklist.length} tracks.', name: 'GenerativePlaylistManager');

      if (resolvedTracks.isEmpty) {
         throw Exception('Could not find any of the generated songs online.');
      }

      // 4. Create the playlist and save tracks
      String playlistName = "AI: $prompt";
      if (playlistName.length > 30) {
        playlistName = '${playlistName.substring(0, 30)}...';
      }

      // Ensure name uniqueness 
      int suffix = 1;
      String uniqueName = playlistName;
      while (await _playlistDao.getPlaylistByName(uniqueName) != null) {
        uniqueName = '$playlistName ($suffix)';
        suffix++;
      }

      final playlistId = await _playlistDao.createPlaylist(uniqueName, description: 'Generated from prompt: $prompt');
      if (playlistId != null) {
        await _playlistDao.addTracksToPlaylist(playlistId, resolvedTracks);
      }
      
      return playlistId;
      
    } catch (e) {
      log('Error creating generative playlist: $e', error: e, name: 'GenerativePlaylistManager');
      rethrow;
    }
  }
}
