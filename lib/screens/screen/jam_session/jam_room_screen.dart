import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:beats_music/blocs/jam_session/jam_session_cubit.dart';
import 'package:beats_music/blocs/media_player/beats_player_cubit.dart';
import 'package:beats_music/core/constants/route_paths.dart';
import 'package:beats_music/core/models/exported.dart';
import 'package:beats_music/core/theme/app_theme.dart';
import 'package:beats_music/services/beats_player.dart';
import 'package:beats_music/services/jam_session_service.dart';
import 'package:beats_music/utils/load_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:share_plus/share_plus.dart';

/// Full-screen Live Listening Room UI.
///
/// Host sees: room code, "now playing" card, live member count, reaction bar.
/// Listener sees: same view but playback controls are disabled.
class JamRoomScreen extends StatefulWidget {
  final String? joinCode;
  const JamRoomScreen({super.key, this.joinCode});

  @override
  State<JamRoomScreen> createState() => _JamRoomScreenState();
}

class _JamRoomScreenState extends State<JamRoomScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _bgController;
  final List<_FloatingEmoji> _floatingEmojis = [];
  Timer? _emojiCleanupTimer;

  // Reaction stream subscription
  StreamSubscription? _reactionSub;
  StreamSubscription? _playerMediaItemSub;
  StreamSubscription? _playerPlayingSub;
  bool _isHostSyncStarted = false;

  // Listener-side sync tracking
  String? _listenerLastTrackId;
  bool? _listenerLastIsPlaying;

  static const _reactions = ['❤️', '🔥', '🎵', '🤩', '😍', '🎶', '👏', '💥'];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Clean up old floating emoji overlays every second
    _emojiCleanupTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _floatingEmojis.removeWhere((e) => e.isDead);
        });
      }
    });

    if (widget.joinCode != null && widget.joinCode!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final cubit = context.read<JamSessionCubit>();
          if (cubit.state is! JamSessionActive) {
            cubit.joinRoom(widget.joinCode!);
          }
        }
      });
    }
  }

  void _setupHostSync(BeatsMusicPlayer player, JamSessionCubit cubit) {
    if (_isHostSyncStarted) return;
    _isHostSyncStarted = true;

    // Immediately push whatever is currently playing
    final currentItem = player.mediaItem.value;
    if (currentItem != null) {
      cubit.pushPlayback(
        trackId: currentItem.id,
        trackTitle: currentItem.title,
        artistName: currentItem.artist,
        artworkUrl: currentItem.artUri?.toString(),
        positionMs: player.engine.position.inMilliseconds,
        isPlaying: player.engine.playing,
      );
    }

    // Listen to mediaItem changes (track change / new song)
    _playerMediaItemSub = player.mediaItem.listen((item) {
      if (!mounted) return;
      if (item != null) {
        cubit.pushPlayback(
          trackId: item.id,
          trackTitle: item.title,
          artistName: item.artist,
          artworkUrl: item.artUri?.toString(),
          positionMs: player.engine.position.inMilliseconds,
          isPlaying: player.engine.playing,
        );
      }
    });

    // Listen to play / pause changes
    _playerPlayingSub = player.engine.playingStream.listen((playing) {
      if (!mounted) return;
      final item = player.mediaItem.value;
      cubit.pushPlayback(
        trackId: item?.id,
        trackTitle: item?.title,
        artistName: item?.artist,
        artworkUrl: item?.artUri?.toString(),
        positionMs: player.engine.position.inMilliseconds,
        isPlaying: playing,
      );
    });

    // Periodic sync heartbeat
    cubit.startSync(() {
      final item = player.mediaItem.value;
      return JamPlaybackState(
        trackId: item?.id,
        trackTitle: item?.title,
        artistName: item?.artist,
        artworkUrl: item?.artUri?.toString(),
        positionMs: player.engine.position.inMilliseconds,
        isPlaying: player.engine.playing,
        syncedAt: DateTime.now(),
      );
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bgController.dispose();
    _reactionSub?.cancel();
    _emojiCleanupTimer?.cancel();
    _playerMediaItemSub?.cancel();
    _playerPlayingSub?.cancel();
    super.dispose();
  }

  void _addFloatingEmoji(String emoji) {
    if (!mounted) return;
    setState(() {
      _floatingEmojis.add(_FloatingEmoji(emoji: emoji));
    });
  }

  void _sendReaction(String emoji) {
    context.read<JamSessionCubit>().sendReaction(emoji);
    _addFloatingEmoji(emoji);
  }

  Future<bool> _onWillPop(JamSessionActive state) async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          state.isHost ? '🔴 End Room?' : '🚪 Leave Room?',
          style: const TextStyle(
              color: Default_Theme.primaryColor1,
              fontFamily: 'Gilroy',
              fontWeight: FontWeight.w700),
        ),
        content: Text(
          state.isHost
              ? 'Ending the room will disconnect all listeners.'
              : 'You can rejoin with the same code.',
          style: TextStyle(
              color: Default_Theme.primaryColor1.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Stay',
                style: TextStyle(color: AppTheme.successAccent)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Leave',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    return leave ?? false;
  }

  /// Synchronises the listener's local player to match the host's
  /// [JamPlaybackState] received from Firestore.
  ///
  /// Rules:
  ///   - New track → [playTrack] with latency-compensated initial position
  ///   - Same track, play/pause changed → [play] or [pause]
  ///   - Same track, drift >3 s → [seek]
  Future<void> _syncListenerPlayback(
    BeatsMusicPlayer player,
    JamPlaybackState pb,
  ) async {
    final trackId = pb.trackId;
    if (trackId == null || trackId.isEmpty) return; // host hasn't picked yet

    final isNewTrack = _listenerLastTrackId != trackId;

    if (isNewTrack) {
      _listenerLastTrackId = trackId;
      _listenerLastIsPlaying = pb.isPlaying;

      // Build a minimal Track so BeatsMusicPlayer can resolve its stream URL.
      final track = Track(
        id: trackId,
        title: pb.trackTitle ?? 'Unknown',
        artists: [
          if (pb.artistName != null && pb.artistName!.isNotEmpty)
            ArtistSummary(
              id: 'jam_artist',
              name: pb.artistName!,
            ),
        ],
        thumbnail: Artwork(
          url: pb.artworkUrl ?? '',
          layout: ImageLayout.square,
        ),
        isExplicit: false,
      );

      // Compensate for round-trip latency.
      final elapsed =
          DateTime.now().difference(pb.syncedAt).inMilliseconds.clamp(0, 10000);
      final seekTo = Duration(
        milliseconds: (pb.positionMs + elapsed).clamp(0, 600000),
      );

      await player.playTrack(track);
      if (seekTo > Duration.zero) {
        // Give the engine a moment to start before seeking.
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) await player.seek(seekTo);
      }
      if (!pb.isPlaying && mounted) await player.pause();
      return;
    }

    // Same track — handle play/pause toggle.
    if (_listenerLastIsPlaying != pb.isPlaying) {
      _listenerLastIsPlaying = pb.isPlaying;
      if (pb.isPlaying) {
        await player.play();
      } else {
        await player.pause();
      }
    }

    // Same track, same play state — correct position drift.
    if (pb.isPlaying) {
      final currentMs = player.engine.position.inMilliseconds;
      final elapsed =
          DateTime.now().difference(pb.syncedAt).inMilliseconds.clamp(0, 10000);
      final expectedMs = pb.positionMs + elapsed;
      final drift = (currentMs - expectedMs).abs();
      if (drift > 3000) {
        await player.seek(Duration(milliseconds: expectedMs.clamp(0, 600000)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<JamSessionCubit, JamSessionState>(
      listener: (context, state) {
        if (state is JamSessionLeft) {
          if (Navigator.canPop(context)) Navigator.pop(context);
        }

        // ── Listener-side audio sync ──────────────────────────────────
        if (state is JamSessionActive && !state.isHost) {
          final pb = state.playback;
          if (pb.trackId != null && pb.trackId!.isNotEmpty) {
            final player = context.read<BeatsPlayerCubit>().BeatsPlayer;
            _syncListenerPlayback(player, pb);
          }
        }
      },
      builder: (context, state) {
        if (state is JamSessionLoading || state is JamSessionInitial) {
          return Scaffold(
            backgroundColor: const Color(0xFF050520),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Colors.redAccent),
                  const SizedBox(height: 16),
                  Text(
                    state is JamSessionLoading
                        ? 'Connecting to Live Room...'
                        : 'Preparing Live Room...',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        context.goNamed(RoutePaths.libraryScreen);
                      }
                    },
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.white54)),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is JamSessionError) {
          return Scaffold(
            backgroundColor: const Color(0xFF050520),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: Colors.redAccent, size: 56),
                    const SizedBox(height: 16),
                    const Text(
                      'Live Room Error',
                      style: TextStyle(
                        fontFamily: 'Fjalla',
                        fontSize: 22,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          context.goNamed(RoutePaths.libraryScreen);
                        }
                      },
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (state is! JamSessionActive) {
          return Scaffold(
            backgroundColor: const Color(0xFF050520),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No active session',
                      style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        context.goNamed(RoutePaths.libraryScreen);
                      }
                    },
                    child: const Text('Go Back',
                        style: TextStyle(color: Colors.redAccent)),
                  ),
                ],
              ),
            ),
          );
        }

        if (state.isHost) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _setupHostSync(
                context.read<BeatsPlayerCubit>().BeatsPlayer,
                context.read<JamSessionCubit>(),
              );
            }
          });
        }

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (!didPop) {
              final shouldLeave = await _onWillPop(state);
              if (shouldLeave && context.mounted) {
                context.read<JamSessionCubit>().leaveRoom();
              }
            }
          },
          child: Scaffold(
            backgroundColor: const Color(0xFF050520),
            body: Stack(
              fit: StackFit.expand,
              children: [
                // ── Animated gradient background ──────────────────────
                _AnimatedBackground(controller: _bgController),

                // ── Main content ──────────────────────────────────────
                SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        _buildTopBar(context, state),
                        const SizedBox(height: 8),
                        _buildRoomCode(state),
                        const SizedBox(height: 16),
                        _buildNowPlayingCard(context, state),
                        const SizedBox(height: 16),
                        if (state.isHost) ...[
                          _buildHostControls(context, state),
                          const SizedBox(height: 16),
                        ] else ...[
                          _buildListenerCard(context, state),
                          const SizedBox(height: 16),
                        ],
                        _buildMembersRow(state),
                        const SizedBox(height: 16),
                        _buildReactionBar(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // ── Floating emoji overlay ────────────────────────────
                ..._floatingEmojis.map((e) => _FloatingEmojiWidget(data: e)),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Sub-builders ─────────────────────────────────────────────────────────

  Widget _buildTopBar(BuildContext context, JamSessionActive state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Back / Leave
          GestureDetector(
            onTap: () async {
              final shouldLeave = await _onWillPop(state);
              if (shouldLeave && context.mounted) {
                context.read<JamSessionCubit>().leaveRoom();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.room.roomName ?? '🎧 Live Room',
                  style: const TextStyle(
                    fontFamily: 'Fjalla',
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                Text(
                  state.isHost ? '🔴 Hosting' : '👂 Listening',
                  style: TextStyle(
                    fontSize: 12,
                    color: state.isHost
                        ? Colors.redAccent
                        : Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          // Share button (host only)
          if (state.isHost)
            GestureDetector(
              onTap: () => SharePlus.instance.share(
                ShareParams(
                  text:
                      '🎧 Join my Live Listening Room on Beats Music!\n\nCode: ${state.room.roomCode}',
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.share_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRoomCode(JamSessionActive state) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: state.room.roomCode));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Room code copied! 📋')),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              state.room.roomCode,
              style: const TextStyle(
                fontFamily: 'CodePro',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 5,
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.copy_rounded,
                size: 16, color: Colors.white.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildNowPlayingCard(BuildContext context, JamSessionActive state) {
    final pb = state.playback;
    final hasTrack = pb.trackTitle != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                // Artwork
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: hasTrack && pb.artworkUrl != null
                      ? LoadImageCached(
                          imageUrl: pb.artworkUrl!,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            MingCute.music_2_fill,
                            color: Colors.white.withValues(alpha: 0.3),
                            size: 36,
                          ),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasTrack
                            ? pb.trackTitle!
                            : (state.isHost
                                ? 'No Music Playing'
                                : 'Waiting for host...'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Gilroy',
                          fontWeight: FontWeight.w700,
                          fontSize: hasTrack ? 16 : 14,
                          color: hasTrack
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.6),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasTrack
                            ? (pb.artistName ?? 'Unknown Artist')
                            : (state.isHost
                                ? 'Pick songs below to stream to room'
                                : 'Host hasn\'t selected music yet'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Playing indicator
                      Row(
                        children: [
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (_, __) => Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (hasTrack && pb.isPlaying)
                                    ? Color.lerp(
                                        AppTheme.successAccent,
                                        AppTheme.successAccent
                                            .withValues(alpha: 0.4),
                                        _pulseController.value,
                                      )!
                                    : Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            !hasTrack
                                ? (state.isHost ? 'Ready to Play' : 'Waiting')
                                : (pb.isPlaying ? 'Live' : 'Paused'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: (hasTrack && pb.isPlaying)
                                  ? AppTheme.successAccent
                                  : Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                          if (hasTrack) ...[
                            const SizedBox(width: 10),
                            Text(
                              _formatMs(pb.positionMs),
                              style: TextStyle(
                                fontFamily: 'CodePro',
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.35),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHostControls(BuildContext context, JamSessionActive state) {
    final playerCubit = context.read<BeatsPlayerCubit>();
    final player = playerCubit.BeatsPlayer;
    final cubit = context.read<JamSessionCubit>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.tune_rounded,
                            size: 16, color: AppTheme.accentColor1),
                        const SizedBox(width: 8),
                        Text(
                          'HOST PLAYBACK CONTROLS',
                          style: TextStyle(
                            fontFamily: 'CodePro',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor1.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Live Broadcast',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.accentColor1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Progress Slider
                StreamBuilder<ProgressBarStreams>(
                  stream: playerCubit.progressStreams,
                  builder: (context, snapshot) {
                    final data = snapshot.data;
                    final position = data?.position ?? Duration.zero;
                    final duration = data?.duration ?? Duration.zero;
                    final maxMs = duration.inMilliseconds.toDouble();
                    final curMs = position.inMilliseconds
                        .toDouble()
                        .clamp(0.0, maxMs > 0 ? maxMs : 1.0);

                    return Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 4,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 14),
                            activeTrackColor: AppTheme.accentColor1,
                            inactiveTrackColor:
                                Colors.white.withValues(alpha: 0.12),
                            thumbColor: Colors.white,
                            overlayColor:
                                AppTheme.accentColor1.withValues(alpha: 0.2),
                          ),
                          child: Slider(
                            value: curMs,
                            min: 0,
                            max: maxMs > 0 ? maxMs : 1.0,
                            onChanged: maxMs > 0 ? (_) {} : null,
                            onChangeEnd: maxMs > 0
                                ? (val) async {
                                    final seekPos =
                                        Duration(milliseconds: val.toInt());
                                    await player.seek(seekPos);
                                    final item = player.mediaItem.value;
                                    cubit.pushPlayback(
                                      trackId: item?.id,
                                      trackTitle: item?.title,
                                      artistName: item?.artist,
                                      artworkUrl: item?.artUri?.toString(),
                                      positionMs: seekPos.inMilliseconds,
                                      isPlaying: player.engine.playing,
                                    );
                                  }
                                : null,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatMs(position.inMilliseconds),
                                style: TextStyle(
                                  fontFamily: 'CodePro',
                                  fontSize: 11,
                                  color: Colors.white.withValues(alpha: 0.4),
                                ),
                              ),
                              Text(
                                _formatMs(duration.inMilliseconds),
                                style: TextStyle(
                                  fontFamily: 'CodePro',
                                  fontSize: 11,
                                  color: Colors.white.withValues(alpha: 0.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8),
                // Playback Buttons
                StreamBuilder<ProgressBarStreams>(
                  stream: playerCubit.progressStreams,
                  builder: (context, snapshot) {
                    final isPlaying = snapshot.data?.isPlaying ?? false;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            player.skipToPrevious();
                          },
                          icon: const Icon(Icons.skip_previous_rounded,
                              size: 30, color: Colors.white),
                          tooltip: 'Previous Track',
                        ),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            if (isPlaying) {
                              player.pause();
                            } else {
                              player.play();
                            }
                          },
                          child: Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  AppTheme.accentColor1,
                                  Color(0xFF8A2BE2)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.accentColor1
                                      .withValues(alpha: 0.4),
                                  blurRadius: 18,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              size: 34,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            player.skipToNext();
                          },
                          icon: const Icon(Icons.skip_next_rounded,
                              size: 30, color: Colors.white),
                          tooltip: 'Next Track',
                        ),
                        IconButton(
                          onPressed: () {
                            context.pushNamed(RoutePaths.playerScreen);
                          },
                          icon: const Icon(Icons.open_in_full_rounded,
                              size: 22, color: Colors.white70),
                          tooltip: 'Full Player',
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Music action shortcuts: Search and Library
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.15)),
                          backgroundColor: Colors.white.withValues(alpha: 0.05),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () =>
                            context.pushNamed(RoutePaths.searchScreen),
                        icon: const Icon(MingCute.search_2_line,
                            size: 18, color: AppTheme.accentColor1),
                        label: const Text(
                          'Search Songs',
                          style: TextStyle(
                            fontFamily: 'Gilroy',
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.15)),
                          backgroundColor: Colors.white.withValues(alpha: 0.05),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () =>
                            context.pushNamed(RoutePaths.libraryScreen),
                        icon: const Icon(MingCute.music_2_line,
                            size: 18, color: AppTheme.successAccent),
                        label: const Text(
                          'From Library',
                          style: TextStyle(
                            fontFamily: 'Gilroy',
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListenerCard(BuildContext context, JamSessionActive state) {
    final pb = state.playback;
    final hasTrack = pb.trackTitle != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.successAccent.withValues(alpha: 0.15),
              ),
              child: const Icon(Icons.headphones_rounded,
                  color: AppTheme.successAccent, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasTrack ? 'Synchronized with Host' : 'Live Room Connected',
                    style: const TextStyle(
                      fontFamily: 'Gilroy',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasTrack
                        ? (pb.isPlaying
                            ? 'Streaming playback live from host'
                            : 'Host paused playback')
                        : 'Waiting for host to pick music',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersRow(JamSessionActive state) {
    final members = state.members;
    final count = members.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Stacked avatars
          SizedBox(
            width: (count.clamp(0, 4) * 20.0) + 28,
            height: 32,
            child: Stack(
              children: [
                for (int i = 0; i < members.take(4).length; i++)
                  Positioned(
                    left: i * 20.0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.accentColor1.withValues(alpha: 0.7),
                            AppTheme.successAccent.withValues(alpha: 0.5),
                          ],
                        ),
                        border: Border.all(
                            color: const Color(0xFF050520), width: 2),
                      ),
                      child: Center(
                        child: Text(
                          members[i].displayName.isNotEmpty
                              ? members[i].displayName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$count ${count == 1 ? 'listener' : 'listeners'}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactionBar() {
    return Column(
      children: [
        Text(
          'Send a reaction',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.35),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _reactions
                .map((emoji) => GestureDetector(
                      onTap: () => _sendReaction(emoji),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Center(
                          child: Text(emoji,
                              style: const TextStyle(fontSize: 24)),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  String _formatMs(int ms) {
    final dur = Duration(milliseconds: ms);
    final m = dur.inMinutes;
    final s = dur.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

// ─── Animated background ─────────────────────────────────────────────────────

class _AnimatedBackground extends StatelessWidget {
  final AnimationController controller;
  const _AnimatedBackground({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final t = controller.value;
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                sin(t * 2 * pi) * 0.6,
                cos(t * 2 * pi) * 0.5,
              ),
              radius: 1.2,
              colors: [
                AppTheme.accentColor1.withValues(alpha: 0.25),
                AppTheme.successAccent.withValues(alpha: 0.08),
                const Color(0xFF050520),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Floating emoji ───────────────────────────────────────────────────────────

class _FloatingEmoji {
  final String emoji;
  final double x;
  final DateTime born;
  static const Duration lifetime = Duration(seconds: 3);

  _FloatingEmoji({required this.emoji})
      : x = Random().nextDouble(),
        born = DateTime.now();

  bool get isDead =>
      DateTime.now().difference(born) > lifetime;
}

class _FloatingEmojiWidget extends StatefulWidget {
  final _FloatingEmoji data;
  const _FloatingEmojiWidget({required this.data});

  @override
  State<_FloatingEmojiWidget> createState() => _FloatingEmojiWidgetState();
}

class _FloatingEmojiWidgetState extends State<_FloatingEmojiWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _yAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: _FloatingEmoji.lifetime,
    )..forward();

    _yAnim = Tween<double>(begin: 0.8, end: 0.1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _fadeAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _ctrl,
          curve: const Interval(0.6, 1.0, curve: Curves.easeIn)),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Positioned(
        left: widget.data.x * size.width - 20,
        top: _yAnim.value * size.height,
        child: Opacity(
          opacity: _fadeAnim.value,
          child: Text(
            widget.data.emoji,
            style: const TextStyle(fontSize: 36),
          ),
        ),
      ),
    );
  }
}
