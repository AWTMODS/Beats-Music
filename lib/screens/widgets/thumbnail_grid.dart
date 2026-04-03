import 'package:beats_music/utils/load_image.dart';
import 'package:flutter/material.dart';
import 'package:beats_music/core/theme/app_theme.dart';
import 'package:icons_plus/icons_plus.dart';

class ThumbnailGrid extends StatelessWidget {
  final List<String> imageUrls;
  final double size;
  final IconData? fallbackIcon;

  const ThumbnailGrid({
    super.key,
    required this.imageUrls,
    this.size = 70,
    this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    final cleanUrls = imageUrls.where((url) => url.isNotEmpty).take(4).toList();

    if (cleanUrls.isEmpty) {
      return Container(
        width: size,
        height: size,
        color: Default_Theme.accentColor1.withValues(alpha: 0.15),
        child: Icon(
          fallbackIcon ?? MingCute.music_2_fill,
          color: Default_Theme.accentColor1,
          size: size * 0.4,
        ),
      );
    }

    if (cleanUrls.length == 1) {
      return SizedBox(
        width: size,
        height: size,
        child: LoadImageCached(
          imageUrl: cleanUrls[0],
          fallbackUrl: cleanUrls[0],
        ),
      );
    }

    // Grid for 2, 3, or 4 images
    return SizedBox(
      width: size,
      height: size,
      child: Wrap(
        children: List.generate(4, (index) {
          final showImage = index < cleanUrls.length;
          // If we have 2 images, show them in top-left and top-right? 
          // Better: 2 images = 2x1 grid, 3 images = 2x2 with one empty, 4 images = 2x2.
          
          return SizedBox(
            width: size / 2,
            height: size / 2,
            child: showImage
                ? LoadImageCached(
                    imageUrl: cleanUrls[index],
                    fallbackUrl: cleanUrls[index],
                  )
                : Container(
                    color: Colors.black.withValues(alpha: 0.2),
                  ),
          );
        }),
      ),
    );
  }
}
