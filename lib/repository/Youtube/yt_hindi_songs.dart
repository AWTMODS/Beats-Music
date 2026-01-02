import 'dart:developer' as dev;
import 'package:beats_music/services/trending_algorithm_service.dart';

/// Fetches trending Hindi songs using Smart Algorithm
Future<List<Map<String, dynamic>>> fetchHindiSongs() async {
  try {
    dev.log('Fetching Smart Trending Hindi Songs...', name: 'HindiSongs');
    return await TrendingAlgorithmService().getSmartTrendingSongs("Hindi");
  } catch (e) {
    dev.log('Error in fetchHindiSongs: $e', name: 'HindiSongs');
    return [];
  }
}
