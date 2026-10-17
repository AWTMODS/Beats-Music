import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:beats_music/core/models/exported.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ─── Domain Models ───────────────────────────────────────────────────────────

class CollabMember {
  final String uid;
  final String displayName;
  final String? avatarUrl;
  final CollabRole role;
  final DateTime joinedAt;

  const CollabMember({
    required this.uid,
    required this.displayName,
    this.avatarUrl,
    required this.role,
    required this.joinedAt,
  });

  factory CollabMember.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return CollabMember(
      uid: doc.id,
      displayName: d['displayName'] as String? ?? 'User',
      avatarUrl: d['avatarUrl'] as String?,
      role: _roleFromString(d['role'] as String? ?? 'viewer'),
      joinedAt: (d['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  static CollabRole _roleFromString(String s) {
    switch (s) {
      case 'owner':
        return CollabRole.owner;
      case 'editor':
        return CollabRole.editor;
      default:
        return CollabRole.viewer;
    }
  }
}

enum CollabRole { owner, editor, viewer }

class CollabTrack {
  final String trackId;
  final String addedByUid;
  final String addedByName;
  final DateTime addedAt;
  final Track track;
  final List<String> upvoterUids;
  final List<String> downvoterUids;
  final int score;

  const CollabTrack({
    required this.trackId,
    required this.addedByUid,
    required this.addedByName,
    required this.addedAt,
    required this.track,
    required this.upvoterUids,
    required this.downvoterUids,
    required this.score,
  });

  bool hasUpvoted(String uid) => upvoterUids.contains(uid);
  bool hasDownvoted(String uid) => downvoterUids.contains(uid);

  factory CollabTrack.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final votes = d['votes'] as Map<String, dynamic>? ?? {};
    final trackData = d['trackData'] as Map<String, dynamic>? ?? {};

    return CollabTrack(
      trackId: doc.id,
      addedByUid: d['addedByUid'] as String? ?? '',
      addedByName: d['addedByName'] as String? ?? 'User',
      addedAt: (d['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      track: _trackFromMap(trackData),
      upvoterUids: List<String>.from(votes['upvotes'] ?? []),
      downvoterUids: List<String>.from(votes['downvotes'] ?? []),
      score: (votes['score'] as int?) ?? 0,
    );
  }

  static Track _trackFromMap(Map<String, dynamic> m) {
    return Track(
      id: m['id'] as String? ?? '',
      title: m['title'] as String? ?? 'Unknown',
      artists: [
        ArtistSummary(
          id: '',
          name: m['artist'] as String? ?? 'Unknown',
        )
      ],
      thumbnail: Artwork(
        url: m['artworkUrl'] as String? ?? '',
        layout: ImageLayout.square,
      ),
      isExplicit: false,
      durationMs: m['durationMs'] != null
          ? BigInt.from(m['durationMs'] as int)
          : null,
    );
  }
}

class CollabPlaylistMeta {
  final String playlistId;
  final String name;
  final String description;
  final String? coverImageUrl;
  final String ownerUid;
  final String ownerName;
  final String inviteCode;
  final int trackCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CollabPlaylistMeta({
    required this.playlistId,
    required this.name,
    required this.description,
    this.coverImageUrl,
    required this.ownerUid,
    required this.ownerName,
    required this.inviteCode,
    required this.trackCount,
    required this.createdAt,
    this.updatedAt,
  });

  factory CollabPlaylistMeta.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return CollabPlaylistMeta(
      playlistId: doc.id,
      name: d['name'] as String? ?? 'Untitled',
      description: d['description'] as String? ?? '',
      coverImageUrl: d['coverImageUrl'] as String?,
      ownerUid: d['ownerUid'] as String? ?? '',
      ownerName: d['ownerName'] as String? ?? 'Unknown',
      inviteCode: d['inviteCode'] as String? ?? '',
      trackCount: (d['trackCount'] as int?) ?? 0,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}

// ─── Service ─────────────────────────────────────────────────────────────────

/// Service layer for all Collaborative Playlist Firestore operations.
///
/// All writes are guarded by [FirebaseAuth] — the current user must be
/// signed in and non-anonymous for create/join operations.
class CollaborativePlaylistService {
  static final CollaborativePlaylistService _instance =
      CollaborativePlaylistService._internal();
  factory CollaborativePlaylistService() => _instance;
  CollaborativePlaylistService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _collection = 'collaborative_playlists';

  // ── Auth helpers ─────────────────────────────────────────────────────────

  User? get _currentUser => _auth.currentUser;

  bool get isSignedIn =>
      _currentUser != null && !(_currentUser!.isAnonymous);

  String get _uid => _currentUser!.uid;
  String get _displayName =>
      _currentUser?.displayName ?? _currentUser?.email ?? 'User';

  // ── Create ───────────────────────────────────────────────────────────────

  /// Creates a new collaborative playlist owned by the current user.
  /// Returns the new [playlistId].
  Future<String> createPlaylist({
    required String name,
    String description = '',
  }) async {
    assert(isSignedIn, 'Must be signed in to create a collaborative playlist');
    final ref = _db.collection(_collection).doc();
    final code = _generateInviteCode();

    final batch = _db.batch();

    batch.set(ref, {
      'name': name.trim(),
      'description': description.trim(),
      'ownerUid': _uid,
      'ownerName': _displayName,
      'inviteCode': code,
      'trackCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    batch.set(ref.collection('members').doc(_uid), {
      'role': 'owner',
      'displayName': _displayName,
      'avatarUrl': _currentUser?.photoURL,
      'joinedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
    developer.log('CollabService: Created playlist "$name" (${ref.id})',
        name: 'CollaborativePlaylistService');
    return ref.id;
  }

  // ── Join ─────────────────────────────────────────────────────────────────

  /// Joins a playlist by its 9-char invite code.
  /// Returns the [playlistId] on success, null if code is invalid.
  Future<String?> joinByInviteCode(String code) async {
    assert(isSignedIn, 'Must be signed in to join a collaborative playlist');

    try {
      final query = await _db
          .collection(_collection)
          .where('inviteCode', isEqualTo: code.trim().toUpperCase())
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;

      final playlistId = query.docs.first.id;
      final memberRef =
          _db.collection(_collection).doc(playlistId).collection('members').doc(_uid);

      // Check if already a member
      final existing = await memberRef.get();
      if (existing.exists) return playlistId;

      await memberRef.set({
        'role': 'editor',
        'displayName': _displayName,
        'avatarUrl': _currentUser?.photoURL,
        'joinedAt': FieldValue.serverTimestamp(),
      });

      developer.log('CollabService: Joined playlist $playlistId', name: 'CollaborativePlaylistService');
      return playlistId;
    } catch (e) {
      developer.log('CollabService: joinByInviteCode error: $e',
          name: 'CollaborativePlaylistService');
      return null;
    }
  }

  // ── Fetch ─────────────────────────────────────────────────────────────────

  /// Fetches all collaborative playlists the current user is a member of.
  Future<List<CollabPlaylistMeta>> fetchMyPlaylists() async {
    if (!isSignedIn) return [];
    try {
      // Firestore collection group query — finds all member docs for current uid
      final memberDocs = await _db
          .collectionGroup('members')
          .where(FieldPath.documentId, isEqualTo: _uid)
          .get();

      if (memberDocs.docs.isEmpty) return [];

      // Extract playlist IDs from member doc paths
      final playlistIds = memberDocs.docs
          .map((d) => d.reference.parent.parent?.id)
          .whereType<String>()
          .toList();

      if (playlistIds.isEmpty) return [];

      // Batch-fetch playlists (Firestore 'whereIn' supports up to 30 items)
      final results = <CollabPlaylistMeta>[];
      for (int i = 0; i < playlistIds.length; i += 30) {
        final chunk = playlistIds.sublist(
            i, i + 30 > playlistIds.length ? playlistIds.length : i + 30);
        final snap = await _db
            .collection(_collection)
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        results.addAll(snap.docs.map(CollabPlaylistMeta.fromFirestore));
      }

      results.sort((a, b) => b.updatedAt
              ?.compareTo(a.updatedAt ?? a.createdAt) ??
          b.createdAt.compareTo(a.createdAt));
      return results;
    } catch (e) {
      developer.log('CollabService: fetchMyPlaylists error: $e',
          name: 'CollaborativePlaylistService');
      return [];
    }
  }

  /// Fetches a single playlist's metadata.
  Future<CollabPlaylistMeta?> fetchPlaylist(String playlistId) async {
    try {
      final doc = await _db.collection(_collection).doc(playlistId).get();
      if (!doc.exists) return null;
      return CollabPlaylistMeta.fromFirestore(doc);
    } catch (e) {
      developer.log('CollabService: fetchPlaylist error: $e',
          name: 'CollaborativePlaylistService');
      return null;
    }
  }

  // ── Real-time streams ─────────────────────────────────────────────────────

  /// Live stream of all tracks in a collaborative playlist, ordered by vote score.
  Stream<List<CollabTrack>> watchTracks(String playlistId) {
    return _db
        .collection(_collection)
        .doc(playlistId)
        .collection('tracks')
        .orderBy('votes.score', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) {
              try {
                return CollabTrack.fromFirestore(doc);
              } catch (e) {
                developer.log('CollabService: Error parsing track ${doc.id}: $e',
                    name: 'CollaborativePlaylistService');
                return null;
              }
            })
            .whereType<CollabTrack>()
            .toList());
  }

  /// Live stream of members in a collaborative playlist.
  Stream<List<CollabMember>> watchMembers(String playlistId) {
    return _db
        .collection(_collection)
        .doc(playlistId)
        .collection('members')
        .snapshots()
        .map((snap) => snap.docs.map(CollabMember.fromFirestore).toList());
  }

  // ── Add / Remove Tracks ───────────────────────────────────────────────────

  /// Adds a [Track] to the collaborative playlist.
  /// Skips silently if the track is already in the playlist.
  Future<bool> addTrack(String playlistId, Track track) async {
    if (!isSignedIn) return false;
    try {
      final trackRef = _db
          .collection(_collection)
          .doc(playlistId)
          .collection('tracks')
          .doc(track.id);

      final existing = await trackRef.get();
      if (existing.exists) return false;

      await _db.runTransaction((tx) async {
        tx.set(trackRef, {
          'addedByUid': _uid,
          'addedByName': _displayName,
          'addedAt': FieldValue.serverTimestamp(),
          'trackData': _trackToMap(track),
          'votes': {
            'upvotes': <String>[],
            'downvotes': <String>[],
            'score': 0,
          },
        });

        tx.update(
          _db.collection(_collection).doc(playlistId),
          {
            'trackCount': FieldValue.increment(1),
            'updatedAt': FieldValue.serverTimestamp(),
          },
        );
      });

      developer.log('CollabService: Added track "${track.title}" to $playlistId',
          name: 'CollaborativePlaylistService');
      return true;
    } catch (e) {
      developer.log('CollabService: addTrack error: $e',
          name: 'CollaborativePlaylistService');
      return false;
    }
  }

  /// Removes a track from the collaborative playlist.
  /// Only the track's adder or the playlist owner can remove.
  Future<bool> removeTrack(String playlistId, String trackId) async {
    if (!isSignedIn) return false;
    try {
      await _db.runTransaction((tx) async {
        final trackRef = _db
            .collection(_collection)
            .doc(playlistId)
            .collection('tracks')
            .doc(trackId);
        tx.delete(trackRef);
        tx.update(
          _db.collection(_collection).doc(playlistId),
          {
            'trackCount': FieldValue.increment(-1),
            'updatedAt': FieldValue.serverTimestamp(),
          },
        );
      });
      return true;
    } catch (e) {
      developer.log('CollabService: removeTrack error: $e',
          name: 'CollaborativePlaylistService');
      return false;
    }
  }

  // ── Voting ───────────────────────────────────────────────────────────────

  /// Toggle upvote or downvote on a track. Atomic Firestore transaction
  /// ensures no double-votes or race conditions.
  Future<void> voteOnTrack({
    required String playlistId,
    required String trackId,
    required bool upvote,
  }) async {
    if (!isSignedIn) return;
    final trackRef = _db
        .collection(_collection)
        .doc(playlistId)
        .collection('tracks')
        .doc(trackId);

    try {
      await _db.runTransaction((tx) async {
        final snap = await tx.get(trackRef);
        if (!snap.exists) return;

        final votes = Map<String, dynamic>.from(
            (snap.data() as Map<String, dynamic>)['votes'] ?? {});
        final upvotes = List<String>.from(votes['upvotes'] ?? []);
        final downvotes = List<String>.from(votes['downvotes'] ?? []);

        if (upvote) {
          if (upvotes.contains(_uid)) {
            upvotes.remove(_uid); // Toggle off
          } else {
            upvotes.add(_uid);
            downvotes.remove(_uid); // Exclusive vote
          }
        } else {
          if (downvotes.contains(_uid)) {
            downvotes.remove(_uid); // Toggle off
          } else {
            downvotes.add(_uid);
            upvotes.remove(_uid); // Exclusive vote
          }
        }

        tx.update(trackRef, {
          'votes.upvotes': upvotes,
          'votes.downvotes': downvotes,
          'votes.score': upvotes.length - downvotes.length,
        });
      });
    } catch (e) {
      developer.log('CollabService: voteOnTrack error: $e',
          name: 'CollaborativePlaylistService');
    }
  }

  // ── Role management ───────────────────────────────────────────────────────

  Future<CollabRole?> getMyRole(String playlistId) async {
    if (!isSignedIn) return null;
    try {
      final doc = await _db
          .collection(_collection)
          .doc(playlistId)
          .collection('members')
          .doc(_uid)
          .get();
      if (!doc.exists) return null;
      return CollabMember.fromFirestore(doc).role;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateMemberRole(
      String playlistId, String targetUid, CollabRole newRole) async {
    if (!isSignedIn) return;
    await _db
        .collection(_collection)
        .doc(playlistId)
        .collection('members')
        .doc(targetUid)
        .update({'role': newRole.name});
  }

  // ── Leave / Delete ────────────────────────────────────────────────────────

  Future<void> leavePlaylist(String playlistId) async {
    if (!isSignedIn) return;
    await _db
        .collection(_collection)
        .doc(playlistId)
        .collection('members')
        .doc(_uid)
        .delete();
  }

  /// Deletes the entire collaborative playlist (owner only).
  Future<void> deletePlaylist(String playlistId) async {
    if (!isSignedIn) return;
    // Note: Firestore subcollections require server-side deletion (Cloud Function)
    // for complete cleanup. We mark it as deleted here.
    await _db
        .collection(_collection)
        .doc(playlistId)
        .update({'isDeleted': true, 'deletedAt': FieldValue.serverTimestamp()});
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random.secure();
    return List.generate(9, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  Map<String, dynamic> _trackToMap(Track track) {
    return {
      'id': track.id,
      'title': track.title,
      'artist': track.artists.isNotEmpty ? track.artists.first.name : 'Unknown',
      'artworkUrl': track.thumbnail.url,
      'durationMs': track.durationMs?.toInt(),
    };
  }

  /// Check if a user is already a member of a playlist
  Future<bool> isMember(String playlistId) async {
    if (!isSignedIn) return false;
    try {
      final doc = await _db
          .collection(_collection)
          .doc(playlistId)
          .collection('members')
          .doc(_uid)
          .get();
      return doc.exists;
    } catch (_) {
      return false;
    }
  }
}
