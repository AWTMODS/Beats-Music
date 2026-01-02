// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:beats_music/theme_data/default.dart';
import 'package:beats_music/services/beats_cache_manager.dart';
import 'package:http/http.dart' as http;

Image loadImage(coverImageUrl,
    {placeholderPath = "assets/icons/beats_music_logo.png"}) {
  ImageProvider<Object> placeHolder = AssetImage(placeholderPath);
  return Image.network(
    coverImageUrl,
    fit: BoxFit.cover,
    loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null) {
        return child;
      } else {
        return Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxHeight > constraints.maxWidth) {
                return SizedBox(
                  height: constraints.maxWidth,
                  width: constraints.maxWidth,
                  child: const CircularProgressIndicator(
                      color: Default_Theme.accentColor2),
                );
              } else {
                return SizedBox(
                  height: constraints.maxHeight,
                  width: constraints.maxHeight,
                  child: const CircularProgressIndicator(
                      color: Default_Theme.accentColor2),
                );
              }
            },
          ),
        );
      }
    },
    errorBuilder: (context, error, stackTrace) {
      return Image(
        image: placeHolder,
        fit: BoxFit.cover,
      );
    },
  );
}

CachedNetworkImage loadImageCached(coverImageURL,
    {placeholderPath = "assets/icons/beats_music_logo.png",
    fit = BoxFit.cover}) {
  ImageProvider<Object> placeHolder = AssetImage(placeholderPath);
  
  // Add User-Agent header
  final Map<String, String> httpHeaders = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
  };

  return CachedNetworkImage(
    imageUrl: coverImageURL,
    httpHeaders: httpHeaders,
    cacheManager: BeatsCacheManager.instance, // Custom Cache Manager
    memCacheWidth: 600, // High Quality Memory Cache (Smooth + Sharp)
    // memCacheHeight: 500,
    placeholder: (context, url) => Image(
      image: const AssetImage("assets/icons/lazy_loading.png"),
      fit: fit,
    ),
    errorWidget: (context, url, error) => Image(
      image: placeHolder,
      fit: fit,
    ),
    fadeInDuration: const Duration(milliseconds: 300),
    fit: fit,
  );
}

class LoadImageCached extends StatefulWidget {
  final String imageUrl;
  final String? fallbackUrl;
  final String placeholderUrl;
  final BoxFit fit;

  const LoadImageCached({
    Key? key,
    required this.imageUrl,
    this.placeholderUrl = "assets/icons/beats_music_logo.png",
    this.fit = BoxFit.cover,
    this.fallbackUrl,
  }) : super(key: key);

  @override
  State<LoadImageCached> createState() => _LoadImageCachedState();
}

class _LoadImageCachedState extends State<LoadImageCached> {
  @override
  Widget build(BuildContext context) {
    if (widget.imageUrl.isEmpty) {
      return Image(
        image: AssetImage(widget.placeholderUrl),
        fit: widget.fit,
      );
    }
    
    // Add User-Agent header to avoid 403 Forbidden on some servers
    final Map<String, String> httpHeaders = {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    };

    return CachedNetworkImage(
      imageUrl: widget.imageUrl,
      httpHeaders: httpHeaders,
      cacheManager: BeatsCacheManager.instance, // Custom Cache Manager to save storage
      memCacheWidth: 600, // High Quality Memory Cache
      placeholder: (context, url) => Image(
        image: const AssetImage("assets/icons/lazy_loading.png"),
        fit: widget.fit,
      ),
      errorWidget: (context, url, error) {
        // Log image load errors for debugging
        debugPrint('Image Load Error for $url: $error');
        if (widget.fallbackUrl != null && widget.fallbackUrl!.isNotEmpty) {
           debugPrint('Attempting fallback: ${widget.fallbackUrl}');
        }
        
        return widget.fallbackUrl == null
          ? Image(
              image: AssetImage(widget.placeholderUrl),
              fit: widget.fit,
            )
          : CachedNetworkImage(
              // now using fallback url
              imageUrl: widget.fallbackUrl!,
              httpHeaders: httpHeaders,
              cacheManager: BeatsCacheManager.instance,
              memCacheWidth: 600,
              placeholder: (context, url) => Image(
                image: const AssetImage("assets/icons/lazy_loading.png"),
                fit: widget.fit,
              ),
              errorWidget: (context, url, error) {
                debugPrint('Fallback Image Load Error for ${widget.fallbackUrl}: $error');
                return Image(
                  image: AssetImage(widget.placeholderUrl),
                  fit: widget.fit,
                );
              },
              fadeInDuration: const Duration(milliseconds: 300),
              fit: widget.fit,
            );
      },
      fadeInDuration: const Duration(milliseconds: 300),
      fit: widget.fit,
    );
  }
}

Future<ImageProvider> getImageProvider(String imageUrl,
    {String placeholderUrl = "assets/icons/beats_music_logo.png"}) async {
  if (imageUrl != "") {
    final response = await http.head(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      CachedNetworkImageProvider cachedImageProvider =
          CachedNetworkImageProvider(imageUrl);
      return cachedImageProvider;
    } else {
      return AssetImage(placeholderUrl);
    }
  }
  return AssetImage(placeholderUrl);
}
