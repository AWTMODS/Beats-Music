bool isUrl(String url) {
  try {
    final uri = Uri.parse(url);
    return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
  } catch (e) {
    return false;
  }
}

/// Extracts a YouTube video ID from common YouTube URL formats:
/// - https://www.youtube.com/watch?v=VIDEO_ID
/// - https://youtu.be/VIDEO_ID
/// - https://www.youtube.com/shorts/VIDEO_ID
/// Returns null if [url] is not a recognisable YouTube video URL.
String? extractVideoId(String url) {
  try {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    final host = uri.host.toLowerCase();
    final isYouTube = host == 'youtube.com' ||
        host == 'www.youtube.com' ||
        host == 'm.youtube.com';
    final isShortLink = host == 'youtu.be';

    if (isYouTube) {
      // /watch?v=VIDEO_ID
      if (uri.pathSegments.contains('watch')) {
        final v = uri.queryParameters['v'];
        if (v != null && v.isNotEmpty) return v;
      }
      // /shorts/VIDEO_ID  or  /embed/VIDEO_ID
      if (uri.pathSegments.length >= 2 &&
          (uri.pathSegments[0] == 'shorts' ||
              uri.pathSegments[0] == 'embed')) {
        final id = uri.pathSegments[1];
        if (id.isNotEmpty) return id;
      }
    }

    if (isShortLink && uri.pathSegments.isNotEmpty) {
      final id = uri.pathSegments[0];
      if (id.isNotEmpty) return id;
    }
  } catch (_) {}
  return null;
}

