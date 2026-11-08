import 'dart:convert';
import 'dart:developer';

import 'package:beats_music/core/constants/setting_keys.dart';
import 'package:beats_music/services/db/global_db.dart';
import 'package:beats_music/services/db/mappers/media_item_mapper.dart';
import 'package:beats_music/src/rust/api/plugin/models.dart';
import 'package:isar_community/isar.dart';

/// DAO for track persistence — accepts domain [Track] models.
///
/// Mappers are handled internally; callers work only with domain models.
///
/// All other DAOs that need to persist or look up a track delegate here.
/// [TrackDB] rows are shared across playlists and downloads — the same
/// track is stored once and referenced by many [PlaylistEntryDB] rows.
class TrackDAO {
  final Future<Isar> _db;

  const TrackDAO(this._db);

  // ── Upsert ────────────────────────────────────────────────────────────────

  /// Insert or update a track.
  ///
  /// Preserves the existing Isar id when the track already exists (matched
  /// by [mediaId]). If we did a plain `put()`, Isar would allocate a new auto-increment
  /// id, silently breaking every `IsarLink<TrackDB>` in `PlaylistEntryDB` rows
  /// that linked to the old id (causing tracks to vanish from all playlists
  /// they were added to before the re-upsert).
  Future<int> upsertTrack(Track track) async {
    final isar = await _db;
    return isar.writeTxnSync(() => upsertTrackInTransaction(isar, track));
  }

  /// Insert or replace many tracks in a single transaction.
  ///
  /// More efficient than calling [upsertTrack] N times for bulk imports.
  /// Preserves existing Isar ids to avoid breaking IsarLink references.
  Future<List<int>> upsertTracks(List<Track> tracks) async {
    final isar = await _db;
    return isar.writeTxnSync(() =>
        [for (final track in tracks) upsertTrackInTransaction(isar, track)]);
  }

  /// Caller must hold a write transaction. Lookup and update share that transaction.
  int upsertTrackInTransaction(Isar isar, Track track) {
    if (track.id.trim().isEmpty) {
      throw ArgumentError('Track ID must not be empty.');
    }
    final row = trackToTrackDB(track);
    final existing =
        isar.trackDBs.filter().mediaIdEqualTo(track.id).findFirstSync();
    if (existing != null) row.id = existing.id;
    return isar.trackDBs.putSync(row);
  }

  /// Queue references and their tracks must become durable together.
  Future<void> persistQueueState(List<Track> tracks,
      {required int currentIndex, required String title}) async {
    final isar = await _db;
    isar.writeTxnSync(() {
      if (tracks.isEmpty) {
        isar.appSettingsStrDBs
            .filter()
            .settingNameEqualTo(SettingKeys.lastQueueState)
            .deleteAllSync();
        return;
      }
      for (final track in tracks) {
        upsertTrackInTransaction(isar, track);
      }
      isar.appSettingsStrDBs.putSync(AppSettingsStrDB(
          settingName: SettingKeys.lastQueueState,
          settingValue: jsonEncode({
            'v': 2,
            'trackIds': tracks.map((t) => t.id).toList(),
            'currentIndex': currentIndex.clamp(0, tracks.length - 1),
            'queueTitle': title
          })));
    });
  }

  /// Internal method: upsert a [TrackDB] directly (for internal DAO use).
  Future<int> upsertTrackDB(TrackDB track) async {
    final isar = await _db;
    return isar.writeTxn(() => isar.trackDBs.put(track));
  }

  // ── Lookup ────────────────────────────────────────────────────────────────

  /// Find a track by its plugin-scoped [mediaId] (e.g. "resolverplugin::id").
  ///
  /// Returns null if not stored locally.
  Future<Track?> getTrackByMediaId(String mediaId) async {
    final isar = await _db;
    final row =
        await isar.trackDBs.filter().mediaIdEqualTo(mediaId).findFirst();
    return row == null ? null : trackDBToTrack(row);
  }

  /// Find a track by its internal Isar auto-increment ID.
  Future<Track?> getTrackById(int id) async {
    final isar = await _db;
    final row = await isar.trackDBs.get(id);
    return row == null ? null : trackDBToTrack(row);
  }

