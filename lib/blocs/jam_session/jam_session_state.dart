part of 'jam_session_cubit.dart';

abstract class JamSessionState {
  const JamSessionState();
}

class JamSessionInitial extends JamSessionState {
  const JamSessionInitial();
}

class JamSessionLoading extends JamSessionState {
  const JamSessionLoading();
}

/// Active state — user is inside a room (either host or listener).
class JamSessionActive extends JamSessionState {
  final JamRoomMeta room;
  final JamPlaybackState playback;
  final List<JamMember> members;
  final JamRole myRole;
  final bool isSyncing;

  const JamSessionActive({
    required this.room,
    required this.playback,
    required this.members,
    required this.myRole,
    this.isSyncing = false,
  });

  bool get isHost => myRole == JamRole.host;

  JamSessionActive copyWith({
    JamRoomMeta? room,
    JamPlaybackState? playback,
    List<JamMember>? members,
    JamRole? myRole,
    bool? isSyncing,
  }) {
    return JamSessionActive(
      room: room ?? this.room,
      playback: playback ?? this.playback,
      members: members ?? this.members,
      myRole: myRole ?? this.myRole,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }
}

/// Error state.
class JamSessionError extends JamSessionState {
  final String message;
  const JamSessionError(this.message);
}

/// Left the room cleanly.
class JamSessionLeft extends JamSessionState {
  const JamSessionLeft();
}
