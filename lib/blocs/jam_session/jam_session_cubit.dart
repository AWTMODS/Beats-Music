import 'dart:async';
import 'dart:developer';

import 'package:beats_music/core/models/exported.dart';
import 'package:beats_music/services/jam_session_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'jam_session_state.dart';

/// Cubit managing the entire lifecycle of a Live Listening Room.
///
/// Host flow:
///   1. [createRoom] → enters [JamSessionActive] as host
///   2. App calls [pushTrack] on every track change + [pushSeek] on seek
///   3. [startSync] is called once to begin the 2-second timer
///
/// Listener flow:
///   1. [joinRoom] → enters [JamSessionActive] as listener
///   2. [watchPlayback] stream triggers [onPlaybackUpdate] → caller seeks player
class JamSessionCubit extends Cubit<JamSessionState> {
  final JamSessionService _service;

  StreamSubscription<JamPlaybackState>? _playbackSub;
  StreamSubscription<List<JamMember>>? _membersSub;

  JamSessionCubit({JamSessionService? service})
      : _service = service ?? JamSessionService(),
        super(const JamSessionInitial());

  @override
  Future<void> close() {
    _service.stopHostSync();
    _playbackSub?.cancel();
    _membersSub?.cancel();
    return super.close();
  }

  // ── Create Room ───────────────────────────────────────────────────────────

  Future<bool> createRoom({String? roomName}) async {
    log('[LIVE_ROOM] Starting Cubit.createRoom', name: 'JamSessionCubit');
    debugPrint('[LIVE_ROOM] Starting Cubit.createRoom');
    if (!_service.isSignedIn) {
      log('[LIVE_ROOM][ERROR] User not signed in to create room', name: 'JamSessionCubit');
      debugPrint('[LIVE_ROOM][ERROR] User not signed in to create room');
      emit(const JamSessionError('Please sign in to host a Live Room.'));
      return false;
    }
    emit(const JamSessionLoading());
    try {
      final meta = await _service.createRoom(roomName: roomName);
      if (meta == null) {
        emit(const JamSessionError('Failed to create room. Please try again.'));
        return false;
      }
      _enterRoom(meta, JamRole.host);
      return true;
    } catch (e) {
      log('[LIVE_ROOM][ERROR] Cubit.createRoom exception: $e', name: 'JamSessionCubit');
      debugPrint('[LIVE_ROOM][ERROR] Cubit.createRoom exception: $e');
      final msg = e is StateError
          ? e.message
          : e.toString().replaceAll('Exception: ', '').replaceAll('Bad state: ', '');
      emit(JamSessionError(msg));
      return false;
    }
  }

  // ── Join Room ─────────────────────────────────────────────────────────────

  Future<bool> joinRoom(String code) async {
    log('[LIVE_ROOM] Starting Cubit.joinRoom for code: $code', name: 'JamSessionCubit');
    if (!_service.isSignedIn) {
      log('[LIVE_ROOM][ERROR] User not signed in to join room', name: 'JamSessionCubit');
      emit(const JamSessionError('Please sign in to join a listening room.'));
      return false;
    }
    emit(const JamSessionLoading());
    try {
      final meta = await _service.joinByCode(code);
      if (meta == null) {
        emit(const JamSessionError(
            'Room not found. Check the code and try again.'));
        return false;
      }
      _enterRoom(meta, JamRole.listener);
      return true;
    } catch (e) {
      log('[LIVE_ROOM][ERROR] Cubit.joinRoom exception: $e', name: 'JamSessionCubit');
      final msg = e is StateError
          ? e.message
          : e.toString().replaceAll('Exception: ', '').replaceAll('Bad state: ', '');
      emit(JamSessionError(msg));
      return false;
    }
  }

  // ── Internal room setup ───────────────────────────────────────────────────

  void _enterRoom(JamRoomMeta meta, JamRole role) {
    _playbackSub?.cancel();
    _membersSub?.cancel();

    final initialPlayback = JamPlaybackState(
      positionMs: 0,
      isPlaying: false,
      syncedAt: DateTime.now(),
    );

    var current = JamSessionActive(
      room: meta,
      playback: initialPlayback,
      members: const [],
      myRole: role,
    );
    emit(current);

    // Subscribe to playback state
    _playbackSub = _service.watchPlayback(meta.roomId).listen(
      (playback) {
        if (state is JamSessionActive) {
          current = current.copyWith(playback: playback);
          emit(current);
        }
      },
      onError: (e) {
        log('[LIVE_ROOM] playback stream error: $e', name: 'JamSessionCubit');
        if (e.toString().contains('Room closed')) {
          emit(const JamSessionError('The Live Room was closed by the host.'));
        }
      },
    );

    // Subscribe to members
    _membersSub = _service.watchMembers(meta.roomId).listen(
      (members) {
        if (state is JamSessionActive) {
          current = current.copyWith(members: members);
          emit(current);
        }
      },
      onError: (e) {
        log('[LIVE_ROOM] members stream error: $e', name: 'JamSessionCubit');
      },
    );
  }

  // ── Host: push track change ───────────────────────────────────────────────

  /// Host calls this whenever the current track changes.
  Future<void> pushTrack(Track track, {required int positionMs, required bool isPlaying}) async {
    final s = state;
    if (s is! JamSessionActive || !s.isHost) return;

    final playback = JamPlaybackState(
      trackId: track.id,
      trackTitle: track.title,
      artistName: track.artists.isNotEmpty ? track.artists.first.name : null,
      artworkUrl: track.thumbnail.url,
      positionMs: positionMs,
      isPlaying: isPlaying,
      syncedAt: DateTime.now(),
    );

    await _service.pushStateNow(s.room.roomId, playback);
  }

  /// Host calls this with raw track metadata and playback status.
  Future<void> pushPlayback({
    String? trackId,
    String? trackTitle,
    String? artistName,
    String? artworkUrl,
    required int positionMs,
    required bool isPlaying,
  }) async {
    final s = state;
    if (s is! JamSessionActive || !s.isHost) return;

    final playback = JamPlaybackState(
      trackId: trackId,
      trackTitle: trackTitle,
      artistName: artistName,
      artworkUrl: artworkUrl,
      positionMs: positionMs,
      isPlaying: isPlaying,
      syncedAt: DateTime.now(),
    );

    await _service.pushStateNow(s.room.roomId, playback);
  }

  /// Host calls this to begin the periodic heartbeat sync.
  /// [getState] is a callback that returns the current [JamPlaybackState].
  void startSync(JamPlaybackState Function() getState) {
    final s = state;
    if (s is! JamSessionActive || !s.isHost) return;
    _service.startHostSync(
      roomId: s.room.roomId,
      getState: getState,
    );
  }

  /// Stops host periodic sync.
  void stopSync() {
    _service.stopHostSync();
  }

  // ── Send reaction ─────────────────────────────────────────────────────────

  Future<void> sendReaction(String emoji) async {
    final s = state;
    if (s is! JamSessionActive) return;
    await _service.sendReaction(s.room.roomId, emoji);
  }

  // ── Leave ─────────────────────────────────────────────────────────────────

  Future<void> leaveRoom() async {
    final s = state;
    if (s is! JamSessionActive) return;

    _service.stopHostSync();
    _playbackSub?.cancel();
    _membersSub?.cancel();

    await _service.leaveRoom(
      s.room.roomId,
      isHost: s.isHost,
    );
    emit(const JamSessionLeft());
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  bool get isInRoom => state is JamSessionActive;
  bool get isSignedIn => _service.isSignedIn;
}
