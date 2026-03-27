import 'package:beats_music/services/beats_player.dart';
import 'package:beats_music/core/theme/app_theme.dart';
import 'package:audio_service/audio_service.dart';

class PlayerInitializer {
  static final PlayerInitializer _instance = PlayerInitializer._internal();
  factory PlayerInitializer() => _instance;
  PlayerInitializer._internal();

  BeatsMusicPlayer? _BeatsMusicPlayer;
  bool _isInitializing = false;

  Future<BeatsMusicPlayer> getBeatsMusicPlayer() async {
    // Return immediately if already healthy
    if (_BeatsMusicPlayer != null) {
      if (!_BeatsMusicPlayer!.isPlayerHealthy) {
        await _BeatsMusicPlayer!.revive();
      }
      return _BeatsMusicPlayer!;
    }

    // Prevent race conditions if multiple UI components request the player simultaneously
    while (_isInitializing) {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    if (_BeatsMusicPlayer == null) {
      _isInitializing = true;
      try {
        _BeatsMusicPlayer = await AudioService.init(
          builder: () => BeatsMusicPlayer(),
          config: const AudioServiceConfig(
            androidNotificationChannelId:
                'com.BeatsPlayer.notification.status',
            androidNotificationChannelName: 'Beats',
            androidNotificationIcon: 'mipmap/ic_launcher',
            androidResumeOnClick: true,
            androidShowNotificationBadge: true,
            // Allows user to swipe away the notification when paused
            androidStopForegroundOnPause: true,
            notificationColor: Default_Theme.accentColor2,
          ),
        );

        // // Brief delay on Android for native side to stabilize
        // if (Platform.isAndroid) {
        //   await Future.delayed(const Duration(milliseconds: 200));
        // }
      } finally {
        _isInitializing = false;
      }
    }

    return _BeatsMusicPlayer!;
  }
}


