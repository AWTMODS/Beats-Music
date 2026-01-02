import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class BeatsCacheManager {
  static const key = 'beatsMusicCacheData';

  static CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 7), // Keep images for 7 days
      maxNrOfCacheObjects: 200, // Max 200 images, then delete old ones
      repo: JsonCacheInfoRepository(databaseName: key), 
    ),
  );
}
