import 'dart:ui';
import 'package:beats_music/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

/// Shows an invite sheet for sharing a collaborative playlist code.
void showInviteSheet(
    BuildContext context, String inviteCode, String playlistName) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _InviteBottomSheet(
      inviteCode: inviteCode,
      playlistName: playlistName,
    ),
  );
}

class _InviteBottomSheet extends StatelessWidget {
  final String inviteCode;
  final String playlistName;

  const _InviteBottomSheet({
    required this.inviteCode,
    required this.playlistName,
  });

  String get _shareText =>
      '🎵 Join my shared playlist "$playlistName" on Beats Music!\n\n'
      'Enter this invite code: $inviteCode\n\n'
      'Download Beats Music to join 👉 https://github.com/AWTMODS/Beats-Music';

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          color: const Color(0xFF0F1035).withValues(alpha: 0.96),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                '🔗 Invite Friends',
                style: TextStyle(
                  fontFamily: 'Fjalla',
                  fontSize: 22,
                  color: Default_Theme.primaryColor1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Share this code to add friends to\n"$playlistName"',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Default_Theme.primaryColor1.withValues(alpha: 0.5),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),

              // Code display
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.accentColor1.withValues(alpha: 0.2),
                      AppTheme.successAccent.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppTheme.accentColor1.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      inviteCode,
                      style: const TextStyle(
                        fontFamily: 'CodePro',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Default_Theme.primaryColor1,
                        letterSpacing: 6,
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: inviteCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Code copied! 📋'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor1.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.copy_rounded,
                          color: AppTheme.accentColor1,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Share buttons row
              Row(
                children: [
                  Expanded(
                    child: _ShareButton(
                      icon: Icons.share_rounded,
                      label: 'Share',
                      color: AppTheme.successAccent,
                      onTap: () {
                        SharePlus.instance.share(
                          ShareParams(
                            text: _shareText,
                            subject: 'Join my playlist on Beats Music',
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ShareButton(
                      icon: Icons.copy_all_rounded,
                      label: 'Copy Link',
                      color: AppTheme.accentColor1,
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: _shareText));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Invite text copied! 📋'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Text(
                'Friends enter this code in Library → Shared Playlists → Join',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Default_Theme.primaryColor1.withValues(alpha: 0.35),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShareButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Gilroy',
                fontWeight: FontWeight.w700,
                color: color,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
