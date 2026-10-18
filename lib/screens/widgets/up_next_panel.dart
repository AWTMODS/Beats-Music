import 'dart:math' as math;
import 'dart:ui';
import 'package:beats_music/blocs/media_player/beats_player_cubit.dart';
import 'package:beats_music/core/adapters/track_adapter.dart';
import 'package:beats_music/l10n/app_localizations.dart';
import 'package:beats_music/core/theme/app_theme.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:beats_music/services/beats_player.dart';
import 'package:beats_music/services/player/player_engine.dart';
import 'package:beats_music/blocs/timer/timer_bloc.dart';
import 'package:beats_music/screens/screen/home_views/timer_view.dart';
import 'package:beats_music/screens/widgets/snackbar.dart';
import 'package:beats_music/screens/widgets/player_components.dart';
import 'package:beats_music/blocs/recommendation/cubit/recommendation_cubit.dart';
import 'package:beats_music/blocs/recommendation/cubit/recommendation_state.dart';
import 'package:beats_music/core/models/exported.dart' hide MediaItem;

import 'song_tile.dart';
import 'more_bottom_sheet.dart';

class _UpNextStyles {
  static final headerTextStyle = Default_Theme.secondoryTextStyleMedium.merge(
    TextStyle(
        color: Default_Theme.primaryColor2.withValues(alpha: 0.9),
        fontSize: 14,
        fontWeight: FontWeight.w600),
  );
  static final queueCountStyle = Default_Theme.secondoryTextStyleMedium.merge(
    TextStyle(
        color: Colors.white.withValues(alpha: 0.7),
        fontSize: 13,
        fontWeight: FontWeight.w500),
  );
  static const panelBorderRadius =
      BorderRadius.vertical(top: Radius.circular(25));
  static const desktopBorderRadius = BorderRadius.all(Radius.circular(25));
}

class UpNextPanelController {
  VoidCallback? _toggleListener;
  VoidCallback? _collapseListener;
  bool Function()? _isExpandedGetter;

  bool get isExpanded => _isExpandedGetter?.call() ?? false;

  void toggle() => _toggleListener?.call();

  bool collapse() {
    if (isExpanded) {
      _collapseListener?.call();
      return true;
    }
    return false;
  }

  void _attach(
      {required VoidCallback toggle,
      required VoidCallback collapse,
      required bool Function() isExpanded}) {
    _toggleListener = toggle;
    _collapseListener = collapse;
    _isExpandedGetter = isExpanded;
  }

  void _detach() {
    _toggleListener = null;
    _collapseListener = null;
    _isExpandedGetter = null;
  }
}

class UpNextPanel extends StatefulWidget {
  const UpNextPanel({
    super.key,
    required this.peekHeight,
    required this.parentHeight,
    this.isDesktopMode = false,
    this.startExpanded = false,
    this.canBeHidden = false,
    this.controller,
  });

  final double peekHeight;
  final double parentHeight;
  final bool isDesktopMode;
  final bool startExpanded;
  final bool canBeHidden;
  final UpNextPanelController? controller;

  @override
  State<UpNextPanel> createState() => _UpNextPanelState();
}

