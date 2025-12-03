import 'dart:async';
import 'dart:io' as io;
import 'package:beats_music/blocs/downloader/cubit/downloader_cubit.dart';
import 'package:beats_music/blocs/global_events/global_events_cubit.dart';
import 'package:beats_music/blocs/internet_connectivity/cubit/connectivity_cubit.dart';
import 'package:beats_music/blocs/lastdotfm/lastdotfm_cubit.dart';
import 'package:beats_music/blocs/lyrics/lyrics_cubit.dart';
import 'package:beats_music/blocs/mini_player/mini_player_bloc.dart';
import 'package:beats_music/blocs/notification/notification_cubit.dart';
import 'package:beats_music/blocs/player_overlay/player_overlay_cubit.dart';
import 'package:beats_music/blocs/search_suggestions/search_suggestion_bloc.dart';
import 'package:beats_music/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:beats_music/blocs/timer/timer_bloc.dart';
import 'package:beats_music/repository/Youtube/youtube_api.dart';
import 'package:beats_music/screens/widgets/global_event_listener.dart';
import 'package:beats_music/screens/widgets/snackbar.dart';
import 'package:beats_music/services/db/beats_music_db_service.dart';
import 'package:beats_music/services/shortcuts_intents.dart';
import 'package:beats_music/theme_data/default.dart';
import 'package:beats_music/services/import_export_service.dart';
import 'package:beats_music/utils/external_list_importer.dart';
import 'package:beats_music/utils/ticker.dart';
import 'package:beats_music/utils/url_checker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:beats_music/blocs/add_to_playlist/cubit/add_to_playlist_cubit.dart';
import 'package:beats_music/blocs/library/cubit/library_items_cubit.dart';
import 'package:beats_music/blocs/search/fetch_search_results.dart';
import 'package:beats_music/routes_and_consts/routes.dart';
import 'package:beats_music/screens/screen/library_views/cubit/current_playlist_cubit.dart';
import 'package:beats_music/screens/screen/library_views/cubit/import_playlist_cubit.dart';
import 'package:beats_music/services/db/cubit/beats_music_db_cubit.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_handler/share_handler.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'blocs/mediaPlayer/beats_player_cubit.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:beats_music/services/discord_service.dart';

