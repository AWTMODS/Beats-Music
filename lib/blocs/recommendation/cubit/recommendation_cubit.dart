import 'dart:async';
import 'dart:developer';
import 'package:beats_music/blocs/recommendation/cubit/recommendation_state.dart';
import 'package:beats_music/core/models/exported.dart';
import 'package:beats_music/services/cloud_sync_service.dart';
import 'package:beats_music/services/listening_statistics_service.dart';
import 'package:beats_music/services/meta_resolver/chart_item_resolver.dart';
import 'package:beats_music/services/meta_resolver/cross_plugin_resolver.dart';
import 'package:beats_music/services/plugin/plugin_service.dart';
import 'package:beats_music/src/rust/api/plugin/commands.dart';
import 'package:bloc/bloc.dart';

class RecommendationCubit extends Cubit<RecommendationState> {
  final PluginService _pluginService;
  final ListeningStatisticsService _statsService;
  final CloudSyncService _cloudSync = CloudSyncService();

  RecommendationCubit({
    required PluginService pluginService,
    required ListeningStatisticsService statsService,
  })  : _pluginService = pluginService,
        _statsService = statsService,
        super(RecommendationInitial());

  Future<void> fetchRecommendations({List<String> resolverPluginIds = const []}) async {
    if (state is RecommendationLoading) return;
    emit(RecommendationLoading());

    try {
      // 1. Get Seeds (History + Onboarding)
      final topArtists = await _statsService.getTopArtists();
      final preferences = await _cloudSync.getUserPreferences();
      final List<String> preferredArtists = preferences['artists'] ?? [];
      final List<String> preferredLanguages = preferences['languages'] ?? [];

      final Set<String> seedArtistNames = {};
      
      // Add top 5 from history
      seedArtistNames.addAll(topArtists.take(5).map((e) => e.artistName));
      
      // Add top 5 from onboarding
      seedArtistNames.addAll(preferredArtists.take(5));

      if (seedArtistNames.isEmpty) {
        // Fallback: If no seeds, try a generic "Popular" list or just wait for history
        emit(const RecommendationLoaded(tracks: [], title: "Recommendations will appear here once you start listening!"));
        return;
      }

      // 2. Fetch related tracks from active plugins
      final List<Track> allRecommended = [];
      final resolver = ChartItemResolver.create(_pluginService);
      
      // We'll pick the top 3 seeds to avoid over-fetching
      final seedsToProcess = seedArtistNames.take(3).toList();
      
      for (final artistName in seedsToProcess) {
        log('Recommendation: Fetching for seed artist: $artistName', name: 'ML');
        
        // Strategy: Search for artist -> Get their ID -> Get Related/Radio tracks
        // For now, we'll do a simple search and take top results if "Radio" isn't direct
        for (final pluginId in resolverPluginIds) {
          try {
            final response = await _pluginService.execute(
              pluginId: pluginId,
              request: PluginRequest.contentResolver(
                ContentResolverCommand.search(
                  query: artistName,
                  filter: ContentSearchFilter.artist,
                  pageToken: null,
                ),
              ),
            );

            final results = response.maybeWhen(
              search: (paged) => paged.items,
              orElse: () => [],
            );

            if (results.isNotEmpty) {
              final firstArtist = results.first.maybeWhen(
                artist: (a) => a,
                orElse: () => null,
              );

              if (firstArtist != null) {
                // Try to get Radio tracks for this artist
                final radioResponse = await _pluginService.execute(
                  pluginId: pluginId,
                  request: PluginRequest.contentResolver(
                    ContentResolverCommand.getRadioTracks(id: firstArtist.id, pageToken: null),
                  ),
                );

                radioResponse.maybeWhen(
                  moreTracks: (paged) {
                    allRecommended.addAll(paged.items);
                  },
                  orElse: () {},
                );
              }
            }
          } catch (e) {
            log('Recommendation: Failed to fetch for $artistName on $pluginId: $e');
          }
        }
      }

      // 3. Filter & Deduplicate
      final seenIds = <String>{};
      final uniqueTracks = <Track>[];
      
      // Also filter by language if possible (simple heuristic)
      for (final track in allRecommended) {
        if (seenIds.contains(track.id)) continue;
        seenIds.add(track.id);
        uniqueTracks.add(track);
      }

      // 4. Final Polish
      final tracksToShow = uniqueTracks.take(20).toList();
      tracksToShow.shuffle(); // Add variety

      emit(RecommendationLoaded(
        tracks: tracksToShow,
        title: preferredLanguages.isNotEmpty 
            ? "Made for You (${preferredLanguages.first})" 
            : "Made for You",
      ));

    } catch (e) {
      log('Recommendation: Global error: $e');
      emit(RecommendationError(e.toString()));
    }
  }
}