class _UpNextPanelState extends State<UpNextPanel> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  late bool _isExpanded;
  double _minSheetSize = 0.1;
  double _maxSheetSize = 0.9;
  late final BeatsPlayerCubit _playerCubit;

  @override
  void initState() {
    super.initState();
    _playerCubit = context.read<BeatsPlayerCubit>();
    _isExpanded = widget.startExpanded;

    widget.controller?._attach(
      toggle: _toggleSheet,
      collapse: _collapseSheet,
      isExpanded: () => _isExpanded,
    );

    _sheetController.addListener(_updateExpandedState);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSheetSizes();
  }

  @override
  void didUpdateWidget(UpNextPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.parentHeight != widget.parentHeight ||
        oldWidget.peekHeight != widget.peekHeight) {
      _updateSheetSizes();
    }
  }

  void _updateSheetSizes() {
    final minSize = widget.canBeHidden
        ? 0.0
        : (widget.parentHeight > 0
            ? (widget.peekHeight / widget.parentHeight)
            : 0.1);

    final safeTopOffset = MediaQuery.of(context).padding.top + 8.0;
    final maxSize = widget.parentHeight > 0
        ? ((widget.parentHeight - safeTopOffset) / widget.parentHeight)
            .clamp(minSize + 0.1, math.max<double>(0.98, minSize + 0.15))
        : 0.95;

    if (minSize != _minSheetSize || maxSize != _maxSheetSize) {
      setState(() {
        _minSheetSize = minSize;
        _maxSheetSize = maxSize;
      });
    }
  }

  void _updateExpandedState() {
    final nowExpanded = _sheetController.size > _minSheetSize + 0.1;
    if (nowExpanded != _isExpanded) {
      setState(() => _isExpanded = nowExpanded);
    }
  }

  @override
  void dispose() {
    widget.controller?._detach();
    _sheetController.removeListener(_updateExpandedState);
    _sheetController.dispose();
    super.dispose();
  }

  void _toggleSheet() {
    if (_sheetController.size < _minSheetSize + 0.1) {
      _sheetController.animateTo(_maxSheetSize,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutExpo);
    } else {
      _collapseSheet();
    }
  }

  void _collapseSheet() {
    _sheetController.animateTo(_minSheetSize,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOutExpo);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isDesktopMode) {
      return _DesktopLayout(playerCubit: _playerCubit);
    }

    return MediaQuery.removeViewInsets(
      context: context,
      removeBottom: true,
      child: DraggableScrollableSheet(
        controller: _sheetController,
        initialChildSize: widget.startExpanded ? _maxSheetSize : _minSheetSize,
        minChildSize: _minSheetSize,
        maxChildSize: _maxSheetSize,
        snap: true,
        snapAnimationDuration: const Duration(milliseconds: 250),
        builder: (context, scrollController) {
          return _PanelContent(
            peekHeight: widget.peekHeight,
            isExpanded: _isExpanded,
            onHeaderTap: _toggleSheet,
            scrollController: scrollController,
            playerCubit: _playerCubit,
            sheetController: _sheetController,
            minSize: _minSheetSize,
            maxSize: _maxSheetSize,
          );
        },
      ),
    );
  }
}

class _PanelContent extends StatelessWidget {
  final double peekHeight;
  final bool isExpanded;
  final VoidCallback onHeaderTap;
  final ScrollController scrollController;
  final BeatsPlayerCubit playerCubit;
  final DraggableScrollableController sheetController;
  final double minSize;
  final double maxSize;

  const _PanelContent({
    required this.peekHeight,
    required this.isExpanded,
    required this.onHeaderTap,
    required this.scrollController,
    required this.playerCubit,
    required this.sheetController,
    required this.minSize,
    required this.maxSize,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: _UpNextStyles.panelBorderRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.85),
                borderRadius: _UpNextStyles.panelBorderRadius,
                border: Border(
                    top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 0.5)),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: onHeaderTap,
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      height: peekHeight - 0.5,
                      child: _CompactHeader(isExpanded: isExpanded),
                    ),
                  ),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: sheetController,
                      builder: (context, child) {
                        final currentSize = sheetController.isAttached
                            ? sheetController.size
                            : minSize;
                        final progress =
                            ((currentSize - minSize) / (maxSize - minSize))
                                .clamp(0.0, 1.0);
                        final opacity = progress < 0.15
                            ? 0.0
                            : ((progress - 0.15) / 0.35).clamp(0.0, 1.0);

                        return IgnorePointer(
                          ignoring: opacity == 0.0,
                          child: Opacity(
                            opacity: opacity,
                            child: Column(
                              children: [
                                Expanded(child: child!),
                                _QueueBottomActionBar(playerCubit: playerCubit),
                              ],
                            ),
                          ),
                        );
                      },
                      child: CustomScrollView(
                        controller: scrollController,
                        physics: const ClampingScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                              child: _QueueInfoRow(playerCubit: playerCubit)),
                          _SongListSliver(
                              playerCubit: playerCubit,
                              scrollController: scrollController),
                          const SliverToBoxAdapter(
                              child: SizedBox(height: 20)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactHeader extends StatelessWidget {
  final bool isExpanded;
  const _CompactHeader({required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.queue_music_rounded,
              color: Default_Theme.primaryColor2.withValues(alpha: 0.8),
              size: 18),
          const SizedBox(width: 8),
          Text(l10n.upNextTitle, style: _UpNextStyles.headerTextStyle),
          const SizedBox(width: 6),
          AnimatedRotation(
            turns: isExpanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            child: Icon(Icons.keyboard_arrow_up_rounded,
                color: Default_Theme.primaryColor2.withValues(alpha: 0.5),
                size: 20),
          ),
        ],
      ),
    );
  }
}