void processIncomingIntent(SharedMedia sharedMedia) {
  // Check if there's text content that might be a URL
  if (sharedMedia.content != null && isUrl(sharedMedia.content!)) {
    final urlType = getUrlType(sharedMedia.content!);
    switch (urlType) {
      case UrlType.spotifyTrack:
        ExternalMediaImporter.sfyMediaImporter(sharedMedia.content!)
            .then((value) async {
          if (value != null) {
            await beatsPlayerCubit.beatsMusicPlayer.addQueueItem(
              value,
            );
          }
        });
        break;
      case UrlType.spotifyPlaylist:
        SnackbarService.showMessage("Import Spotify Playlist from library!");
        break;
      case UrlType.youtubePlaylist:
        SnackbarService.showMessage("Import Youtube Playlist from library!");
        break;
      case UrlType.spotifyAlbum:
        SnackbarService.showMessage("Import Spotify Album from library!");
        break;
      case UrlType.youtubeVideo:
        ExternalMediaImporter.ytMediaImporter(sharedMedia.content!)
            .then((value) async {
          if (value != null) {
            await beatsPlayerCubit.beatsMusicPlayer
                .updateQueue([value], doPlay: true);
          }
        });
        break;
      case UrlType.other:
        // Handle as file if it's a file URL
        if (sharedMedia.attachments != null &&
            sharedMedia.attachments!.isNotEmpty) {
          final attachment = sharedMedia.attachments!.first;
          SnackbarService.showMessage("Processing File...");
          importItems(attachment!.path);
        }
    }
  } else if (sharedMedia.attachments != null &&
      sharedMedia.attachments!.isNotEmpty) {
    // Handle attachments
    // todo: handle multiple attachments
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

late BeatsPlayerCubit beatsPlayerCubit;
void setupPlayerCubit() {
  beatsPlayerCubit = BeatsPlayerCubit();
}

Future<void> initServices() async {
  String appDocPath = (await getApplicationDocumentsDirectory()).path;
  String appSuppPath = (await getApplicationSupportDirectory()).path;
  BeatsMusicDBService(appDocPath: appDocPath, appSuppPath: appSuppPath);
  YouTubeServices(appDocPath: appDocPath, appSuppPath: appSuppPath);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GestureBinding.instance.resamplingEnabled = true;
  if (io.Platform.isLinux || io.Platform.isWindows) {
    JustAudioMediaKit.ensureInitialized(
      linux: true,
      windows: true,
    );
  }
  await initServices();
  setHighRefreshRate();
  setupPlayerCubit();
  DiscordService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Initialize the player
  // This widget is the root of your application.
  late StreamSubscription _intentSub;
  SharedMedia? sharedMedia;
  @override
  void initState() {
    super.initState();
    if (io.Platform.isAndroid) {
      initPlatformState();
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    final handler = ShareHandlerPlatform.instance;
    sharedMedia = await handler.getInitialSharedMedia();

    _intentSub = handler.sharedMediaStream.listen((SharedMedia media) {
      if (!mounted) return;
      setState(() {
        sharedMedia = media;
      });
      if (sharedMedia != null) {
        processIncomingIntent(sharedMedia!);
      }
    });
    if (!mounted) return;

    setState(() {
      // If there's initial shared media, process it
      if (sharedMedia != null) {
        processIncomingIntent(sharedMedia!);
      }
    });
  }

  @override
  void dispose() {
    _intentSub.cancel();
    beatsPlayerCubit.beatsMusicPlayer.audioPlayer.dispose();
    beatsPlayerCubit.close();
    if (io.Platform.isWindows || io.Platform.isLinux || io.Platform.isMacOS) {
      DiscordService.clearPresence();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => beatsPlayerCubit,
          lazy: false,
        ),
        BlocProvider(
            create: (context) =>
                MiniPlayerBloc(playerCubit: beatsPlayerCubit),
            lazy: true),
        BlocProvider(
          create: (context) => BeatsMusicDBCubit(),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => SettingsCubit(),
          lazy: false,
        ),
        BlocProvider(create: (context) => NotificationCubit(), lazy: false),
        BlocProvider(
            create: (context) => TimerBloc(
                ticker: const Ticker(), beatsPlayerCubit: beatsPlayerCubit)),
        BlocProvider(
          create: (context) => ConnectivityCubit(),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => CurrentPlaylistCubit(
              beatsMusicDBCubit: context.read<BeatsMusicDBCubit>()),
          lazy: false,
        ),
        BlocProvider(
          create: (context) =>
              LibraryItemsCubit(beatsMusicDBCubit: context.read<BeatsMusicDBCubit>()),
        ),
        BlocProvider(
          create: (context) => AddToPlaylistCubit(),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => ImportPlaylistCubit(),
        ),
        BlocProvider(
          create: (context) => FetchSearchResultsCubit(),
        ),
        BlocProvider(create: (context) => SearchSuggestionBloc()),
        BlocProvider(
          create: (context) => LyricsCubit(beatsPlayerCubit),
        ),
        BlocProvider(
          create: (context) => LastdotfmCubit(playerCubit: beatsPlayerCubit),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => DownloaderCubit(
            connectivityCubit: context.read<ConnectivityCubit>(),
            libraryItemsCubit: context.read<LibraryItemsCubit>(),
          ),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => GlobalEventsCubit(),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => PlayerOverlayCubit(),
          lazy: false,
        ),
      ],
      child: BlocBuilder<BeatsPlayerCubit, BeatsPlayerState>(
        builder: (context, state) {
          if (state is BeatsPlayerInitial) {
            return const Center(
              child: SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            return MaterialApp.router(
              shortcuts: {
                LogicalKeySet(LogicalKeyboardKey.space):
                    const PlayPauseIntent(),
                LogicalKeySet(LogicalKeyboardKey.mediaPlayPause):
                    const PlayPauseIntent(),
                LogicalKeySet(LogicalKeyboardKey.arrowLeft):
                    const PreviousIntent(),
                LogicalKeySet(LogicalKeyboardKey.arrowRight):
                    const NextIntent(),
                LogicalKeySet(LogicalKeyboardKey.keyR): const RepeatIntent(),
                LogicalKeySet(LogicalKeyboardKey.keyL): const LikeIntent(),
                LogicalKeySet(
                        LogicalKeyboardKey.arrowRight, LogicalKeyboardKey.alt):
                    const NSecForwardIntent(),
                LogicalKeySet(
                        LogicalKeyboardKey.arrowLeft, LogicalKeyboardKey.alt):
                    const NSecBackwardIntent(),
                LogicalKeySet(LogicalKeyboardKey.arrowUp):
                    const VolumeUpIntent(),
                LogicalKeySet(LogicalKeyboardKey.arrowDown):
                    const VolumeDownIntent(),
              },
              actions: {
                PlayPauseIntent: CallbackAction(onInvoke: (intent) {
                  if (context
                      .read<BeatsPlayerCubit>()
                      .beatsMusicPlayer
                      .audioPlayer
                      .playing) {
                    context
                        .read<BeatsPlayerCubit>()
                        .beatsMusicPlayer
                        .audioPlayer
                        .pause();
                  } else {
                    context
                        .read<BeatsPlayerCubit>()
                        .beatsMusicPlayer
                        .audioPlayer
                        .play();
                  }
                  return null;
                }),
                NextIntent: CallbackAction(onInvoke: (intent) {
                  context.read<BeatsPlayerCubit>().beatsMusicPlayer.skipToNext();
                  return null;
                }),
                PreviousIntent: CallbackAction(onInvoke: (intent) {
                  context
                      .read<BeatsPlayerCubit>()
                      .beatsMusicPlayer
                      .skipToPrevious();
                  return null;
                }),
                NSecForwardIntent: CallbackAction(onInvoke: (intent) {
                  context
                      .read<BeatsPlayerCubit>()
                      .beatsMusicPlayer
                      .seekNSecForward(const Duration(seconds: 5));
                  return null;
                }),
                NSecBackwardIntent: CallbackAction(onInvoke: (intent) {
                  context
                      .read<BeatsPlayerCubit>()
                      .beatsMusicPlayer
                      .seekNSecBackward(const Duration(seconds: 5));
                  return null;
                }),
                VolumeUpIntent: CallbackAction(onInvoke: (intent) {
                  context
                      .read<BeatsPlayerCubit>()
                      .beatsMusicPlayer
                      .audioPlayer
                      .setVolume((context
                                  .read<BeatsPlayerCubit>()
                                  .beatsMusicPlayer
                                  .audioPlayer
                                  .volume +
                              0.1)
                          .clamp(0.0, 1.0));
                  return null;
                }),
                VolumeDownIntent: CallbackAction(onInvoke: (intent) {
                  context
                      .read<BeatsPlayerCubit>()
                      .beatsMusicPlayer
                      .audioPlayer
                      .setVolume((context
                                  .read<BeatsPlayerCubit>()
                                  .beatsMusicPlayer
                                  .audioPlayer
                                  .volume -
                              0.1)
                          .clamp(0.0, 1.0));
                  return null;
                }),
              },
              builder: (context, child) => ResponsiveBreakpoints.builder(
                breakpoints: [
                  const Breakpoint(start: 0, end: 450, name: MOBILE),
                  const Breakpoint(start: 451, end: 800, name: TABLET),
                  const Breakpoint(start: 801, end: 1920, name: DESKTOP),
                  const Breakpoint(
                      start: 1921, end: double.infinity, name: '4K'),
                ],
                child: GlobalEventListener(
                  child: child!,
                  navigatorKey: GlobalRoutes.globalRouterKey,
                ),
              ),
              scaffoldMessengerKey: SnackbarService.messengerKey,
              routerConfig: GlobalRoutes.globalRouter,
              theme: Default_Theme().defaultThemeData,
              scrollBehavior: CustomScrollBehavior(),
              debugShowCheckedModeBanner: false,
            );
          }
        },
      ),
    );
  }
}

class CustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        // etc.
      };
}
