import 'dart:async';
import 'dart:io' as io;
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
import 'package:beats_music/core/di/service_locator.dart';
import 'package:beats_music/services/db/dao/settings_dao.dart';
import 'package:beats_music/services/db/db_provider.dart';
import 'dart:ui';

void processIncomingIntent(SharedMedia sharedMedia) {
  if (sharedMedia.content != null && isUrl(sharedMedia.content!)) {
    SnackbarService.showMessage(
        'Open the Import screen in Library to import from this URL.');
  } else if (sharedMedia.attachments != null &&
      sharedMedia.attachments!.isNotEmpty) {
    final attachment = sharedMedia.attachments!.first;
    if (attachment != null) {
      SnackbarService.showMessage('Processing File...');
      importItems(attachment.path);
    }
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
    
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    
    // Small delay to allow Firebase Auth to restore the user session
    await Future.delayed(const Duration(milliseconds: 500));
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

  setHighRefreshRate();
  DiscordService.initialize();

  final player = await AudioService.init(
    builder: () => BeatsMusicPlayer(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.beats.app.notification',
      androidNotificationChannelName: 'Beats',
      androidNotificationIcon: 'mipmap/ic_launcher',
      androidResumeOnClick: true,
      androidShowNotificationBadge: true,
      androidStopForegroundOnPause: false,
      notificationColor: Default_Theme.accentColor2,
    ),
  );

  runApp(MyApp(player: player));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.player});
  final BeatsMusicPlayer player;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<SharedMedia>? _intentSub;
  SharedMedia? sharedMedia;

  bool _onboardingPending = false;
  bool _bootstrapPending = false;
  bool _migrationPending = false;

  @override
  void initState() {
    super.initState();

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
      _requestNotificationPermission();
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
  void dispose() {
    _intentSub?.cancel();
    if (io.Platform.isWindows || io.Platform.isLinux || io.Platform.isMacOS) {
      DiscordService.clearPresence();
    }
    super.dispose();
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


