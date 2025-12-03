import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import 'dart:convert';

class SpotifyDownloaderAPI {
  static const String baseUrl = 'http://api-aswin-sparky.koyeb.app/api/downloader/spotify';
  
  /// Get direct download URL from Spotify track URL or ID
  static Future<Map<String, dynamic>?> getTrackInfo(String spotifyUrl) async {
    try {
      // Build the API URL
      final apiUrl = '$baseUrl?url=${Uri.encodeComponent(spotifyUrl)}';
      
      dev.log('Fetching Spotify track info: $apiUrl', name: 'SpotifyDownloaderAPI');
      
      // Make the request with timeout
      final response = await http.get(
        Uri.parse(apiUrl),
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('Spotify API timeout');
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == true && data['data'] != null) {
          dev.log('Successfully fetched Spotify track: ${data['data']['title']}', 
                  name: 'SpotifyDownloaderAPI');
          return {
            'title': data['data']['title'] ?? '',
            'artist': data['data']['artist'] ?? '',
            'cover': data['data']['cover'] ?? '',
            'download': data['data']['download'] ?? '',
          };
        } else {
          dev.log('Spotify API returned error: ${data['message'] ?? 'Unknown error'}', 
                  name: 'SpotifyDownloaderAPI');
          return null;
        }
      } else {
        dev.log('Spotify API HTTP error: ${response.statusCode}', 
                name: 'SpotifyDownloaderAPI');
        return null;
      }
    } catch (e) {
      dev.log('Spotify API error: $e', name: 'SpotifyDownloaderAPI');
      return null;
    }
  }
  
  /// Get direct download URL from Spotify track ID
  static Future<String?> getDirectDownloadUrl(String spotifyTrackId) async {
    try {
      final spotifyUrl = 'https://open.spotify.com/track/$spotifyTrackId';
      final trackInfo = await getTrackInfo(spotifyUrl);
      
      if (trackInfo != null && trackInfo['download'] != null) {
        return trackInfo['download'];
      }
      return null;
    } catch (e) {
      dev.log('Error getting Spotify download URL: $e', name: 'SpotifyDownloaderAPI');
      return null;
    }
  }
  
  /// Extract Spotify track ID from URL
  static String? extractTrackId(String url) {
    try {
      // Handle different Spotify URL formats
      // https://open.spotify.com/track/0JGTfiC4Z41GEEpMYLbWwO?si=...
      // spotify:track:0JGTfiC4Z41GEEpMYLbWwO
      
      if (url.contains('open.spotify.com/track/')) {
        final uri = Uri.parse(url);
        final pathSegments = uri.pathSegments;
        final trackIndex = pathSegments.indexOf('track');
        if (trackIndex != -1 && trackIndex + 1 < pathSegments.length) {
          return pathSegments[trackIndex + 1];
        }
      } else if (url.contains('spotify:track:')) {
        return url.split('spotify:track:').last;
      }
      
      // If it's already just an ID
      if (url.length == 22 && !url.contains('/') && !url.contains(':')) {
        return url;
      }
      
      return null;
    } catch (e) {
      dev.log('Error extracting Spotify track ID: $e', name: 'SpotifyDownloaderAPI');
      return null;
    }
  }
}
