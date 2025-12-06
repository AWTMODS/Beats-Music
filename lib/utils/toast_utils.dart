import 'package:flutter/material.dart';
import 'package:beats_music/screens/widgets/snackbar.dart';

class ToastUtils {
  static void showSleepTimerExpired() {
    SnackbarService.showMessage(
      "Sleep Timer\nPlayback stopped automatically",
      backgroundColor: Colors.indigo,
    );
  }

  static void showComingSoon() {
    SnackbarService.showMessage(
      "Coming Soon\nWe are working on this, will be soon available",
       backgroundColor: Colors.blueGrey,
    );
  }

   static void showPrivacyPolicyComingSoon() {
    SnackbarService.showMessage(
      "Privacy Policy\nComing soon in the next update",
      backgroundColor: Colors.blueGrey,
    );
  }

  static void showAccountComingSoon() {
    SnackbarService.showMessage(
      "Account\nComing soon - User profiles & cloud sync",
      backgroundColor: Colors.green,
    );
  }

  static void showNotAvailable() {
    SnackbarService.showMessage(
      "Feature Not Available\nThis feature is temporarily disabled",
      backgroundColor: Colors.redAccent,
    );
  }
  
  static void showDefault() {
    SnackbarService.showMessage(
      "Coming Soon\nWe are working on this, will be soon available",
    );
  }
}
