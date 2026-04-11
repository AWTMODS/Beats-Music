import 'dart:io';

import 'package:beats_music/core/theme/app_theme.dart';
import 'package:beats_music/l10n/app_localizations.dart';
import 'package:beats_music/services/apk_update_service.dart';
import 'package:beats_music/services/beats_updater_tools.dart';
import 'package:beats_music/utils/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class CheckUpdateView extends StatelessWidget {
  const CheckUpdateView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      appBar: AppBar(
        backgroundColor: Default_Theme.themeColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.updateCheckTitle,
          style: const TextStyle(
            color: Default_Theme.primaryColor1,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ).merge(Default_Theme.secondoryTextStyle),
        ),
      ),
      body: Center(
        child: FutureBuilder<Map<String, dynamic>>(
          future: getLatestVersion(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              // ── Loading ────────────────────────────────────────────────────
              return _LoadingView(l10n: l10n);
            }

            final data = snapshot.data!;
            final hasUpdate = data['results'] == true;

            if (!hasUpdate) {
              return _UpToDateView(data: data, l10n: l10n);
            }

            return _UpdateAvailableView(data: data, l10n: l10n);
          },
        ),
      ),
    );
  }
}

// ── Loading ──────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  final AppLocalizations l10n;
  const _LoadingView({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          height: 50,
          width: 50,
          child: CircularProgressIndicator(color: Default_Theme.accentColor2),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.updateChecking,
          style: const TextStyle(color: Default_Theme.accentColor2, fontSize: 18)
              .merge(Default_Theme.tertiaryTextStyle),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ── Up to date ───────────────────────────────────────────────────────────────

class _UpToDateView extends StatelessWidget {
  final Map<String, dynamic> data;
  final AppLocalizations l10n;
  const _UpToDateView({required this.data, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        const Icon(Icons.check_circle_rounded,
            color: Default_Theme.accentColor2, size: 56),
        const SizedBox(height: 12),
        Text(
          l10n.updateUpToDate,
          style: const TextStyle(color: Default_Theme.accentColor2, fontSize: 20)
              .merge(Default_Theme.secondoryTextStyleMedium),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: FilledButton.icon(
            onPressed: () => launch_Url(
                Uri.parse('https://github.com/AWTMODS/Beats-Music/releases')),
            icon: const Icon(FontAwesome.github_alt_brand, size: 20),
            label: Text(l10n.updateViewPreRelease,
                style: const TextStyle(fontSize: 15)
                    .merge(Default_Theme.secondoryTextStyleMedium)),
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Text(
            l10n.updateCurrentVersion(
                data['currVer'] ?? '', data['currBuild'] ?? ''),
            style: TextStyle(
              color: Default_Theme.primaryColor2.withValues(alpha: 0.45),
              fontSize: 12,
            ).merge(Default_Theme.tertiaryTextStyle),
          ),
        ),
      ],
    );
  }
}

// ── Update available ─────────────────────────────────────────────────────────

class _UpdateAvailableView extends StatelessWidget {
  final Map<String, dynamic> data;
  final AppLocalizations l10n;
  const _UpdateAvailableView({required this.data, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final downloadUrl = (data['download_url'] as String?) ?? '';
    final isAndroid = Platform.isAndroid;
    final hasDirectApk =
        isAndroid && downloadUrl.isNotEmpty && downloadUrl.endsWith('.apk');

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),

        // ── Icon + badge ─────────────────────────────
        Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Default_Theme.accentColor2.withValues(alpha: 0.10),
                border: Border.all(
                  color: Default_Theme.accentColor2.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: const Icon(MingCute.download_3_fill,
                  color: Default_Theme.accentColor2, size: 36),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Default_Theme.accentColor2,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'NEW',
                style: Default_Theme.secondoryTextStyleMedium.copyWith(
                  color: Default_Theme.themeColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Text(
          l10n.updateNewVersionAvailable,
          style: const TextStyle(
            color: Default_Theme.accentColor2,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ).merge(Default_Theme.tertiaryTextStyle),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 6),

        Text(
          'v${data['newVer'] ?? ''}+${data['newBuild'] ?? ''}',
          style: TextStyle(
            color: Default_Theme.primaryColor1.withValues(alpha: 0.7),
            fontSize: 16,
          ).merge(Default_Theme.tertiaryTextStyle),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 24),

        // ── Action button ────────────────────────────
        if (hasDirectApk) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Default_Theme.accentColor2,
                foregroundColor: Default_Theme.themeColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => _showDownloadSheet(context, downloadUrl),
              icon: const Icon(Icons.download_rounded, size: 22),
              label: Text(
                l10n.updateDownloadNow,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => launch_Url(Uri.parse(
                downloadUrl.isNotEmpty
                    ? downloadUrl
                    : 'https://github.com/AWTMODS/Beats-Music/releases')),
            child: Text(
              'Open in Browser',
              style: TextStyle(
                color: Default_Theme.primaryColor2.withValues(alpha: 0.55),
                fontSize: 13,
              ),
            ),
          ),
        ] else ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => launch_Url(Uri.parse(
                  downloadUrl.isNotEmpty
                      ? downloadUrl
                      : 'https://github.com/AWTMODS/Beats-Music/releases')),
              icon: const Icon(Icons.open_in_browser_rounded, size: 22),
              label: Text(
                l10n.updateDownloadNow,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],

        const Spacer(),

        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Text(
            l10n.updateCurrentVersion(
                data['currVer'] ?? '', data['currBuild'] ?? ''),
            style: TextStyle(
              color: Default_Theme.primaryColor2.withValues(alpha: 0.45),
              fontSize: 12,
            ).merge(Default_Theme.tertiaryTextStyle),
          ),
        ),
      ],
    );
  }

  void _showDownloadSheet(BuildContext context, String url) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => _DownloadSheet(url: url),
    );
  }
}

