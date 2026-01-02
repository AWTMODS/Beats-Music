import 'songModel.dart';

MediaItemModel fromYtVidSongMap2MediaItem(Map<dynamic, dynamic> songItem) {
  
  // Get artUri: prioritize provided 'image' URL, fallback to YouTube template
  String? artUrl = songItem["image"]?.toString() ?? songItem["images"]?[0]?.toString();
  if (artUrl == null || artUrl.isEmpty) {
    final videoId = songItem["id"].toString().replaceAll("youtube", '');
    artUrl = "https://img.youtube.com/vi/$videoId/hqdefault.jpg";
  }

  // Handle duration safely (could be null, "null", string, or int)
  int durationSecs = 120;
  var rawDuration = songItem["duration"];
  if (rawDuration != null && rawDuration != "null") {
    if (rawDuration is int) {
      durationSecs = rawDuration;
    } else if (rawDuration is String) {
      durationSecs = int.tryParse(rawDuration) ?? 120;
    }
  }

  final model = MediaItemModel(
      id: songItem["id"] ?? 'Unknown',
      title: songItem["title"] ?? 'Unknown',
      album: songItem["album"] ?? 'Unknown',
      artist: songItem["artist"] ?? 'Unknown',
      artUri: Uri.parse(artUrl),
      genre: songItem["genre"] ?? 'Unknown',
      duration: Duration(seconds: durationSecs),
      extras: {
        "url": songItem["url"] ?? 'Unknown',
        "source": songItem["source"] ?? "youtube",
        "perma_url": songItem["perma_url"] ?? songItem["url"] ?? 'Unknown',
        "language": songItem["language"] ?? 'Unknown',
        "artistsID": songItem["album_id"]
      });
  return model;
}

List<MediaItemModel> fromYtVidSongMapList2MediaItemList(
    List<dynamic> songList) {
  List<MediaItemModel> mediaList = [];
  mediaList = songList
      .map((e) => fromYtVidSongMap2MediaItem(e as Map<dynamic, dynamic>))
      .toList();
  return mediaList;
}
