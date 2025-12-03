import 'package:beats_music/services/beats_music_player.dart';
import 'package:beats_music/theme_data/default.dart';
import 'package:audio_service/audio_service.dart';

class PlayerInitializer {
  static final PlayerInitializer _instance = PlayerInitializer._internal();
  factory PlayerInitializer() {
    return _instance;
  }

  PlayerInitializer._internal();

  static bool _isInitialized = false;
  static BeatsMusicPlayer? beatsMusicPlayer;

  Future<void> _initialize() async {
    beatsMusicPlayer = await AudioService.init(
      builder: () => BeatsMusicPlayer(),
      config: const AudioServiceConfig(
        androidStopForegroundOnPause: false,
        androidNotificationChannelId: 'com.beatsMusicPlayer.notification.status',
        androidNotificationChannelName: 'Beats Music',
        androidResumeOnClick: true,
        // androidNotificationIcon: 'assets/icons/BeatsMusic_logo_fore.png',
        androidShowNotificationBadge: true,
        notificationColor: Default_Theme.accentColor2,
      ),
    );
  }

  Future<BeatsMusicPlayer> getBeatsMusicPlayer() async {
    if (!_isInitialized) {
      await _initialize();
      _isInitialized = true;
    }
    return beatsMusicPlayer!;
  }
}
