import 'dart:developer';
import 'package:beats_music/blocs/internet_connectivity/cubit/connectivity_cubit.dart';
import 'package:beats_music/blocs/lastdotfm/lastdotfm_cubit.dart';
import 'package:beats_music/blocs/notification/notification_cubit.dart';
import 'package:beats_music/blocs/recommendation/cubit/recommendation_cubit.dart';
import 'package:beats_music/blocs/recommendation/cubit/recommendation_state.dart';
import 'package:beats_music/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:beats_music/core/di/service_locator.dart';
import 'package:beats_music/core/models/exported.dart';
import 'package:beats_music/plugins/blocs/content/content_bloc.dart';
import 'package:beats_music/plugins/blocs/content/content_event.dart';
import 'package:beats_music/plugins/blocs/content/content_state.dart';
import 'package:beats_music/plugins/blocs/plugin/plugin_bloc.dart';
import 'package:beats_music/plugins/blocs/plugin/plugin_state.dart';
import 'package:beats_music/blocs/explore/cubit/recently_cubit.dart';
import 'package:beats_music/blocs/library/cubit/library_items_cubit.dart';
import 'package:beats_music/screens/screen/home_views/recents_view.dart';
import 'package:beats_music/screens/screen/home_views/setting_views/about.dart';
import 'package:beats_music/screens/widgets/sign_board_widget.dart';
import 'package:flutter/material.dart';
import 'package:beats_music/screens/screen/home_views/notification_view.dart';
import 'package:beats_music/screens/screen/home_views/setting_view.dart';
import 'package:beats_music/screens/screen/home_views/timer_view.dart';
import 'package:beats_music/screens/widgets/plugin_bootstrap_overlay.dart';
import 'package:beats_music/core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:beats_music/core/constants/route_paths.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:go_router/go_router.dart';
import 'chart/carousal_widget.dart';
import '../widgets/horizontal_card_view.dart';
import '../widgets/side_drawer.dart';
import 'package:badges/badges.dart' as badges;

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  bool isUpdateChecked = false;
  late final ContentBloc _homeContentBloc;
  Future<List<Track>> lFMData = Future.value(const []);

  @override
  void initState() {
    super.initState();
    _homeContentBloc = ContentBloc(pluginService: ServiceLocator.pluginService);
    _tryLoadHomeSections();
    
    // Trigger Recommendations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerRecommendations();
    });
  }

  void _triggerRecommendations() {
    final pluginState = context.read<PluginBloc>().state;
    final allIds = pluginState.loadedContentResolvers.map((p) => p.manifest.id).toList();
    if (allIds.isNotEmpty) {
      context.read<RecommendationCubit>().fetchRecommendations(resolverPluginIds: allIds);
    }
  }

  /// Only loads home sections when both settings are ready and plugins are loaded.
  void _tryLoadHomeSections() {
    final settingsState = context.read<SettingsCubit>().state;
    if (!settingsState.settingsReady) return;

    final pluginState = context.read<PluginBloc>().state;
    final contentResolvers = pluginState.loadedContentResolvers;
    if (contentResolvers.isEmpty) return;

    final preferredId = settingsState.homePluginId;
    // If the user's preferred plugin is installed but not yet loaded, wait for it.
    // This prevents flashing the wrong plugin's home page on startup.
    if (preferredId.isNotEmpty) {
      final isAlreadyLoaded =
          contentResolvers.any((p) => p.manifest.id == preferredId);
      if (!isAlreadyLoaded) {
        final isInstalled = pluginState.availablePlugins
            .any((p) => p.manifest.id == preferredId);
        if (isInstalled) return; // Preferred plugin is loading — wait for it
      }
    }

    final pluginId = _effectiveHomePluginId(contentResolvers);

    // Don't reload if we're already showing content from this plugin.
    if (_homeContentBloc.state.activePluginId == pluginId &&
        _homeContentBloc.state.homeSections != null) {
      return;
    }

    _homeContentBloc.add(GetHomeSections(pluginId: pluginId));
  }

  String _effectiveHomePluginId(List<dynamic> loadedResolvers) {
    final preferredId = context.read<SettingsCubit>().state.homePluginId;
    final hasPreferred = preferredId.isNotEmpty &&
        loadedResolvers.any((plugin) => plugin.manifest.id == preferredId);
    return hasPreferred ? preferredId : loadedResolvers.first.manifest.id;
  }

  @override
  void dispose() {
    _homeContentBloc.close();
    super.dispose();
  }

  Future<List<Track>> fetchLFMPicks(bool state, BuildContext ctx) async {
    if (state) {
      try {
        final data = await lFMData;
        if (data.isNotEmpty) return data;
        if (ctx.mounted) {
          final pluginState = ctx.read<PluginBloc>().state;
          final priority = ctx.read<SettingsCubit>().state.resolverPriority;
          final allIds = pluginState.loadedContentResolvers
              .map((p) => p.manifest.id)
              .toList();
          final resolverIds = [
            ...priority.where(allIds.contains),
            ...allIds.where((id) => !priority.contains(id)),
          ];
          lFMData = ctx.read<LastdotfmCubit>().getRecommendedTracks(
                resolverPluginIds: resolverIds,
              );
        }
        return (await lFMData);
      } catch (e) {
        log(e.toString(), name: "ExploreScreen");
      }
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MultiBlocListener(
        listeners: [
          BlocListener<SettingsCubit, SettingsState>(
            listenWhen: (previous, current) =>
                previous.homePluginId != current.homePluginId ||
                (!previous.settingsReady && current.settingsReady),
            listener: (context, state) {
              _homeContentBloc.add(const ClearHomeSections());
              _tryLoadHomeSections();
            },
          ),
          BlocListener<PluginBloc, PluginState>(
            listenWhen: (previous, current) {
              return previous.loadedContentResolvers !=
                      current.loadedContentResolvers ||
                  previous.loadedPluginIds != current.loadedPluginIds;
            },
            listener: (context, state) {
              if (state.loadedContentResolvers.isEmpty) {
                _homeContentBloc.add(const ClearHomeSections());
                return;
              }

              final activePluginId = _homeContentBloc.state.activePluginId;
              if (activePluginId != null &&
                  !state.loadedPluginIds.contains(activePluginId)) {
                // Active plugin was unloaded — reload from preferred.
                _homeContentBloc.add(const ClearHomeSections());
                _tryLoadHomeSections();
                return;
              }

              // Plugin list changed — check if preferred plugin is different.
              _tryLoadHomeSections();
            },
          ),
        ],
        child: Scaffold(
          drawer: const SideDrawer(),
          body: RefreshIndicator(
            onRefresh: () async {
              final pluginId = _effectiveHomePluginId(
                context.read<PluginBloc>().state.loadedContentResolvers,
              );
              _homeContentBloc.add(
                GetHomeSections(pluginId: pluginId, bypassCache: true),
              );
            },
            child: CustomScrollView(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              slivers: [
                const CustomDiscoverBar(),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      const ShortcutGrid(),
                      const CaraouselWidget(),
                      // Jump back in (Recently Played) Section
                      BlocBuilder<RecentlyCubit, RecentlyCubitState>(
                        builder: (context, state) {
                          if (state.tracks.isNotEmpty) {
                            final section = Section(
                              id: 'recently_played',
                              title: 'Jump back in',
                              cardType: CardType.carousel,
                              items: state.tracks.map((t) => MediaItem.track(t)).toList(),
                            );
                            return HorizontalCardView(
                              section: section,
                              pluginId: '',
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      // Recents (User Library Playlists) Section
                      BlocBuilder<LibraryItemsCubit, LibraryItemsState>(
                        builder: (context, state) {
                          if (state.playlists.isNotEmpty) {
                            final recentsSection = Section(
                              id: 'library_recents',
                              title: 'Recents',
                              cardType: CardType.carousel,
                              items: state.playlists.map((p) {
                                return MediaItem.playlist(
                                  PlaylistSummary(
                                    id: p.storageKey,
                                    title: p.playlistName,
                                    owner: p.subTitle ?? 'Playlist',
                                    thumbnail: Artwork(
                                      url: p.imageUrls.isNotEmpty ? p.imageUrls.first : '',
                                      urlLow: null,
                                      urlHigh: null,
                                      layout: ImageLayout.square,
                                    ),
                                    url: null,
                                  ),
                                );
                              }).toList(),
                            );
                            return HorizontalCardView(
                              section: recentsSection,
                              pluginId: '',
                              trailingText: 'Show all',
                              onTrailingTap: () {
                                context.go('/Library');
                              },
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      // More of what you like (AI Recommendations) Section
                      BlocBuilder<RecommendationCubit, RecommendationState>(
                        builder: (context, state) {
                          if (state is RecommendationLoaded && state.tracks.isNotEmpty) {
                            final section = Section(
                              id: 'recommendations',
                              title: state.title.isNotEmpty ? state.title : 'More of what you like',
                              cardType: CardType.carousel,
                              items: state.tracks.map((t) => MediaItem.track(t)).toList(),
                            );
                            return HorizontalCardView(
                              section: section,
                              pluginId: '',
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      // Last.Fm Picks Section
                      BlocBuilder<SettingsCubit, SettingsState>(
                        builder: (context, state) {
                          if (state.lFMPicks) {
                            return FutureBuilder(
                              future: fetchLFMPicks(state.lFMPicks, context),
                              builder: (context, snapshot) {
                                if (snapshot.hasData &&
                                    (snapshot.data?.isNotEmpty ?? false)) {
                                  final section = Section(
                                    id: 'lfm_picks',
                                    title: 'Last.Fm Picks',
                                    cardType: CardType.carousel,
                                    items: snapshot.data!.map((t) => MediaItem.track(t)).toList(),
                                  );
                                  return HorizontalCardView(
                                    section: section,
                                    pluginId: '',
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      // Home sections from plugin
                      BlocBuilder<ContentBloc, ContentState>(
                        bloc: _homeContentBloc,
                        builder: (context, state) {
                          final loadedResolvers = context
                              .read<PluginBloc>()
                              .state
                              .loadedContentResolvers;
                          final allLoadedIds =
                              context.read<PluginBloc>().state.loadedPluginIds;

                          if (loadedResolvers.isEmpty) {
                            final hasOtherPlugins = allLoadedIds.isNotEmpty;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Column(
                                children: [
                                  SignBoardWidget(
                                    message: hasOtherPlugins
                                        ? 'No content source loaded.\nInstall a "Content Resolver" to see the Home feed.'
                                        : 'No content plugin loaded.\nSync repositories to get started.',
                                    icon: hasOtherPlugins
                                        ? MingCute.warning_line
                                        : MingCute.plugin_2_line,
                                  ),
                                  const SizedBox(height: 16),
                                  if (!hasOtherPlugins)
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        // Trigger Bootstrap Overlay
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) =>
                                              PluginBootstrapOverlay(
                                            onComplete: () =>
                                                Navigator.pop(context),
                                          ),
                                        );
                                      },
                                      icon: const Icon(MingCute.refresh_3_line),
                                      label: const Text('Sync Plugins Now'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Default_Theme.successAccent,
                                        foregroundColor: Colors.white,
                                      ),
                                    )
                                  else
                                    TextButton.icon(
                                      onPressed: () => context.go('/Settings'),
                                      icon: const Icon(MingCute.settings_2_line, size: 18),
                                      label: const Text('Manage Plugins'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Default_Theme.accentColor2,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }

                          final sections = state.homeSections ?? const [];
                          final hasSections = sections.isNotEmpty;
                          final activePluginId = state.activePluginId;
                          if (activePluginId != null &&
                              !context
                                  .read<PluginBloc>()
                                  .state
                                  .loadedPluginIds
                                  .contains(activePluginId) &&
                              !hasSections) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: SignBoardWidget(
                                message:
                                    'Refreshing Discover source...\nThe previous source is no longer available.',
                                icon: MingCute.warning_line,
                              ),
                            );
                          }

                          if (state.homeSectionsStatus ==
                              DetailStatus.loading) {
                            if (hasSections) {
                              return _HomeSectionsList(
                                sections: sections,
                                contentBloc: _homeContentBloc,
                                state: state,
                              );
                            }

                            return BlocBuilder<ConnectivityCubit,
                                ConnectivityState>(
                              builder: (context, connState) {
                                if (connState ==
                                    ConnectivityState.disconnected) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: SignBoardWidget(
                                      message: 'No Internet Connection!',
                                      icon: MingCute.wifi_off_line,
                                    ),
                                  );
                                }

                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 40),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Default_Theme.accentColor2,
                                    ),
                                  ),
                                );
                              },
                            );
                          }

                          if (state.homeSectionsStatus == DetailStatus.error) {
                            if (hasSections) {
                              return _HomeSectionsList(
                                sections: sections,
                                contentBloc: _homeContentBloc,
                                state: state,
                              );
                            }

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: SignBoardWidget(
                                message: state.error ??
                                    'Failed to load home sections.',
                                icon: MingCute.sweats_line,
                              ),
                            );
                          }

                          if (!hasSections) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: SizedBox.shrink(),
                            );
                          }

                          return _HomeSectionsList(
                            sections: sections,
                            contentBloc: _homeContentBloc,
                            state: state,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: Default_Theme.themeColor,
        ),
      ),
    );
  }
}

class _HomeSectionsList extends StatelessWidget {
  final List<Section> sections;
  final ContentBloc contentBloc;
  final ContentState state;

  const _HomeSectionsList({
    required this.sections,
    required this.contentBloc,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemExtent: 275,
      padding: const EdgeInsets.only(top: 0),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final section = sections[index];
        return HorizontalCardView(
          section: section,
          pluginId: contentBloc.state.activePluginId ?? '',
          canLoadMore: section.moreLink != null,
          isLoadingMore: state.isHomeSectionLoading(section.id),
          onLoadMore: section.moreLink == null
              ? null
              : () {
                  contentBloc.add(
                    LoadMoreHomeSectionItems(
                      pluginId: contentBloc.state.activePluginId ?? '',
                      sectionId: section.id,
                      moreLink: section.moreLink!,
                    ),
                  );
                },
        );
      },
    );
  }
}

class CustomDiscoverBar extends StatelessWidget {
  const CustomDiscoverBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      surfaceTintColor: Default_Theme.themeColor,
      backgroundColor: Default_Theme.themeColor,
      leading: Builder(builder: (context) {
        return IconButton(
          icon: const Icon(MingCute.menu_fill, size: 30),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        );
      }),
      actions: const [
        NotificationIcon(),
        StatsIcon(),
        TimerIcon(),
        SizedBox(width: 8),
      ],
    );
  }
}

class ShortcutGrid extends StatelessWidget {
  const ShortcutGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.8,
        children: [
          ShortcutCard(
            title: 'Liked Songs',
            icon: MingCute.heart_fill,
            color: const Color(0xFF9E54E5), // Purple
            onTap: () {
              context.goNamed(RoutePaths.playlistView, extra: 'Liked');
            },
          ),
          ShortcutCard(
            title: 'Recently Played',
            icon: MingCute.time_fill,
            color: const Color(0xFF1A73E8), // Blue
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryView()),
              );
            },
          ),
          ShortcutCard(
            title: 'Your Top Mix',
            icon: MingCute.star_fill,
            color: const Color(0xFFF29900), // Orange
            onTap: () {
              // Usually a custom mix, for now go to discover
              context.go('/Search');
            },
          ),
          ShortcutCard(
            title: 'Discover Weekly',
            icon: MingCute.compass_fill,
            color: const Color(0xFF34A853), // Green
            onTap: () {
               context.go('/Search');
            },
          ),
          ShortcutCard(
            title: 'Release Radar',
            icon: MingCute.radar_line,
            color: const Color(0xFFEA4335), // Red
            onTap: () {
               context.go('/Search');
            },
          ),
          ShortcutCard(
            title: 'Daily Mix 1',
            icon: MingCute.music_2_fill,
            color: const Color(0xFF512DA8), // Deep purple
            onTap: () {
              context.go('/Search');
            },
          ),
        ],
      ),
    );
  }
}

class ShortcutCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const ShortcutCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatsIcon extends StatelessWidget {
  const StatsIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: const EdgeInsets.all(5),
      constraints: const BoxConstraints(),
      onPressed: () {
        context.pushNamed(RoutePaths.wrappedScreen);
      },
      icon: const Icon(
        MingCute.chart_bar_fill,
        color: Default_Theme.primaryColor1,
        size: 30.0,
      ),
    );
  }
}

class NotificationIcon extends StatelessWidget {
  const NotificationIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        if (state is NotificationInitial || state.notifications.isEmpty) {
          return IconButton(
            padding: const EdgeInsets.all(5),
            constraints: const BoxConstraints(),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationView(),
                ),
              );
            },
            icon: const Icon(
              MingCute.notification_line,
              color: Default_Theme.primaryColor1,
              size: 30.0,
            ),
          );
        }
        return badges.Badge(
          badgeContent: Padding(
            padding: const EdgeInsets.all(1.5),
            child: Text(
              state.notifications.length.toString(),
              style: Default_Theme.primaryTextStyle.merge(
                const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Default_Theme.primaryColor2,
                ),
              ),
            ),
          ),
          badgeStyle: const badges.BadgeStyle(
            badgeColor: Default_Theme.accentColor2,
            shape: badges.BadgeShape.circle,
          ),
          position: badges.BadgePosition.topEnd(top: -10, end: -5),
          child: IconButton(
            padding: const EdgeInsets.all(5),
            constraints: const BoxConstraints(),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationView(),
                ),
              );
            },
            icon: const Icon(
              MingCute.notification_line,
              color: Default_Theme.primaryColor1,
              size: 30.0,
            ),
          ),
        );
      },
    );
  }
}

class TimerIcon extends StatelessWidget {
  const TimerIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: const EdgeInsets.all(5),
      constraints: const BoxConstraints(),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TimerView()),
        );
      },
      icon: const Icon(
        MingCute.stopwatch_line,
        color: Default_Theme.primaryColor1,
        size: 30.0,
      ),
    );
  }
}

class SettingsIcon extends StatelessWidget {
  const SettingsIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: const EdgeInsets.all(5),
      constraints: const BoxConstraints(),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsView()),
        );
      },
      icon: const Icon(
        MingCute.settings_3_line,
        color: Default_Theme.primaryColor1,
        size: 30.0,
      ),
    );
  }
}

class SiteIcon extends StatelessWidget {
  const SiteIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: const EdgeInsets.all(5),
      constraints: const BoxConstraints(),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const About()),
        );
      },
      icon: const Icon(
        MingCute.flower_4_fill,
        color: Default_Theme.primaryColor1,
        size: 28.0,
      ),
    );
  }
}


