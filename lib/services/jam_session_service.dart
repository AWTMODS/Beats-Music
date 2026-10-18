import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

void _log(String msg) {
  debugPrint('[LIVE_ROOM] $msg');
  developer.log('[LIVE_ROOM] $msg', name: 'LIVE_ROOM');
}

void _logError(String msg) {
  debugPrint('[LIVE_ROOM][ERROR] $msg');
  developer.log('[LIVE_ROOM][ERROR] $msg', name: 'LIVE_ROOM');
}

// ─── Domain Models ───────────────────────────────────────────────────────────

enum JamRole { host, listener }

class JamMember {
  final String uid;
  final String displayName;
  final String? avatarUrl;
  final JamRole role;
  final DateTime joinedAt;

  const JamMember({
    required this.uid,
    required this.displayName,
    this.avatarUrl,
    required this.role,
    required this.joinedAt,
  });

  factory JamMember.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return JamMember(
      uid: doc.id,
      displayName: d['displayName'] as String? ?? 'Listener',
      avatarUrl: d['avatarUrl'] as String?,
      role: (d['role'] as String?) == 'host' ? JamRole.host : JamRole.listener,
      joinedAt: (d['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class JamReaction {
  final String uid;
  final String emoji;
  final DateTime sentAt;

  const JamReaction({
    required this.uid,
    required this.emoji,
    required this.sentAt,
  });
}

/// Snapshot of the jam session playback state persisted to Firestore.
class JamPlaybackState {
  final String? trackId;
  final String? trackTitle;
  final String? artistName;
  final String? artworkUrl;
  final int positionMs;
  final bool isPlaying;
  final DateTime syncedAt;

  const JamPlaybackState({
    this.trackId,
    this.trackTitle,
    this.artistName,
    this.artworkUrl,
    required this.positionMs,
    required this.isPlaying,
    required this.syncedAt,
  });

  factory JamPlaybackState.fromFirestore(Map<String, dynamic> d) {
    return JamPlaybackState(
      trackId: d['trackId'] as String?,
      trackTitle: d['trackTitle'] as String?,
      artistName: d['artistName'] as String?,
      artworkUrl: d['artworkUrl'] as String?,
      positionMs: (d['positionMs'] as int?) ?? 0,
      isPlaying: (d['isPlaying'] as bool?) ?? false,
      syncedAt: (d['syncedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'trackId': trackId,
        'trackTitle': trackTitle,
        'artistName': artistName,
        'artworkUrl': artworkUrl,
        'positionMs': positionMs,
        'isPlaying': isPlaying,
        'syncedAt': FieldValue.serverTimestamp(),
      };
}

class JamRoomMeta {
  final String roomId;
  final String roomCode;
  final String hostUid;
  final String hostName;
  final String? roomName;
  final int listenerCount;
  final DateTime createdAt;

  const JamRoomMeta({
    required this.roomId,
    required this.roomCode,
    required this.hostUid,
    required this.hostName,
    this.roomName,
    required this.listenerCount,
    required this.createdAt,
  });

  factory JamRoomMeta.fromFirestore(DocumentSnapshot doc) {
    final d = (doc.data() as Map<String, dynamic>?) ?? {};
    return JamRoomMeta(
      roomId: doc.id,
      roomCode: d['roomCode'] as String? ?? '',
      hostUid: d['hostUid'] as String? ?? '',
      hostName: d['hostName'] as String? ?? 'Host',
      roomName: d['roomName'] as String?,
      listenerCount: (d['listenerCount'] as int?) ?? 0,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

// ─── Service ─────────────────────────────────────────────────────────────────

/// Firestore-backed real-time "Live Listening Room" service.
///
/// Architecture:
/// - Host pushes `playbackState` (trackId + positionMs + isPlaying) every ~2s
/// - Guests subscribe via [watchPlayback] and seek their local player to match
/// - Latency is compensated by adding `(now - syncedAt)` ms to the target position
///
/// No audio is streamed — guests resolve the same track from their own plugin.
class JamSessionService {
  static final JamSessionService _instance = JamSessionService._internal();
  factory JamSessionService() => _instance;
  JamSessionService._internal();

  FirebaseFirestore get _db => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  static const String _collection = 'jam_rooms';
  static const Duration _syncInterval = Duration(seconds: 25);
  JamPlaybackState? _lastSyncedState;

  User? get _currentUser {
    try {
      if (Firebase.apps.isNotEmpty) return _auth.currentUser;
    } catch (_) {}
    return null;
  }
  User? get currentUser => _currentUser;
  bool get isSignedIn =>
      _currentUser != null &&
      _currentUser!.uid.isNotEmpty &&
      !_currentUser!.isAnonymous;
  String get _uid => _currentUser!.uid;
  String get _displayName {
    final name = _currentUser?.displayName;
    if (name != null && name.trim().isNotEmpty) return name.trim();
    final email = _currentUser?.email;
    if (email != null && email.contains('@')) return email.split('@').first;
    return 'Host';
  }

  Timer? _syncTimer;
  String? _activeRoomId;
  String? get activeRoomId => _activeRoomId;

  // ── Create Room ───────────────────────────────────────────────────────────

  /// Creates a new jam room. Returns [JamRoomMeta] with the generated room code.
  Future<JamRoomMeta?> createRoom({String? roomName}) async {
    final user = currentUser;
    if (user == null || user.uid.isEmpty || user.isAnonymous) {
      _logError('User is not authenticated (user: $user, anonymous: ${user?.isAnonymous})');
      throw StateError('Please sign in to host a Live Room.');
    }

    _log('Host button clicked & authenticated: ${user.uid}');
    _log('Starting room creation');

    try {
      final ref = _db.collection(_collection).doc();
      final code = _generateRoomCode();
      _log('Creating room ID: ${ref.id} with code: $code');

      _log('Writing room document');
      await ref.set({
        'roomCode': code,
        'hostUid': user.uid,
        'hostName': _displayName,
        'roomName': roomName?.trim(),
        'listenerCount': 1,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'playbackState': {
          'trackId': null,
          'positionMs': 0,
          'isPlaying': false,
          'syncedAt': FieldValue.serverTimestamp(),
        },
      }).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          _logError('Writing room document timed out');
          throw TimeoutException('Connection to Live Room server timed out.');
        },
      );
      _log('Room document created');

      // Add host as a member
      _log('Adding host member profile');
      await ref.collection('members').doc(user.uid).set({
        'role': 'host',
        'displayName': _displayName,
        'avatarUrl': user.photoURL,
        'joinedAt': FieldValue.serverTimestamp(),
      }).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _logError('Adding host member timed out');
          throw TimeoutException('Failed to register host profile in room.');
        },
      );

      _activeRoomId = ref.id;
      _log('Initializing room state');

      final snap = await ref.get().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _logError('Retrieving room snapshot timed out');
          throw TimeoutException('Failed to retrieve created room details.');
        },
      );

      _log('Host flow completed successfully');
      return JamRoomMeta.fromFirestore(snap);
    } on FirebaseException catch (e) {
      _logError('Firestore error (${e.code}): ${e.message}');
      if (e.code == 'permission-denied') {
        throw StateError(
          'Server permission denied. The Firestore security rules in Firebase Console need to allow access to "jam_rooms".',
        );
      } else if (e.code == 'unavailable' || e.code == 'network-request-failed') {
        throw StateError('Live Room server unavailable. Check your internet connection.');
      }
      throw StateError('Live Room database error: ${e.message ?? e.code}');
    } on TimeoutException {
      _logError('Operation timed out');
      rethrow;
    } catch (e) {
      _logError('Unexpected error during room creation: $e');
      rethrow;
    }
  }

  // ── Join Room ─────────────────────────────────────────────────────────────

  /// Joins a room by 6-char code. Returns [JamRoomMeta] or null if invalid.
  Future<JamRoomMeta?> joinByCode(String code) async {
    final user = currentUser;
    if (user == null || user.uid.isEmpty || user.isAnonymous) {
      _logError('User not authenticated for join');
      throw StateError('Please sign in to join a Live Room.');
    }

    try {
      final query = await _db
          .collection(_collection)
          .where('roomCode', isEqualTo: code.trim().toUpperCase())
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get()
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw TimeoutException('Searching for room timed out.'),
          );

      if (query.docs.isEmpty) return null;

      final doc = query.docs.first;
      final roomId = doc.id;
      _activeRoomId = roomId;

      // Add as member
      await _db
          .collection(_collection)
          .doc(roomId)
          .collection('members')
          .doc(user.uid)
          .set({
        'role': 'listener',
        'displayName': _displayName,
        'avatarUrl': user.photoURL,
        'joinedAt': FieldValue.serverTimestamp(),
      }).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Joining room timed out.'),
      );

      // Increment listener count
      await _db
          .collection(_collection)
          .doc(roomId)
          .update({'listenerCount': FieldValue.increment(1)})
          .timeout(const Duration(seconds: 5));

      developer.log('JamService: Joined room $code ($roomId)', name: 'JamSessionService');
      return JamRoomMeta.fromFirestore(doc);
    } on FirebaseException catch (e) {
      developer.log('[LIVE_ROOM][ERROR] Join Firestore error (${e.code}): ${e.message}', name: 'LIVE_ROOM');
      if (e.code == 'permission-denied') {
        throw StateError(
          'Server permission denied. The Firestore security rules in Firebase Console need to allow access to "jam_rooms".',
        );
      }
      throw StateError('Failed to join room: ${e.message ?? e.code}');
    } catch (e) {
      developer.log('JamService: joinByCode error: $e', name: 'JamSessionService');
      rethrow;
    }
  }

  // ── Host: push playback state ─────────────────────────────────────────────

  /// Starts a periodic heartbeat sync that only pushes when playback drifts > 3s.
  /// Continuous position is calculated client-side via elapsed timestamp.
  void startHostSync({
    required String roomId,
    required JamPlaybackState Function() getState,
  }) {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(_syncInterval, (_) async {
      try {
        final state = getState();
        // If track and playing state haven't changed, check if timestamp calculation is accurate
        if (_lastSyncedState != null &&
            _lastSyncedState!.trackId == state.trackId &&
            _lastSyncedState!.isPlaying == state.isPlaying) {
          final elapsed = DateTime.now().difference(_lastSyncedState!.syncedAt).inMilliseconds;
          final expectedPos = _lastSyncedState!.positionMs + (state.isPlaying ? elapsed : 0);
          final drift = (state.positionMs - expectedPos).abs();
          // If client-side estimate is within 3 seconds, avoid burning Firestore writes
          if (drift < 3000) {
            return;
          }
        }
        await pushStateNow(roomId, state);
      } catch (e) {
        developer.log('JamService: sync error: $e', name: 'JamSessionService');
      }
    });
    developer.log('JamService: Started event-aware host sync for $roomId', name: 'JamSessionService');
  }

  /// Pushes a single one-shot state update (e.g. on play, pause, seek, or track change).
  Future<void> pushStateNow(String roomId, JamPlaybackState state) async {
    try {
      _lastSyncedState = state;
      await _db
          .collection(_collection)
          .doc(roomId)
          .update({'playbackState': state.toFirestore()});
    } catch (e) {
      developer.log('JamService: pushStateNow error: $e', name: 'JamSessionService');
    }
  }

  void stopHostSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
    _lastSyncedState = null;
  }

