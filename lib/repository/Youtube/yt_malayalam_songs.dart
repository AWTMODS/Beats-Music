import 'dart:developer' as dev;
import 'package:beats_music/services/trending_algorithm_service.dart';

/// Fetches trending Malayalam songs using Smart Algorithm
Future<List<Map<String, dynamic>>> fetchMalayalamSongs() async {
  try {
    dev.log('Fetching Smart Trending Malayalam Songs...', name: 'MalayalamSongs');
    return await TrendingAlgorithmService().getSmartTrendingSongs("Malayalam");
  } catch (e) {
    dev.log('Error in fetchMalayalamSongs: $e', name: 'MalayalamSongs');
    return [];
  }
}
