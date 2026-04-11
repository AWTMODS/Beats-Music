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
    CancelToken? cancelToken,
  }) async {
    try {
      // ── 1. Resolve save path ──────────────────────────────────────────────
      final Directory cacheDir = Platform.isAndroid
          ? (await getExternalCacheDirectories() ?? []).firstOrNull ??
              await getTemporaryDirectory()
          : await getTemporaryDirectory();

      final savePath = '${cacheDir.path}/beats_update.apk';

      // Delete stale download if present
      final file = File(savePath);
      if (await file.exists()) await file.delete();

      log('ApkUpdateService: Downloading $url → $savePath', name: 'ApkUpdate');

      log('ApkUpdateService: Fetching content length for parallel download...', name: 'ApkUpdate');
      
      // ── 2. Get Content Length ───
      final headResponse = await _dio.head(url, options: Options(headers: {
        'User-Agent': 'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 Chrome/112.0.0.0 Mobile Safari/537.36',
      }));
      final totalLengthStr = headResponse.headers.value('content-length');
      final totalLength = int.tryParse(totalLengthStr ?? '') ?? 0;
      final acceptRanges = headResponse.headers.value('accept-ranges') == 'bytes';

      if (totalLength <= 0 || !acceptRanges) {
        log('ApkUpdateService: Range download not supported or length unknown. Falling back to single stream.', name: 'ApkUpdate');
        await _dio.download(url, savePath, cancelToken: cancelToken, onReceiveProgress: (received, total) {
          if (total > 0) onProgress?.call(received / total);
        });
      } else {
        // ── 3. Parallel Chunked Download ───
        const int concurrentThreads = 3;
        final chunkSize = (totalLength / concurrentThreads).ceil();
        final List<Future<void>> downloadFutures = [];
        final Map<int, int> progressMap = {};
        
        await file.create(recursive: true);
        final raf = await file.open(mode: FileMode.write);
        await raf.truncate(totalLength);
        await raf.close();

        for (int i = 0; i < concurrentThreads; i++) {
          final start = i * chunkSize;
          final end = (i == concurrentThreads - 1) ? totalLength - 1 : (i + 1) * chunkSize - 1;
          
          downloadFutures.add(() async {
            final threadDio = Dio(); // Separate instance for each thread
            final response = await threadDio.get<ResponseBody>(
              url,
              options: Options(
                responseType: ResponseType.stream,
                headers: {
                  'Range': 'bytes=$start-$end',
                  'User-Agent': 'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 Chrome/112.0.0.0 Mobile Safari/537.36',
                },
              ),
              cancelToken: cancelToken,
            );

            final threadRaf = await file.open(mode: FileMode.append);
            // Move pointer to the start of this chunk's range
            // NOTE: Dart's RandomAccessFile.setPosition combined with append Mode 
            // is tricky. We'll use write Only mode with setPosition.
            final writeRaf = await file.open(mode: FileMode.write);
            await writeRaf.setPosition(start);
            
            int received = 0;
            await for (final chunk in response.data!.stream) {
              await writeRaf.writeFrom(chunk);
              received += chunk.length;
              progressMap[i] = received;
              
              // Calculate aggregate progress
              final totalReceived = progressMap.values.fold(0, (sum, v) => sum + v);
              onProgress?.call(totalReceived / totalLength);
            }
            await writeRaf.close();
          }());
        }

        await Future.wait(downloadFutures);
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
      return ApkUpdateResult(
        state: ApkUpdateState.error,
        errorMessage: 'Download failed: ${e.message}',
      );
    } catch (e, st) {
      log('ApkUpdateService: unexpected error – $e\n$st', name: 'ApkUpdate');
      return ApkUpdateResult(
        state: ApkUpdateState.error,
        errorMessage: e.toString(),
      );
    }
  }
}
