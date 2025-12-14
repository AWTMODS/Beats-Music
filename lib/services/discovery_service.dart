import 'dart:async';
import 'dart:math';
import 'package:audio_service/audio_service.dart';
import 'package:beats_music/model/statistics/song_statistics.dart';
import 'package:beats_music/model/statistics/artist_statistics.dart';
import 'package:beats_music/services/listening_statistics_service.dart';
import 'package:beats_music/repository/Youtube/ytm/ytmusic.dart';
import 'package:beats_music/model/songModel.dart';
import 'package:beats_music/model/yt_music_model.dart';
import 'package:flutter/foundation.dart';

/// Service to generate personalized playlists and recommendations
class DiscoveryService {
  // Singleton pattern
  static final DiscoveryService _instance = DiscoveryService._internal();
  factory DiscoveryService() => _instance;
  DiscoveryService._internal();
  
  final _statisticsService = ListeningStatisticsService();
  final _ytMusic = YTMusic();
  
  DateTime? _lastDailyMixGeneration;
  DateTime? _lastDiscoverWeeklyGeneration;
  List<List<MediaItemModel>>? _cachedDailyMixes;
  List<MediaItemModel>? _cachedDiscoverWeekly;
  
  /// Generate Daily Mix playlists (3-5 mixes based on listening habits)
  Future<List<List<MediaItemModel>>> generateDailyMixes({bool forceRefresh = false}) async {
    try {
      // Check if we need to regenerate (once per day)
      if (!forceRefresh && 
          _cachedDailyMixes != null && 
          _lastDailyMixGeneration != null &&
          DateTime.now().difference(_lastDailyMixGeneration!).inHours < 24) {
        debugPrint('Discovery: Using cached Daily Mixes');
        return _cachedDailyMixes!;
      }
      
      debugPrint('Discovery: Generating new Daily Mixes...');
      
      // Get top artists and genres
      final topArtists = await _statisticsService.getTopArtists(limit: 10);
      final topGenres = await _statisticsService.getTopGenres(limit: 5);
      
      if (topArtists.isEmpty) {
        debugPrint('Discovery: No listening history yet, cannot generate Daily Mixes');
        return [];
      }
      
      final dailyMixes = <List<MediaItemModel>>[];
      
      // Generate mixes based on top artists (up to 3 artist-based mixes)
      for (int i = 0; i < min(3, topArtists.length); i++) {
        final artist = topArtists[i];
        final mix = await _generateArtistMix(artist.artistName, mixNumber: i + 1);
        if (mix.isNotEmpty) {
          dailyMixes.add(mix);
        }
      }
      
      // Generate genre-based mix if we have genre data
      if (topGenres.isNotEmpty) {
        final topGenre = topGenres.keys.first;
        final genreMix = await _generateGenreMix(topGenre);
        if (genreMix.isNotEmpty) {
          dailyMixes.add(genreMix);
        }
      }
      
      _cachedDailyMixes = dailyMixes;
      _lastDailyMixGeneration = DateTime.now();
      
      debugPrint('Discovery: Generated ${dailyMixes.length} Daily Mixes');
      return dailyMixes;
    } catch (e) {
      debugPrint('Error generating Daily Mixes: $e');
      return [];
    }
  }
  
  /// Generate artist-based mix
  Future<List<MediaItemModel>> _generateArtistMix(String artistName, {required int mixNumber}) async {
    try {
      // Search for songs by this artist
      final searchResultMap = await _ytMusic.searchYtm(artistName, type: 'songs');
      
      if (searchResultMap == null || searchResultMap['songs'] == null) {
        return [];
      }
      
      final List searchResults = searchResultMap['songs'];
      
      if (searchResults.isEmpty) {
        return [];
      }
      
      // Convert Map list to MediaItemModel list
      final mediaItems = ytmMapList2MediaItemList(searchResults);
      
      // Take up to 25 songs
      final mixSongs = mediaItems.take(25).toList();
      
      debugPrint('Discovery: Generated Daily Mix #$mixNumber for $artistName (${mixSongs.length} songs)');
      return mixSongs;
    } catch (e) {
      debugPrint('Error generating artist mix for $artistName: $e');
      return [];
    }
  }
  
  /// Generate genre-based mix
  Future<List<MediaItemModel>> _generateGenreMix(String genre) async {
    try {
      // Search for songs in this genre
      final searchResultMap = await _ytMusic.searchYtm('$genre music', type: 'songs');

      if (searchResultMap == null || searchResultMap['songs'] == null) {
        return [];
      }

      final List searchResults = searchResultMap['songs'];
      
      if (searchResults.isEmpty) {
        return [];
      }
      
       // Convert Map list to MediaItemModel list
      final mediaItems = ytmMapList2MediaItemList(searchResults);
      
      // Take up to 25 songs
      final mixSongs = mediaItems.take(25).toList();
      
      debugPrint('Discovery: Generated genre mix for $genre (${mixSongs.length} songs)');
      return mixSongs;
    } catch (e) {
      debugPrint('Error generating genre mix for $genre: $e');
      return [];
    }
  }
  
