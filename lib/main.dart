import 'dart:async';
import 'dart:io' as io;
import 'package:beats_music/services/auth_service.dart';
import 'package:beats_music/services/shared_url_resolver_service.dart';
import 'package:beats_music/blocs/downloader/cubit/downloader_cubit.dart';
import 'package:beats_music/blocs/global_events/global_events_cubit.dart';
import 'package:beats_music/blocs/internet_connectivity/cubit/connectivity_cubit.dart';
import 'package:beats_music/blocs/lastdotfm/lastdotfm_cubit.dart';
import 'package:beats_music/blocs/local_music/cubit/local_music_cubit.dart';
import 'package:beats_music/blocs/lyrics/lyrics_cubit.dart';
import 'package:beats_music/blocs/mini_player/mini_player_cubit.dart';
import 'package:beats_music/blocs/notification/notification_cubit.dart';
import 'package:beats_music/blocs/history/cubit/history_cubit.dart';
import 'package:beats_music/blocs/explore/cubit/recently_cubit.dart';
import 'package:beats_music/blocs/player_overlay/player_overlay_cubit.dart';
import 'package:beats_music/blocs/search_suggestions/search_suggestion_bloc.dart';
import 'package:beats_music/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:beats_music/plugins/blocs/plugin/plugin_bloc.dart';
import 'package:beats_music/plugins/blocs/plugin/plugin_event.dart';
import 'package:beats_music/repository/Beats/download_repository.dart';
import 'package:beats_music/repository/Beats/settings_repository.dart';
import 'package:beats_music/services/db/dao/cache_dao.dart';
import 'package:beats_music/services/db/dao/download_dao.dart';
import 'package:beats_music/services/db/dao/history_dao.dart';
import 'package:beats_music/services/db/dao/lyrics_dao.dart';
import 'package:beats_music/services/db/dao/notification_dao.dart';
import 'package:beats_music/services/db/dao/library_dao.dart';
import 'package:beats_music/services/db/dao/playlist_dao.dart';
import 'package:beats_music/services/db/dao/search_history_dao.dart';
import 'package:beats_music/core/di/service_locator.dart';
import 'package:beats_music/services/db/dao/track_dao.dart';
import 'package:beats_music/services/db/dao/settings_dao.dart';
import 'package:beats_music/services/db/db_provider.dart';
import 'package:beats_music/blocs/timer/timer_bloc.dart';
import 'package:beats_music/screens/widgets/global_event_listener.dart';
import 'package:beats_music/screens/widgets/shortcut_indicator_overlay.dart';
import 'package:beats_music/screens/widgets/snackbar.dart';
import 'package:beats_music/services/bootstrap.dart';
import 'package:beats_music/services/keyboard_shortcuts_service.dart';
import 'package:beats_music/services/shortcut_indicator_service.dart';
import 'package:beats_music/core/theme/app_theme.dart';
import 'package:beats_music/services/import_export_service.dart';
import 'package:beats_music/utils/ticker.dart';
import 'package:beats_music/utils/url_checker.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:beats_music/l10n/app_localizations.dart';
import 'package:beats_music/blocs/add_to_playlist/cubit/add_to_playlist_cubit.dart';
import 'package:beats_music/blocs/library/cubit/library_items_cubit.dart';
import 'package:beats_music/plugins/blocs/import/content_import_cubit.dart';
import 'package:beats_music/routes/app_router.dart';
import 'package:beats_music/screens/screen/library_views/cubit/current_playlist_cubit.dart';
import 'package:media_kit/media_kit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_handler/share_handler.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:beats_music/blocs/recommendation/cubit/recommendation_cubit.dart';
import 'package:beats_music/services/listening_statistics_service.dart';
import 'package:beats_music/services/beats_player.dart';
import 'package:beats_music/services/audio_service_initializer.dart';
import 'package:beats_music/blocs/media_player/beats_player_cubit.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:beats_music/services/discord_service.dart';
import 'package:beats_music/services/db/legacy/legacy_migration_service.dart'
    as legacy_migration;