class _QueueInfoRow extends StatelessWidget {
  final BeatsPlayerCubit playerCubit;
  const _QueueInfoRow({required this.playerCubit});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          StreamBuilder<List<MediaItem>>(
            stream: playerCubit.BeatsPlayer.queue,
            builder: (context, snapshot) {
              return Text(l10n.upNextItemsInQueue(snapshot.data?.length ?? 0),
                  style: _UpNextStyles.queueCountStyle);
            },
          ),
          _ClearQueueButton(playerCubit: playerCubit),
        ],
      ),
    );
  }
}

/// Pill-styled "Clear Queue" button that keeps only the currently
/// playing track and removes everything else from the queue.
class _ClearQueueButton extends StatelessWidget {
  final BeatsPlayerCubit playerCubit;
  const _ClearQueueButton({required this.playerCubit});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => playerCubit.BeatsPlayer.clearQueue(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.18),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.playlist_remove_rounded,
              size: 15,
              color: Default_Theme.primaryColor2.withValues(alpha: 0.75),
            ),
            const SizedBox(width: 6),
            Text(
              'Clear',
              style: Default_Theme.secondoryTextStyleMedium.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Default_Theme.primaryColor2.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  final BeatsPlayerCubit playerCubit;
  const _DesktopLayout({required this.playerCubit});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: _UpNextStyles.desktopBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1), width: 0.5),
            ),
            child: Column(
              children: [
                const SizedBox(height: 16),
                const _CompactHeader(isExpanded: true),
                _QueueInfoRow(playerCubit: playerCubit),
                Expanded(child: _DesktopSongList(playerCubit: playerCubit)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopSongList extends StatefulWidget {
  final BeatsPlayerCubit playerCubit;
  const _DesktopSongList({required this.playerCubit});

  @override
  State<_DesktopSongList> createState() => _DesktopSongListState();
}

class _DesktopSongListState extends State<_DesktopSongList> {
  final ScrollController _scrollController = ScrollController();
  String? _lastPlayingId;
  static const double _itemHeight = 70.0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentSong(List<MediaItem> queue, String currentId) {
    final index = queue.indexWhere((item) => item.id == currentId);
    if (index == -1) {
      return;
    }

    // FIX: Subtract 1.5 item heights so the current song sits cleanly
    // in view with the previous song above it, instead of jamming into the top header.
    final targetOffset =
        math.max(0.0, (index * _itemHeight) - (_itemHeight * 1.5));
    final clampedOffset =
        targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent);

    _scrollController.animateTo(clampedOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MediaItem>>(
      stream: widget.playerCubit.BeatsPlayer.queue,
      builder: (context, queueSnapshot) {
        if (!queueSnapshot.hasData) {
          return const Center(
              child: CircularProgressIndicator(
                  color: Default_Theme.primaryColor2));
        }
        final queue = queueSnapshot.data!;

        return StreamBuilder<MediaItem?>(
          stream: widget.playerCubit.BeatsPlayer.mediaItem,
          builder: (context, mediaSnapshot) {
            final currentId = mediaSnapshot.data?.id;
            if (currentId != null && currentId != _lastPlayingId) {
              _lastPlayingId = currentId;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients) {
                  _scrollToCurrentSong(queue, currentId);
                }
              });
            }

            // Defensive deduplication: identical IDs would assign the same
            // GlobalKey to two ReorderableListView items, causing Flutter's
            // semantics traversal to recurse infinitely.
            final seenIds = <String>{};
            final uniqueQueue =
                queue.where((m) => seenIds.add(m.id)).toList(growable: false);

            return ReorderableListView.builder(
              scrollController: _scrollController,
              physics: const BouncingScrollPhysics(),
              itemCount: uniqueQueue.length,
              onReorder: widget.playerCubit.BeatsPlayer.moveQueueItem,
              buildDefaultDragHandles: false,
              itemBuilder: (context, index) {
                return _QueueItem(
                  key: ValueKey('desktop_${uniqueQueue[index].id}'),
                  mediaItem: uniqueQueue[index],
                  index: index,
                  playerCubit: widget.playerCubit,
                  isDesktop: true,
                );
              },
            );
          },
        );
      },
    );
  }
}

