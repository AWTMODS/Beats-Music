import 'dart:developer';
import 'package:go_router/go_router.dart';
import 'package:beats_music/blocs/explore/cubit/explore_cubits.dart';
import 'package:beats_music/blocs/internet_connectivity/cubit/connectivity_cubit.dart';
import 'package:beats_music/blocs/lastdotfm/lastdotfm_cubit.dart';
import 'package:beats_music/blocs/mediaPlayer/beats_player_cubit.dart';
import 'package:beats_music/blocs/notification/notification_cubit.dart';
import 'package:beats_music/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:beats_music/model/MediaPlaylistModel.dart';
import 'package:beats_music/screens/screen/library_views/cubit/current_playlist_cubit.dart';
import 'package:beats_music/screens/screen/home_views/recents_view.dart';
import 'package:beats_music/screens/screen/home_views/setting_views/about.dart';
import 'package:beats_music/screens/widgets/more_bottom_sheet.dart';
import 'package:beats_music/screens/widgets/sign_board_widget.dart';
import 'package:beats_music/screens/widgets/song_tile.dart';
import 'package:flutter/material.dart';
import 'package:beats_music/screens/screen/home_views/notification_view.dart';
import 'package:beats_music/screens/screen/home_views/setting_view.dart';
import 'package:beats_music/screens/screen/home_views/timer_view.dart';
import 'package:beats_music/theme_data/default.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'chart/carousal_widget.dart';
import '../widgets/horizontal_card_view.dart';
import '../widgets/tabList_widget.dart';
import '../widgets/quick_access_card.dart';
import '../widgets/app_drawer.dart';
import 'package:badges/badges.dart' as badges;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:audio_service/audio_service.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  bool isUpdateChecked = false;
  YTMusicCubit yTMusicCubit = YTMusicCubit();
  Future<MediaPlaylist> lFMData =
      Future.value(const MediaPlaylist(mediaItems: [], playlistName: ""));

  @override
  void initState() {
    super.initState();
  }

  Future<MediaPlaylist> fetchLFMPicks(bool state, BuildContext ctx) async {
    if (state) {
      try {
        final data = await lFMData;
        if (data.mediaItems.isNotEmpty) {
          return data;
        }

        if (ctx.mounted) {
          lFMData = ctx.read<LastdotfmCubit>().getRecommendedTracks();
        }
        return (await lFMData);
      } catch (e) {
        log(e.toString(), name: "ExploreScreen");
      }
    }
    return const MediaPlaylist(mediaItems: [], playlistName: "");
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MultiBlocProvider(
        providers: [
          BlocProvider<RecentlyCubit>(
            create: (context) => RecentlyCubit(),
            lazy: false,
          ),
          BlocProvider(
            create: (context) => yTMusicCubit,
            lazy: false,
          ),
          BlocProvider(
            create: (context) => FetchChartCubit(),
            lazy: false,
          ),
          BlocProvider(
            create: (context) => MalayalamSongsCubit(),
            lazy: false,
          ),
          BlocProvider(
            create: (context) => HindiSongsCubit(),
            lazy: false,
          ),
          BlocProvider(
            create: (context) => TamilSongsCubit(),
            lazy: false,
          ),
        ],
        child: Scaffold(
          drawer: const AppDrawer(),
          body: RefreshIndicator(
            onRefresh: () async {
              await yTMusicCubit.fetchYTMusic();
            },
            child: CustomScrollView(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              slivers: [
                const CustomDiscoverBar(),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      const SizedBox(height: 8),
                      // Quick Access Grid
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 3.2,
                          children: [
                            QuickAccessCard(
                              title: "Liked Songs",
                              icon: MingCute.heart_fill,
                              iconColor: Color(0xFFB565D8),
                              onTap: () {
                                context.read<CurrentPlaylistCubit>().setupPlaylist('Liked');
                                context.pushNamed('PlaylistView');
                              },
                            ),
                            QuickAccessCard(
                              title: "Recently Played",
                              icon: MingCute.time_fill,
                              iconColor: Color(0xFF1E88E5),
                              onTap: () {
                                context.read<CurrentPlaylistCubit>().setupPlaylist('recently_played');
                                context.pushNamed('PlaylistView');
                              },
                            ),
                            QuickAccessCard(
                              title: "Your Top Mix",
                              icon: MingCute.star_fill,
                              iconColor: Color(0xFFFF9800),
                              onTap: () {
                                context.read<CurrentPlaylistCubit>().setupPlaylist('your_top_mix');
                                context.pushNamed('PlaylistView');
                              },
                            ),
                            QuickAccessCard(
                              title: "Discover Weekly",
                              icon: MingCute.compass_fill,
                              iconColor: Color(0xFF43A047),
                              onTap: () {
                                context.read<CurrentPlaylistCubit>().setupPlaylist('discover_weekly');
                                context.pushNamed('PlaylistView');
                              },
                            ),
                            QuickAccessCard(
                              title: "Release Radar",
                              icon: MingCute.radar_fill,
                              iconColor: Color(0xFFE53935),
                              onTap: () {
                                context.read<CurrentPlaylistCubit>().setupPlaylist('release_radar');
                                context.pushNamed('PlaylistView');
                              },
                            ),
                            QuickAccessCard(
                              title: "Daily Mix 1",
                              icon: MingCute.playlist_2_fill,
                              iconColor: Color(0xFF5E35B1),
                              onTap: () {
                                context.read<CurrentPlaylistCubit>().setupPlaylist('daily_mix_1');
                                context.pushNamed('PlaylistView');
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Trending Now Section
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          "Trending Now",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Default_Theme.primaryColor1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: CaraouselWidget(),
                      ),
                      const SizedBox(height: 24),
                      // Trending Malayalam Songs Section
                      BlocBuilder<SettingsCubit, SettingsState>(
                        builder: (context, settingsState) {
                          if (!settingsState.showMalayalamTrending) {
                            return const SizedBox.shrink();
                          }
                          return BlocBuilder<MalayalamSongsCubit,
                              MalayalamSongsState>(
                            builder: (context, state) {
                              if (state.isLoading && state.songs.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              if (state.songs.isNotEmpty) {
                                // Precache first 3 images and preload audio for first 2 songs
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  for (var i = 0; i < state.songs.length && i < 3; i++) {
                                    final song = state.songs[i];
                                    final imageUrl = song['image'];
                                    
                                    // Precache image
                                    if (imageUrl != null && imageUrl.toString().isNotEmpty) {
                                      precacheImage(
                                        CachedNetworkImageProvider(imageUrl.toString()),
                                        context,
                                      );
                                    }
                                    
                                    // Preload audio (first 2 songs only)
                                    if (i < 2) {
                                      try {
                                        final mediaItem = MediaItem(
                                          id: song['id'] ?? 'unknown',
                                          title: song['title'] ?? 'Unknown',
                                          artist: song['artist'] ?? song['subtitle'] ?? 'Unknown Artist',
                                          artUri: Uri.parse(song['image'] ?? ''),
                                          extras: {
                                            'url': song['url'] ?? '',
                                            'source': song['provider'] ?? 'youtube',
                                          },
                                        );
                                        context.read<BeatsPlayerCubit>().beatsMusicPlayer.preloadSong(mediaItem);
                                      } catch (e) {
                                        log('Error preloading audio: $e', name: 'ExploreScreen');
                                      }
                                    }
                                  }
                                });
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: HorizontalCardView(
                                    data: {
                                      'title': 'Trending Malayalam Songs',
                                      'items': state.songs,
                                    },
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      // Trending Hindi Songs Section
                      BlocBuilder<SettingsCubit, SettingsState>(
                        builder: (context, settingsState) {
                          if (!settingsState.showHindiTrending) {
                            return const SizedBox.shrink();
                          }
                          return BlocBuilder<HindiSongsCubit, HindiSongsState>(
                            builder: (context, state) {
                              if (state.isLoading && state.songs.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              if (state.songs.isNotEmpty) {
                                // Precache first 3 images and preload audio for first 2 songs
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  for (var i = 0; i < state.songs.length && i < 3; i++) {
                                    final song = state.songs[i];
                                    final imageUrl = song['image'];
                                    
                                    // Precache image
                                    if (imageUrl != null && imageUrl.toString().isNotEmpty) {
                                      precacheImage(
                                        CachedNetworkImageProvider(imageUrl.toString()),
                                        context,
                                      );
                                    }
                                    
                                    // Preload audio (first 2 songs only)
                                    if (i < 2) {
                                      try {
                                        final mediaItem = MediaItem(
                                          id: song['id'] ?? 'unknown',
                                          title: song['title'] ?? 'Unknown',
                                          artist: song['artist'] ?? song['subtitle'] ?? 'Unknown Artist',
                                          artUri: Uri.parse(song['image'] ?? ''),
                                          extras: {
                                            'url': song['url'] ?? '',
                                            'source': song['provider'] ?? 'youtube',
                                          },
                                        );
                                        context.read<BeatsPlayerCubit>().beatsMusicPlayer.preloadSong(mediaItem);
                                      } catch (e) {
                                        log('Error preloading audio: $e', name: 'ExploreScreen');
                                      }
                                    }
                                  }
                                });
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: HorizontalCardView(
                                    data: {
                                      'title': 'Trending Hindi Songs',
                                      'items': state.songs,
                                    },
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      // Trending Tamil Songs Section
                      BlocBuilder<SettingsCubit, SettingsState>(
                        builder: (context, settingsState) {
                          if (!settingsState.showTamilTrending) {
                            return const SizedBox.shrink();
                          }
                          return BlocBuilder<TamilSongsCubit, TamilSongsState>(
                            builder: (context, state) {
                              if (state.isLoading && state.songs.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              if (state.songs.isNotEmpty) {
                                // Precache first 3 images and preload audio for first 2 songs
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  for (var i = 0; i < state.songs.length && i < 3; i++) {
                                    final song = state.songs[i];
                                    final imageUrl = song['image'];
                                    
                                    // Precache image
                                    if (imageUrl != null && imageUrl.toString().isNotEmpty) {
                                      precacheImage(
                                        CachedNetworkImageProvider(imageUrl.toString()),
                                        context,
                                      );
                                    }
                                    
                                    // Preload audio (first 2 songs only)
                                    if (i < 2) {
                                      try {
                                        final mediaItem = MediaItem(
                                          id: song['id'] ?? 'unknown',
                                          title: song['title'] ?? 'Unknown',
                                          artist: song['artist'] ?? song['subtitle'] ?? 'Unknown Artist',
                                          artUri: Uri.parse(song['image'] ?? ''),
                                          extras: {
                                            'url': song['url'] ?? '',
                                            'source': song['provider'] ?? 'youtube',
                                          },
                                        );
                                        context.read<BeatsPlayerCubit>().beatsMusicPlayer.preloadSong(mediaItem);
                                      } catch (e) {
                                        log('Error preloading audio: $e', name: 'ExploreScreen');
                                      }
                                    }
                                  }
                                });
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: HorizontalCardView(
                                    data: {
                                      'title': 'Trending Tamil Songs',
                                      'items': state.songs,
                                    },
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: SizedBox(
                          child: BlocBuilder<RecentlyCubit, RecentlyCubitState>(
                            builder: (context, state) {
                              if (state is RecentlyCubitInitial) {
                                return const Center(
                                  child: SizedBox(
                                      height: 60,
                                      width: 60,
                                      child: CircularProgressIndicator(
                                        color: Default_Theme.accentColor2,
                                      )),
                                );
                              }
                              if (state.mediaPlaylist.mediaItems.isNotEmpty) {
                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const HistoryView()));
                                  },
                                  child: TabSongListWidget(
                                    list:
                                        state.mediaPlaylist.mediaItems.map((e) {
                                      return SongCardWidget(
                                        song: e,
                                        onTap: () {
                                          context
                                              .read<BeatsPlayerCubit>()
                                              .beatsMusicPlayer
                                              .updateQueue(
                                            [e],
                                            doPlay: true,
                                          );
                                        },
                                        onOptionsTap: () =>
                                            showMoreBottomSheet(context, e),
                                      );
                                    }).toList(),
                                    category: "Recently Played",
                                    columnSize: 3,
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                      ),
                      BlocBuilder<SettingsCubit, SettingsState>(
                        builder: (context, state) {
                          if (state.lFMPicks) {
                            return FutureBuilder(
                                future: fetchLFMPicks(state.lFMPicks, context),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData &&
                                      (snapshot.data?.mediaItems.isNotEmpty ??
                                          false)) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 24.0),
                                      child: TabSongListWidget(
                                          list: snapshot.data!.mediaItems
                                              .map((e) {
                                            return SongCardWidget(
                                              song: e,
                                              onTap: () {
                                                context
                                                    .read<BeatsPlayerCubit>()
                                                    .beatsMusicPlayer
                                                    .loadPlaylist(
                                                      snapshot.data!,
                                                      idx: snapshot
                                                          .data!.mediaItems
                                                          .indexOf(e),
                                                      doPlay: true,
                                                    );
                                              },
                                              onOptionsTap: () =>
                                                  showMoreBottomSheet(
                                                      context, e),
                                            );
                                          }).toList(),
                                          category: "Last.Fm Picks",
                                          columnSize: 3),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                });
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      BlocBuilder<YTMusicCubit, YTMusicCubitState>(
                        builder: (context, state) {
                          if (state is YTMusicCubitInitial) {
                            return BlocBuilder<ConnectivityCubit,
                                ConnectivityState>(
                              builder: (context, state2) {
                                if (state2 == ConnectivityState.disconnected) {
                                  return const SignBoardWidget(
                                    message: "No Internet Connection!",
                                    icon: MingCute.wifi_off_line,
                                  );
                                }
                                return const SizedBox();
                              },
                            );
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            itemExtent: 275,
                            padding: const EdgeInsets.only(top: 8),
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.ytmData["body"]!.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: HorizontalCardView(
                                    data: state.ytmData["body"]![index]),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                )
              ],
            ),
          ),
          backgroundColor: Default_Theme.themeColor,
        ),
      ),
    );
  }
}

class CustomDiscoverBar extends StatelessWidget {
  const CustomDiscoverBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      surfaceTintColor: Default_Theme.themeColor,
      backgroundColor: Default_Theme.themeColor,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(
            MingCute.menu_fill,
            color: Default_Theme.primaryColor1,
          ),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      actions: const [
        NotificationIcon(),
        SizedBox(width: 8),
        TimerIcon(),
        SizedBox(width: 12),
      ],
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
                      builder: (context) => const NotificationView()));
            },
            icon: const Icon(MingCute.notification_line,
                color: Default_Theme.primaryColor1, size: 30.0),
          );
        }
        return badges.Badge(
          badgeContent: Padding(
            padding: const EdgeInsets.all(1.5),
            child: Text(
              state.notifications.length.toString(),
              style: Default_Theme.primaryTextStyle.merge(const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Default_Theme.primaryColor2)),
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
                      builder: (context) => const NotificationView()));
            },
            icon: const Icon(MingCute.notification_line,
                color: Default_Theme.primaryColor1, size: 30.0),
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
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const TimerView()));
      },
      icon: const Icon(MingCute.stopwatch_line,
          color: Default_Theme.primaryColor1, size: 30.0),
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
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const SettingsView()));
      },
      icon: const Icon(MingCute.settings_3_line,
          color: Default_Theme.primaryColor1, size: 30.0),
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
            context, MaterialPageRoute(builder: (context) => const About()));
      },
      icon: const Icon(MingCute.flower_4_fill,
          color: Default_Theme.primaryColor1, size: 28.0),
    );
  }
}
