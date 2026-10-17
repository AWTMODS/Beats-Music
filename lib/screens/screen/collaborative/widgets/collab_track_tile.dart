import 'package:beats_music/core/theme/app_theme.dart';
import 'package:beats_music/services/collaborative_playlist_service.dart';
import 'package:beats_music/utils/load_image.dart';
import 'package:flutter/material.dart';

/// A track tile in the collaborative playlist detail view.
/// Shows rank, artwork, title/artist, added-by info, and vote controls.
class CollabTrackTile extends StatelessWidget {
  final CollabTrack collabTrack;
  final String myUid;
  final int rank;
  final bool canRemove;
  final VoidCallback onPlay;
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;
  final VoidCallback? onRemove;

  const CollabTrackTile({
    super.key,
    required this.collabTrack,
    required this.myUid,
    required this.rank,
    required this.canRemove,
    required this.onPlay,
    required this.onUpvote,
    required this.onDownvote,
    this.onRemove,
  });

  bool get _hasUpvoted => collabTrack.hasUpvoted(myUid);
  bool get _hasDownvoted => collabTrack.hasDownvoted(myUid);

  Color get _scoreColor {
    if (collabTrack.score > 0) return const Color(0xFF5EFF43);
    if (collabTrack.score < 0) return const Color(0xFFFF4A4A);
    return Default_Theme.primaryColor1.withValues(alpha: 0.5);
  }

  @override
  Widget build(BuildContext context) {
    final track = collabTrack.track;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _hasUpvoted
              ? AppTheme.successAccent.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPlay,
          borderRadius: BorderRadius.circular(16),
          splashColor: AppTheme.successAccent.withValues(alpha: 0.06),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // ── Rank ───────────────────────────────────────────────
                SizedBox(
                  width: 28,
                  child: Text(
                    '$rank',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'CodePro',
                      fontSize: 13,
                      color:
                          Default_Theme.primaryColor1.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // ── Artwork ────────────────────────────────────────────
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LoadImageCached(
                    imageUrl: track.thumbnail.url,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),

                // ── Info ───────────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Gilroy',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Default_Theme.primaryColor1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        track.artists.isNotEmpty
                            ? track.artists.first.name
                            : 'Unknown',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Default_Theme.primaryColor1
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'by ${collabTrack.addedByName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.accentColor1
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Vote controls ──────────────────────────────────────
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Score badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: _scoreColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        collabTrack.score >= 0
                            ? '+${collabTrack.score}'
                            : '${collabTrack.score}',
                        style: TextStyle(
                          fontFamily: 'CodePro',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _scoreColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),

                    // Upvote
                    _VoteButton(
                      icon: Icons.thumb_up_rounded,
                      active: _hasUpvoted,
                      activeColor: AppTheme.successAccent,
                      onTap: onUpvote,
                    ),

                    // Downvote
                    _VoteButton(
                      icon: Icons.thumb_down_rounded,
                      active: _hasDownvoted,
                      activeColor: const Color(0xFFFF4A4A),
                      onTap: onDownvote,
                    ),

                    // Remove (if allowed)
                    if (onRemove != null)
                      _VoteButton(
                        icon: Icons.close_rounded,
                        active: false,
                        activeColor: Colors.red,
                        onTap: onRemove!,
                        size: 16,
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
}

class _VoteButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;
  final double size;

  const _VoteButton({
    required this.icon,
    required this.active,
    required this.activeColor,
    required this.onTap,
    this.size = 17,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: active ? activeColor.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: size,
          color: active
              ? activeColor
              : Default_Theme.primaryColor1.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
