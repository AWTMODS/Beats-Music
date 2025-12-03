import 'package:flutter/material.dart';
import 'package:beats_music/theme_data/default.dart';
import 'package:icons_plus/icons_plus.dart';

class GenreCard extends StatelessWidget {
  final String genreName;
  final List<Color> gradientColors;
  final VoidCallback? onTap;

  const GenreCard({
    super.key,
    required this.genreName,
    required this.gradientColors,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            // Genre name
            Positioned(
              top: 12,
              left: 12,
              child: Text(
                genreName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ).merge(Default_Theme.primaryTextStyle),
              ),
            ),
            // Music note icon (tilted)
            Positioned(
              bottom: -10,
              right: -10,
              child: Transform.rotate(
                angle: 0.4, // Tilt angle in radians
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    MingCute.music_2_fill,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
