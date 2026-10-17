import 'dart:async';
import 'dart:developer';

import 'package:beats_music/core/models/exported.dart';
import 'package:beats_music/services/collaborative_playlist_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'collab_playlist_state.dart';

/// Cubit that manages both the list view (all my collab playlists) and
/// the detail view (a single open playlist with live Firestore streams).
class CollabPlaylistCubit extends Cubit<CollabPlaylistState> {
  final CollaborativePlaylistService _service;

  StreamSubscription<List<CollabTrack>>? _tracksSub;
  StreamSubscription<List<CollabMember>>? _membersSub;

  String? _openPlaylistId;

  CollabPlaylistCubit({CollaborativePlaylistService? service})
      : _service = service ?? CollaborativePlaylistService(),
        super(const CollabPlaylistInitial());

  @override
  Future<void> close() {
    _tracksSub?.cancel();
    _membersSub?.cancel();
    return super.close();
  }

  // ── List ──────────────────────────────────────────────────────────────────

  /// Load all collaborative playlists the current user belongs to.
  Future<void> loadMyPlaylists() async {
    emit(const CollabPlaylistListLoading());
    try {
      final playlists = await _service.fetchMyPlaylists();
      emit(CollabPlaylistListLoaded(playlists));
    } catch (e) {
      log('CollabCubit: loadMyPlaylists error: $e', name: 'CollabPlaylistCubit');
      emit(CollabPlaylistError('Failed to load playlists: $e'));
    }
  }

  // ── Create ────────────────────────────────────────────────────────────────

  Future<void> createPlaylist(String name, {String description = ''}) async {
    if (!_service.isSignedIn) {
      emit(const CollabPlaylistError(
          'Please sign in to create a collaborative playlist.'));
      return;
    }
    try {
      final id = await _service.createPlaylist(
        name: name,
        description: description,
      );
      emit(CollabPlaylistActionSuccess(
        'Playlist "$name" created!',
        playlistId: id,
      ));
      // Refresh list
      loadMyPlaylists();
    } catch (e) {
      emit(CollabPlaylistError('Failed to create playlist: $e'));
    }
  }

  // ── Join ──────────────────────────────────────────────────────────────────

  Future<void> joinByCode(String code) async {
    if (!_service.isSignedIn) {
      emit(const CollabPlaylistError(
          'Please sign in to join a collaborative playlist.'));
      return;
    }
    final id = await _service.joinByInviteCode(code);
    if (id == null) {
      emit(const CollabPlaylistError(
          'Invalid invite code. Please check and try again.'));
    } else {
      emit(CollabPlaylistActionSuccess('Joined playlist!', playlistId: id));
      loadMyPlaylists();
    }
  }

  // ── Open detail ───────────────────────────────────────────────────────────

  /// Opens a playlist for real-time streaming. Cancels any previous subscription.
  Future<void> openPlaylist(String playlistId) async {
    if (_openPlaylistId == playlistId &&
        state is CollabPlaylistDetailLoaded) {
      return; // Already open
    }

    // Cancel any existing real-time subscriptions
    await _tracksSub?.cancel();
    await _membersSub?.cancel();
    _openPlaylistId = playlistId;

    emit(const CollabPlaylistDetailLoading());

    final meta = await _service.fetchPlaylist(playlistId);
    if (meta == null) {
      emit(const CollabPlaylistError('Playlist not found.'));
      return;
    }

    final myRole = await _service.getMyRole(playlistId) ?? CollabRole.viewer;

    // Seed the state with empty lists — real-time subs will fill them in
    var currentState = CollabPlaylistDetailLoaded(
      meta: meta,
      tracks: const [],
      members: const [],
      myRole: myRole,
    );
    emit(currentState);

    // Start real-time track stream
    _tracksSub = _service.watchTracks(playlistId).listen((tracks) {
      if (state is CollabPlaylistDetailLoaded &&
          _openPlaylistId == playlistId) {
        currentState = currentState.copyWith(tracks: tracks);
        emit(currentState);
      }
    }, onError: (e) {
      log('CollabCubit: track stream error: $e', name: 'CollabPlaylistCubit');
    });

    // Start real-time member stream
    _membersSub = _service.watchMembers(playlistId).listen((members) {
      if (state is CollabPlaylistDetailLoaded &&
          _openPlaylistId == playlistId) {
        currentState = currentState.copyWith(members: members);
        emit(currentState);
      }
    }, onError: (e) {
      log('CollabCubit: member stream error: $e', name: 'CollabPlaylistCubit');
    });
  }

  // ── Track management ──────────────────────────────────────────────────────

  Future<bool> addTrack(Track track) async {
    if (_openPlaylistId == null) return false;

    final current = state;
    if (current is CollabPlaylistDetailLoaded) {
      emit(current.copyWith(isAddingTrack: true));
    }

    final success = await _service.addTrack(_openPlaylistId!, track);

    if (current is CollabPlaylistDetailLoaded) {
      emit(current.copyWith(isAddingTrack: false));
    }

    return success;
  }

  Future<void> removeTrack(String trackId) async {
    if (_openPlaylistId == null) return;
    await _service.removeTrack(_openPlaylistId!, trackId);
  }

  // ── Voting ────────────────────────────────────────────────────────────────

  Future<void> vote(String trackId, {required bool upvote}) async {
    if (_openPlaylistId == null) return;
    await _service.voteOnTrack(
      playlistId: _openPlaylistId!,
      trackId: trackId,
      upvote: upvote,
    );
  }

  // ── Leave / Delete ────────────────────────────────────────────────────────

  Future<void> leavePlaylist(String playlistId) async {
    await _service.leavePlaylist(playlistId);
    loadMyPlaylists();
  }

  Future<void> deletePlaylist(String playlistId) async {
    await _service.deletePlaylist(playlistId);
    loadMyPlaylists();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  bool get isServiceSignedIn => _service.isSignedIn;
}
