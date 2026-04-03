import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:beats_music/blocs/downloader/cubit/downloader_cubit.dart';
import 'package:beats_music/blocs/library/cubit/library_items_cubit.dart';
import 'package:beats_music/blocs/media_player/beats_player_cubit.dart';
import 'package:beats_music/blocs/mini_player/mini_player_cubit.dart';
import 'package:beats_music/core/adapters/track_adapter.dart';
import 'package:beats_music/screens/screen/home_views/timer_view.dart';
import 'package:beats_music/screens/screen/home_views/setting_views/player_setting.dart';
import 'package:beats_music/screens/widgets/gradient_progress_bar.dart';
import 'package:beats_music/screens/widgets/volume_slider.dart';
import 'package:beats_music/screens/widgets/media_metadata_links.dart';
import 'package:beats_music/services/beats_player.dart';
import 'package:audio_service/audio_service.dart';
import 'package:beats_music/l10n/app_localizations.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:beats_music/screens/widgets/like_widget.dart';
import 'package:beats_music/screens/widgets/play_pause_widget.dart';
import 'package:beats_music/screens/widgets/snackbar.dart';
import 'package:beats_music/core/theme/app_theme.dart';
import 'package:beats_music/utils/load_image.dart';
import 'package:beats_music/utils/pallete_generator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screen/player_views/fullscreen_lyrics_view.dart';
import 'package:beats_music/services/player/player_engine.dart';

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
  const PlayerCtrlWidgets({super.key, required this.musicPlayer});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _SongInfoRow(),
        const SizedBox(height: 15),
        const _PlayerProgressBar(),
        const SizedBox(height: 25),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: _PlayerControlsRow(musicPlayer: musicPlayer),
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

