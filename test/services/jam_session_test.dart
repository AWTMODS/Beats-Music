import 'dart:async';

import 'package:beats_music/blocs/jam_session/jam_session_cubit.dart';
import 'package:beats_music/services/jam_session_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockJamSessionService extends Mock implements JamSessionService {}
class MockUser extends Mock implements User {}

void main() {
  late MockJamSessionService mockService;
  late JamSessionCubit cubit;

  setUp(() {
    mockService = MockJamSessionService();
    cubit = JamSessionCubit(service: mockService);
  });

  tearDown(() {
    cubit.close();
  });

  group('JamSessionCubit - Host & Join Room Tests', () {
    test('initial state is JamSessionInitial', () {
      expect(cubit.state, isA<JamSessionInitial>());
    });

    test('createRoom fails immediately if user is not signed in (no infinite loading)', () async {
      when(() => mockService.isSignedIn).thenReturn(false);

      final success = await cubit.createRoom();

      expect(success, isFalse);
      expect(cubit.state, isA<JamSessionError>());
      expect((cubit.state as JamSessionError).message, contains('Please sign in'));
    });

    test('createRoom handles backend exception without hanging in loading state', () async {
      when(() => mockService.isSignedIn).thenReturn(true);
      when(() => mockService.createRoom(roomName: any(named: 'roomName')))
          .thenThrow(TimeoutException('Connection to Live Room server timed out.'));

      final states = <JamSessionState>[];
      final sub = cubit.stream.listen(states.add);

      final success = await cubit.createRoom();
      await Future<void>.delayed(Duration.zero);

      expect(success, isFalse);
      expect(cubit.state, isA<JamSessionError>());
      expect((cubit.state as JamSessionError).message, contains('Connection to Live Room server timed out.'));
      // Verified state transitioned: Loading -> Error (never stuck on Loading)
      expect(states, [isA<JamSessionLoading>(), isA<JamSessionError>()]);

      await sub.cancel();
    });

    test('createRoom transitions to JamSessionActive upon successful creation', () async {
      final meta = JamRoomMeta(
        roomId: 'test-room-123',
        roomCode: 'BEAT99',
        hostUid: 'host-uid-1',
        hostName: 'BeatsHost',
        listenerCount: 1,
        createdAt: DateTime.now(),
      );

      when(() => mockService.isSignedIn).thenReturn(true);
      when(() => mockService.createRoom(roomName: any(named: 'roomName')))
          .thenAnswer((_) async => meta);
      when(() => mockService.watchPlayback('test-room-123'))
          .thenAnswer((_) => Stream.value(JamPlaybackState(
                positionMs: 0,
                isPlaying: false,
                syncedAt: DateTime.now(),
              )));
      when(() => mockService.watchMembers('test-room-123'))
          .thenAnswer((_) => Stream.value([
                JamMember(
                  uid: 'host-uid-1',
                  displayName: 'BeatsHost',
                  role: JamRole.host,
                  joinedAt: DateTime.now(),
                ),
              ]));

      final states = <JamSessionState>[];
      final sub = cubit.stream.listen(states.add);

      final success = await cubit.createRoom();
      await Future<void>.delayed(Duration.zero);

      expect(success, isTrue);
      expect(cubit.state, isA<JamSessionActive>());
      final active = cubit.state as JamSessionActive;
      expect(active.room.roomId, equals('test-room-123'));
      expect(active.room.roomCode, equals('BEAT99'));
      expect(active.isHost, isTrue);
      expect(states.first, isA<JamSessionLoading>());
      expect(states.last, isA<JamSessionActive>());

      await sub.cancel();
    });

    test('joinRoom fails if user is not signed in', () async {
      when(() => mockService.isSignedIn).thenReturn(false);

      final success = await cubit.joinRoom('BEAT99');

      expect(success, isFalse);
      expect(cubit.state, isA<JamSessionError>());
    });

    test('joinRoom handles invalid room code without hanging in loading state', () async {
      when(() => mockService.isSignedIn).thenReturn(true);
      when(() => mockService.joinByCode('INVALID'))
          .thenAnswer((_) async => null);

      final states = <JamSessionState>[];
      final sub = cubit.stream.listen(states.add);

      final success = await cubit.joinRoom('INVALID');
      await Future<void>.delayed(Duration.zero);

      expect(success, isFalse);
      expect(cubit.state, isA<JamSessionError>());
      expect((cubit.state as JamSessionError).message, contains('Room not found'));
      expect(states, [isA<JamSessionLoading>(), isA<JamSessionError>()]);

      await sub.cancel();
    });

    test('joinRoom transitions to JamSessionActive as listener when code is valid', () async {
      final meta = JamRoomMeta(
        roomId: 'test-room-456',
        roomCode: 'JOIN88',
        hostUid: 'host-uid-2',
        hostName: 'HostUser',
        listenerCount: 2,
        createdAt: DateTime.now(),
      );

      when(() => mockService.isSignedIn).thenReturn(true);
      when(() => mockService.joinByCode('JOIN88'))
          .thenAnswer((_) async => meta);
      when(() => mockService.watchPlayback('test-room-456'))
          .thenAnswer((_) => Stream.value(JamPlaybackState(
                positionMs: 12000,
                isPlaying: true,
                syncedAt: DateTime.now(),
              )));
      when(() => mockService.watchMembers('test-room-456'))
          .thenAnswer((_) => Stream.value([]));

      final success = await cubit.joinRoom('JOIN88');

      expect(success, isTrue);
      expect(cubit.state, isA<JamSessionActive>());
      final active = cubit.state as JamSessionActive;
      expect(active.isHost, isFalse);
      expect(active.myRole, equals(JamRole.listener));
    });
  });
}
