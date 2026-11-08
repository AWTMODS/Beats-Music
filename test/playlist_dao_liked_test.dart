import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:path/path.dart' as p;
import 'package:beats_music/core/models/exported.dart';
import 'package:beats_music/services/db/dao/playlist_dao.dart';
import 'package:beats_music/services/db/dao/track_dao.dart';
import 'package:beats_music/services/db/db_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PlaylistDAO Liked & Playlist Tests', () {
    late Directory tempRoot;
    late Directory supportDir;
    late Directory docsDir;
    late TrackDAO trackDao;
    late PlaylistDAO playlistDao;

    setUp(() async {
      tempRoot = await Directory.systemTemp.createTemp('beats_liked_test_');
      supportDir = Directory(p.join(tempRoot.path, 'support'))
        ..createSync(recursive: true);
      docsDir = Directory(p.join(tempRoot.path, 'docs'))
        ..createSync(recursive: true);

      await DBProvider.init(
        appSupportPath: supportDir.path,
        appDocumentsPath: docsDir.path,
      );
      await DBProvider.db;

      trackDao = TrackDAO(DBProvider.db);
      playlistDao = PlaylistDAO(DBProvider.db, trackDao);
    });

    tearDown(() async {
      final currentDb = await DBProvider.db;
      if (currentDb.isOpen) {
        await currentDb.close();
      }
      final defaultDb = Isar.getInstance('default');
      if (defaultDb != null && defaultDb.isOpen) {
        await defaultDb.close();
      }
      if (tempRoot.existsSync()) {
        tempRoot.deleteSync(recursive: true);
      }
    });

    final testTrack = Track(
      id: 'resolver::track-1',
      title: 'Amazing Song',
      album: const AlbumSummary(
        id: 'album-1',
        title: 'Hit Album',
        artists: [ArtistSummary(id: 'artist-1', name: 'Great Artist')],
      ),
      artists: const [ArtistSummary(id: 'artist-1', name: 'Great Artist')],
      durationMs: BigInt.from(200000),
      thumbnail: const Artwork(
        url: 'https://example.com/art.jpg',
        layout: ImageLayout.square,
      ),
      isExplicit: false,
    );

    test('Liking a song correctly adds it to Liked playlist and persists links', () async {
      // 1. Initial state: not liked
      expect(await playlistDao.isTrackLiked(testTrack.id), isFalse);

      // 2. Like the track
      await playlistDao.setTrackLiked(testTrack, true);

      // 3. Verify isTrackLiked returns true
      expect(await playlistDao.isTrackLiked(testTrack.id), isTrue);

      // 4. Verify Liked playlist contains the track
      final likedDb = await playlistDao.getPlaylistByName(PlaylistDAO.likedPlaylist);
      expect(likedDb, isNotNull);
      final tracks = await playlistDao.getPlaylistTracks(likedDb!.id);
      expect(tracks.length, equals(1));
      expect(tracks.first.mediaId, equals(testTrack.id));
      expect(tracks.first.title, equals(testTrack.title));

      // 5. Verify purging broken entries does NOT delete this valid entry
      final purged = await playlistDao.purgeBrokenPlaylistEntries();
      expect(purged, equals(0));

      final tracksAfterPurge = await playlistDao.getPlaylistTracks(likedDb.id);
      expect(tracksAfterPurge.length, equals(1));

      // 6. Unlike the track
      await playlistDao.setTrackLiked(testTrack, false);
      expect(await playlistDao.isTrackLiked(testTrack.id), isFalse);

      final tracksAfterUnlike = await playlistDao.getPlaylistTracks(likedDb.id);
      expect(tracksAfterUnlike.length, equals(0));
    });

    test('Adding a track to a custom user playlist persists links', () async {
      const playlistName = 'My Chill Mix';
      final playlistId = await playlistDao.createPlaylist(playlistName);
      expect(playlistId, isNotNull);

      // Add track
      final entryId = await playlistDao.addTrackToPlaylist(playlistId!, testTrack);
      expect(entryId, isNotNull);

      // Fetch tracks
      final tracks = await playlistDao.getPlaylistTracks(playlistId);
      expect(tracks.length, equals(1));
      expect(tracks.first.mediaId, equals(testTrack.id));
      expect(tracks.first.title, equals(testTrack.title));

      // Verify page fetching also loads the track link correctly
      final pagedTracks = await playlistDao.getPlaylistTracksPage(
        playlistId,
        offset: 0,
        limit: 10,
      );
      expect(pagedTracks.length, equals(1));
      expect(pagedTracks.first.mediaId, equals(testTrack.id));
    });
  });
}

