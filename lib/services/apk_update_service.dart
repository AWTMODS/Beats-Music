import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

/// Tracks the current state of an in-app APK download / install flow.
enum ApkUpdateState {
  idle,
  downloading,
  installing,
  done,
  error,
}

/// Thin result wrapper returned from [ApkUpdateService.downloadAndInstall].
class ApkUpdateResult {
  final ApkUpdateState state;
  final String? errorMessage;
  const ApkUpdateResult({required this.state, this.errorMessage});
}

/// Handles downloading the latest APK from a remote URL and opening
/// it via the system installer (content:// via open_filex).
///
/// Progress is reported through [onProgress] (0.0 – 1.0).
class ApkUpdateService {
  static final _dio = Dio();

  /// Download the APK from [url] and immediately hand it to the system
  /// package installer.  Returns an [ApkUpdateResult] describing the outcome.
  ///
  /// [onProgress] is called with a value between 0.0 and 1.0 as the download
  /// proceeds.  It is NOT guaranteed to be called from the main isolate;
  /// callers must use setState / streams accordingly.
  static Future<ApkUpdateResult> downloadAndInstall(
    String url, {
    void Function(double progress)? onProgress,
    void Function(int received, int total)? onBytesProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      // ── 1. Resolve save path ──────────────────────────────────────────────
      final Directory cacheDir = Platform.isAndroid
          ? (await getExternalCacheDirectories() ?? []).firstOrNull ??
              await getTemporaryDirectory()
          : await getTemporaryDirectory();

      final savePath = '${cacheDir.path}/beats_update.apk';
      final tempPath = '$savePath.part';

      // Delete stale downloads if present
      final file = File(savePath);
      if (await file.exists()) await file.delete();
      final tempFile = File(tempPath);
      if (await tempFile.exists()) await tempFile.delete();

      log('ApkUpdateService: Downloading $url → $tempPath', name: 'ApkUpdate');

      try {
        await _dio.download(
          url,
          tempPath,
          cancelToken: cancelToken,
          options: Options(
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 Chrome/112.0.0.0 Mobile Safari/537.36',
            },
            followRedirects: true,
            maxRedirects: 5,
          ),
          onReceiveProgress: (received, total) {
            if (total > 0) onProgress?.call(received / total);
            onBytesProgress?.call(received, total);
          },
        );

        // Atomically rename .part file to final .apk upon verified completion
        if (await tempFile.exists()) {
          await tempFile.rename(savePath);
        } else {
          throw const FileSystemException('Downloaded temporary file not found');
        }
      } catch (e) {
        // Clean up partial file on failure or cancellation
        if (await tempFile.exists()) {
          try {
            await tempFile.delete();
          } catch (_) {}
        }
        rethrow;
      }

      log('ApkUpdateService: Download complete, opening installer…',
          name: 'ApkUpdate');

      // ── 3. Open with system installer ─────────────────────────────────────
      final result = await OpenFilex.open(savePath);

      log('ApkUpdateService: OpenFilex result → ${result.type} ${result.message}',
          name: 'ApkUpdate');

      return const ApkUpdateResult(state: ApkUpdateState.installing);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        log('ApkUpdateService: Download cancelled', name: 'ApkUpdate');
        return const ApkUpdateResult(state: ApkUpdateState.idle);
      }
      log('ApkUpdateService: DioException – ${e.message}', name: 'ApkUpdate');
      final statusCode = e.response?.statusCode;
      String friendlyMessage;
      if (statusCode == 404) {
        friendlyMessage =
            'Update file not found on server (404). The release package has not been uploaded to GitHub yet.';
      } else if (statusCode != null && statusCode >= 500) {
        friendlyMessage =
            'Server error ($statusCode). Please try again in a few minutes.';
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        friendlyMessage =
            'Connection timed out. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        friendlyMessage =
            'Unable to connect to the update server. Please check your network connection.';
      } else {
        friendlyMessage =
            'Download failed (${statusCode != null ? "HTTP $statusCode" : "network error"}). Please try again later.';
      }
      return ApkUpdateResult(
        state: ApkUpdateState.error,
        errorMessage: friendlyMessage,
      );
    } catch (e, st) {
      log('ApkUpdateService: unexpected error – $e\n$st', name: 'ApkUpdate');
      return const ApkUpdateResult(
        state: ApkUpdateState.error,
        errorMessage:
            'An unexpected error occurred during download. Please try again.',
      );
    }
  }
}
