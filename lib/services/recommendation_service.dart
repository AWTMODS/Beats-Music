import 'dart:developer';
import 'package:audio_service/audio_service.dart';
import 'package:beats_music/model/saavnModel.dart';
import 'package:beats_music/model/songModel.dart';
import 'package:beats_music/model/yt_music_model.dart';
import 'package:beats_music/repository/Saavn/saavn_api.dart';
import 'package:beats_music/repository/Youtube/ytm/ytmusic.dart';
import 'package:beats_music/services/listening_statistics_service.dart';
import 'package:beats_music/services/trending_algorithm_service.dart';

class RecommendationService {
  static final RecommendationService _instance = RecommendationService._internal();
  factory RecommendationService() => _instance;
  RecommendationService._internal();

  final ListeningStatisticsService _statsService = ListeningStatisticsService();
  final SaavnAPI _saavnAPI = SaavnAPI();
  final YTMusic _ytMusic = YTMusic();
  final TrendingAlgorithmService _trendingService = TrendingAlgorithmService();

  Future<List<MediaItem>> getRecommendations({int limit = 20}) async {
    List<MediaItem> allRecommendations = [];
    final seenIds = <String>{};

    try {
      // 1. Get Seeds from Statistics
      final topSongs = await _statsService.getTopSongs(limit: 5);
      final topArtists = await _statsService.getTopArtists(limit: 3);
      final topGenres = await _statsService.getTopGenres(limit: 2);

      // Add recently played to 'seen' list to avoid suggesting them
      final recentlyPlayed = await _statsService.getRecentlyPlayed(limit: 50);
      for (var song in recentlyPlayed) {
        seenIds.add(song.songId);
      }

      // 2. Fetch Related Songs for Top Hits & Top Songs for Top Artists in parallel
      final relatedSongsFutures = topSongs.map((stat) async {
        try {
          if (stat.songId.startsWith('youtube')) {
            final ytId = stat.songId.replaceAll('youtube', '');
            final related = await _ytMusic.getRelatedSongs(ytId);
            return ytmMapList2MediaItemList(related);
          } else {
            final related = await _saavnAPI.getRelated(stat.songId);
            if (related['songs'] != null) {
              return fromSaavnSongMapList2MediaItemList(related['songs']);
            }
          }
        } catch (e) {
          log('Error fetching related for ${stat.songTitle}: $e');
        }
        return <MediaItem>[];
      });

      final artistTracksFutures = topArtists.map((stat) async {
        try {
          final results = await _saavnAPI.fetchSongSearchResults(searchQuery: stat.artistName, count: 10);
          if (results['songs'] != null) {
            return fromSaavnSongMapList2MediaItemList(results['songs']);
          }
        } catch (e) {
          log('Error fetching artist songs for ${stat.artistName}: $e');
        }
        return <MediaItem>[];
      });

      // Wait for all requests to complete
      final allResults = await Future.wait([...relatedSongsFutures, ...artistTracksFutures]);
      for (var result in allResults) {
        allRecommendations.addAll(result);
      }

      // 4. Fallback/Fill: Trending Smart Hits
      if (allRecommendations.length < limit) {
         final trending = await _trendingService.getSmartTrendingSongs("Hindi");
         allRecommendations.addAll(ytmMapList2MediaItemList(trending));
      }

      // 5. Filter & Shuffle
      var filtered = allRecommendations.where((item) {
        if (seenIds.contains(item.id)) return false;
        if (seenIds.contains(item.id.replaceAll('youtube', ''))) return false;
        seenIds.add(item.id);
        return true;
      }).toList();

      filtered.shuffle();
      return filtered.take(limit).toList();

    } catch (e) {
      log('Critical Error in RecommendationService: $e');
      return [];
    }
  }
}
