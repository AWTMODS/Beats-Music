import 'package:beats_music/core/models/exported.dart';
import 'package:beats_music/services/db/db_provider.dart';
import 'package:beats_music/services/db/dao/playlist_dao.dart';
import 'package:beats_music/services/db/dao/track_dao.dart';
import 'package:beats_music/services/db/dao/history_dao.dart';
import 'package:beats_music/services/db/global_db.dart';
import 'package:isar_community/isar.dart';


class SyncAdapter {
  static final TrackDAO _trackDAO = TrackDAO(DBProvider.db);
  static final PlaylistDAO _playlistDAO = PlaylistDAO(DBProvider.db, _trackDAO);
  static final HistoryDAO _historyDAO = HistoryDAO(DBProvider.db, _trackDAO);

  /// Export user-created playlists for cloud sync
  static Future<List<Map<String, dynamic>>> exportUserPlaylists() async {
    final playlists = await _playlistDAO.getAllPlaylists();
    List<Map<String, dynamic>> exportData = [];

    for (var playlist in playlists) {
      if (DBProvider.standardPlaylists.contains(playlist.name)) continue;

      final tracks = await _playlistDAO.getPlaylistTracks(playlist.id);
      final songs = tracks.map((song) => {
        'mediaID': song.mediaId,
        'title': song.title,
        'artist': song.artists?.firstOrNull?.name ?? '',
        'album': song.album?.name ?? '',
        'artURL': song.thumbnail?.url ?? '',
        'genre': song.genre,
        'duration': song.durationMs,
        'source': song.mediaId.split('::').first,
      }).toList();

      exportData.add({
        'playlistName': playlist.name,
        'lastUpdated': playlist.updatedAt.millisecondsSinceEpoch,
        'artURL': playlist.thumbnail?.url,
        'description': playlist.description,
        'subtitle': playlist.subtitle,
        'songs': songs,
      });
    }
    return exportData;
  }

  /// Import playlists from cloud sync data
  static Future<void> importPlaylists(List<Map<String, dynamic>> playlistsData) async {
    for (var data in playlistsData) {
      final name = (data['playlistName'] ?? data['name'] ?? data['title'])?.toString();
      if (name == null || name.trim().isEmpty) continue;
      if (DBProvider.standardPlaylists.contains(name)) continue;

      final playlistId = await _playlistDAO.createPlaylist(
        name,
        thumbnail: data['artURL'] != null ? (ArtworkDB()..url = data['artURL'].toString()) : null,
        description: data['description']?.toString(),
        subtitle: data['subtitle']?.toString(),
      );

      if (playlistId != null) {
        final songs = (data['songs'] ?? data['tracks']) as List<dynamic>? ?? [];
        List<Track> tracks = songs.whereType<Map>().map((s) {
          final sMap = Map<String, dynamic>.from(s);
          final rawId = (sMap['mediaID'] ?? sMap['mediaId'] ?? sMap['id'] ?? sMap['songId'])?.toString() ?? '';
          return Track(
            id: _upgradeLegacyMediaId(rawId) ?? rawId,
            title: (sMap['title'] ?? sMap['songTitle'] ?? '')?.toString() ?? '',
            artists: [
               ArtistSummary(
                id: 'unknown',
                name: (sMap['artist'] ?? sMap['artistName'] ?? 'Unknown Artist')?.toString() ?? 'Unknown Artist',
              )
            ],
            album: sMap['album'] != null ? AlbumSummary(id: 'unknown', title: sMap['album'].toString(), artists: []) : null,
            thumbnail: Artwork(url: (sMap['artURL'] ?? sMap['thumbnailUrl'] ?? '')?.toString() ?? '', layout: ImageLayout.square),
            isExplicit: false,
            url: (sMap['streamingURL'] ?? sMap['permaURL'] ?? sMap['url'])?.toString(),
            durationMs: sMap['duration'] != null ? BigInt.tryParse(sMap['duration'].toString()) : null,
          );
        }).toList();

        await _playlistDAO.addTracksToPlaylist(playlistId, tracks);
      }
    }
  }

  /// Export Liked Songs
  static Future<List<Map<String, dynamic>>> exportLikedSongs() async {
    final likedPlaylist = await _playlistDAO.getPlaylistByName(DBProvider.likedPlaylist);
    if (likedPlaylist == null) return [];

    final tracks = await _playlistDAO.getPlaylistTracks(likedPlaylist.id);
    return tracks.map((song) => {
      'mediaID': song.mediaId,
      'title': song.title,
      'artist': song.artists?.firstOrNull?.name ?? '',
      'album': song.album?.name ?? '',
      'artURL': song.thumbnail?.url ?? '',
      'source': song.mediaId.split('::').first,
    }).toList();
  }

