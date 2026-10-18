import 'dart:io';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:beats_music/core/theme/app_theme.dart';
import 'package:beats_music/services/apk_update_service.dart';
import 'package:beats_music/utils/url_launcher.dart';

/// Shows a premium, glassmorphic bottom sheet indicating an update is available.
Future<void> showUpdateSheet({
  required BuildContext context,
  required String newVersion,
  required String newBuild,
  required String downloadUrl,
  VoidCallback? onUpdate,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    builder: (context) => UpdateSheet(
      newVersion: newVersion,
      newBuild: newBuild,
      downloadUrl: downloadUrl,
      onUpdate: onUpdate,
    ),
  );
}

class UpdateSheet extends StatefulWidget {
  final String newVersion;
  final String newBuild;
  final String downloadUrl;
  final VoidCallback? onUpdate;

  const UpdateSheet({
    super.key,
    required this.newVersion,
    required this.newBuild,
    required this.downloadUrl,
    this.onUpdate,
  });

  @override
  State<UpdateSheet> createState() => _UpdateSheetState();
}

class _UpdateSheetState extends State<UpdateSheet> {
  bool _isDownloading = false;
  double _progress = 0.0;
  int _receivedBytes = 0;
  int _totalBytes = 0;
  String? _errorMessage;
  CancelToken? _cancelToken;
  bool _isInstalling = false;

  void _startUpdate() async {
    if (!Platform.isAndroid) {
      if (widget.onUpdate != null) {
        widget.onUpdate!();
      } else {
        launch_Url(Uri.parse(widget.downloadUrl));
      }
      Navigator.pop(context);
      return;
    }

    setState(() {
      _isDownloading = true;
      _progress = 0.0;
      _receivedBytes = 0;
      _totalBytes = 0;
      _errorMessage = null;
      _cancelToken = CancelToken();
    });

    final result = await ApkUpdateService.downloadAndInstall(
      widget.downloadUrl,
      cancelToken: _cancelToken,
      onProgress: (p) {
        if (mounted) setState(() => _progress = p);
      },
      onBytesProgress: (received, total) {
        if (mounted) {
          setState(() {
            _receivedBytes = received;
            _totalBytes = total;
          });
        }
      },
    );

    if (!mounted) return;

    if (result.state == ApkUpdateState.installing) {
      setState(() {
        _isInstalling = true;
      });
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.pop(context);
    } else if (result.state == ApkUpdateState.error) {
      setState(() {
        _isDownloading = false;
        _errorMessage =
            result.errorMessage ?? 'Download failed. Please try again.';
      });
    } else {
      // User cancelled
      setState(() {
        _isDownloading = false;
      });
    }
  }

  void _cancelDownload() {
    _cancelToken?.cancel();
    setState(() {
      _isDownloading = false;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDownloading,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.85),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Icon with Glow
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentColor1.withValues(alpha: 0.3),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.accentColor1, AppTheme.accentColor2],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isDownloading
                              ? Icons.downloading_rounded
                              : (_isInstalling
                                  ? Icons.install_mobile_rounded
                                  : Icons.system_update_rounded),
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Text(
                    _isDownloading
                        ? 'Downloading Update'
                        : (_isInstalling ? 'Installing Update' : 'Update Ready'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    _isDownloading
                        ? 'Please keep Beats open while we download the latest package.'
                        : 'A new version of Beats is available with the latest features and bug fixes.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withValues(alpha: 0.7),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Version Badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _VersionBadge(
                        label: 'NEW VERSION',
                        value: 'v${widget.newVersion}+${widget.newBuild}',
                        isNew: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Error message banner
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              color: Colors.redAccent, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Downloading progress view
                  if (_isDownloading || _isInstalling) ...[
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _isInstalling
                                    ? 'Opening installer...'
                                    : 'Downloading APK...',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '${(_progress * 100).toInt()}%',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accentColor1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: _progress > 0 ? _progress : null,
                              minHeight: 8,
                              backgroundColor: Colors.white10,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppTheme.accentColor1),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _totalBytes > 0
                                    ? '${(_receivedBytes / (1024 * 1024)).toStringAsFixed(1)} MB / ${(_totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB'
                                    : 'Connecting...',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                              ),
                              if (!_isInstalling)
                                GestureDetector(
                                  onTap: _cancelDownload,
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    // Features list
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.bolt_rounded,
                              color: AppTheme.accentColor1, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              Platform.isAndroid
                                  ? 'Seamless in-app installation with automatic package installer.'
                                  : 'Featuring performance improvements and bug fixes.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              foregroundColor:
                                  Colors.white.withValues(alpha: 0.5),
                            ),
                            child: const Text('Maybe Later'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppTheme.accentColor1,
                                  AppTheme.accentColor2
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.accentColor1
                                      .withValues(alpha: 0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _startUpdate,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                _errorMessage != null ? 'Retry' : 'Update Now',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton.icon(
                          onPressed: () {
                            final targetUrl =
                                widget.downloadUrl.contains('/releases/download/')
                                    ? 'https://github.com/AWTMODS/Beats-Music/releases'
                                    : widget.downloadUrl;
                            launch_Url(Uri.parse(targetUrl));
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.open_in_browser_rounded,
                              size: 16, color: Colors.white70),
                          label: const Text(
                            'Open Releases in Browser',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VersionBadge extends StatelessWidget {
  final String label;
  final String value;
  final bool isNew;

  const _VersionBadge({
    required this.label,
    required this.value,
    this.isNew = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isNew 
            ? AppTheme.accentColor1.withValues(alpha: 0.1) 
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isNew 
              ? AppTheme.accentColor1.withValues(alpha: 0.3) 
              : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isNew ? AppTheme.accentColor1 : Colors.white.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