class _DownloadButton extends StatelessWidget {
  const _DownloadButton();

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
          return FutureBuilder(
            future: context
                .read<DownloaderCubit>()
                .getDownloadInfo(mediaItemToTrack(currentMedia)),
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

class _LikeButton extends StatelessWidget {
  const _LikeButton();

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

            return FutureBuilder<bool>(
              future: context
                  .read<LibraryItemsCubit>()
                  .isTrackLiked(mediaItemToTrack(currentMedia)),
              builder: (context, snapshot) {
                final isLiked = snapshot.data ?? false;
                return StreamBuilder<bool>(
                  stream: player.engine.playingStream,
                  builder: (context, playingSnapshot) {
                    final isPlaying = playingSnapshot.data ?? false;
                    return LikeBtnWidget(
                      isPlaying: isPlaying,
                      isLiked: isLiked,
                      iconSize: 25,
                      onLiked: () {
                        context.read<LibraryItemsCubit>().setTrackLiked(
                            mediaItemToTrack(currentMedia), true);
                        SnackbarService.showMessage(
                            l10n.playerLiked(currentMedia.title));
                      },
                      onDisliked: () {
                        context.read<LibraryItemsCubit>().setTrackLiked(
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

  Widget _buildControlColumn({required Widget top, required Widget bottom}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Fixed Top Height ensures perfectly horizontal snapping alignment
        Container(height: 70, alignment: Alignment.center, child: top),
        SizedBox(height: 40, child: bottom),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment:
          CrossAxisAlignment.start, // Ensures flush horizontal grid
      children: [
        _buildControlColumn(
          top: IconButton(
            icon: const Icon(MingCute.alarm_1_line,
                color: Default_Theme.primaryColor1, size: 28),
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const TimerView())),
          ),
          bottom: const _LoopControl(),
        ),
        _buildControlColumn(
          top: IconButton(
            icon: const Icon(MingCute.skip_previous_fill,
                color: Default_Theme.primaryColor1, size: 35),
            onPressed: musicPlayer.skipToPrevious,
          ),
          bottom: IconButton(
            icon: const Icon(MingCute.align_center_line,
                color: Default_Theme.primaryColor1, size: 24),
            onPressed: () {
              Navigator.of(context).push(PageRouteBuilder(
                pageBuilder: (_, __, ___) => const FullscreenLyricsView(),
                transitionsBuilder: (_, a, __, c) =>
                    FadeTransition(opacity: a, child: c),
                transitionDuration: const Duration(milliseconds: 300),
              ));
            },
          ),
        ),
        _buildControlColumn(
          top:
              const _PlayPauseButton(), // Perfectly integrated into the alignment matrix
          bottom: const SizedBox(height: 40),
        ),
        _buildControlColumn(
          top: IconButton(
            icon: const Icon(MingCute.skip_forward_fill,
                color: Default_Theme.primaryColor1, size: 35),
            onPressed: musicPlayer.skipToNext,
          ),
          bottom: IconButton(
            icon: const Icon(MingCute.settings_6_line,
                color: Default_Theme.primaryColor1, size: 24),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PlayerSettings())),
          ),
        ),
        _buildControlColumn(
          top: const _ShuffleControl(),
          bottom: const SizedBox(height: 40),
        ),
      ],
    );
  }
}

class _LoopControl extends StatelessWidget {
  const _LoopControl();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<LoopMode>(
      stream: context.read<BeatsPlayerCubit>().BeatsPlayer.loopMode,
      builder: (context, snapshot) {
        final loopMode = snapshot.data ?? LoopMode.off;
        final l10n = AppLocalizations.of(context)!;
        return PopupMenuButton(
          itemBuilder: (_) => [
            PopupMenuItem(value: 0, child: Text(l10n.playerLoopOff)),
            PopupMenuItem(value: 1, child: Text(l10n.playerLoopOne)),
            PopupMenuItem(value: 2, child: Text(l10n.playerLoopAll)),
          ],
          child: Icon(
            loopMode == LoopMode.off
                ? MingCute.repeat_line
                : loopMode == LoopMode.one
                    ? MingCute.repeat_one_line
                    : MingCute.repeat_fill,
            color: loopMode == LoopMode.off
                ? Default_Theme.primaryColor1
                : Default_Theme.accentColor1,
            size: 24,
          ),
          onSelected: (value) {
            final player = context.read<BeatsPlayerCubit>().BeatsPlayer;
            if (value == 0) player.setLoopMode(LoopMode.off);
            if (value == 1) player.setLoopMode(LoopMode.one);
            if (value == 2) player.setLoopMode(LoopMode.all);
          },
        );
      },
    );
  }
}

class _ShuffleControl extends StatelessWidget {
  const _ShuffleControl();

  @override
  Widget build(BuildContext context) {
    final player = context.read<BeatsPlayerCubit>().BeatsPlayer;
    return StreamBuilder<bool>(
      stream: player.shuffleMode,
      builder: (context, snapshot) {
        final isShuffle = snapshot.data ?? false;
        return IconButton(
          icon: Icon(
            MingCute.shuffle_2_fill,
            color: isShuffle
                ? Default_Theme.accentColor1
                : Default_Theme.primaryColor1,
            size: 28,
          ),
          onPressed: () => player.shuffle(!isShuffle),
        );
      },
    );
  }
}

class _ExternalLinkControl extends StatelessWidget {
  const _ExternalLinkControl();

  @override
  Widget build(BuildContext context) {
    final player = context.read<BeatsPlayerCubit>().BeatsPlayer;
    return IconButton(
      icon: const Icon(MingCute.external_link_line,
          color: Default_Theme.primaryColor1, size: 24),
      onPressed: () async {
        final url = player.currentTrackInfo.url;
        if (url != null) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        } else {
          SnackbarService.showMessage(
              AppLocalizations.of(context)!.snackbarCouldNotOpenLink);
        }
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
        Color buttonColor = Colors.white;

        if (state.isLoading || state.isResolving) {
          child = const CircularProgressIndicator(
              strokeWidth: 3, color: Colors.black);
        } else if (state.isCompleted) {
          child = const Icon(FontAwesome.rotate_right_solid,
              color: Colors.black, size: 32);
        } else if (state.hasError) {
          child = const Icon(MingCute.warning_line,
              color: Colors.black, size: 32);
        } else if (state.isVisible) {
          return PlayPauseButton(
            size: 70, // Resized to perfectly match and feel proportional
            onPause: musicPlayer.pause,
            onPlay: musicPlayer.play,
            isPlaying: state.isPlaying,
          );
        } else {
          child = const SizedBox();
        }

        return GestureDetector(
          onTap: () {
            if (state.isCompleted) {
              musicPlayer.seek(Duration.zero);
              musicPlayer.play();
            } else if (state.hasError) {
              musicPlayer.play();
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: buttonColor,
              boxShadow: [
                BoxShadow(
                    color: Colors.white.withValues(alpha: 0.6),
                    spreadRadius: 1,
                    blurRadius: 15)
              ],
            ),
            child: Center(child: SizedBox(width: 32, height: 32, child: child)),
          ),
        );
      },
    );
  }
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