  /// Import Liked Songs
  static Future<void> importLikedSongs(List<Map<String, dynamic>> likedSongs) async {
    for (var s in likedSongs) {
      final rawId = (s['mediaID'] ?? s['mediaId'] ?? s['id'] ?? s['songId'])?.toString() ?? '';
      if (rawId.isEmpty) continue;
      final track = Track(
        id: _upgradeLegacyMediaId(rawId) ?? rawId,
        title: (s['title'] ?? s['songTitle'] ?? '')?.toString() ?? '',
        artists: [
          ArtistSummary(
            id: 'unknown',
            name: (s['artist'] ?? s['artistName'] ?? 'Unknown Artist')?.toString() ?? 'Unknown Artist',
          )
        ],
        thumbnail: Artwork(url: (s['artURL'] ?? s['thumbnailUrl'] ?? '')?.toString() ?? '', layout: ImageLayout.square),
        isExplicit: false,
        url: (s['permaURL'] ?? s['streamingURL'] ?? s['url'])?.toString(),
      );
      await _playlistDAO.setTrackLiked(track, true);
    }
  }

  /// Export Recently Played
  static Future<List<Map<String, dynamic>>> exportRecentlyPlayed() async {
    final history = await _historyDAO.getRawHistory(limit: 50);
    return history.map((h) => {
      'mediaID': h.track.value?.mediaId,
      'title': h.track.value?.title,
      'artist': h.track.value?.artists?.firstOrNull?.name ?? '',
      'album': h.track.value?.album?.name ?? '',
      'artURL': h.track.value?.thumbnail?.url ?? '',
      'lastPlayed': h.playedAt.millisecondsSinceEpoch,
    }).toList();
  }

  /// Import Recently Played
  static Future<void> importRecentlyPlayed(List<Map<String, dynamic>> recentlyPlayedData) async {
    for (var data in recentlyPlayedData) {
      final rawId = (data['mediaID'] ?? data['mediaId'] ?? data['id'] ?? data['songId'])?.toString() ?? '';
      if (rawId.isEmpty) continue;
      final track = Track(
        id: _upgradeLegacyMediaId(rawId) ?? rawId,
        title: (data['title'] ?? data['songTitle'] ?? '')?.toString() ?? '',
        artists: [
          ArtistSummary(
            id: 'unknown',
            name: (data['artist'] ?? data['artistName'] ?? 'Unknown Artist')?.toString() ?? 'Unknown Artist',
          )
        ],
        thumbnail: Artwork(url: (data['artURL'] ?? data['thumbnailUrl'] ?? '')?.toString() ?? '', layout: ImageLayout.square),
        isExplicit: false,
      );
      await _historyDAO.recordPlay(track);
      // Note: We can't easily set the exact 'playedAt' time with the current DAO recordPlay method
      // but this is a close approximation.
    }
  }

  /// Export Downloads List
  static Future<List<Map<String, dynamic>>> exportDownloadsList() async {
    final isar = await DBProvider.db;
    final downloads = await isar.downloadDBs.where().findAll();
    return downloads.map((d) => {
      'mediaId': d.mediaId,
      'fileName': d.fileName,
      'lastDownloaded': d.lastDownloaded?.millisecondsSinceEpoch,
    }).toList();
  }

  /// Import Downloads List
  static Future<void> importDownloadsList(List<Map<String, dynamic>> downloadsData) async {
    // metadata only
    _pendingRestorableDownloads = downloadsData;
  }

  static List<Map<String, dynamic>> _pendingRestorableDownloads = [];
  static List<Map<String, dynamic>> getPendingRestorableDownloads() => List.from(_pendingRestorableDownloads);
  static void clearPendingRestorableDownloads() => _pendingRestorableDownloads.clear();

  /// Helper to convert legacy plugin IDs from cloud backups into the new structure.
  static String? _upgradeLegacyMediaId(dynamic rawId) {
    if (rawId == null) return null;
    String idStr = rawId.toString();
    if (idStr.startsWith('youtube::')) {
      return idStr.replaceFirst('youtube::', 'bex-ytmusic::');
    } else if (idStr.startsWith('saavn::')) {
      return idStr.replaceFirst('saavn::', 'bex-jiosaavn::');
    } else if (idStr.startsWith('spotify::')) {
      return idStr.replaceFirst('spotify::', 'bex-spotify::');
    }
    return idStr;
  }
}
