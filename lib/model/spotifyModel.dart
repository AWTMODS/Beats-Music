import 'package:beats_music/model/songModel.dart';

/// Convert Aswin Sparky Spotify track data to MediaItemModel
MediaItemModel fromSpotifyAswinMap2MediaItem(Map trackData, {String? spotifyUrl}) {
  // Extract track ID from download URL or use title+artist as fallback
  String trackId = 'spotify_${trackData['title']}_${trackData['artist']}'
      .replaceAll(' ', '_')
      .replaceAll(RegExp(r'[^\w_]'), '');

  return MediaItemModel(
    id: trackId,
    title: trackData['title'] ?? 'Unknown Title',
    artist: trackData['artist'] ?? 'Unknown Artist',
    album: trackData['album'] ?? trackData['artist'] ?? 'Unknown Album',
    artUri: Uri.parse(trackData['cover'] ?? ''),
    duration: Duration(seconds: int.tryParse(trackData['duration']?.toString() ?? '0') ?? 0),
    genre: 'Spotify',
    extras: {
      'url': trackData['download'] ?? '',
      'language': 'Spotify',
      'has_lyrics': 'false',
      '320kbps': 'true',
      'perma_url': spotifyUrl ?? '',
      'subtitle': trackData['artist'] ?? '',
      'source': 'spotify_aswin',
      'year': '',
      'release_date': '',
    },
  );
}

/// Convert list of Spotify tracks to MediaItemModel list
List<MediaItemModel> fromSpotifyAswinMapList2MediaItemList(List<Map> trackList) {
  return trackList
      .map((track) => fromSpotifyAswinMap2MediaItem(track))
      .toList();
}
