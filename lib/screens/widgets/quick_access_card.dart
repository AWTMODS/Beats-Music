import 'package:flutter/material.dart';
import 'package:beats_music/theme_data/default.dart';

class QuickAccessCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  const QuickAccessCard({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Default_Theme.cardColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Colored icon background
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            // Title text
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Default_Theme.primaryColor1,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ).merge(Default_Theme.secondoryTextStyleMedium),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
