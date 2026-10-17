part of 'collab_playlist_cubit.dart';

abstract class CollabPlaylistState {
  const CollabPlaylistState();
}

/// Initial idle state — no playlist loaded.
class CollabPlaylistInitial extends CollabPlaylistState {
  const CollabPlaylistInitial();
}

/// Loading the list of my collaborative playlists.
class CollabPlaylistListLoading extends CollabPlaylistState {
  const CollabPlaylistListLoading();
}

/// The list of collaborative playlists is ready.
class CollabPlaylistListLoaded extends CollabPlaylistState {
  final List<CollabPlaylistMeta> playlists;
  const CollabPlaylistListLoaded(this.playlists);
}

/// A single playlist is being loaded/opened.
class CollabPlaylistDetailLoading extends CollabPlaylistState {
  const CollabPlaylistDetailLoading();
}

/// A single playlist detail view is open and streaming.
class CollabPlaylistDetailLoaded extends CollabPlaylistState {
  final CollabPlaylistMeta meta;
  final List<CollabTrack> tracks;
  final List<CollabMember> members;
  final CollabRole myRole;
  final bool isAddingTrack;

  const CollabPlaylistDetailLoaded({
    required this.meta,
    required this.tracks,
    required this.members,
    required this.myRole,
    this.isAddingTrack = false,
  });

  CollabPlaylistDetailLoaded copyWith({
    CollabPlaylistMeta? meta,
    List<CollabTrack>? tracks,
    List<CollabMember>? members,
    CollabRole? myRole,
    bool? isAddingTrack,
  }) {
    return CollabPlaylistDetailLoaded(
      meta: meta ?? this.meta,
      tracks: tracks ?? this.tracks,
      members: members ?? this.members,
      myRole: myRole ?? this.myRole,
      isAddingTrack: isAddingTrack ?? this.isAddingTrack,
    );
  }
}

/// An error occurred.
class CollabPlaylistError extends CollabPlaylistState {
  final String message;
  const CollabPlaylistError(this.message);
}

/// A success action (e.g. playlist created, joined) — one-shot notification.
class CollabPlaylistActionSuccess extends CollabPlaylistState {
  final String message;
  final String? playlistId;
  const CollabPlaylistActionSuccess(this.message, {this.playlistId});
}
