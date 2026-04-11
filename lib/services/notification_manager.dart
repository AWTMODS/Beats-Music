import 'dart:io';
import 'dart:math';
import 'package:beats_music/model/statistics/song_statistics.dart';
import 'package:beats_music/services/listening_statistics_service.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  
  /// Emits the song ID when a re-engagement notification is tapped.
  final ValueNotifier<String?> onNotificationTap = ValueNotifier<String?>(null);
  
  static const String _lastReengagementKey = 'last_reengagement_shown_at';
  
  // Remote Config Keys
  static const String _remoteThrottleKey = 'reengagement_throttle_hours';
  static const String _remoteTitleKey = 'reengagement_title';
  static const String _remoteMsgDefaultKey = 'reengagement_msg_default';

  Future<void> init() async {
    if (_isInitialized) return;

    // 1. Init Local Notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          debugPrint('NotificationManager: Tap detected with payload: ${response.payload}');
          onNotificationTap.value = response.payload;
          // Reset to null so subsequent identical taps are detected
          onNotificationTap.value = null; 
        }
      },
    );

    // 2. Init Firebase Remote Config
    await _setupRemoteConfig();

    _isInitialized = true;
  }

  Future<void> _setupRemoteConfig() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      
      // Set Defaults
      await remoteConfig.setDefaults(<String, dynamic>{
        _remoteThrottleKey: 12,
        _remoteTitleKey: 'Rediscover your favorites!',
        _remoteMsgDefaultKey: 'Missing your favorite? Come back and listen to $songTitle! 🌸',
      });

      // Fetch and Activate
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      
      await remoteConfig.fetchAndActivate();
      debugPrint('NotificationManager: Remote Config activated');
    } catch (e) {
      debugPrint('NotificationManager: Remote Config setup failed: $e');
    }
  }

  /// Cancels any scheduled re-engagement notifications
  Future<void> cancelReengagementNotification() async {
    await _notificationsPlugin.cancel(888); 
  }

  /// Schedules a smart re-engagement notification based on user's trending song
  Future<void> scheduleReengagementNotification() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      final throttleHours = remoteConfig.getInt(_remoteThrottleKey);
      final notificationTitle = remoteConfig.getString(_remoteTitleKey);

      // 1. Throttle check
      final prefs = await SharedPreferences.getInstance();
      final lastShown = prefs.getInt(_lastReengagementKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      if (now - lastShown < throttleHours * 60 * 60 * 1000) {
        debugPrint('Notification: Skipping re-engagement (throttled at $throttleHours hours)');
        return;
      }

      final trendingSong = await ListeningStatisticsService().getTrendingSong();
      if (trendingSong == null) return;

      final String? imagePath = await _downloadThumbnail(trendingSong.thumbnailUrl);
      final String message = _generateGenreAwareMessage(trendingSong, remoteConfig);

      // Large Icon (shows in collapsed shade)
      final AndroidBitmap<Object>? largeIcon = imagePath != null ? FilePathAndroidBitmap(imagePath) : null;

      // Big Picture Style (shows when expanded)
      final BigPictureStyleInformation? bigPictureStyleInformation = imagePath != null
          ? BigPictureStyleInformation(
              FilePathAndroidBitmap(imagePath),
              largeIcon: largeIcon,
              contentTitle: notificationTitle,
              summaryText: message,
            )
          : null;

      final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'reengagement_channel',
        'Smart Suggestions',
        channelDescription: 'Notifications to remind you of your favorite music',
        importance: Importance.max,
        priority: Priority.high,
        largeIcon: largeIcon, 
        styleInformation: bigPictureStyleInformation,
      );

      final NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );

      await _notificationsPlugin.show(
        888,
        notificationTitle,
        message,
        platformChannelSpecifics,
        payload: trendingSong.songId, // Pass the song ID to handle "Tap to Play"
      );

      // Update throttle timestamp
      await prefs.setInt(_lastReengagementKey, now);
      debugPrint('Notification: Re-engagement shown and throttled for $throttleHours hours');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  Future<String?> _downloadThumbnail(String? url) async {
    if (url == null || url.isEmpty) return null;
    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      if (response.statusCode != 200) return null;
      
      final tempDir = await getTemporaryDirectory();
      final String filePath = p.join(tempDir.path, 'trending_art_${DateTime.now().millisecondsSinceEpoch}.jpg');
      final File file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      return filePath;
    } catch (e) {
      return null;
    }
  }

  static const String songTitle = '{songTitle}'; // Placeholder for remote template

  String _generateGenreAwareMessage(SongStatisticsDB song, FirebaseRemoteConfig config) {
    final genre = (song.genre ?? 'Music').toLowerCase();
    final title = song.songTitle;
    
    final Map<String, List<String>> templates = {
      'pop': [
        'Get into the groove with $title! 🎵',
        'Ready for some Pop magic? $title is waiting. ✨',
        'Your daily Pop fix: $title. 🌸',
      ],
      'rock': [
        'Ready to rock? $title is calling! 🤘',
        'Turn it up! $title is waiting to be played. 🔥',
        'Relive the energy of $title. 🎸',
      ],
      'lofi': [
        'Relax and unwind with $title... ☁️',
        'Perfect time for some Chill vibes with $title. ✨',
        'De-stress with your favorite: $title. 🌸',
      ],
      'sad': [
        'Embrace the feels with $title... 🥀',
        'A moment of reflection with $title. ✨',
        'Rediscover the soul of $title.',
      ],
      'energetic': [
        'Boost your mood with $title! ⚡',
        'Time to get moving! $title is ready. 🔥',
        'Power up with your favorite: $title! 🚀',
      ],
    };

    List<String>? selectedPool;
    if (genre.contains('pop')) {
      selectedPool = templates['pop'];
    } else if (genre.contains('rock') || genre.contains('metal')) {
      selectedPool = templates['rock'];
    } else if (genre.contains('lofi') || genre.contains('chill') || genre.contains('ambient')) {
      selectedPool = templates['lofi'];
    } else if (genre.contains('sad') || genre.contains('emotional')) {
      selectedPool = templates['sad'];
    } else if (genre.contains('energ') || genre.contains('dance') || genre.contains('electronic')) {
      selectedPool = templates['energetic'];
    }

    if (selectedPool != null) {
      return selectedPool[Random().nextInt(selectedPool.length)];
    }

    // Fallback to Remote Config default message
    String remoteDefault = config.getString(_remoteMsgDefaultKey);
    if (remoteDefault.contains(songTitle)) {
      return remoteDefault.replaceAll(songTitle, title);
    }
    return remoteDefault.isEmpty ? 'Your favorite song is waiting: $title! 🌸' : remoteDefault;
  }
}