import 'package:beats_music/screens/widgets/legacy_migration_overlay.dart';
import 'package:beats_music/screens/widgets/plugin_bootstrap_overlay.dart';
import 'package:beats_music/services/plugin_bootstrap_service.dart';
import 'package:beats_music/screens/widgets/onboarding_overlay.dart';
import 'package:beats_music/services/onboarding_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:beats_music/services/notification_manager.dart';
import 'package:app_links/app_links.dart';
import 'dart:ui';

/// Module-level reference set once in [main] after [AudioService.init] so
/// top-level handlers (e.g. [_handleYoutubeVideoIntent]) can reach the player
/// without going through a BuildContext.
BeatsMusicPlayer? _activePlayer;

void processIncomingIntent(SharedMedia sharedMedia) {
  if (sharedMedia.content != null && isUrl(sharedMedia.content!)) {
    final content = sharedMedia.content!;
    // Detect YouTube video links and play them directly via a loaded plugin.
    if (extractVideoId(content) != null) {
      _handleYoutubeVideoIntent(content);
    } else {
      SnackbarService.showMessage(
          'Open the Import screen in Library to import from this URL.');
    }
  } else if (
      sharedMedia.attachments != null &&
      sharedMedia.attachments!.isNotEmpty) {
    final attachment = sharedMedia.attachments!.first;
    if (attachment != null) {
      SnackbarService.showMessage('Processing File...');
      importItems(attachment.path);
    }
  }
}

Future<void> _handleYoutubeVideoIntent(String url) async {
  SnackbarService.showMessage('Getting YouTube Audio...');

  final result = await SharedUrlResolverService.resolveYoutubeVideo(url);

  if (result.status == SharedUrlResolveStatus.invalidUrl) {
    SnackbarService.showMessage('Invalid YouTube URL');
    return;
  }

  if (result.status == SharedUrlResolveStatus.noResolver) {
    SnackbarService.showMessage(
        'No loaded content resolver can handle this URL.');
    return;
  }

  final track = result.track;
  if (result.status == SharedUrlResolveStatus.success && track != null) {
    final player = _activePlayer;
    if (player == null) {
      SnackbarService.showMessage('Player not ready. Please try again.');
      return;
    }
    await player.updateQueueTracks([track], doPlay: true);
    SnackbarService.showMessage('Playing: ${track.title}');
    return;
  }

  if (result.status == SharedUrlResolveStatus.failed) {
    SnackbarService.showMessage('Failed to get YouTube audio.');
  }
}

Future<void> importItems(String path) async {
  bool res = await ImportExportService.importMediaItem(path);
  if (res) {
    SnackbarService.showMessage("Media Item Imported");
  } else {
    res = await ImportExportService.importPlaylist(path);
    if (res) {
      SnackbarService.showMessage("Playlist Imported");
    } else {
      SnackbarService.showMessage("Invalid File Format");
    }
  }
}

