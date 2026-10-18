// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:http/http.dart' as http;

// Helpers
bool _isValidNetworkUrl(String? url) {
  if (url == null || url.trim().isEmpty) return false;
  final parsed = Uri.tryParse(url.trim());
  return parsed != null &&
      (parsed.scheme == 'http' || parsed.scheme == 'https') &&
      parsed.host.isNotEmpty;
}

File? _resolveLocalImageFile(String? url) {
  if (url == null || url.trim().isEmpty) return null;

  final trimmed = url.trim();
  final parsed = Uri.tryParse(trimmed);

  String? path;
  if (parsed != null && parsed.scheme == 'file') {
    try {
      path = parsed.toFilePath(windows: Platform.isWindows);
    } catch (_) {
      path = null;
    }
  }

  if (path == null && trimmed.startsWith('file://')) {
    final rawPath = trimmed.substring('file://'.length);
    if (rawPath.startsWith('/') ||
        rawPath.startsWith(r'\\') ||
        RegExp(r'^[a-zA-Z]:[\\/]').hasMatch(rawPath)) {
      path = rawPath;
    }
  } else if (trimmed.startsWith('/') ||
      trimmed.startsWith(r'\\') ||
      RegExp(r'^[a-zA-Z]:[\\/]').hasMatch(trimmed)) {
    path = trimmed;
  }

  if (path == null || path.isEmpty) return null;

  final file = File(path);
  return file.existsSync() ? file : null;
}

Widget _placeholderImage(String placeholderPath, BoxFit fit) {
  return Image(
    image: AssetImage(placeholderPath),
    fit: fit,
  );
}

Widget _lazyLoadingPlaceholder(BoxFit fit) {
  return Image(
    image: const AssetImage("assets/icons/lazy_loading.png"),
    fit: fit,
  );
}

Widget _buildLocalFileImage({
  required File file,
  required String placeholderPath,
  required BoxFit fit,
  double? width,
  double? height,
}) {
  return Image.file(
    file,
    fit: fit,
    width: width,
    height: height,
    errorBuilder: (context, error, stackTrace) =>
        _placeholderImage(placeholderPath, fit),
  );
}

// Synchronous ImageProvider resolver
ImageProvider<Object> getImageProviderSync(
  String? imageUrl, {
  String? fallbackUrl,
  String placeholderUrl = "assets/icons/beats_music_logo.png",
}) {
  final primaryFile = _resolveLocalImageFile(imageUrl);
  if (primaryFile != null) return FileImage(primaryFile);

  final fallbackFile = _resolveLocalImageFile(fallbackUrl);
  if (fallbackFile != null && !_isValidNetworkUrl(imageUrl)) {
    return FileImage(fallbackFile);
  }

  if (_isValidNetworkUrl(imageUrl)) {
    return CachedNetworkImageProvider(imageUrl!.trim());
  }
  if (_isValidNetworkUrl(fallbackUrl)) {
    return CachedNetworkImageProvider(fallbackUrl!.trim());
  }

  return AssetImage(placeholderUrl);
}

class LoadImageCached extends StatefulWidget {
  final String imageUrl;
  final String? fallbackUrl;
  final String placeholderUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const LoadImageCached({
    Key? key,
    required this.imageUrl,
    this.placeholderUrl = "assets/icons/beats_music_logo.png",
    this.fit = BoxFit.cover,
    this.fallbackUrl,
    this.width,
    this.height,
    this.borderRadius,
  }) : super(key: key);

  /// Creates a LoadImageCached that automatically fills all available space
  /// from its parent, making sizing fully deterministic and independent of
  /// the source image resolution.
  static Widget deterministic({
    Key? key,
    required String imageUrl,
    String? fallbackUrl,
    String placeholderUrl = "assets/icons/beats_music_logo.png",
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Resolve finite dimensions from the layout
        final w = constraints.maxWidth.isFinite ? constraints.maxWidth : null;
        final h = constraints.maxHeight.isFinite ? constraints.maxHeight : null;

        return LoadImageCached(
          key: key,
          imageUrl: imageUrl,
          fallbackUrl: fallbackUrl,
          placeholderUrl: placeholderUrl,
          fit: fit,
          width: w,
          height: h,
          borderRadius: borderRadius,
        );
      },
    );
  }

  @override
  State<LoadImageCached> createState() => _LoadImageCachedState();
}

class _LoadImageCachedState extends State<LoadImageCached> {
  static final Set<String> _failedImageUrls = <String>{};

  /// Compute memCacheWidth based on explicit width + device pixel ratio
  /// for efficient memory usage while maintaining sharpness.
  int? get _memCacheWidth {
    if (widget.width == null) return 500; // sensible default
    final dpr = MediaQuery.of(context).devicePixelRatio;
    return (widget.width! * dpr).ceil().clamp(100, 1500);
  }

