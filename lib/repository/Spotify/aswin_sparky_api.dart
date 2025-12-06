import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

/// Aswin Sparky API wrapper for Spotify downloads
/// No authentication required
class AswinSparkyAPI {
  static const String baseUrl = 'https://api-aswin-sparky.koyeb.app/api';
  
  static const Map<String, String> headers = {
    'Accept': 'application/json',
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
  };

  /// Get track details and download URL from Spotify URL
  Future<Map?> getTrackFromUrl(String spotifyUrl) async {
    log('[AswinSparky] Fetching track from URL: $spotifyUrl', name: 'AswinSparkyAPI');
    
    try {
      final url = Uri.parse('$baseUrl/downloader/spotify?url=$spotifyUrl');
      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == true && data['data'] != null) {
          log('[AswinSparky] ✓ Track fetched: ${data['data']['title']}', name: 'AswinSparkyAPI');
          return data['data'];
        } else {
          log('[AswinSparky] ⚠️ Invalid response format', name: 'AswinSparkyAPI');
          return null;
        }
      } else {
        log('[AswinSparky] ⚠️ HTTP ${response.statusCode}: ${response.body}', name: 'AswinSparkyAPI');
        return null;
      }
    } catch (e) {
      log('[AswinSparky] ⚠️ Error fetching track: $e', name: 'AswinSparkyAPI');
      return null;
    }
  }

  /// Get track details from Spotify track ID
  Future<Map?> getTrackFromId(String trackId) async {
    final url = 'https://open.spotify.com/track/$trackId';
    return await getTrackFromUrl(url);
  }

  /// Search for tracks on Spotify
  /// Returns a list of search results with track details
  Future<List<Map>> searchSpotify(String query) async {
    log('[AswinSparky] Searching for: $query', name: 'AswinSparkyAPI');
    
    try {
      final url = Uri.parse('$baseUrl/search/spotify?search=${Uri.encodeComponent(query)}');
      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == true && data['data'] != null && data['data'] is List) {
          final results = (data['data'] as List).cast<Map>();
          log('[AswinSparky] ✓ Found ${results.length} results', name: 'AswinSparkyAPI');
          return results;
        } else {
          log('[AswinSparky] ⚠️ No results found', name: 'AswinSparkyAPI');
          return [];
        }
      } else {
        log('[AswinSparky] ⚠️ Search failed with HTTP ${response.statusCode}', name: 'AswinSparkyAPI');
        return [];
      }
    } catch (e) {
      log('[AswinSparky] ⚠️ Error searching: $e', name: 'AswinSparkyAPI');
      return [];
    }
  }

  /// Search and get audio URL for first result
  /// Convenience method that combines search + download
  Future<String?> getSpotifyAudio(String query) async {
    try {
      // 1. Search for the track
      final searchResults = await searchSpotify(query);
      
      if (searchResults.isEmpty) {
        log('[AswinSparky] No search results found', name: 'AswinSparkyAPI');
        return null;
      }

      // 2. Get first result's link
      final firstResult = searchResults[0];
      final spotifyLink = firstResult['link'];
      
      if (spotifyLink == null) {
        log('[AswinSparky] No link in search result', name: 'AswinSparkyAPI');
        return null;
      }

      // 3. Get download URL
      final trackData = await getTrackFromUrl(spotifyLink);
      
      if (trackData == null || trackData['download'] == null) {
        log('[AswinSparky] No download URL found', name: 'AswinSparkyAPI');
        return null;
      }

      return trackData['download'];
    } catch (e) {
      log('[AswinSparky] Error in getSpotifyAudio: $e', name: 'AswinSparkyAPI');
      return null;
    }
  }

  /// Format Aswin Sparky track data to app's MediaItem format
  Map<String, dynamic> formatTrack(Map trackData, {String? spotifyUrl}) {
    // Extract track ID from download URL or use title+artist as fallback
    String trackId = 'spotify_${trackData['title']}_${trackData['artist']}'
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^\w_]'), '');
    
    return {
      'id': trackId,
      'title': trackData['title'] ?? 'Unknown Title',
      'artist': trackData['artist'] ?? 'Unknown Artist',
      'album': trackData['album'] ?? trackData['artist'] ?? 'Unknown Album',
      'image': trackData['cover'] ?? '',
      'url': trackData['download'] ?? '',
      'duration': trackData['duration']?.toString() ?? '0',
      'language': 'Spotify',
      'genre': 'Spotify',
      'has_lyrics': 'false',
      '320kbps': 'true',
      'perma_url': spotifyUrl ?? '',
      'subtitle': trackData['artist'] ?? '',
      'provider': 'spotify_aswin',
      'year': '',
      'release_date': '',
    };
  }
}
