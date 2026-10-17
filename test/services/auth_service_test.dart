import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:beats_music/services/auth_service.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockGoogleSignIn extends Mock implements GoogleSignIn {}
class MockUserCredential extends Mock implements UserCredential {}
class MockUser extends Mock implements User {}

void main() {
  group('AuthService Unit Tests', () {
    late MockFirebaseAuth mockAuth;
    late MockGoogleSignIn mockGoogleSignIn;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockGoogleSignIn = MockGoogleSignIn();
    });

    test('Guest Mode Sign-In returns UserCredential on success', () async {
      final mockCredential = MockUserCredential();
      when(() => mockAuth.signInAnonymously())
          .thenAnswer((_) async => mockCredential);

      final service = AuthService(auth: mockAuth, googleSignIn: mockGoogleSignIn);
      final result = await service.signInAnonymously();

      expect(result, equals(mockCredential));
      verify(() => mockAuth.signInAnonymously()).called(1);
    });

    test('Guest Mode Sign-In returns null on error', () async {
      when(() => mockAuth.signInAnonymously()).thenThrow(Exception('Network error'));

      final service = AuthService(auth: mockAuth, googleSignIn: mockGoogleSignIn);
      final result = await service.signInAnonymously();

      expect(result, isNull);
    });

    test('Sign in with Email and Password delegates to FirebaseAuth', () async {
      final mockCredential = MockUserCredential();
      final mockUser = MockUser();
      when(() => mockCredential.user).thenReturn(mockUser);
      when(() => mockAuth.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          )).thenAnswer((_) async => mockCredential);

      final service = AuthService(auth: mockAuth, googleSignIn: mockGoogleSignIn);
      final result = await service.signInWithEmail('test@example.com', 'password123');

      expect(result, equals(mockCredential));
      verify(() => mockAuth.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          )).called(1);
    });
  });
}
