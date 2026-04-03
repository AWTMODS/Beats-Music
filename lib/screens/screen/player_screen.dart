import 'package:beats_music/screens/widgets/player_components.dart';
import 'package:beats_music/blocs/downloader/cubit/downloader_cubit.dart';
import 'package:beats_music/blocs/library/cubit/library_items_cubit.dart';
import 'package:beats_music/blocs/player_overlay/player_overlay_cubit.dart';
import 'package:beats_music/core/adapters/track_adapter.dart';
import 'package:beats_music/screens/screen/home_views/timer_view.dart';
import 'package:beats_music/screens/screen/home_views/setting_views/player_setting.dart';
import 'package:beats_music/screens/widgets/gradient_progress_bar.dart';
import 'package:beats_music/screens/widgets/more_bottom_sheet.dart';
import 'package:beats_music/screens/widgets/up_next_panel.dart';
import 'package:beats_music/screens/widgets/volume_slider.dart';
import 'package:beats_music/screens/widgets/media_metadata_links.dart';
import 'package:beats_music/screens/screen/player_views/segments_sheet.dart';
import 'package:beats_music/services/beats_player.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:beats_music/l10n/app_localizations.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:beats_music/services/player/player_engine.dart';
import 'package:beats_music/screens/widgets/like_widget.dart';
import 'package:beats_music/screens/widgets/play_pause_widget.dart';
import 'package:beats_music/screens/widgets/snackbar.dart';
import 'package:beats_music/core/theme/app_theme.dart';
import 'package:beats_music/utils/load_image.dart';
import 'package:beats_music/utils/pallete_generator.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../blocs/media_player/beats_player_cubit.dart';
import '../../blocs/mini_player/mini_player_cubit.dart';
import 'player_views/fullscreen_lyrics_view.dart';

class AudioPlayerView extends StatefulWidget {
  const AudioPlayerView({super.key});

  @override
  State<AudioPlayerView> createState() => _AudioPlayerViewState();
}

class _AudioPlayerViewState extends State<AudioPlayerView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final UpNextPanelController _upNextPanelController = UpNextPanelController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PlayerOverlayCubit>().registerUpNextPanelCollapse(
              () => _upNextPanelController.collapse(),
            );
      }
    });
  }

  @override
  void dispose() {
    context.read<PlayerOverlayCubit>().unregisterUpNextPanelCollapse();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final playerCubit = context.read<BeatsPlayerCubit>();
    final musicPlayer = playerCubit.BeatsPlayer;
    final isMobile = ResponsiveBreakpoints.of(context).smallerOrEqualTo(TABLET);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 12, 4, 9),
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Default_Theme.primaryColor1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
          onPressed: () {
            if (!_upNextPanelController.collapse()) {
              context.read<PlayerOverlayCubit>().hidePlayer();
            }
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              final mi = musicPlayer.mediaItem.valueOrNull;
              if (mi != null) {
                showSegmentsSheet(
                  context,
                  trackId: mi.id,
                  trackDuration: mi.duration ?? Duration.zero,
                  onSeek: (pos) => musicPlayer.seek(pos),
                );
              }
            },
            icon: const Icon(MingCute.list_check_3_line,
                size: 22, color: Default_Theme.primaryColor1),
          ),
          IconButton(
            onPressed: () =>
                showMoreBottomSheet(context, musicPlayer.currentMedia),
            icon: const Icon(MingCute.more_2_fill,
                size: 25, color: Default_Theme.primaryColor1),
          )
        ],
        title: Column(
          children: [
            Text(
              l10n.playerEnjoyingFrom,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Default_Theme.primaryColor1,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ).merge(Default_Theme.secondoryTextStyle),
            ),
            StreamBuilder<String>(
              stream: musicPlayer.queueTitle,
              builder: (context, snapshot) {
                return Text(
                  snapshot.data ?? l10n.playerUnknownQueue,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Default_Theme.primaryColor2,
                    fontSize: 12,
                  ).merge(Default_Theme.secondoryTextStyle),
                );
              },
            ),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(seconds: 1),
        child: isMobile
            ? LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    alignment: Alignment.bottomCenter, // Strictly ground the UI
                    children: [
                      Positioned.fill(
                        child: _PlayerUI(
                          musicPlayer: musicPlayer,
                          tabController: _tabController,
                        ),
                      ),
                      UpNextPanel(
                        peekHeight: 60.0,
                        parentHeight: constraints.maxHeight,
                        controller: _upNextPanelController,
                      ),
                    ],
                  );
                },
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: 400,
                      maxWidth: MediaQuery.of(context).size.width * 0.60,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _PlayerUI(
                        musicPlayer: musicPlayer,
                        tabController: _tabController,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: UpNextPanel(
                          peekHeight: 60,
                          parentHeight:
                              MediaQuery.of(context).size.height * 0.8,
                          isDesktopMode: true,
                          controller: _upNextPanelController,
                        ),
                      ),
                    ),
                  )
                ],
              ),
      ),
    );
  }
}

class _PlayerUI extends StatelessWidget {
  final BeatsMusicPlayer musicPlayer;
  final TabController tabController;

  const _PlayerUI({
    required this.musicPlayer,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: tabController.animation!,
            builder: (context, child) {
              return Opacity(
                opacity: (1 - tabController.animation!.value),
                child: child,
              );
            },
            child: const AmbientImgShadowWidget(),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(height: 60), // Space for AppBar

              // EXPANDED allows artwork to claim 100% of available space securely
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: CoverImageVolSlider(),
                ),
              ),

              const SizedBox(height: 15),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: PlayerCtrlWidgets(musicPlayer: musicPlayer),
              ),

              // Reserve exact space for the grounded UpNextPanel so buttons are never hidden
              const SizedBox(height: 80),
            ],
          ),
        ),
      ],
    );
  }
}