// ── Download bottom sheet ─────────────────────────────────────────────────────

class _DownloadSheet extends StatefulWidget {
  final String url;
  const _DownloadSheet({required this.url});

  @override
  State<_DownloadSheet> createState() => _DownloadSheetState();
}

class _DownloadSheetState extends State<_DownloadSheet> {
  double _progress = 0.0;
  ApkUpdateState _state = ApkUpdateState.downloading;
  String? _error;
  final CancelToken _cancelToken = CancelToken();

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  Future<void> _startDownload() async {
    final result = await ApkUpdateService.downloadAndInstall(
      widget.url,
      cancelToken: _cancelToken,
      onProgress: (p) {
        if (mounted) setState(() => _progress = p);
      },
    );

    if (!mounted) return;
    setState(() {
      _state = result.state;
      _error = result.errorMessage;
    });

    // Auto-dismiss once the installer is handed off
    if (_state == ApkUpdateState.installing) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.of(context).pop();
    }
  }

  void _cancel() {
    _cancelToken.cancel();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Default_Theme.primaryColor2.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle ──────────────────────────────────
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Default_Theme.primaryColor2.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // ── State icon ───────────────────────────────
          _buildStateIcon(),

          const SizedBox(height: 20),

          // ── Label ────────────────────────────────────
          Text(
            _stateLabel(),
            style: Default_Theme.secondoryTextStyleMedium.copyWith(
              color: Default_Theme.primaryColor1,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // ── Progress bar ─────────────────────────────
          if (_state == ApkUpdateState.downloading) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 8,
                backgroundColor:
                    Default_Theme.primaryColor2.withValues(alpha: 0.12),
                valueColor: const AlwaysStoppedAnimation<Color>(
                    Default_Theme.accentColor2),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(_progress * 100).toStringAsFixed(0)}%',
              style: Default_Theme.tertiaryTextStyle.copyWith(
                color: Default_Theme.accentColor2,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],

          if (_state == ApkUpdateState.error && _error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Default_Theme.tertiaryTextStyle.copyWith(
                color: Colors.redAccent.withValues(alpha: 0.8),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: 20),

          // ── Action button ────────────────────────────
          if (_state == ApkUpdateState.downloading)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color:
                          Default_Theme.primaryColor2.withValues(alpha: 0.2)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _cancel,
                child: Text(
                  'Cancel',
                  style: Default_Theme.secondoryTextStyleMedium.copyWith(
                    color: Default_Theme.primaryColor2.withValues(alpha: 0.6),
                    fontSize: 15,
                  ),
                ),
              ),
            )
          else if (_state == ApkUpdateState.error)
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Default_Theme.accentColor2,
                  foregroundColor: Default_Theme.themeColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStateIcon() {
    switch (_state) {
      case ApkUpdateState.downloading:
        return Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Default_Theme.accentColor2.withValues(alpha: 0.10),
          ),
          child: const Center(
            child: SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                color: Default_Theme.accentColor2,
                strokeWidth: 3,
              ),
            ),
          ),
        );
      case ApkUpdateState.installing:
        return Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green.withValues(alpha: 0.12),
          ),
          child: const Icon(Icons.check_rounded, color: Colors.green, size: 34),
        );
      case ApkUpdateState.error:
        return Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.redAccent.withValues(alpha: 0.12),
          ),
          child: Icon(Icons.error_outline_rounded,
              color: Colors.redAccent.withValues(alpha: 0.8), size: 34),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  String _stateLabel() {
    switch (_state) {
      case ApkUpdateState.downloading:
        return 'Downloading Update…';
      case ApkUpdateState.installing:
        return 'Opening Installer…';
      case ApkUpdateState.error:
        return 'Download Failed';
      default:
        return '';
    }
  }
}