class _SongListSliver extends StatefulWidget {
  final BeatsPlayerCubit playerCubit;
  final ScrollController scrollController;
  const _SongListSliver(
      {required this.playerCubit, required this.scrollController});

  @override
  State<_SongListSliver> createState() => _SongListSliverState();
}

class _SongListSliverState extends State<_SongListSliver> {
  String? _lastPlayingId;
  static const double _itemHeight = 70.0;
  static const double _headerOffset = 60.0;

  void _scrollToCurrentSong(List<MediaItem> queue, String currentId) {
    if (!widget.scrollController.hasClients) {
      return;
    }
    final index = queue.indexWhere((item) => item.id == currentId);
    if (index == -1) {
      return;
    }

    // FIX: Subtract 1.5 item heights so the current song sits cleanly
    // in view with the previous song above it, instead of jamming into the top header.
    final targetOffset = math.max(
        0.0, _headerOffset + (index * _itemHeight) - (_itemHeight * 1.5));
    final clampedOffset = targetOffset.clamp(
        0.0, widget.scrollController.position.maxScrollExtent);

    widget.scrollController.animateTo(clampedOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MediaItem>>(
      stream: widget.playerCubit.BeatsPlayer.queue,
      builder: (context, queueSnapshot) {
        if (!queueSnapshot.hasData) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
        final queue = queueSnapshot.data!;

        return StreamBuilder<MediaItem?>(
          stream: widget.playerCubit.BeatsPlayer.mediaItem,
          builder: (context, mediaSnapshot) {
            final currentId = mediaSnapshot.data?.id;
            if (currentId != null && currentId != _lastPlayingId) {
              _lastPlayingId = currentId;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToCurrentSong(queue, currentId);
              });
            }

            // Defensive deduplication — same reason as the desktop list above.
            final seenIds = <String>{};
            final uniqueQueue =
                queue.where((m) => seenIds.add(m.id)).toList(growable: false);

            return SliverReorderableList(
              itemCount: uniqueQueue.length,
              onReorder: widget.playerCubit.BeatsPlayer.moveQueueItem,
              itemBuilder: (context, index) {
                return _QueueItem(
                  key: ValueKey('mobile_${uniqueQueue[index].id}'),
                  mediaItem: uniqueQueue[index],
                  index: index,
                  playerCubit: widget.playerCubit,
                  isDesktop: false,
                );
              },
            );
          },
        );
      },
    );
  }
}

class _QueueItem extends StatelessWidget {
  final MediaItem mediaItem;
  final int index;
  final BeatsPlayerCubit playerCubit;
  final bool isDesktop;

  const _QueueItem({
    super.key,
    required this.mediaItem,
    required this.index,
    required this.playerCubit,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final songModel = mediaItemToTrack(mediaItem);

    Widget content = Dismissible(
      key: ValueKey('dismiss_${mediaItem.id}'),
      direction: DismissDirection.startToEnd,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        color: Colors.red.withValues(alpha: 0.8),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => playerCubit.BeatsPlayer.removeQueueItemAt(index),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          // FIX: Removed the massive 24px Android padding gap. Just a slim 8px edge.
          padding: EdgeInsets.only(right: isDesktop ? 8.0 : 0.0),
          child: Row(
            children: [
              Expanded(
                child: SongCardWidget(
                  showOptions: true,
                  onTap: () => playerCubit.BeatsPlayer.skipToQueueItem(index),
                  onOptionsTap: () => showMoreBottomSheet(
                    context,
                    songModel,
                    showAddToQueue: false,
                    showPlayNext: false,
                    showSinglePlay: true,
                  ),
                  song: songModel,
                ),
              ),
              if (isDesktop)
                ReorderableDragStartListener(
                  index: index,
                  child: Padding(
                    // FIX: Slimmer horizontal padding limits the width entirely while maintaining grabability
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    child: Icon(Icons.drag_handle_rounded,
                        color:
                            Default_Theme.primaryColor2.withValues(alpha: 0.4),
                        size: 20),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    return isDesktop
        ? content
        : ReorderableDelayedDragStartListener(index: index, child: content);
  }
}

class _QueueBottomActionBar extends StatelessWidget {
  final BeatsPlayerCubit playerCubit;
  const _QueueBottomActionBar({required this.playerCubit});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161616).withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 0.5,
          ),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        math.max(MediaQuery.of(context).padding.bottom, 24) + 8,
      ),
      child: Row(
        children: [
          Expanded(child: _QueueShuffleAction(playerCubit: playerCubit)),
          const SizedBox(width: 10),
          Expanded(child: _QueueRepeatAction(playerCubit: playerCubit)),
          const SizedBox(width: 10),
          const Expanded(child: _QueueTimerAction()),
        ],
      ),
    );
  }
}

class _QueueShuffleAction extends StatelessWidget {
  final BeatsPlayerCubit playerCubit;
  const _QueueShuffleAction({required this.playerCubit});

