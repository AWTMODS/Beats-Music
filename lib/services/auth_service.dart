import 'package:beats_music/services/cloud_sync_service.dart';
import 'package:beats_music/services/auto_sync_service.dart';
import 'package:beats_music/services/listening_statistics_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:beats_music/services/db/db_provider.dart';
import 'package:flutter/material.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Stream to listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User canceled

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      final userCredential = await _auth.signInWithCredential(credential);
      
      // Trigger Cloud Sync Download (Restore)
      if (userCredential.user != null) {
        // Trigger Cloud Sync Download (Restore) - BACKGROUND
        // Fix for Pixel 5a hang: Don't block UI waiting for full sync
        _restoreDataInBackground();
      }
      
      return userCredential;
    } catch (e) {
      debugPrint("AuthService Error: $e");
      return null;
    }
  }

  // Sign in Anonymously (Guest Mode)
  Future<UserCredential?> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
       debugPrint("AuthService Error: $e");
       return null;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      if (_auth.currentUser != null && !_auth.currentUser!.isAnonymous) {
          debugPrint("AuthService: Signing out. Backing up data...");
          // Backup before logout - parallelize for speed
          final syncService = CloudSyncService();
          await Future.wait([
            syncService.uploadStats(),
            syncService.uploadPlaylists(),
            syncService.uploadLikedSongs(),
            syncService.uploadRecentlyPlayed(),
            syncService.uploadDownloadsList(),
          ]);
          
          // Stop auto-sync
          AutoSyncService().stopAutoSync();
          debugPrint("AuthService: Auto-sync stopped");
      }
    } catch (e) {
      debugPrint("AuthService: Backup failed during logout: $e");
    }

    await _googleSignIn.signOut();
    await _auth.signOut();
    
    // Clear local stats and library to ensure privacy for next user
    debugPrint("AuthService: Clearing local stats and library...");
    await Future.wait([
      ListeningStatisticsService().clearAllStatistics(),
      DBProvider.clearUserLocalData(),
    ]);
  }

  Future<void> _restoreDataInBackground() async {
    debugPrint("AuthService: Sign in successful. Triggering Cloud Restore (Background)...");
    try {
        final syncService = CloudSyncService();
        // Run independently in background so UI doesn't hang
        await Future.wait([
          syncService.downloadStats(),
          syncService.downloadPlaylists(),
          syncService.downloadLikedSongs(),
          syncService.downloadRecentlyPlayed(),
          syncService.downloadDownloadsList(),
        ]);
        
        // Start auto-sync timer
        AutoSyncService().startAutoSync();
        debugPrint("AuthService: Background Auto-sync started");
    } catch (e) {
        debugPrint("AuthService: Background sync error: $e");
    }
  }
}
