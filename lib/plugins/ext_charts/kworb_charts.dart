import 'dart:developer';
import 'dart:convert';
import 'package:beats_music/secrets.dart';

import 'package:beats_music/model/chart_model.dart';
import 'package:beats_music/plugins/ext_charts/chart_defines.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:beats_music/repository/Youtube/yt_music_api.dart';

// Placeholder images for charts since Kworb doesn't provide them in the table
const List<String> kworbIMGs = [
  "https://upload.wikimedia.org/wikipedia/commons/thumb/1/19/Spotify_logo_without_text.svg/2048px-Spotify_logo_without_text.svg.png",
];
RandomIMGs kworbRandomIMGs = RandomIMGs(imgURLs: kworbIMGs);

class KworbChartLinks {
  static const String GLOBAL_DAILY = 'https://kworb.net/spotify/country/global_daily.html';
  static const String INDIA_DAILY = 'https://kworb.net/spotify/country/in_daily.html';
  static const String JAPAN_DAILY = 'https://kworb.net/spotify/country/jp_daily.html';
  static const String KOREA_DAILY = 'https://kworb.net/spotify/country/kr_daily.html';

  static const String GLOBAL_DAILY_IMG = "https://charts-images.scdn.co/assets/locale_en/regional/daily/region_global_default.jpg";
  static const String INDIA_DAILY_IMG = "https://charts-images.scdn.co/assets/locale_en/regional/daily/region_in_default.jpg";
  static const String JAPAN_DAILY_IMG = "https://charts-images.scdn.co/assets/locale_en/regional/daily/region_jp_default.jpg";
  static const String KOREA_DAILY_IMG = "https://charts-images.scdn.co/assets/locale_en/regional/daily/region_kr_default.jpg";
}

class KworbCharts {
  static final ChartURL GLOBAL_DAILY =
      ChartURL(title: "Spotify Global\nDaily", url: KworbChartLinks.GLOBAL_DAILY);
  static final ChartURL INDIA_DAILY =
      ChartURL(title: "Spotify India\nDaily", url: KworbChartLinks.INDIA_DAILY);
  static final ChartURL JAPAN_DAILY =
      ChartURL(title: "Spotify Japan\nDaily", url: KworbChartLinks.JAPAN_DAILY);
  static final ChartURL KOREA_DAILY =
      ChartURL(title: "Spotify Korea\nDaily", url: KworbChartLinks.KOREA_DAILY);
}

Future<ChartModel> getKworbChart(ChartURL url) async {
  var client = http.Client();
  try {
    var response = await client.get(Uri.parse(url.url), headers: {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
    });

    if (response.statusCode == 200) {
      var document = parse(response.body);
      var table = document.querySelector('table#spotify-daily-table');
      if (table == null) {
        // Fallback or error if table ID changes, but checking generic table inside container might be safer
        table = document.querySelector('table');
      }

      List<ChartItemModel> chartItems = [];
      
      if (table != null) {
        var rows = table.querySelectorAll('tbody tr');
        for (var row in rows) {
          var columns = row.querySelectorAll('td');
          if (columns.length >= 3) {
             // Column 0: Rank (usually)
             // Column 1: Artist and Title (in Kworb, it's often: <div>Artist</div><div><a href...>Title</a></div> or similiar)
             // Let's inspect based on the text content we saw earlier
             
             // Kworb structure for Spotify Daily:
             // Pos, Pos+, Artist, Title, Days, Peak, P+, Streams, Streams+
             // 0    1     2       3      4     5     6   7        8
             
             // Wait, looking at the chunk view earlier:
             // [Humdard (From "Ek Villain")](link)
             // [sufr](artist link)
             
             // In HTML:
             // <tr>
             //   <td class="text">1</td>
             //   <td class="text">...</td>
             //   <td class="text"><div><a href="artist...">Artist</a></div></td>
             //   <td class="text"><div><a href="track...">Title</a></div></td>
             // ...
             
             // Actually, usually Kworb is:
             // Rank | Artist | Title | ... 
             // But sometimes Artist and Title are swapped or combined.
             // Based on the "view_content_chunk" we saw:
             // Link to Track
             // Link to Artist
             // Link to Track ...
             
             // It seems column 0 is rank/pos.
             // Column 1 might be Artist.
             // Column 2 might be Title.
             
             // Let's rely on finding <a> tags.
             var links = row.querySelectorAll('a');
             String title = '';
             String artist = '';
             String imgURL = ''; // Kworb doesn't give images in the main table easily.
             
             for (var link in links) {
               var href = link.attributes['href'];
               if (href != null && href.contains('/artist/')) {
                 artist = link.text.trim();
               } else if (href != null && href.contains('/track/')) {
                 title = link.text.trim();
               }
             }
             
             // If we didn't find them via links (sometimes multiple artists), try columns
             if (title.isEmpty) {
                // assume column 1 is Artist and 2 is Title or vice versa.
                // Standard Kworb Spotify: Col 0 = Rank, Col 1 = Artist, Col 2 = Title
                if (columns.length > 2) {
                   if (artist.isEmpty) artist = columns[1].text.trim();
                   title = columns[2].text.trim();
                }
             }

             if (title.isNotEmpty) {
                // Use a generic music icon or fetch if we really wanted to (too slow).
                // Existing charts used lazy-load fallback which was often just a placeholder.
                // We will use a high quality placeholder from beats assets or network.
                // For now, empty string or a default one will be handled by UI using the generated color/icon.
                // But the UI expects an imageUrl.
                imgURL = "https://ui-avatars.com/api/?name=${Uri.encodeComponent(title)}&background=random&size=200";
                
                chartItems.add(ChartItemModel(name: title, imageUrl: imgURL, subtitle: artist));
             }
          }
        }
      }

      final chart = ChartModel(
          chartName: url.title,
          chartItems: chartItems,
          url: url.url,
          lastUpdated: DateTime.now());

      // Return immediately so UI shows the list
      // Enrichment will be handled by the Cubit progressively
      log('Kworb Charts: ${chart.chartItems!.length} tracks (Enrichment pending)', name: "Kworb");
      return chart;
    } else {
      throw Exception("Failed to load page: ${response.statusCode}");
    }
  } catch (e) {
    log('Error while getting data from:${url.url}', name: "Kworb");
    throw Exception("Error: $e");
  }
}

