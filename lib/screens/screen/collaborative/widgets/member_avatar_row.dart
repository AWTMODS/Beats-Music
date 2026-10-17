import 'package:beats_music/core/theme/app_theme.dart';
import 'package:beats_music/services/collaborative_playlist_service.dart';
import 'package:beats_music/utils/load_image.dart';
import 'package:flutter/material.dart';

/// A horizontal row of member avatar circles, stacked with overlap.
/// Shows up to [maxVisible] members then a "+N" overflow badge.
class MemberAvatarRow extends StatelessWidget {
  final List<CollabMember> members;
  final int maxVisible;

  const MemberAvatarRow({
    super.key,
    required this.members,
    this.maxVisible = 5,
  });

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) return const SizedBox.shrink();

    final visible = members.take(maxVisible).toList();
    final overflow = members.length - maxVisible;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Stacked avatars
        SizedBox(
          width: visible.length * 20.0 + 28,
          height: 32,
          child: Stack(
            children: [
              for (int i = 0; i < visible.length; i++)
                Positioned(
                  left: i * 20.0,
                  child: _MemberAvatar(member: visible[i]),
                ),
            ],
          ),
        ),
        // Overflow count
        if (overflow > 0) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '+$overflow',
              style: TextStyle(
                fontSize: 11,
                color: Default_Theme.primaryColor1.withValues(alpha: 0.6),
                fontFamily: 'CodePro',
              ),
            ),
          ),
        ],
        const SizedBox(width: 8),
        // Role legend
        Text(
          '${members.length} ${members.length == 1 ? 'member' : 'members'}',
          style: TextStyle(
            fontSize: 11,
            color: Default_Theme.primaryColor1.withValues(alpha: 0.45),
          ),
        ),
      ],
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  final CollabMember member;

  const _MemberAvatar({required this.member});

  Color get _roleColor {
    switch (member.role) {
      case CollabRole.owner:
        return AppTheme.successAccent;
      case CollabRole.editor:
        return AppTheme.accentColor1;
      case CollabRole.viewer:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Default_Theme.themeColor, width: 2),
      ),
      child: ClipOval(
        child: member.avatarUrl != null && member.avatarUrl!.isNotEmpty
            ? LoadImageCached(
                imageUrl: member.avatarUrl!,
                width: 32,
                height: 32,
                fit: BoxFit.cover,
              )
            : _initials(member.displayName),
      ),
    );
  }

  Widget _initials(String name) {
    final initial =
        name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      color: _roleColor.withValues(alpha: 0.25),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: _roleColor,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
