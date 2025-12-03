import 'dart:convert';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import 'ytmusic_format.dart';

/// Fetches trending Hindi songs from YouTube Music
/// Returns a list of formatted song items
Future<List<Map<String, dynamic>>> fetchHindiSongs() async {
  try {
    // YouTube Music search endpoint for Hindi trending songs
    final Uri searchUri = Uri.https(
      'www.youtube.com',
      '/youtubei/v1/search',
      {'key': 'AIzaSyC9XL3ZjWddXya6X74dJoCTL-WEYFDNX30'},
    );

    // Request body for Hindi trending songs search
    final Map<String, dynamic> requestBody = {
      "context": {
        "client": {
          "clientName": "WEB_REMIX",
          "clientVersion": "1.20231122.01.00",
          "hl": "en",
          "gl": "IN",
        }
      },
      "query": "now trending hindi songs",
      "params": "EgWKAQIIAWoMEAMQBBAJEAoQBRAV"  // Filter for songs
    };

    final response = await http.post(
      searchUri,
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode != 200) {
      dev.log('Failed to fetch Hindi songs: ${response.statusCode}',
          name: 'HindiSongs');
      return [];
    }

    final Map<String, dynamic> data = json.decode(response.body);
    
    // Extract music shelf renderer items
    final List<dynamic>? contents = data['contents']?['tabbedSearchResultsRenderer']
        ?['tabs']?[0]?['tabRenderer']?['content']?['sectionListRenderer']
        ?['contents'];

    if (contents == null || contents.isEmpty) {
      dev.log('No contents found in Hindi songs response', name: 'HindiSongs');
      return [];
    }

    List<Map<String, dynamic>> songs = [];

    for (var section in contents) {
      final musicShelf = section['musicShelfRenderer'];
      if (musicShelf == null) continue;

      final List<dynamic>? shelfContents = musicShelf['contents'];
      if (shelfContents == null) continue;

      for (var item in shelfContents) {
        try {
          final renderer = item['musicResponsiveListItemRenderer'];
          if (renderer == null) continue;

          // Extract title
          final String? title = renderer['flexColumns']?[0]
              ?['musicResponsiveListItemFlexColumnRenderer']
              ?['text']?['runs']?[0]?['text'];

          // Extract artist/subtitle
          final String? subtitle = renderer['flexColumns']?[1]
              ?['musicResponsiveListItemFlexColumnRenderer']
              ?['text']?['runs']?[0]?['text'];

          // Extract video ID
          final String? videoId = renderer['playlistItemData']?['videoId'] ??
              renderer['overlay']?['musicItemThumbnailOverlayRenderer']
                  ?['content']?['musicPlayButtonRenderer']
                  ?['playNavigationEndpoint']?['watchEndpoint']?['videoId'];

          // Extract thumbnail
          final String? thumbnail = renderer['thumbnail']
              ?['musicThumbnailRenderer']?['thumbnail']
              ?['thumbnails']?.last?['url'];

          if (title != null && videoId != null && thumbnail != null) {
            songs.add({
              'title': title,
              'type': 'video',
              'subtitle': subtitle ?? 'Unknown Artist',
              'artist': subtitle ?? 'Unknown Artist',
              'id': 'youtube$videoId',
              'firstItemId': 'youtube$videoId',
              'image': thumbnail,
              'images': [thumbnail],
              'isWide': true,
              'url': await getSongUrl('youtube$videoId'),
              'provider': 'youtube',
            });

            // Limit to 20 songs
            if (songs.length >= 20) break;
          }
        } catch (e) {
          dev.log('Error parsing Hindi song item: $e', name: 'HindiSongs');
          continue;
        }
      }

      if (songs.length >= 20) break;
    }

    dev.log('Fetched ${songs.length} Hindi songs', name: 'HindiSongs');
    return songs;
  } catch (e) {
    dev.log('Error in fetchHindiSongs: $e', name: 'HindiSongs');
    return [];
  }
}
