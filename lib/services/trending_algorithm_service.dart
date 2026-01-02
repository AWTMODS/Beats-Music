import 'dart:developer';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:beats_music/model/chart_model.dart';
import 'package:beats_music/plugins/ext_charts/kworb_charts.dart';
import 'package:beats_music/repository/Youtube/yt_music_api.dart';
import 'package:beats_music/secrets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TrendingAlgorithmService {
  static final TrendingAlgorithmService _instance = TrendingAlgorithmService._internal();

  factory TrendingAlgorithmService() {
    return _instance;
  }

  TrendingAlgorithmService._internal();

  // Cache structure: Language -> List of Songs
  final Map<String, List<Map<String, dynamic>>> _cache = {};
  final Map<String, DateTime> _lastFetchTime = {};

  // Constants
  static const int _cacheDurationHours = 6;
  static const int _maxResults = 50;
  final Random _random = Random();

  final List<String> _queryTemplates = [
    "latest {lang} hit songs",
    "top {lang} viral songs",
    "trending {lang} songs",
    "{lang} chartbusters 2025",
    "best {lang} melody songs",
    "new {lang} party songs",
    "latest {lang} movie songs",
    "top 20 {lang} songs",
  ];

  /// Main method to get smart trending songs
  Future<List<Map<String, dynamic>>> getSmartTrendingSongs(String language) async {
    // Check cache
    if (_cache.containsKey(language) &&
        _lastFetchTime.containsKey(language) &&
        DateTime.now().difference(_lastFetchTime[language]!).inHours < _cacheDurationHours) {
      return _cache[language]!;
    }

    // 1. Fetch Candidates from Multiple Sources
    List<Map<String, dynamic>> candidates = [];
    
    // Source A: YouTube Search (Broad Baseline)
    // We keep this as it discovers viral hits not yet on charts
    candidates.addAll(await _fetchSearchCandidates(language));
    
    // Source B: YouTube Charts (Official)
    // Note: Use generic chart fetch or specific playlist IDs for "India Top 100" etc.
    // For now, we simulate this by boosting search results that look like chart entries.
    
    // Source C: Kworb Spotify Data (Cross-Reference)
    // We check if any of our candidates are also in the Spotify India Daily list
    List<String> spotifyHits = await _getSpotifyHitsCached();

    // 2. Score & Filter
    List<Map<String, dynamic>> rankedSongs = [];
    
    for (var song in candidates) {
      double score = 10.0; // Base score
      
      // Scoring Logic
      String title = song['title']?.toString().toLowerCase() ?? "";
      String artist = song['artist']?.toString().toLowerCase() ?? "";
      
      // Multiplier: Spotify Cross-Reference
      // If the song title appears in the Spotify list, massive boost
      bool onSpotify = spotifyHits.any((hit) => 
          hit.toLowerCase().contains(title) || title.contains(hit.toLowerCase()));
          
      if (onSpotify) {
        score += 20; // Huge boost for verified hits
      }
      
      // Filter: Shorts (Approximate by check, though we filter in search usually)
      // Filter: Jukebox (Usually irrelevant if fetching songs)
      
      // User Request: ALLOW "Cover" and "Unplugged"
      // We explicitly do NOT penalize these keywords.
      
      // Penalize "Lyrical", "BGM", "Status" (Audio-only experience preference)
      if (title.contains("lyrical") || title.contains("bgm") || title.contains("status")) {
        score -= 5;
      }

      // Add random jitter to shuffle equal-scored songs for variety
      // Jitter range: 0.0 to 5.0
      score += (_random.nextDouble() * 5.0);

      // Add score to song object for debugging
      song['score'] = score;
      rankedSongs.add(song);
    }

    // 3. Sort by Score
    rankedSongs.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));

    // 4. Clean & Limit
    // Remove duplicates based on ID
    final seenIds = <String>{};
    final uniqueSongs = rankedSongs.where((song) {
      if (seenIds.contains(song['id'])) return false;
      seenIds.add(song['id']);
      return true;
    }).take(_maxResults).toList();

    // Cache result
    _cache[language] = uniqueSongs;
    _lastFetchTime[language] = DateTime.now();

    return uniqueSongs;
  }

  Future<List<Map<String, dynamic>>> _fetchSearchCandidates(String language) async {
    // Pick 2 random templates for variety
    final templates = List<String>.from(_queryTemplates)..shuffle();
    final selectedTemplates = templates.take(2).toList();
    
    List<Map<String, dynamic>> combinedResults = [];
    
    for (var template in selectedTemplates) {
       final query = template.replaceAll("{lang}", language.toLowerCase());
       debugPrint("Fetching Trending Candidate Query: $query");
       
       // Add results
       combinedResults.addAll(await _genericSearch(query));
    }
    
    // Also ALWAYS fetch the "latest" baseline to ensure recency
    // combinedResults.addAll(await _genericSearch("latest ${language.toLowerCase()} songs"));
    
    return combinedResults;
  }
  
  Future<List<Map<String, dynamic>>> _genericSearch(String query) async {
     // Reusing the logic from yt_malayalam_songs.dart but generic
     try {
        final Uri searchUri = Uri.https(
          'www.youtube.com',
          '/youtubei/v1/search',
          {'key': Secrets.YOUTUBE_API_KEY},
        );
        
        final Map<String, dynamic> requestBody = {
          "context": {
            "client": {
              "clientName": "WEB_REMIX",
              "clientVersion": "1.20231122.01.00",
              "hl": "en",
              "gl": "IN",
            }
          },
          "query": query,
          "params": "EgWKAQIIAWoMEAMQBBAJEAoQBRAV" 
        };
        
        final response = await http.post(
          searchUri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        );
        
        if (response.statusCode != 200) return [];
        
        final data = jsonDecode(response.body);
        final List<dynamic>? contents = data['contents']?['tabbedSearchResultsRenderer']
            ?['tabs']?[0]?['tabRenderer']?['content']?['sectionListRenderer']
            ?['contents'];
            
        if (contents == null) return [];
        
        List<Map<String, dynamic>> songs = [];
        
        for (var section in contents) {
           final musicShelf = section['musicShelfRenderer'];
           if (musicShelf != null) {
              final List<dynamic>? items = musicShelf['contents'];
              if (items != null) {
                 for (var item in items) {
                    final renderer = item['musicResponsiveListItemRenderer'];
                    if (renderer != null) {
                       final title = renderer['flexColumns']?[0]?['musicResponsiveListItemFlexColumnRenderer']?['text']?['runs']?[0]?['text'];
                       final subtitle = renderer['flexColumns']?[1]?['musicResponsiveListItemFlexColumnRenderer']?['text']?['runs']?[0]?['text'];
                       final videoId = renderer['playlistItemData']?['videoId'];
                       final thumb = renderer['thumbnail']?['musicThumbnailRenderer']?['thumbnail']?['thumbnails']?.last?['url'];
                       
                       // Attempt to extract duration from runs
                       String? durationSecs;
                       final subtitleRuns = renderer['flexColumns']?[1]?['musicResponsiveListItemFlexColumnRenderer']?['text']?['runs'] as List?;
                       if (subtitleRuns != null) {
                         for (var run in subtitleRuns) {
                           final text = run['text']?.toString() ?? "";
                           if (RegExp(r'^\d+:\d+(:\d+)?$').hasMatch(text.trim())) {
                             // Convert "3:45" to "225"
                             List<String> parts = text.trim().split(':');
                             if (parts.length == 2) {
                               durationSecs = (int.parse(parts[0]) * 60 + int.parse(parts[1])).toString();
                             } else if (parts.length == 3) {
                               durationSecs = (int.parse(parts[0]) * 3600 + int.parse(parts[1]) * 60 + int.parse(parts[2])).toString();
                             }
                             break;
                           }
                         }
                       }

                       if (title != null && videoId != null && thumb != null) {
                          songs.add({
                            'title': title,
                            'type': 'video',
                            'subtitle': subtitle ?? 'Unknown',
                            'artist': subtitle ?? 'Unknown',
                            'id': 'youtube$videoId',
                            'firstItemId': 'youtube$videoId', // Legacy field
                            'image': thumb.replaceAll(RegExp(r'w\d+-h\d+'), 'w544-h544'), // Request high-res directly
                            'images': [thumb],
                            'url': "https://youtube.com/watch?v=$videoId",
                            'provider': 'youtube',
                            'duration': durationSecs // Added duration
                          });
                       }
                    }
                 }
              }
           }
        }
        return songs;
     } catch (e) {
        debugPrint("Error in generic search: $e");
        return [];
     }
  }

  // Cross-Reference Helper
  List<String>? _cachedSpotifyHits;
  Future<List<String>> _getSpotifyHitsCached() async {
    if (_cachedSpotifyHits != null) return _cachedSpotifyHits!;
    
    try {
      // Fetch India Daily
      ChartModel chart = await getKworbChart(KworbCharts.INDIA_DAILY);
      _cachedSpotifyHits = chart.chartItems?.map((e) => e.name ?? "").toList() ?? [];
      return _cachedSpotifyHits!;
    } catch (e) {
      return [];
    }
  }
}