// Made public for external progressive calling
Future<void> enrichChartItems(List<ChartItemModel> items, {Function()? onUpdate}) async {
  try {
    // Process in batches to avoid rate limiting
    int batchSize = 12; // Increased to reduce UI rebuild frequency
    for (var i = 0; i < items.length; i += batchSize) {
      int end = (i + batchSize < items.length) ? i + batchSize : items.length;
      List<Future<void>> batch = [];
      
      for (var j = i; j < end; j++) {
        batch.add(_fetchMetadataSimple(items, j));
      }
      
      await Future.wait(batch);
      
      // Notify listener (Cubit) to update UI
      if (onUpdate != null) {
          onUpdate();
      }
      
      // Delay between batches to yield to UI thread
      await Future.delayed(const Duration(milliseconds: 100));
    }
  } catch (e) {
    log("Error enriching charts: $e", name: "KworbCharts");
  }
}

Future<void> _fetchMetadataSimple(List<ChartItemModel> items, int index) async {
  try {
    final item = items[index];
    
    // 1. Clean Query (Title + Artist)
    var cleanName = (item.name ?? "")
        .replaceAll(RegExp(r'\(From.*?\)', caseSensitive: false), '')
        .replaceAll(RegExp(r'\|.*'), '')
        .replaceAll(RegExp(r'\-.*'), '')
        .trim();
        
    if (cleanName.length < 3) cleanName = item.name ?? "";
    
    // Attempt 1: Title + Artist
    String query = "$cleanName ${item.subtitle ?? ""}";
    String? thumb = await _performYtmSearch(query);

    // Attempt 2: Title Only (Fallback)
    if (thumb == null) {
       thumb = await _performYtmSearch(cleanName);
    }

    if (thumb != null) {
      items[index] = ChartItemModel(
          name: item.name,
          subtitle: item.subtitle,
          imageUrl: thumb
      );
    }
  } catch (e) {
    log("Failed to fetch image for ${items[index].name}: $e", name: "KworbCharts");
  }
}

Future<String?> _performYtmSearch(String query) async {
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
          "gl": "US",
        }
      },
      "query": query,
      // Removed params to allow broader search (inc. "Top Result" card)
    };

    final response = await http.post(
      searchUri,
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      
      final List<dynamic>? contents = data['contents']?['tabbedSearchResultsRenderer']
          ?['tabs']?[0]?['tabRenderer']?['content']?['sectionListRenderer']
          ?['contents'];

      if (contents == null) return null;

      for (var section in contents) {
        // Check MusicShelf (Songs)
        final musicShelf = section['musicShelfRenderer'];
        if (musicShelf != null) {
             final List<dynamic>? shelfContents = musicShelf['contents'];
             if (shelfContents != null && shelfContents.isNotEmpty) {
                final item = shelfContents.first;
                final renderer = item['musicResponsiveListItemRenderer'];
                if (renderer != null) {
                   final thumb = renderer['thumbnail']?['musicThumbnailRenderer']?['thumbnail']?['thumbnails']?.last?['url'];
                   if (thumb != null) {
                      return (thumb as String).replaceAll(RegExp(r'w\d+-h\d+'), 'w544-h544');
                   }
                }
             }
        }
        
        // Check generic "Top Result" card (often has the best image)
        final cardShelf = section['musicCardShelfRenderer'];
        if (cardShelf != null) {
            final thumb = cardShelf['thumbnail']?['musicThumbnailRenderer']?['thumbnail']?['thumbnails']?.last?['url'];
             if (thumb != null) {
                return (thumb as String).replaceAll(RegExp(r'w\d+-h\d+'), 'w544-h544');
             }
        }
      }
    }
  } catch (e) {
    log("Search failed for '$query': $e", name: "KworbCharts");
  }
  return null;
}