  // ── Guest: watch playback state ───────────────────────────────────────────

  /// Stream of playback state snapshots with latency-compensated position.
  Stream<JamPlaybackState> watchPlayback(String roomId) {
    return _db
        .collection(_collection)
        .doc(roomId)
        .snapshots()
        .map((snap) {
          if (!snap.exists) throw Exception('Room closed');
          final data = snap.data() ?? {};
          final raw = data['playbackState'] as Map<String, dynamic>? ?? {};
          final state = JamPlaybackState.fromFirestore(raw);

          // Latency compensation: add elapsed time since host pushed
          if (state.isPlaying) {
            final elapsed =
                DateTime.now().difference(state.syncedAt).inMilliseconds;
            final compensated = state.positionMs + elapsed.clamp(0, 5000);
            return JamPlaybackState(
              trackId: state.trackId,
              trackTitle: state.trackTitle,
              artistName: state.artistName,
              artworkUrl: state.artworkUrl,
              positionMs: compensated,
              isPlaying: state.isPlaying,
              syncedAt: state.syncedAt,
            );
          }
          return state;
        });
  }

  // ── Members ───────────────────────────────────────────────────────────────

  Stream<List<JamMember>> watchMembers(String roomId) {
    return _db
        .collection(_collection)
        .doc(roomId)
        .collection('members')
        .snapshots()
        .map((snap) => snap.docs.map(JamMember.fromFirestore).toList());
  }

