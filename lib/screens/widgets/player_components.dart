import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:beats_music/blocs/downloader/cubit/downloader_cubit.dart';
import 'package:beats_music/blocs/library/cubit/library_items_cubit.dart';
import 'package:beats_music/blocs/media_player/beats_player_cubit.dart';
import 'package:beats_music/blocs/mini_player/mini_player_cubit.dart';
import 'package:beats_music/core/adapters/track_adapter.dart';
import 'package:beats_music/core/models/exported.dart' hide MediaItem;
import 'package:beats_music/screens/widgets/gradient_progress_bar.dart';
import 'package:beats_music/screens/widgets/volume_slider.dart';
import 'package:beats_music/screens/widgets/media_metadata_links.dart';
import 'package:beats_music/services/beats_player.dart';
import 'package:audio_service/audio_service.dart';
import 'package:beats_music/l10n/app_localizations.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:beats_music/screens/widgets/like_widget.dart';
import 'package:beats_music/screens/widgets/snackbar.dart';
import 'package:beats_music/core/theme/app_theme.dart';
import 'package:beats_music/utils/load_image.dart';
import 'package:beats_music/utils/pallete_generator.dart';
import 'package:beats_music/services/player/player_engine.dart';
import 'package:beats_music/services/db/global_db.dart';
import 'package:beats_music/blocs/recommendation/cubit/recommendation_cubit.dart';
import 'package:beats_music/blocs/recommendation/cubit/recommendation_state.dart';
import 'package:beats_music/screens/widgets/up_next_panel.dart';
import 'package:share_plus/share_plus.dart';

class CoverImageVolSlider extends StatelessWidget {
  const CoverImageVolSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final playerCubit = context.read<BeatsPlayerCubit>();

