import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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

  /// Resolves the file location where update APKs should be stored.
  /// On Android, this MUST be in getExternalStorageDirectory()
  /// (context.getExternalFilesDir(null)) so that OpenFilex does NOT trigger
  /// pathRequiresPermission() which erroneously demands MANAGE_EXTERNAL_STORAGE
  /// on Android 11+ (API 30+).
  static Future<File> getApkFile() async {
    final Directory dir = Platform.isAndroid
        ? (await getExternalStorageDirectory()) ??
            await getApplicationSupportDirectory()
        : await getTemporaryDirectory();

    return File('${dir.path}/beats_update.apk');
  }

  /// Checks whether an update APK is already downloaded on disk and non-empty.
  static Future<bool> isApkDownloaded() async {
    try {
      final file = await getApkFile();
      return await file.exists() && (await file.length()) > 1024 * 1024;
    } catch (_) {
      return false;
    }
  }

  /// Request package installer permission on Android if needed.
  /// Returns true if granted or not on Android.
  static Future<bool> ensureInstallPermission() async {
    if (!Platform.isAndroid) return true;
    try {
      final status = await Permission.requestInstallPackages.status;
      if (status.isGranted) return true;
      final requestStatus = await Permission.requestInstallPackages.request();
      return requestStatus.isGranted;
    } catch (e) {
      log('ApkUpdateService: Failed to check install permission: $e',
          name: 'ApkUpdate');
      return true;
    }
  }

  /// Installs an already-downloaded APK file.
  static Future<ApkUpdateResult> installDownloadedApk([File? apkFile]) async {
    try {
      final file = apkFile ?? await getApkFile();
      if (!await file.exists()) {
        return const ApkUpdateResult(
          state: ApkUpdateState.error,
          errorMessage: 'Update package not found. Please download again.',
        );
      }

      // Check install permission first on Android
      final hasPermission = await ensureInstallPermission();
      if (!hasPermission) {
        return const ApkUpdateResult(
          state: ApkUpdateState.error,
          errorMessage:
              'Install permission required. Please enable "Allow from this source" for Beats in Settings.',
        );
      }

      log('ApkUpdateService: Opening installer for ${file.path}',
          name: 'ApkUpdate');

      final result = await OpenFilex.open(
        file.path,
        type: 'application/vnd.android.package-archive',
      );

      log('ApkUpdateService: OpenFilex result → ${result.type} ${result.message}',
          name: 'ApkUpdate');

      if (result.type != ResultType.done) {
        String msg = result.message;
        if (result.type == ResultType.permissionDenied) {
          msg =
              'Permission denied to install APK. Please enable "Allow from this source" in Settings.';
        } else if (result.type == ResultType.noAppToOpen) {
          msg = 'No package installer app found on this device to open APK.';
        }
        return ApkUpdateResult(
          state: ApkUpdateState.error,
          errorMessage: msg,
        );
      }

      return const ApkUpdateResult(state: ApkUpdateState.installing);
    } catch (e, st) {
      log('ApkUpdateService: Error opening installer: $e\n$st',
          name: 'ApkUpdate');
      return ApkUpdateResult(
        state: ApkUpdateState.error,
        errorMessage: 'Failed to open package installer: $e',
      );
    }
  }

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
      // ── 0. Pre-check install permission on Android ─────────────────────────
      final hasPermission = await ensureInstallPermission();
      if (!hasPermission) {
        return const ApkUpdateResult(
          state: ApkUpdateState.error,
          errorMessage:
              'Permission to install unknown apps is required. Please enable "Allow from this source" for Beats in Settings to update.',
        );
      }

      // ── 1. Resolve save path ──────────────────────────────────────────────
      final file = await getApkFile();
      final savePath = file.path;
      final tempPath = '$savePath.part';

      // Delete stale downloads if present
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
      return await installDownloadedApk(file);
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
