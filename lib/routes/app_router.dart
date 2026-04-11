import 'package:beats_music/core/constants/route_paths.dart';
import 'package:beats_music/screens/widgets/global_footer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:beats_music/screens/screen/common_views/add_to_playlist_screen.dart';
import 'package:beats_music/screens/screen/explore_screen.dart';
import 'package:beats_music/screens/screen/library_screen.dart';
import 'package:beats_music/screens/screen/library_views/import_media_view.dart';
import 'package:beats_music/screens/screen/library_views/import_process_screen.dart';
import 'package:beats_music/screens/screen/library_views/playlist_screen.dart';
import 'package:beats_music/screens/screen/offline_screen.dart';
import 'package:beats_music/screens/screen/local_music_screen.dart';
import 'package:beats_music/screens/screen/search_screen.dart';
import 'package:beats_music/screens/screen/chart/chart_view.dart';
import 'package:beats_music/screens/auth/login_screen.dart';
import 'package:beats_music/screens/auth/permission_screen.dart';
import 'package:beats_music/screens/screen/home_views/preference_selection_screen.dart';
import 'package:beats_music/screens/screen/home_views/wrapped_view.dart';
import 'package:beats_music/screens/auth/email_auth_screen.dart';

/// Canonical app router configuration.
///
/// Use [AppRouter] in new code. The [GlobalRoutes] typedef at the bottom
/// provides backward-compatible access for existing callers.
class AppRouter {
  static final globalRouterKey = GlobalKey<NavigatorState>();
  static String initialRoute = '/Explore';

  static final globalRouter = GoRouter(
    initialLocation: initialRoute,
    navigatorKey: globalRouterKey,
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => initialRoute,
      ),
      GoRoute(
        path: '/AddToPlaylist',
        parentNavigatorKey: globalRouterKey,
        name: RoutePaths.addToPlaylistScreen,
        builder: (context, state) => const AddToPlaylistScreen(),
      ),
      GoRoute(
        path: '/Login',
        name: RoutePaths.loginScreen,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/EmailAuth',
        name: RoutePaths.emailAuthScreen,
        builder: (context, state) => const EmailAuthScreen(),
      ),
      GoRoute(
        path: '/Permission',
        name: RoutePaths.permissionScreen,
        builder: (context, state) => const PermissionScreen(),
      ),
      GoRoute(
        path: '/PreferenceSelection',
        name: RoutePaths.preferenceSelectionScreen,
        builder: (context, state) => const PreferenceSelectionScreen(),
      ),
      GoRoute(
        path: '/Wrapped',
        name: RoutePaths.wrappedScreen,
        builder: (context, state) => const WrappedView(),
      ),
      StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              GlobalFooter(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(
                  name: RoutePaths.exploreScreen,
                  path: '/Explore',
                  builder: (context, state) => const ExploreScreen(),
                  routes: [
                    GoRoute(
                        name: RoutePaths.chartScreen,
                        path: 'ChartScreen',
                        builder: (context, state) {
                          final qp = state.uri.queryParameters;
                          return ChartScreen(
                            pluginId: qp['pluginId'] ?? '',
                            chartId: qp['chartId'] ?? '',
                            chartTitle: qp['chartTitle'] ?? 'Chart',
                          );
                        }),
                  ])
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                name: RoutePaths.searchScreen,
                path: '/Search',
                builder: (context, state) {
                  if (state.uri.queryParameters['query'] != null) {
                    return SearchScreen(
                      searchQuery:
                          state.uri.queryParameters['query']!.toString(),
                    );
                  } else {
                    return const SearchScreen();
                  }
                },
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                  name: RoutePaths.libraryScreen,
                  path: '/Library',
                  builder: (context, state) => const LibraryScreen(),
                  routes: [
                    GoRoute(
                      path: RoutePaths.importMediaFromPlatforms,
                      name: RoutePaths.importMediaFromPlatforms,
                      builder: (context, state) =>
                          const ImportMediaFromPlatformsView(),
                    ),
                    GoRoute(
                      path: RoutePaths.importProcess,
                      name: RoutePaths.importProcess,
                      builder: (context, state) {
                        final pluginId =
                            state.uri.queryParameters['pluginId'] ?? '';
                        return ImportProcessScreen(pluginId: pluginId);
                      },
                    ),
                    GoRoute(
                      name: RoutePaths.playlistView,
                      path: RoutePaths.playlistView,
                      builder: (context, state) {
                        final initialPlaylistName = state.extra as String?;
                        return PlaylistView(
                          initialPlaylistName: initialPlaylistName,
                        );
                      },
                    ),
                    GoRoute(
                      name: RoutePaths.offlineScreen,
                      path: 'Offline',
                      builder: (context, state) => const OfflineScreen(),
                    ),
                  ]),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                name: RoutePaths.localMusicScreen,
                path: '/LocalMusic',
                builder: (context, state) => const LocalMusicScreen(),
              ),
            ]),
          ])
    ],
  );
}

/// Backward-compat alias for [AppRouter].
/// Prefer importing from [routes/app_router.dart] and using [AppRouter] directly.
typedef GlobalRoutes = AppRouter;