  /// Batch lookup domain [Track] models for multiple [mediaIds].
  Future<List<Track>> getTracksByMediaIds(List<String> mediaIds) async {
    if (mediaIds.isEmpty) return [];
    final isar = await _db;

    // Isar lacks a bulk whereIn for custom string fields, so we batch with anyOf.
    final rows = await isar.trackDBs
        .filter()
        .anyOf(mediaIds, (q, String id) => q.mediaIdEqualTo(id))
        .findAll();

    final rowMap = {for (final r in rows) r.mediaId: r};
    final result = <Track>[];
    for (final id in mediaIds) {
      final row = rowMap[id];
      if (row != null) result.add(trackDBToTrack(row));
    }
    return result;
  }

  /// Find internal [TrackDB] row by [mediaId] (for internal DAO linking).
  Future<TrackDB?> getTrackDBByMediaId(String mediaId) async {
    final isar = await _db;
    return isar.trackDBs.filter().mediaIdEqualTo(mediaId).findFirst();
  }

  /// Bulk lookup by a list of Isar internal ids (used by PlaylistDAO).
  Future<List<TrackDB>> getTracksByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    final isar = await _db;
    final results = await isar.trackDBs.getAll(ids);
    return results.whereType<TrackDB>().toList();
  }

  // ── Search ────────────────────────────────────────────────────────────────

  /// Full-text search by title or artists using Isar's indexed value scan.
  ///
  /// Returns up to [limit] results (default 50). Pass 0 for unlimited.
  Future<List<TrackDB>> searchTracks(String query, {int limit = 50}) async {
    if (query.trim().isEmpty) return [];
    final isar = await _db;
    final q = isar.trackDBs.filter().titleContains(query, caseSensitive: false);
    return limit == 0 ? q.findAll() : q.limit(limit).findAll();
  }

  // ── Deletion & Cleanup ────────────────────────────────────────────────────

  /// Delete a track only when it is no longer referenced by any
  /// [PlaylistEntryDB] or [DownloadDB] row, and not currently in the queue.
  ///
  /// Safe to call after removing a playlist entry.
  Future<void> purgeOrphanTrack(String mediaId) async {
    final isar = await _db;
    isar.writeTxnSync(() {
      final track =
          isar.trackDBs.filter().mediaIdEqualTo(mediaId).findFirstSync();
      if (track != null) _deleteIfOrphan(isar, track, _queueIds(isar));
    });
  }

  /// Scan all tracks and delete those with no playlist entries, no downloads,
  /// no playback history references, and not in the queue.
  ///
  /// Run as periodic maintenance (30 s after startup).
  Future<int> purgeOrphanTracks() async {
    final isar = await _db;
    final ids = await isar.trackDBs.where().idProperty().findAll();
    var purged = 0;
    for (var offset = 0; offset < ids.length; offset += 100) {
      purged += isar.writeTxnSync(() {
        final queue = _queueIds(isar);
        var count = 0;
        for (final id in ids.skip(offset).take(100)) {
          final track = isar.trackDBs.getSync(id);
          if (track != null && _deleteIfOrphan(isar, track, queue)) count++;
        }
        return count;
      });
      await Future<void>.delayed(Duration.zero);
    }
    log('Purged $purged orphan track(s)', name: 'TrackDAO');
    return purged;
  }

  Set<String>? _queueIds(Isar isar) {
    final value = isar.appSettingsStrDBs
        .filter()
        .settingNameEqualTo(SettingKeys.lastQueueState)
        .findFirstSync()
        ?.settingValue;
    if (value == null) return {};
    try {
      return ((jsonDecode(value) as Map)['trackIds'] as List)
          .cast<String>()
          .toSet();
    } catch (_) {
      return null;
    } // Do not delete tracks when queue references cannot be verified.
  }

  bool _deleteIfOrphan(Isar isar, TrackDB track, Set<String>? queue) {
    if (queue == null || queue.contains(track.mediaId)) return false;
    if (isar.playlistEntryDBs
            .filter()
            .track((q) => q.idEqualTo(track.id))
            .findFirstSync() !=
        null) {
      return false;
    }
    if (isar.downloadDBs
            .filter()
            .mediaIdEqualTo(track.mediaId)
            .findFirstSync() !=
        null) {
      return false;
    }
    if (isar.playbackHistoryDBs
            .filter()
            .track((q) => q.idEqualTo(track.id))
            .findFirstSync() !=
        null) {
      return false;
    }
    return isar.trackDBs.deleteSync(track.id);
  }

  // ── Watchers ──────────────────────────────────────────────────────────────

  Future<Stream<void>> watchTracks() async {
    final isar = await _db;
    return isar.trackDBs.watchLazy(fireImmediately: false);
  }
}
