import 'package:flutter/material.dart';
import 'package:beats_music/screens/widgets/snackbar.dart';

class ToastUtils {
  static void showSleepTimerExpired() {
    SnackbarService.showMessage(
      "Sleep timer has expired.",
    );
  }

  static void showComingSoon() {
    SnackbarService.showMessage(
      "We are working on this, will be soon available",
    );
  }

  static void showNotAvailable() {
    SnackbarService.showMessage(
      "This Feature is not available now",
    );
  }
  static void showDefault() {
    SnackbarService.showMessage(
      "We are working on this, will be soon available",
    );
  }
}