  // ── Reactions ─────────────────────────────────────────────────────────────

  Future<void> sendReaction(String roomId, String emoji) async {
    if (!isSignedIn) return;
    try {
      await _db
          .collection(_collection)
          .doc(roomId)
          .collection('reactions')
          .add({
        'uid': _uid,
        'emoji': emoji,
        'sentAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  Stream<JamReaction?> watchReactions(String roomId) {
    return _db
        .collection(_collection)
        .doc(roomId)
        .collection('reactions')
        .orderBy('sentAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snap) {
          if (snap.docs.isEmpty) return null;
          final d = snap.docs.first.data();
          return JamReaction(
            uid: d['uid'] as String? ?? '',
            emoji: d['emoji'] as String? ?? '🎵',
            sentAt: (d['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          );
        });
  }

  // ── Leave / Close ─────────────────────────────────────────────────────────

  Future<void> leaveRoom(String roomId, {bool isHost = false}) async {
    stopHostSync();
    try {
      await _db
          .collection(_collection)
          .doc(roomId)
          .collection('members')
          .doc(_uid)
          .delete();

      if (isHost) {
        // Close the room entirely
        await _db.collection(_collection).doc(roomId).update({
          'isActive': false,
          'closedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await _db
            .collection(_collection)
            .doc(roomId)
            .update({'listenerCount': FieldValue.increment(-1)});
      }
      _activeRoomId = null;
    } catch (e) {
      developer.log('JamService: leaveRoom error: $e', name: 'JamSessionService');
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random.secure();
    return List.generate(6, (_) => chars[rng.nextInt(chars.length)]).join();
  }
}
