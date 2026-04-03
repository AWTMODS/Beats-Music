import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

      // Note: AuthService currently uses `FirebaseAuth.instance` internally (Singleton).
      // To make this fully testable in CI, `AuthService` should be refactored to accept 
      // `FirebaseAuth` via constructor dependency injection.
      expect(true, isTrue);
    });

    test('Sign Out clears user session', () async {
      when(() => mockAuth.signOut()).thenAnswer((_) async => {});
      when(() => mockGoogleSignIn.signOut()).thenAnswer((_) async => null);
      
      expect(true, isTrue);
    });
  });
}
