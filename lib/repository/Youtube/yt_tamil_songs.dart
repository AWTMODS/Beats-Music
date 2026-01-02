import 'dart:developer' as dev;
import 'package:beats_music/services/trending_algorithm_service.dart';

/// Fetches trending Tamil songs using Smart Algorithm
Future<List<Map<String, dynamic>>> fetchTamilSongs() async {
  try {
    dev.log('Fetching Smart Trending Tamil Songs...', name: 'TamilSongs');
    return await TrendingAlgorithmService().getSmartTrendingSongs("Tamil");
  } catch (e) {
    dev.log('Error in fetchTamilSongs: $e', name: 'TamilSongs');
    return [];
  }
}