  /// Generate Song Radio (similar songs based on a specific track)
  Future<List<MediaItemModel>> generateSongRadio(MediaItemModel seed) async {
    try {
      debugPrint('Discovery: Generating Song Radio for "${seed.title}"');
      
      // Strategy 1: Search for artist's other songs
      final artistResultMap = await _ytMusic.searchYtm(
        '${seed.artist} songs',
        type: 'songs',
      );
      
      // Strategy 2: Search for similar songs by genre/style
      final similarResultMap = await _ytMusic.searchYtm(
        '${seed.title} ${seed.artist}',
        type: 'songs',
      );

      final List artistSongsList = artistResultMap?['songs'] ?? [];
      final List similarSongsList = similarResultMap?['songs'] ?? [];

      final artistSongs = ytmMapList2MediaItemList(artistSongsList);
      final similarSongs = ytmMapList2MediaItemList(similarSongsList);
      
      // Combine and deduplicate
      final radioSongs = <MediaItemModel>[];
      final seenIds = <String>{};
      
      // Add artist songs first
      for (var song in artistSongs) {
        if (!seenIds.contains(song.extras?['perma_url'] ?? song.id) && 
            (song.extras?['perma_url'] ?? song.id) != (seed.extras?['perma_url'] ?? seed.id)) {
          radioSongs.add(song);
          seenIds.add(song.extras?['perma_url'] ?? song.id);
        }
        if (radioSongs.length >= 25) break;
      }
      
      // Fill remaining with similar songs
      for (var song in similarSongs) {
        if (!seenIds.contains(song.extras?['perma_url'] ?? song.id) && 
            (song.extras?['perma_url'] ?? song.id) != (seed.extras?['perma_url'] ?? seed.id)) {
          radioSongs.add(song);
          seenIds.add(song.extras?['perma_url'] ?? song.id);
        }
        if (radioSongs.length >= 50) break;
      }
      
      debugPrint('Discovery: Generated Song Radio with ${radioSongs.length} songs');
      return radioSongs;
    } catch (e) {
      debugPrint('Error generating Song Radio: $e');
      return [];
    }
  }
  
  /// Generate Discover Weekly (new recommendations based on listening history)
  Future<List<MediaItemModel>> generateDiscoverWeekly({bool forceRefresh = false}) async {
    try {
      // Check if we need to regenerate (once per week)
      if (!forceRefresh && 
          _cachedDiscoverWeekly != null && 
          _lastDiscoverWeeklyGeneration != null &&
          DateTime.now().difference(_lastDiscoverWeeklyGeneration!).inDays < 7) {
        debugPrint('Discovery: Using cached Discover Weekly');
        return _cachedDiscoverWeekly!;
      }
      
      debugPrint('Discovery: Generating new Discover Weekly...');
      
      // Get top artists and genres
      final topArtists = await _statisticsService.getTopArtists(limit: 5);
      final topGenres = await _statisticsService.getTopGenres(limit: 3);
      
      if (topArtists.isEmpty) {
        debugPrint('Discovery: No listening history yet, cannot generate Discover Weekly');
        return [];
      }
      
      final discoveries = <MediaItemModel>[];
      final seenIds = <String>{};
      
      // Get played song IDs to exclude them
      final playedSongs = await _statisticsService.getTopSongs(limit: 100);
      final playedIds = playedSongs.map((s) => s.songId).toSet();
      
      // Search for new songs by top artists
      // Search for new songs by top artists
      for (var artist in topArtists.take(3)) {
        final artistResultMap = await _ytMusic.searchYtm(
          '${artist.artistName} new songs',
          type: 'songs',
        );
        final List artistSongsList = artistResultMap?['songs'] ?? [];
        final artistSongs = ytmMapList2MediaItemList(artistSongsList);
        
        for (var song in artistSongs) {
          if (!seenIds.contains(song.extras?['perma_url'] ?? song.id) && 
              !playedIds.contains(song.extras?['perma_url'] ?? song.id)) {
            discoveries.add(song);
            seenIds.add(song.extras?['perma_url'] ?? song.id);
          }
          if (discoveries.length >= 30) break;
        }
        if (discoveries.length >= 30) break;
      }
      
      // Add genre-based discoveries
      // Add genre-based discoveries
      for (var genre in topGenres.keys.take(2)) {
        final genreResultMap = await _ytMusic.searchYtm(
          '$genre new music',
          type: 'songs',
        );
        final List genreSongsList = genreResultMap?['songs'] ?? [];
        final genreSongs = ytmMapList2MediaItemList(genreSongsList);
        
        for (var song in genreSongs) {
          if (!seenIds.contains(song.extras?['perma_url'] ?? song.id) && 
              !playedIds.contains(song.extras?['perma_url'] ?? song.id)) {
            discoveries.add(song);
            seenIds.add(song.extras?['perma_url'] ?? song.id);
          }
          if (discoveries.length >= 50) break;
        }
        if (discoveries.length >= 50) break;
      }
      
      _cachedDiscoverWeekly = discoveries;
      _lastDiscoverWeeklyGeneration = DateTime.now();
      
      debugPrint('Discovery: Generated Discover Weekly with ${discoveries.length} songs');
      return discoveries;
    } catch (e) {
      debugPrint('Error generating Discover Weekly: $e');
      return [];
    }
  }
  
  /// Get Daily Mix title
  String getDailyMixTitle(int mixNumber, String? artistOrGenre) {
    if (artistOrGenre != null) {
      return 'Daily Mix $mixNumber: $artistOrGenre';
    }
    return 'Daily Mix $mixNumber';
  }
  
  /// Clear cached playlists (for testing or manual refresh)
  void clearCache() {
    _cachedDailyMixes = null;
    _cachedDiscoverWeekly = null;
    _lastDailyMixGeneration = null;
    _lastDiscoverWeeklyGeneration = null;
    debugPrint('Discovery: Cache cleared');
  }
  
  /// Check if Daily Mixes need refresh
  bool shouldRefreshDailyMixes() {
    if (_lastDailyMixGeneration == null) return true;
    return DateTime.now().difference(_lastDailyMixGeneration!).inHours >= 24;
  }
  
  /// Check if Discover Weekly needs refresh
  bool shouldRefreshDiscoverWeekly() {
    if (_lastDiscoverWeeklyGeneration == null) return true;
    return DateTime.now().difference(_lastDiscoverWeeklyGeneration!).inDays >= 7;
  }
}