  @override
  Widget build(BuildContext context) {
    final player = playerCubit.BeatsPlayer;
    return StreamBuilder<ShuffleModeState>(
      stream: player.shuffleState,
      builder: (context, snapshot) {
        final mode = snapshot.data ?? ShuffleModeState.off;
        final isActive = mode != ShuffleModeState.off;
        final color = isActive ? AppTheme.successAccent : Colors.white;

        Widget iconWidget;
        String label = 'Shuffle';
        if (mode == ShuffleModeState.smartShuffle) {
          label = 'Smart';
          iconWidget = Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(MingCute.shuffle_2_line, color: color, size: 24),
              Positioned(
                top: -3,
                right: -4,
                child: Icon(MingCute.sparkles_fill, color: color, size: 12),
              ),
            ],
          );
        } else {
          iconWidget = Icon(MingCute.shuffle_2_line, color: color, size: 24);
        }

        return InkWell(
          onTap: () {
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
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              color: const Color(0xFF282828),
              borderRadius: BorderRadius.circular(16),
              border: isActive
                  ? Border.all(
                      color: AppTheme.successAccent.withValues(alpha: 0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                iconWidget,
                const SizedBox(height: 5),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QueueRepeatAction extends StatelessWidget {
  final BeatsPlayerCubit playerCubit;
  const _QueueRepeatAction({required this.playerCubit});

  @override
  Widget build(BuildContext context) {
    final player = playerCubit.BeatsPlayer;
    return StreamBuilder<LoopMode>(
      stream: player.loopMode,
      builder: (context, snapshot) {
        final loop = snapshot.data ?? LoopMode.off;
        final isActive = loop != LoopMode.off;
        final color = isActive ? AppTheme.successAccent : Colors.white;

        IconData icon = MingCute.repeat_line;
        String label = 'Repeat';
        if (loop == LoopMode.one) {
          icon = MingCute.repeat_one_line;
          label = 'Repeat 1';
        }

        return InkWell(
          onTap: () {
            if (loop == LoopMode.off) {
              player.setLoopMode(LoopMode.all);
              SnackbarService.showMessage('Repeat All');
            } else if (loop == LoopMode.all) {
              player.setLoopMode(LoopMode.one);
              SnackbarService.showMessage('Repeat Current');
            } else {
              player.setLoopMode(LoopMode.off);
              SnackbarService.showMessage('Repeat Off');
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              color: const Color(0xFF282828),
              borderRadius: BorderRadius.circular(16),
              border: isActive
                  ? Border.all(
                      color: AppTheme.successAccent.withValues(alpha: 0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 5),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QueueTimerAction extends StatelessWidget {
  const _QueueTimerAction();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerBloc, TimerState>(
      builder: (context, state) {
        final isRunning = state is TimerRunInProgress;
        final color = isRunning ? AppTheme.successAccent : Colors.white;

        String label = 'Timer';
        if (isRunning) {
          final minutes = (state.duration / 60).ceil();
          label = '${minutes}m left';
        }

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TimerView()),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              color: const Color(0xFF282828),
              borderRadius: BorderRadius.circular(16),
              border: isRunning
                  ? Border.all(
                      color: AppTheme.successAccent.withValues(alpha: 0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(MingCute.stopwatch_line, color: color, size: 24),
                const SizedBox(height: 5),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}