Future<void> setHighRefreshRate() async {
  if (io.Platform.isAndroid) {
    await FlutterDisplayMode.setHighRefreshRate();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GestureBinding.instance.resamplingEnabled = true;
  MediaKit.ensureInitialized();
  await bootstrapApp();

  try {
    await Firebase.initializeApp();
    
    FlutterError.onError = (FlutterErrorDetails details) {
      // Completely swallow expected network image exceptions (like HTTP 404s)
      if (details.library == 'image resource service' || 
          details.exception is NetworkImageLoadException) {
        return;
      }
      
      if (details.exception is io.SocketException ||
          details.exception is io.HandshakeException ||
          details.exception is io.HttpException) {
        // Report other transient network errors as non-fatal
        FirebaseCrashlytics.instance.recordFlutterError(details);
        return;
      }
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      if (error is NetworkImageLoadException) {
        return true; 
      }
      
      bool isNetworkError = error is io.SocketException || 
                            error is io.HandshakeException || 
                            error is io.HttpException;
      
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: !isNetworkError);
      return true;
    };
    
    // Small delay to allow Firebase Auth to restore the user session
    await Future.delayed(const Duration(milliseconds: 100));
  } catch (e) {
    debugPrint("Firebase init failed: $e");
  }

  final prefs = await SharedPreferences.getInstance();
  final bool seenPermission = prefs.getBool('seen_permission') ?? false;
  final bool loginSkipped = prefs.getBool('login_skipped') ?? false;

  bool isLoggedIn = false;
  String? userEmail;
  try {
    if (Firebase.apps.isNotEmpty) {
      final currentUser = FirebaseAuth.instance.currentUser;
      isLoggedIn = currentUser != null;
      userEmail = currentUser?.email;
    }
  } catch (e) {
    debugPrint("Firebase Auth check failed: $e");
  }

  debugPrint("Main: isLoggedIn=$isLoggedIn, userEmail=$userEmail, loginSkipped=$loginSkipped");

  if (!seenPermission) {
    AppRouter.initialRoute = '/Permission';
  } else if (!isLoggedIn && !loginSkipped) {
    AppRouter.initialRoute = '/Login';
  } else {
    AppRouter.initialRoute = '/Explore';
  }
  
  debugPrint("Main: Initial Route set to: ${AppRouter.initialRoute}");

  DiscordService.initialize();

  await setupAudioSession();
  final player = await PlayerInitializer().getBeatsMusicPlayer();

  _activePlayer = player;

  await NotificationManager().init();

  runApp(MyApp(player: player));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.player});
  final BeatsMusicPlayer player;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  StreamSubscription<SharedMedia>? _intentSub;
  StreamSubscription<Uri>? _linkSub;
  SharedMedia? sharedMedia;
  late final AppLinks _appLinks;

  bool _onboardingPending = false;
  bool _bootstrapPending = false;
  bool _migrationPending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    _appLinks = AppLinks();
    _initDeepLinks();

    _onboardingPending = !OnboardingService.onboardingDone;
    _bootstrapPending = !PluginBootstrapService.bootstrapDone;

    _migrationPending = legacy_migration.needsMigration(
      DBProvider.appSuppDir,
      DBProvider.appDocDir,
    );

    if (!_onboardingPending && !_bootstrapPending) {
      _runPluginSyncIfDue();
    }

    if (io.Platform.isAndroid) {
      initPlatformState();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setHighRefreshRate();
        _requestNotificationPermission();
      });
    }

    // Listen for notification "Tap to Play"
    NotificationManager().onNotificationTap.addListener(_handleNotificationTap);
  }

  void _handleNotificationTap() async {
    final songId = NotificationManager().onNotificationTap.value;
    if (songId == null || songId.isEmpty) return;

    debugPrint('Main: Notification tap received for songId: $songId');
    
    try {
      final track = await TrackDAO(DBProvider.db).getTrackByMediaId(songId);
      if (track != null) {
        debugPrint('Main: Playing song from notification: ${track.title}');
        await widget.player.playTrack(track);
      } else {
        debugPrint('Main: Song from notification not found in database.');
      }
    } catch (e) {
      debugPrint('Main: Error playing song from notification: $e');
    }
  }

  void _runPluginSyncIfDue() {
    unawaited(
      PluginBootstrapService.syncOnAppOpenIfDue(
        pluginService: ServiceLocator.pluginService,
        repositoryService: ServiceLocator.pluginRepositoryService,
        settingsDao: SettingsDAO(DBProvider.db),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    NotificationManager().onNotificationTap.removeListener(_handleNotificationTap);
    _linkSub?.cancel();
    _intentSub?.cancel();
    if (io.Platform.isWindows || io.Platform.isLinux || io.Platform.isMacOS) {
      DiscordService.clearPresence();
    }
    super.dispose();
  }

  Future<void> _initDeepLinks() async {
    // Check initial link
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint("Deep Link Error (Initial): $e");
    }

    // Listen for incoming links
    _linkSub = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });
  }

  Future<void> _handleDeepLink(Uri uri) async {
    final link = uri.toString();
    debugPrint("Deep Link Received: $link");

    if (link.contains('apiKey') && link.contains('oobCode')) {
      // Looks like a Firebase Auth link
      try {
        final prefs = await SharedPreferences.getInstance();
        final email = prefs.getString('magic_link_email');

        if (email != null) {
          debugPrint("Main: Magic Link detected for $email. Completing sign-in...");
          final userCredential = await AuthService().completeSignInWithEmailLink(email, link);

          if (userCredential != null && mounted) {
            // Clear used email
            await prefs.remove('magic_link_email');
            
            // Navigate to explore
            AppRouter.globalRouter.go('/Explore');
            
            SnackbarService.showMessage("Welcome back! Signed in with Magic Link.");
          }
        } else {
           debugPrint("Main: Magic Link detected but no cached email found.");
        }
      } catch (e) {
        debugPrint("Deep Link Auth Error: $e");
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // User left the app - schedule a suggestion for later
      NotificationManager().scheduleReengagementNotification();
    } else if (state == AppLifecycleState.resumed) {
      // User came back - cancel existing suggestion
      NotificationManager().cancelReengagementNotification();
    }
  }

  Future<void> initPlatformState() async {
    try {
      final handler = ShareHandlerPlatform.instance;
      sharedMedia = await handler.getInitialSharedMedia();

      _intentSub = handler.sharedMediaStream.listen((SharedMedia media) {
        if (!mounted) return;
        setState(() => sharedMedia = media);
        processIncomingIntent(media);
      });

      if (!mounted) return;
      if (sharedMedia != null) {
        setState(() {});
        processIncomingIntent(sharedMedia!);
      }
    } catch (error, stackTrace) {
      debugPrint('Failed to initialize share handler: $error\n$stackTrace');
    }
  }

  Future<void> _requestNotificationPermission() async {
    if (io.Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (status.isDenied) {
        await Permission.notification.request();
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    if (_onboardingPending) {
      return OnboardingOverlay(
        onComplete: () {
          setState(() {
            _onboardingPending = false;
          });
          if (!_bootstrapPending) {
            _runPluginSyncIfDue();
          }
        },
      );
    }

    if (_bootstrapPending) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: PluginBootstrapOverlay(
          onComplete: () {
            _runPluginSyncIfDue();
            setState(() => _bootstrapPending = false);
          },
        ),
      );
    }

    if (_migrationPending) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: LegacyMigrationOverlay(
          appSuppDir: DBProvider.appSuppDir,
          appDocDir: DBProvider.appDocDir,
          onComplete: (result) {
            if (!result.success) return;
            setState(() => _migrationPending = false);
          },
        ),
      );
    }

    final trackDao = TrackDAO(DBProvider.db);
    final playlistDao = PlaylistDAO(DBProvider.db, trackDao);
    final historyDao = HistoryDAO(DBProvider.db, trackDao);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => PluginBloc(
            pluginService: ServiceLocator.pluginService,
            eventBus: ServiceLocator.pluginEventBus,
          )..add(const InitializePluginSystem()),
          lazy: false,
        ),
        BlocProvider(
          create: (_) => BeatsPlayerCubit(widget.player),
          lazy: false,
        ),
        BlocProvider(
          create: (context) =>
              MiniPlayerCubit(playerCubit: context.read<BeatsPlayerCubit>()),
          lazy: true,
        ),
        BlocProvider(
          create: (_) => SettingsCubit(
            SettingsRepository(SettingsDAO(DBProvider.db)),
          ),
          lazy: false, // Critical for theming
        ),
        BlocProvider(
          create: (_) => NotificationCubit(
            notificationDao: NotificationDAO(DBProvider.db),
          ),
          lazy: true,
        ),
        BlocProvider(
          create: (context) => TimerBloc(
              ticker: const Ticker(),
              BeatsPlayer: context.read<BeatsPlayerCubit>()),
        ),
        BlocProvider(
          create: (_) => ConnectivityCubit(),
          lazy: false,
        ),
        BlocProvider(
          create: (_) => CurrentPlaylistCubit(playlistDao: playlistDao),
          lazy: true,
        ),
        BlocProvider(
          create: (_) => RecentlyCubit(historyDao),
          lazy: true,
        ),
        BlocProvider(
          create: (_) => HistoryCubit(historyDao: historyDao),
          lazy: true,
        ),
        BlocProvider(
          create: (_) => LibraryItemsCubit(
            playlistDao: playlistDao,
            libraryDao: LibraryDAO(DBProvider.db),
          ),
        ),
        BlocProvider(
          create: (_) => ContentImportCubit(),
          lazy: true,
        ),
        BlocProvider(
          create: (_) => AddToPlaylistCubit(),
          lazy: true,
        ),
        BlocProvider(
          create: (_) => SearchSuggestionBloc(
            searchHistoryDao: SearchHistoryDAO(DBProvider.db),
            pluginService: ServiceLocator.pluginService,
            settingsDao: SettingsDAO(DBProvider.db),
          ),
        ),
        BlocProvider(
          create: (context) => LyricsCubit(
            context.read<BeatsPlayerCubit>(),
            lyricsDao: LyricsDAO(DBProvider.db),
            settingsDao: SettingsDAO(DBProvider.db),
            pluginService: ServiceLocator.pluginService,
          ),
        ),
        BlocProvider(
          create: (context) => LastdotfmCubit(
            playerCubit: context.read<BeatsPlayerCubit>(),
            cacheDao: CacheDAO(DBProvider.db),
            settingsDao: SettingsDAO(DBProvider.db),
            pluginService: ServiceLocator.pluginService,
          ),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => DownloaderCubit(
            connectivityCubit: context.read<ConnectivityCubit>(),
            libraryItemsCubit: context.read<LibraryItemsCubit>(),
            downloadRepo: DownloadRepository(
              DownloadDAO(DBProvider.db, trackDao, playlistDao),
            ),
            settingsDao: SettingsDAO(DBProvider.db),
            pluginService: ServiceLocator.pluginService,
          ),
          lazy: false,
        ),
        BlocProvider(
          create: (_) => GlobalEventsCubit(
            settingsDao: SettingsDAO(DBProvider.db),
          ),
          lazy: true,
        ),
        BlocProvider(
          create: (_) => PlayerOverlayCubit(),
          lazy: true,
        ),
        BlocProvider(
          create: (_) => ShortcutIndicatorCubit(),
          lazy: true,
        ),
        BlocProvider(
          create: (_) => LocalMusicCubit(),
          lazy: true,
        ),
        BlocProvider(
          create: (_) => RecommendationCubit(
            pluginService: ServiceLocator.pluginService,
            statsService: ListeningStatisticsService(),
          ),
          lazy: true,
        ),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) {
          final locale = settingsState.languageCode.isEmpty
              ? null
              : Locale(settingsState.languageCode);

          return KeyboardShortcutsHandler(
            child: ShortcutIndicatorOverlay(
              child: MaterialApp.router(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                locale: locale,
                builder: (context, child) => ResponsiveBreakpoints.builder(
                  breakpoints: [
                    const Breakpoint(start: 0, end: 450, name: MOBILE),
                    const Breakpoint(start: 451, end: 800, name: TABLET),
                    const Breakpoint(start: 801, end: 1920, name: DESKTOP),
                    const Breakpoint(
                        start: 1921, end: double.infinity, name: '4K'),
                  ],
                  child: GlobalEventListener(
                    navigatorKey: GlobalRoutes.globalRouterKey,
                    child: child!,
                  ),
                ),
                scaffoldMessengerKey: SnackbarService.messengerKey,
                routerConfig: GlobalRoutes.globalRouter,
                theme: Default_Theme().defaultThemeData,
                scrollBehavior: CustomScrollBehavior(),
                debugShowCheckedModeBanner: false,
              ),
            ),
          );
        },
      ),
    );
  }
}

class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus,
      };
}