  @override
  Widget build(BuildContext context) {
    final content = _buildImageContent();

    // Wrap with explicit size if provided — this is the key to deterministic rendering
    if (widget.width != null || widget.height != null) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: widget.borderRadius != null
            ? ClipRRect(borderRadius: widget.borderRadius!, child: content)
            : content,
      );
    }

    return widget.borderRadius != null
        ? ClipRRect(borderRadius: widget.borderRadius!, child: content)
        : content;
  }

  Widget _buildImageContent() {
    if (widget.imageUrl.startsWith('smart_icon:')) {
      final type = widget.imageUrl.substring('smart_icon:'.length);
      final (icon, Color startColor, Color endColor) = switch (type) {
        'create_playlist' => (
            MingCute.add_circle_fill,
            const Color(0xFF8B5CF6),
            const Color(0xFF6D28D9),
          ),
        'downloads' => (
            MingCute.download_2_fill,
            const Color(0xFF2563EB),
            const Color(0xFF1D4ED8),
          ),
        'history' => (
            MingCute.time_fill,
            const Color(0xFF0284C7),
            const Color(0xFF0369A1),
          ),
        'top_mix' => (
            MingCute.star_fill,
            const Color(0xFFF59E0B),
            const Color(0xFFD97706),
          ),
        'radio' => (
            MingCute.radio_line,
            const Color(0xFFEF4444),
            const Color(0xFFDC2626),
          ),
        _ => (
            MingCute.music_2_fill,
            const Color(0xFF7C3AED),
            const Color(0xFF5B21B6),
          ),
      };

      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [startColor, endColor],
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 36,
            color: Colors.white,
          ),
        ),
      );
    }

    // ── 1. Try local file (primary) ──
    final primaryFile = _resolveLocalImageFile(widget.imageUrl);
    if (primaryFile != null) {
      return _buildLocalFileImage(
        file: primaryFile,
        placeholderPath: widget.placeholderUrl,
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
      );
    }

    // ── 2. Try local file (fallback) when primary is not a valid network URL ──
    final fallbackFile = _resolveLocalImageFile(widget.fallbackUrl);
    if (!_isValidNetworkUrl(widget.imageUrl) && fallbackFile != null) {
      return _buildLocalFileImage(
        file: fallbackFile,
        placeholderPath: widget.placeholderUrl,
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
      );
    }

    // ── 3. Resolve network URLs ──
    final hasPrimary = _isValidNetworkUrl(widget.imageUrl);
    final hasFallback = _isValidNetworkUrl(widget.fallbackUrl);

    if (!hasPrimary && !hasFallback) {
      return _placeholderImage(widget.placeholderUrl, widget.fit);
    }

    final primaryUrl = hasPrimary ? widget.imageUrl : widget.fallbackUrl!;
    final fallbackUrl = hasPrimary && hasFallback ? widget.fallbackUrl : null;

    // Both already known to fail — skip network entirely
    if (_failedImageUrls.contains(primaryUrl) &&
        (fallbackUrl == null || _failedImageUrls.contains(fallbackUrl))) {
      return _placeholderImage(widget.placeholderUrl, widget.fit);
    }

    // ── 4. Primary network image ──
    return CachedNetworkImage(
      imageUrl: primaryUrl,
      width: widget.width,
      height: widget.height,
      memCacheWidth: _memCacheWidth,
      placeholder: (context, url) => _lazyLoadingPlaceholder(widget.fit),
      errorWidget: (context, url, error) {
        _failedImageUrls.add(url);

        // Try local fallback file
        if (fallbackFile != null) {
          return _buildLocalFileImage(
            file: fallbackFile,
            placeholderPath: widget.placeholderUrl,
            fit: widget.fit,
            width: widget.width,
            height: widget.height,
          );
        }

        // Try network fallback
        if (fallbackUrl == null || _failedImageUrls.contains(fallbackUrl)) {
          return _placeholderImage(widget.placeholderUrl, widget.fit);
        }

        return CachedNetworkImage(
          imageUrl: fallbackUrl,
          width: widget.width,
          height: widget.height,
          memCacheWidth: _memCacheWidth,
          placeholder: (context, url) => _lazyLoadingPlaceholder(widget.fit),
          errorWidget: (context, url, error) {
            _failedImageUrls.add(url);
            return _placeholderImage(widget.placeholderUrl, widget.fit);
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

// Async ImageProvider resolver (unchanged API)
Future<ImageProvider> getImageProvider(
  String imageUrl, {
  String placeholderUrl = "assets/icons/beats_music_logo.png",
}) async {
  final localFile = _resolveLocalImageFile(imageUrl);
  if (localFile != null) return FileImage(localFile);

  final parsed = Uri.tryParse(imageUrl);
  if (parsed != null &&
      (parsed.scheme == 'http' || parsed.scheme == 'https') &&
      parsed.host.isNotEmpty) {
    final response = await http.head(parsed);
    if (response.statusCode == 200) {
      return CachedNetworkImageProvider(imageUrl);
    } else {
      return AssetImage(placeholderUrl);
    }
  }
  return AssetImage(placeholderUrl);
}

