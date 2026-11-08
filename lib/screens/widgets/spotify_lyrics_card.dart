import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:audio_service/audio_service.dart';

import 'package:beats_music/blocs/lyrics/lyrics_cubit.dart';
import 'package:beats_music/blocs/media_player/beats_player_cubit.dart';
import 'package:beats_music/core/models/lyrics_models.dart';
import 'package:beats_music/screens/screen/player_views/fullscreen_lyrics_view.dart';
import 'package:beats_music/screens/screen/player_views/lyrics_search.dart';
import 'package:beats_music/utils/pallete_generator.dart';

/// A Spotify-identical Lyrics card preview rendered on the player screen.
///
/// Features:
/// - Rounded palette-colored container matching album artwork.
/// - Top header with "Lyrics" title, Share button, and Expand/Fullscreen button.
/// - Live synchronized lyric lines with active line highlighted in bold white.
/// - Tap anywhere on the card or the expand button to open [FullscreenLyricsView].
class SpotifyLyricsPreviewCard extends StatefulWidget {
  const SpotifyLyricsPreviewCard({super.key});

  @override
  State<SpotifyLyricsPreviewCard> createState() =>
      _SpotifyLyricsPreviewCardState();
}

class _SpotifyLyricsPreviewCardState extends State<SpotifyLyricsPreviewCard> {
  Color? _cachedColor;
  String? _lastArtUri;

