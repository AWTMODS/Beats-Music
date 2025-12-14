import 'package:beats_music/services/cloud_sync_service.dart';
import 'package:beats_music/services/auto_sync_service.dart';
import 'package:beats_music/services/listening_statistics_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
        debugPrint("AuthService: Sign in successful. Triggering Cloud Restore...");
        // Non-blocking sync to avoid freezing UI? 
        // Or blocking to ensure data is there? Blocking is safer for UX ("Loading Profile...").
        final syncService = CloudSyncService();
        await syncService.downloadStats();
        await syncService.downloadPlaylists();
        await syncService.downloadLikedSongs();
        await syncService.downloadRecentlyPlayed();
        await syncService.downloadDownloadsList();
        
        // Start auto-sync timer
        AutoSyncService().startAutoSync();
        debugPrint("AuthService: Auto-sync started");
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
          // Backup before logout
          final syncService = CloudSyncService();
          await syncService.uploadStats();
          await syncService.uploadPlaylists();
          await syncService.uploadLikedSongs();
          await syncService.uploadRecentlyPlayed();
          await syncService.uploadDownloadsList();
          
          // Stop auto-sync
          AutoSyncService().stopAutoSync();
          debugPrint("AuthService: Auto-sync stopped");
      }
    } catch (e) {
      debugPrint("AuthService: Backup failed during logout: $e");
    }

    await _googleSignIn.signOut();
    await _auth.signOut();
    
    // Clear local stats to ensure privacy for next user
    debugPrint("AuthService: Clearing local stats...");
    await ListeningStatisticsService().clearAllStatistics();
  }
}
