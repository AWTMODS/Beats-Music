import 'dart:developer';
import 'dart:io';

import 'package:beats_music/plugins/utils/media_id.dart';
import 'package:beats_music/services/db/dao/playlist_dao.dart';
import 'package:beats_music/services/db/dao/track_dao.dart';
import 'package:beats_music/services/db/global_db.dart';
import 'package:beats_music/src/rust/api/plugin/models.dart';
import 'package:isar_community/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// DAO for tracking downloaded media files — accepts domain [Track] models.
///
/// Each download record links a [DownloadDB] row (file path, time) to a
/// [TrackDB] entry and the "_DOWNLOADS" system playlist.
class DownloadDAO {
  final Future<Isar> _db;
  final TrackDAO _trackDAO;
  final PlaylistDAO _playlistDAO;
  final DownloadFileResolver _files;

  static const downloadsPlaylistName = '_DOWNLOADS';

  DownloadDAO(this._db, this._trackDAO, this._playlistDAO,
      {DownloadFileResolver? files})
      : _files = files ?? DownloadFileResolver();

  // -- Write ------------------------------------------------------------------

  /// Record a new download (or update an existing one for the same [mediaId]).
  ///
  /// Accepts a domain [Track] model. Upserts it into [TrackDB] and ensures
  /// it is added to the "_DOWNLOADS" system playlist. If a record with the
  /// same [mediaId] already exists its file path and timestamp are updated.
  Future<void> putDownload({
    required String fileName,
    required String filePath,
    required Track track,
    DateTime? lastDownloaded,
  }) async {
    final isar = await _db;
    lastDownloaded ??= DateTime.now();

    // Upsert track and ensure the downloads playlist exists.
    await _trackDAO.upsertTrack(track);
    final downloadsId =
        await _playlistDAO.ensurePlaylist(downloadsPlaylistName);
    await _playlistDAO.addTrackToPlaylist(downloadsId, track);

    // Upsert the DownloadDB row.
    final existing =
        await isar.downloadDBs.filter().mediaIdEqualTo(track.id).findFirst();

    await isar.writeTxn(() async {
      if (existing != null) {
        existing
          ..fileName = fileName
          ..filePath = filePath
          ..lastDownloaded = lastDownloaded;
        await isar.downloadDBs.put(existing);
        log('Updated download record for ${track.id}', name: 'DownloadDAO');
      } else {
        final record = DownloadDB(
          fileName: fileName,
          filePath: filePath,
          lastDownloaded: lastDownloaded,
          mediaId: track.id,
        );
        await isar.downloadDBs.put(record);
        log('Created download record for ${track.id}', name: 'DownloadDAO');
      }
    });
  }

  /// Remove the download record for [mediaId] and optionally delete the file.
  Future<void> removeDownload(String mediaId, {bool deleteFile = true}) async {
    final isar = await _db;
    final record =
        await isar.downloadDBs.filter().mediaIdEqualTo(mediaId).findFirst();

    if (record == null) return;

    await isar.writeTxn(() => isar.downloadDBs.delete(record.id));

    final downloadsPlaylist =
        await _playlistDAO.getPlaylistByName(downloadsPlaylistName);
    if (downloadsPlaylist != null) {
      await _playlistDAO.removeTrackFromPlaylist(downloadsPlaylist.id, mediaId);
    }

    if (deleteFile) {
      try {
        final file = File(p.join(record.filePath, record.fileName));
        if (file.existsSync()) {
          file.deleteSync();
          log('Deleted file: ${record.fileName}', name: 'DownloadDAO');
        }
      } catch (e) {
        log('Failed to delete file: ${record.fileName}',
            error: e, name: 'DownloadDAO');
      }
    }
  }

  /// Record a file mapping without touching any playlist (for local music).
  ///
  /// Unlike [putDownload], this only upserts [TrackDB] + [DownloadDB] rows.
  Future<void> putDownloadRecord({
    required String fileName,
    required String filePath,
    required Track track,
    DateTime? lastDownloaded,
  }) async {
    final isar = await _db;
    lastDownloaded ??= DateTime.now();

    await _trackDAO.upsertTrack(track);

    final existing =
        await isar.downloadDBs.filter().mediaIdEqualTo(track.id).findFirst();

    await isar.writeTxn(() async {
      if (existing != null) {
        existing
          ..fileName = fileName
          ..filePath = filePath
          ..lastDownloaded = lastDownloaded;
        await isar.downloadDBs.put(existing);
      } else {
        await isar.downloadDBs.put(DownloadDB(
          fileName: fileName,
          filePath: filePath,
          lastDownloaded: lastDownloaded,
          mediaId: track.id,
        ));
      }
    });
  }

  /// Remove a [DownloadDB] record without deleting the underlying file.
  Future<void> removeDownloadRecord(String mediaId) async {
    final isar = await _db;
    final record =
        await isar.downloadDBs.filter().mediaIdEqualTo(mediaId).findFirst();
    if (record == null) return;
    await isar.writeTxn(() => isar.downloadDBs.delete(record.id));
  }

  // -- Read -------------------------------------------------------------------

  /// Return the [DownloadDB] record for [mediaId], or null if not found or the
  /// file no longer exists on disk.
  Future<DownloadDB?> getDownloadRecord(String mediaId) async {
    final isar = await _db;
    final record =
        await isar.downloadDBs.filter().mediaIdEqualTo(mediaId).findFirst();
    if (record == null) return null;
    return _resolveRecord(isar, record);
  }