    return VolumeDragController(
      child: StreamBuilder<MediaItem?>(
        stream: playerCubit.BeatsPlayer.mediaItem,
        builder: (context, snapshot) {
          final currentTrack =
              playerCubit.BeatsPlayer.currentTrackInfo;
          final highResUrl =
              currentTrack.thumbnail.urlHigh ?? currentTrack.thumbnail.url;
          final lowResUrl =
              currentTrack.thumbnail.urlLow ?? currentTrack.thumbnail.url;

          // the source image resolution.
          return SizedBox.expand(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1.0, // Square album art
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LoadImageCached(
                    imageUrl: highResUrl,
                    fallbackUrl: lowResUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class PlayerCtrlWidgets extends StatelessWidget {
  final BeatsMusicPlayer musicPlayer;
  final UpNextPanelController? upNextController;
  const PlayerCtrlWidgets({
    super.key,
    required this.musicPlayer,
    this.upNextController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _SongInfoRow(),
        const SizedBox(height: 10),
        const _PlayerProgressBar(),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PlayerControlsRow(musicPlayer: musicPlayer),
              const SizedBox(height: 6),
              _DeviceAndActionsRow(
                musicPlayer: musicPlayer,
                upNextController: upNextController,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SongInfoRow extends StatelessWidget {
  const _SongInfoRow();

  @override
  Widget build(BuildContext context) {
    final player = context.read<BeatsPlayerCubit>().BeatsPlayer;
    return Row(
      children: [
        Expanded(
          child: StreamBuilder<MediaItem?>(
            stream: player.mediaItem,
            builder: (context, snapshot) {
              final currentTrack = player.currentTrackInfo;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentTrack.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        Default_Theme.secondoryTextStyle.merge(const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Default_Theme.primaryColor1,
                    )),
                  ),
                  const SizedBox(height: 4),
                  TrackMetadataLinks(
                    track: currentTrack,
                    showAlbum: currentTrack.album != null,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Default_Theme.secondoryTextStyle.merge(TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Default_Theme.primaryColor1.withValues(alpha: 0.7),
                    )),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        const _DownloadButton(),
        const _LikeButton(),
      ],
    );
  }
}

class _DownloadButton extends StatefulWidget {
  const _DownloadButton();

  @override
  State<_DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<_DownloadButton> {
  String? _lastTrackId;
  Future<DownloadDB?>? _downloadFuture;

  @override
  Widget build(BuildContext context) {
    final player = context.read<BeatsPlayerCubit>().BeatsPlayer;
    return Tooltip(
      message: AppLocalizations.of(context)!.tooltipAvailableOffline,
      child: StreamBuilder<MediaItem?>(
        stream: player.mediaItem,
        builder: (context, mediaSnapshot) {
          final currentMedia = mediaSnapshot.data;
          if (currentMedia == null) return const SizedBox.shrink();

          if (_lastTrackId != currentMedia.id || _downloadFuture == null) {
            _lastTrackId = currentMedia.id;
            _downloadFuture = context
                .read<DownloaderCubit>()
                .getDownloadInfo(mediaItemToTrack(currentMedia));
          }

          return FutureBuilder<DownloadDB?>(
            future: _downloadFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return IconButton(
                  iconSize: 25,
                  icon: Icon(
                    Icons.offline_pin_rounded,
                    color: Default_Theme.primaryColor1.withValues(alpha: 0.5),
                  ),
                  onPressed: () {},
                );
              }
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}

class _LikeButton extends StatefulWidget {
  const _LikeButton();

  @override
  State<_LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<_LikeButton> {
  String? _lastTrackId;
  Future<bool>? _likeFuture;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final player = context.read<BeatsPlayerCubit>().BeatsPlayer;
    return BlocBuilder<LibraryItemsCubit, LibraryItemsState>(
      builder: (context, _) {
        return StreamBuilder<MediaItem?>(
          stream: player.mediaItem,
          builder: (context, mediaSnapshot) {
            final currentMedia = mediaSnapshot.data;
            if (currentMedia == null) return const SizedBox.shrink();

            if (_lastTrackId != currentMedia.id || _likeFuture == null) {
              _lastTrackId = currentMedia.id;
              _likeFuture = context
                  .read<LibraryItemsCubit>()
                  .isTrackLiked(mediaItemToTrack(currentMedia));
            }

            return FutureBuilder<bool>(
              future: _likeFuture,
              builder: (context, snapshot) {
                final isLiked = snapshot.data ?? false;
                return StreamBuilder<bool>(
                  stream: player.engine.playingStream,
                  builder: (context, playingSnapshot) {
                    final isPlaying = playingSnapshot.data ?? false;
                    return LikeBtnWidget(
                      isPlaying: isPlaying,
                      isLiked: isLiked,
                      useSpotifyStyle: true,
                      iconSize: 28,
                      onLiked: () async {
                        setState(() {
                          _likeFuture = Future.value(true);
                        });
                        await context.read<LibraryItemsCubit>().setTrackLiked(
                            mediaItemToTrack(currentMedia), true);
                        SnackbarService.showMessage(
                            l10n.playerLiked(currentMedia.title));
                      },
                      onDisliked: () async {
                        setState(() {
                          _likeFuture = Future.value(false);
                        });
                        await context.read<LibraryItemsCubit>().setTrackLiked(
                            mediaItemToTrack(currentMedia), false);
                        SnackbarService.showMessage(
                            l10n.playerUnliked(currentMedia.title));
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class _PlayerProgressBar extends StatelessWidget {
  const _PlayerProgressBar();

  @override
  Widget build(BuildContext context) {
    final playerCubit = context.read<BeatsPlayerCubit>();
    return RepaintBoundary(
      child: StreamBuilder<ProgressBarStreams>(
        stream: playerCubit.progressStreams,
        builder: (context, snapshot) {
          final data = snapshot.data;
          return GradientProgressBar.fromAccentColors(
            progress: data?.position ?? Duration.zero,
            total: data?.duration ?? Duration.zero,
            buffered: data?.buffered ?? Duration.zero,
            onSeek: playerCubit.BeatsPlayer.seek,
            isPlaying: data?.isPlaying ?? false,
            activeAccentColor: Colors.white,
            inactiveAccentColor: Colors.white.withValues(alpha: 0.3),
            activeGradientStyle: GradientStyle.lightAndBreezy,
            inactiveGradientStyle: GradientStyle.lightAndBreezy,
            trackHeight: 4.0,
            thumbRadius: 6.0,
            timeLabelPadding: 5,
            timeLabelStyle: Default_Theme.secondoryTextStyle.merge(TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.7),
            )),
            timeLabelLocation: TimeLabelLocation.above,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
            animationDuration: const Duration(milliseconds: 200),
            animationCurve: Curves.easeOutCubic,
          );
        },
      ),
    );
  }
}

class _PlayerControlsRow extends StatelessWidget {
  final BeatsMusicPlayer musicPlayer;
  const _PlayerControlsRow({required this.musicPlayer});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Shuffle / Smart Shuffle
          const _ShuffleControl(),

          // 2. Skip Previous
          IconButton(
            icon: const Icon(MingCute.skip_previous_fill,
                color: Colors.white, size: 36),
            onPressed: musicPlayer.skipToPrevious,
          ),

          // 3. Play / Pause (Large white circle with black icon)
          const _PlayPauseButton(),

          // 4. Skip Next
          IconButton(
            icon: const Icon(MingCute.skip_forward_fill,
                color: Colors.white, size: 36),
            onPressed: musicPlayer.skipToNext,
          ),

          // 5. Repeat / Loop
          const _LoopControl(),
        ],
      ),
    );
  }
}

class _DeviceAndActionsRow extends StatelessWidget {
  final BeatsMusicPlayer musicPlayer;
  final UpNextPanelController? upNextController;

  const _DeviceAndActionsRow({
    required this.musicPlayer,
    this.upNextController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Audio Device / Connection status in theme green
          InkWell(
            onTap: () {
              SnackbarService.showMessage('Listening on this device');
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.devices_rounded,
                    size: 18,
                    color: AppTheme.successAccent,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Wired Connection',
                    style: TextStyle(
                      color: AppTheme.successAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right action buttons: Share & Queue
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(
                  MingCute.share_2_line,
                  color: Colors.white70,
                  size: 22,
                ),
                tooltip: 'Share',
                onPressed: () {
                  final current = musicPlayer.currentMedia;
                  final url = current.url ?? '';
                  if (url.isNotEmpty) {
                    SharePlus.instance.share(ShareParams(
                      text: url,
                      subject: current.title,
                    ));
                  } else {
                    SharePlus.instance.share(ShareParams(
                      text:
                          '${current.title} - ${current.artists.map((a) => a.name).join(", ")}',
                      subject: current.title,
                    ));
                  }
                },
              ),
              IconButton(
                icon: const Icon(
                  MingCute.playlist_2_line,
                  color: Colors.white70,
                  size: 24,
                ),
                tooltip: 'Queue',
                onPressed: () {
                  upNextController?.toggle();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShuffleControl extends StatelessWidget {
  const _ShuffleControl();

  @override
  Widget build(BuildContext context) {
    final player = context.read<BeatsPlayerCubit>().BeatsPlayer;
    return StreamBuilder<ShuffleModeState>(
      stream: player.shuffleState,
      builder: (context, snapshot) {
        final mode = snapshot.data ?? ShuffleModeState.off;
        final isActive = mode != ShuffleModeState.off;
        final color = isActive ? AppTheme.successAccent : Colors.white60;

        Widget iconWidget;
        if (mode == ShuffleModeState.smartShuffle) {
          // Spotify Smart Shuffle icon: crossed arrows with a sparkle star!
          iconWidget = Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(MingCute.shuffle_2_line, color: color, size: 26),
              Positioned(
                top: -3,
                right: -4,
                child: Icon(MingCute.sparkles_fill, color: color, size: 13),
              ),
            ],
          );
        } else {
          iconWidget = Icon(MingCute.shuffle_2_line, color: color, size: 26);
        }

        return InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            // Cycle: off -> shuffle -> smartShuffle -> off
            if (mode == ShuffleModeState.off) {
              player.setShuffleModeState(ShuffleModeState.shuffle);
              SnackbarService.showMessage('Shuffle is on');
            } else if (mode == ShuffleModeState.shuffle) {
              final recState = context.read<RecommendationCubit>().state;
              List<Track>? recTracks;
              if (recState is RecommendationLoaded &&
                  recState.tracks.isNotEmpty) {
                recTracks = recState.tracks.take(5).toList();
              }
              player.setShuffleModeState(
                ShuffleModeState.smartShuffle,
                recommendations: recTracks,
              );
              SnackbarService.showMessage(
                  'Smart Shuffle is on. Recommendations added to Queue.');
            } else {
              player.setShuffleModeState(ShuffleModeState.off);
              SnackbarService.showMessage('Shuffle is off');
            }
          },
          onLongPress: () {
            showListeningModesBottomSheet(context, player);
          },
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: iconWidget,
          ),
        );
      },
    );
  }
}

class _LoopControl extends StatelessWidget {
  const _LoopControl();

  @override
  Widget build(BuildContext context) {
    final player = context.read<BeatsPlayerCubit>().BeatsPlayer;
    return StreamBuilder<LoopMode>(
      stream: player.loopMode,
      builder: (context, snapshot) {
        final loopMode = snapshot.data ?? LoopMode.off;
        final isActive = loopMode != LoopMode.off;
        final color = isActive ? AppTheme.successAccent : Colors.white60;

        IconData iconData = MingCute.repeat_line;
        if (loopMode == LoopMode.one) {
          iconData = MingCute.repeat_one_line;
        }

        return IconButton(
          icon: Icon(iconData, color: color, size: 26),
          onPressed: () {
            // Spotify direct cycle: off -> all -> one -> off
            if (loopMode == LoopMode.off) {
              player.setLoopMode(LoopMode.all);
              SnackbarService.showMessage('Repeat All');
            } else if (loopMode == LoopMode.all) {
              player.setLoopMode(LoopMode.one);
              SnackbarService.showMessage('Repeat Current');
            } else {
              player.setLoopMode(LoopMode.off);
              SnackbarService.showMessage('Repeat Off');
            }
          },
        );
      },
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton();

  @override
  Widget build(BuildContext context) {
    final musicPlayer = context.read<BeatsPlayerCubit>().BeatsPlayer;
    return BlocBuilder<MiniPlayerCubit, MiniPlayerState>(
      builder: (context, state) {
        Widget child;

        if (state.isLoading || state.isResolving) {
          child = const CircularProgressIndicator(
            strokeWidth: 3,
            color: Colors.black,
          );
        } else if (state.isCompleted) {
          child = const Icon(
            FontAwesome.rotate_right_solid,
            color: Colors.black,
            size: 28,
          );
        } else if (state.hasError) {
          child = const Icon(
            MingCute.warning_line,
            color: Colors.black,
            size: 28,
          );
        } else if (state.isPlaying) {
          child = const Icon(
            MingCute.pause_fill,
            color: Colors.black,
            size: 32,
          );
        } else {
          child = const Padding(
            padding: EdgeInsets.only(left: 3),
            child: Icon(
              MingCute.play_fill,
              color: Colors.black,
              size: 32,
            ),
          );
        }

        return GestureDetector(
          onTap: () {
            if (state.isCompleted) {
              musicPlayer.seek(Duration.zero);
              musicPlayer.play();
            } else if (state.hasError) {
              musicPlayer.play();
            } else if (state.isPlaying) {
              musicPlayer.pause();
            } else {
              musicPlayer.play();
            }
          },
          child: Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: Center(child: child),
              ),
            ),
          ),
        );
      },
    );
  }
}

void showListeningModesBottomSheet(
    BuildContext context, BeatsMusicPlayer player) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return StreamBuilder<ShuffleModeState>(
        stream: player.shuffleState,
        builder: (context, snapshot) {
          final currentMode = snapshot.data ?? ShuffleModeState.off;
          final isRegularShuffle = currentMode == ShuffleModeState.shuffle;
          final isSmartShuffle = currentMode == ShuffleModeState.smartShuffle;

          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFF242424),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Center(
                    child: Text(
                      'Listening modes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Option 1: Shuffle
                  InkWell(
                    onTap: () {
                      player.setShuffleModeState(
                        isRegularShuffle
                            ? ShuffleModeState.off
                            : ShuffleModeState.shuffle,
                      );
                      Navigator.pop(sheetContext);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Icon(
                            MingCute.shuffle_2_line,
                            color: isRegularShuffle
                                ? AppTheme.successAccent
                                : Colors.white,
                            size: 26,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Shuffle',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isRegularShuffle
                                    ? AppTheme.successAccent
                                    : Colors.white,
                              ),
                            ),
                          ),
                          if (isRegularShuffle)
                            const Icon(
                              MingCute.check_fill,
                              color: AppTheme.successAccent,
                              size: 22,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Option 2: Smart Shuffle
                  InkWell(
                    onTap: () {
                      final recState =
                          context.read<RecommendationCubit>().state;
                      List<Track>? recTracks;
                      if (recState is RecommendationLoaded &&
                          recState.tracks.isNotEmpty) {
                        recTracks = recState.tracks.take(5).toList();
                      }
                      player.setShuffleModeState(
                        isSmartShuffle
                            ? ShuffleModeState.off
                            : ShuffleModeState.smartShuffle,
                        recommendations: recTracks,
                      );
                      Navigator.pop(sheetContext);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Icon(
                              MingCute.sparkles_line,
                              color: isSmartShuffle
                                  ? AppTheme.successAccent
                                  : Colors.white,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Smart Shuffle',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isSmartShuffle
                                        ? AppTheme.successAccent
                                        : Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Shuffle and get recommendations in your Queue, refreshed daily.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white60,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSmartShuffle)
                            const Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: Icon(
                                MingCute.check_fill,
                                color: AppTheme.successAccent,
                                size: 22,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Learn More
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (dContext) => AlertDialog(
                          backgroundColor: const Color(0xFF282828),
                          title: const Text('Smart Shuffle',
                              style: TextStyle(color: Colors.white)),
                          content: const Text(
                            'Smart Shuffle breathes new life into your playlists by automatically mixing in tailored recommendations based on the songs you love.',
                            style: TextStyle(color: Colors.white70),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dContext),
                              child: const Text('Got it',
                                  style:
                                      TextStyle(color: AppTheme.successAccent)),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Learn More',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

class AmbientImgShadowWidget extends StatefulWidget {
  const AmbientImgShadowWidget({super.key});

  @override
  State<AmbientImgShadowWidget> createState() => _AmbientImgShadowWidgetState();
}

class _AmbientImgShadowWidgetState extends State<AmbientImgShadowWidget> {
  Color? cachedColor;
  String? lastArtUri;

  @override
  Widget build(BuildContext context) {
    final player = context.read<BeatsPlayerCubit>().BeatsPlayer;
    return StreamBuilder<MediaItem?>(
      stream: player.mediaItem,
      builder: (context, snapshot) {
        final artUri = snapshot.data?.artUri?.toString();
        if (artUri != lastArtUri) {
          lastArtUri = artUri;
          _fetchPalette(artUri);
        }

        return RepaintBoundary(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  (cachedColor ?? const Color.fromARGB(255, 163, 44, 115))
                      .withValues(alpha: 0.35),
                  Colors.transparent,
                ],
                center: Alignment.center,
                radius: 0.70,
              ),
            ),
          ),
        );
      },
    );
  }

  void _fetchPalette(String? artUri) async {
    if (artUri == null || artUri.isEmpty) return;
    try {
      final palette = await getPalleteFromImage(artUri);
      if (mounted) {
        setState(() => cachedColor = palette.dominantColor?.color);
      }
    } catch (_) {}
  }
}