  @override
  Widget build(BuildContext context) {
    final playerCubit = context.read<BeatsPlayerCubit>();
    final musicPlayer = playerCubit.BeatsPlayer;

    return StreamBuilder<MediaItem?>(
      stream: musicPlayer.mediaItem,
      builder: (context, mediaSnapshot) {
        final currentMedia = mediaSnapshot.data;
        if (currentMedia == null) return const SizedBox.shrink();

        final artUri = currentMedia.artUri?.toString() ?? '';
        if (artUri != _lastArtUri) {
          _lastArtUri = artUri;
          _fetchPalette(artUri);
        }

        final baseColor = _cachedColor ?? const Color(0xFF4A151D);
        final cardColor = HSLColor.fromColor(baseColor)
            .withLightness(
              HSLColor.fromColor(baseColor).lightness.clamp(0.18, 0.32),
            )
            .toColor();

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cardColor,
                cardColor.withValues(alpha: 0.88),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () => _openFullscreen(context),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Row: 'Lyrics' | Share + Expand
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Lyrics',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _CircleActionBtn(
                              icon: MingCute.share_2_line,
                              tooltip: 'Share lyrics',
                              onTap: () => _shareLyrics(context, musicPlayer),
                            ),
                            const SizedBox(width: 8),
                            _CircleActionBtn(
                              icon: Icons.open_in_full_rounded,
                              tooltip: 'Full screen',
                              onTap: () => _openFullscreen(context),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Lyrics lines preview
                    BlocBuilder<LyricsCubit, LyricsState>(
                      builder: (context, state) {
                        if (state is LyricsLoading) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Loading lyrics...',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        if (state is LyricsLoaded) {
                          final parsed = state.lyrics.parsedLyrics;
                          if (parsed != null && parsed.lyrics.isNotEmpty) {
                            return StreamBuilder<Duration>(
                              stream: musicPlayer.engine.positionStream,
                              builder: (context, posSnapshot) {
                                final position =
                                    posSnapshot.data ?? Duration.zero;
                                final activeIndex = _findCurrentLyricIndex(
                                  parsed.lyrics,
                                  position,
                                );

                                // Display 3 to 4 visible lines centered around activeIndex
                                final startIndex = max(0, activeIndex - 1);
                                final endIndex = min(
                                  parsed.lyrics.length,
                                  startIndex + 4,
                                );
                                final visibleLines = parsed.lyrics.sublist(
                                  startIndex,
                                  endIndex,
                                );

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: visibleLines.asMap().entries.map((entry) {
                                    final i = entry.key;
                                    final line = entry.value;
                                    final lineIndex = startIndex + i;
                                    final isCurrent = lineIndex == activeIndex;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0),
                                      child: AnimatedDefaultTextStyle(
                                        duration:
                                            const Duration(milliseconds: 250),
                                        style: TextStyle(
                                          color: isCurrent
                                              ? Colors.white
                                              : Colors.black.withValues(alpha: 0.55),
                                          fontSize: isCurrent ? 22 : 18,
                                          fontWeight: isCurrent
                                              ? FontWeight.bold
                                              : FontWeight.w600,
                                          height: 1.35,
                                        ),
                                        child: Text(
                                          line.text.isEmpty
                                              ? '♪'
                                              : line.text,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
                            );
                          } else if (state.lyrics.lyricsPlain
                              .trim()
                              .isNotEmpty) {
                            final lines = state.lyrics.lyricsPlain
                                .split('\n')
                                .map((l) => l.trim())
                                .where((l) => l.isNotEmpty)
                                .take(4)
                                .toList();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (int i = 0; i < lines.length; i++)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    child: Text(
                                      lines[i],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: i == 0
                                            ? Colors.white
                                            : Colors.black.withValues(alpha: 0.55),
                                        fontSize: i == 0 ? 20 : 17,
                                        fontWeight: i == 0
                                            ? FontWeight.bold
                                            : FontWeight.w600,
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          }
                        }

                        // No lyrics or Error
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  "Lyrics aren't available for this song",
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.65),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  final currentMedia = musicPlayer.currentMedia;
                                  showSearch(
                                    context: context,
                                    delegate: LyricsSearchDelegate(
                                      mediaID: currentMedia.id,
                                      searchFieldLabelText: 'Search lyrics',
                                    ),
                                    query: buildLyricsSearchSeedQuery(
                                      title: currentMedia.title,
                                      artists: currentMedia.artists
                                          .map((a) => a.name)
                                          .toList(),
                                      album: currentMedia.album?.title,
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.white12,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Search'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  int _findCurrentLyricIndex(
      List<ParsedLyric> lyrics, Duration currentPosition) {
    if (lyrics.isEmpty) return 0;
    if (currentPosition < lyrics[0].start) return 0;
    if (currentPosition >= lyrics.last.start) return lyrics.length - 1;
    for (int i = 0; i < lyrics.length; i++) {
      final nextStart =
          i + 1 < lyrics.length ? lyrics[i + 1].start : const Duration(days: 1);
      if (currentPosition >= lyrics[i].start && currentPosition < nextStart) {
        return i;
      }
    }
    return lyrics.length - 1;
  }

  void _openFullscreen(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const FullscreenLyricsView(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 0.08);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;
          final tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: animation.drive(tween),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _shareLyrics(BuildContext context, dynamic musicPlayer) {
    final lyricsState = context.read<LyricsCubit>().state;
    final track = musicPlayer.currentMedia;
    String textToShare = '${track.title} - ${track.artists.map((a) => a.name).join(", ")}\n';

    if (lyricsState is LyricsLoaded &&
        lyricsState.lyrics.lyricsPlain.trim().isNotEmpty) {
      final sample = lyricsState.lyrics.lyricsPlain
          .split('\n')
          .take(6)
          .join('\n');
      textToShare += '\n$sample\n\nListen on Beats Music';
    } else if (track.url != null && track.url!.isNotEmpty) {
      textToShare += '${track.url}';
    }

    SharePlus.instance.share(ShareParams(
      text: textToShare,
      subject: track.title,
    ));
  }

  void _fetchPalette(String artUri) async {
    if (artUri.isEmpty) return;
    try {
      final palette = await getPalleteFromImage(artUri);
      final picked = palette.darkMutedColor?.color ??
          palette.dominantColor?.color ??
          palette.darkVibrantColor?.color;
      if (mounted && picked != null) {
        setState(() => _cachedColor = picked);
      }
    } catch (_) {}
  }
}

class _CircleActionBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _CircleActionBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: Colors.black26,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 18),
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        onPressed: onTap,
      ),
    );
  }
}
