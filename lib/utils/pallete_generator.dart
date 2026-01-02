import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

Future<PaletteGenerator> getPalleteFromImage(String url) async {
  ImageProvider<Object> placeHolder =
      const AssetImage("assets/icons/beats_music_logo.png");

  try {
    // Add a timeout to prevent hanging on slow network images
    return await PaletteGenerator.fromImageProvider(
      CachedNetworkImageProvider(url),
    ).timeout(const Duration(seconds: 3));
  } catch (e) {
    debugPrint("Palette extraction failed for $url: $e");
    try {
      return await PaletteGenerator.fromImageProvider(placeHolder)
          .timeout(const Duration(seconds: 1));
    } catch (_) {
      // Return a basic palette if even placeholder fails
      return PaletteGenerator.fromColors([
        PaletteColor(const Color(0xFF1DB954), 100),
      ]);
    }
  }
}