  Future<DownloadDB?> _resolveRecord(Isar isar, DownloadDB record) async {
    final resolved = await _files.resolve(record.filePath, record.fileName);
    if (resolved == null) return null;
    final directory = p.dirname(resolved);
    if (directory == record.filePath) return record;
    return isar.writeTxnSync(() {
      final current = isar.downloadDBs.getSync(record.id);
      if (current == null) return null;
      if (current.filePath != record.filePath ||
          current.fileName != record.fileName ||
          current.mediaId != record.mediaId ||
          current.lastDownloaded != record.lastDownloaded) {
        return null;
      }
      current.filePath = directory;
      isar.downloadDBs.putSync(current);
      return current;
    });
  }

  /// Return all [DownloadDB] records whose files still exist on disk.
  ///
  /// Missing/inaccessible files never cause record or playlist deletion.
  Future<List<DownloadDB>> getValidDownloads() async {
    final isar = await _db;
    final all = await isar.downloadDBs.where().findAll();
    all.sort((a, b) {
      final aDate = a.lastDownloaded;
      final bDate = b.lastDownloaded;
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });

    final valid = <DownloadDB>[];
    for (var offset = 0; offset < all.length; offset += 32) {
      final resolved = await Future.wait(all
          .skip(offset)
          .take(32)
          .map((record) => _resolveRecord(isar, record)));
      valid.addAll(resolved.whereType<DownloadDB>());
    }

    return valid;
  }

  /// Return downloaded [Track]s using persisted track metadata.
  ///
  /// The order matches [getValidDownloads] (most recent first).
  /// Excludes locally scanned tracks (they have their own playlist).
  /// Falls back to a lightweight track if track metadata is missing.
  Future<List<Track>> getValidDownloadedTracks() async {
    final downloads = (await getValidDownloads())
        .where((record) => !isLocalMediaId(record.mediaId))
        .toList();
    if (downloads.isEmpty) return [];
    final result = <Track>[];
    final mediaIds = downloads.map((d) => d.mediaId).toList();
    final tracksList = await _trackDAO.getTracksByMediaIds(mediaIds);
    final tracks = {for (final t in tracksList) t.id: t};

    for (final record in downloads) {
      final track = tracks[record.mediaId];
      if (track != null) {
        result.add(track);
      } else {
        result.add(
          Track(
            id: record.mediaId,
            title: record.fileName,
            artists: const [],
            thumbnail: const Artwork(url: '', layout: ImageLayout.square),
            isExplicit: false,
          ),
        );
      }
    }

    return result;
  }

  /// Returns true if [mediaId] has a valid download record and the file exists.
  Future<bool> isDownloaded(String mediaId) async {
    final record = await getDownloadRecord(mediaId);
    return record != null;
  }

  /// Update an existing [DownloadDB] record in-place.
  Future<void> updateDownloadRecord(DownloadDB record) async {
    final isar = await _db;
    await isar.writeTxn(() => isar.downloadDBs.put(record));
  }

  // -- Reactive Streams -------------------------------------------------------

  /// Watch for changes to the [DownloadDB] collection.
  Future<Stream<void>> watchDownloads() async {
    final isar = await _db;
    return isar.downloadDBs.watchLazy(fireImmediately: true);
  }
}

/// Resolves exact paths and known app-container relocations. Never searches by
/// basename: different songs can have the same filename.
class DownloadFileResolver {
  final String? supportPath;
  final String? documentsPath;
  Future<List<String?>>? _roots;
  DownloadFileResolver({this.supportPath, this.documentsPath});

  Future<List<String?>> _loadRoots() async {
    try {
      return [
        supportPath ?? (await getApplicationSupportDirectory()).path,
        documentsPath ?? (await getApplicationDocumentsDirectory()).path
      ];
    } catch (_) {
      return [supportPath, documentsPath];
    }
  }

  Future<String?> resolve(String directory, String name) async {
    if (name.isEmpty || p.basename(name) != name) return null;
    if (directory.startsWith('file:')) {
      try {
        directory = Uri.parse(directory).toFilePath();
      } catch (_) {
        return null;
      }
    }
    final candidates = <String>{
      p.join(directory, name),
      if (p.basename(directory) == name) directory
    };
    for (final path in candidates) {
      if (await _exists(path)) return path;
    }
    final roots = await (_roots ??= _loadRoots());
    final normalized =
        (p.basename(directory) == name ? p.dirname(directory) : directory)
            .replaceAll('\\', '/');
    final android = RegExp(
            r'^/data/(?:data|user(?:_de)?/\d+)/[^/]+/(files|app_flutter)(?:/|$)')
        .firstMatch(normalized);
    final apple = RegExp(
            r'/Containers/Data/Application/[^/]+/(Documents|Library/Application Support)(?:/|$)')
        .firstMatch(normalized);
    final relocations = <(String, String?)>[
      if (android != null)
        (
          normalized.substring(android.end),
          android.group(1) == 'files' ? roots[0] : roots[1]
        ),
      if (apple != null)
        (
          normalized.substring(apple.end),
          apple.group(1) == 'Documents' ? roots[1] : roots[0]
        ),
    ];
    for (final (suffix, root) in relocations) {
      if (root == null) continue;
      final moved = p.normalize(p.join(root, suffix, name));
      if (!p.isWithin(root, moved)) continue;
      if (await _exists(moved)) return moved;
    }
    return null;
  }

  Future<bool> _exists(String path) async {
    try {
      return await File(path).exists();
    } on FileSystemException {
      return false;
    }
  }
}
