import 'package:beats_music/blocs/downloader/cubit/downloader_cubit.dart';
import 'package:beats_music/core/models/exported.dart';
import 'package:beats_music/services/db/sync_adapter.dart';
import 'package:beats_music/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';

class RestoreDownloadsScreen extends StatefulWidget {
  const RestoreDownloadsScreen({super.key});

  @override
  State<RestoreDownloadsScreen> createState() => _RestoreDownloadsScreenState();
}

class _RestoreDownloadsScreenState extends State<RestoreDownloadsScreen> {
  List<Map<String, dynamic>> _pendingDownloads = [];
  final Set<String> _restoredIds = {};
  bool _isRestoringAll = false;

  @override
  void initState() {
    super.initState();
    _loadPendingDownloads();
  }

  void _loadPendingDownloads() {
    setState(() {
      _pendingDownloads = SyncAdapter.getPendingRestorableDownloads();
    });
  }

  Future<void> _restoreSong(Map<String, dynamic> data) async {
    final mediaId = data['mediaId'] as String;
    if (_restoredIds.contains(mediaId)) return;

    // Create a minimal Track object from available metadata
    final track = Track(
      id: mediaId,
      title: data['fileName'] ?? 'Unknown Title',
      artists: [
        const ArtistSummary(id: 'unknown', name: 'Unknown Artist'),
      ],
      thumbnail: const Artwork(url: '', layout: ImageLayout.square),
      isExplicit: false,
    );

    setState(() {
      _restoredIds.add(mediaId);
    });

    try {
      await context.read<DownloaderCubit>().downloadSong(track, showSnackbar: false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _restoredIds.remove(mediaId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to restore ${track.title}: $e')),
        );
      }
    }
  }

  Future<void> _restoreAll() async {
    setState(() {
      _isRestoringAll = true;
    });

    final downloader = context.read<DownloaderCubit>();
    for (var song in _pendingDownloads) {
      final mediaId = song['mediaId'] as String;
      if (!_restoredIds.contains(mediaId)) {
        // Only trigger if not already downloaded
        if (!downloader.isDownloaded(mediaId)) {
           await _restoreSong(song);
           // Small delay to avoid overwhelming the queue
           await Future.delayed(const Duration(milliseconds: 200));
        } else {
           setState(() {
             _restoredIds.add(mediaId);
           });
        }
      }
    }

    setState(() {
      _isRestoringAll = false;
    });
    
    if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Restoration tasks queued!')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          "Restore Downloads",
          style: const TextStyle(
            color: Default_Theme.primaryColor1,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ).merge(Default_Theme.secondoryTextStyleMedium),
        ),
        actions: [
          if (_pendingDownloads.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                onPressed: _isRestoringAll ? null : _restoreAll,
                icon: _isRestoringAll 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.download_rounded, color: Default_Theme.accentColor2),
                tooltip: 'Restore All',
              ),
            )
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: _pendingDownloads.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(MingCute.download_3_line, size: 64, color: Default_Theme.primaryColor1.withValues(alpha: 0.2)),
                    const SizedBox(height: 16),
                    Text(
                      "No pending downloads found to restore.",
                      style: Default_Theme.secondoryTextStyle.copyWith(color: Default_Theme.primaryColor1.withValues(alpha: 0.5)),
                    ),
                  ],
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _pendingDownloads.length,
                  itemBuilder: (context, index) {
                    final song = _pendingDownloads[index];
                    final mediaId = song['mediaId'];
                    final isRestored = _restoredIds.contains(mediaId);
                    final isAlreadyDownloaded = context.watch<DownloaderCubit>().isDownloaded(mediaId);
                    
                    return Card(
                      color: Default_Theme.primaryColor1.withValues(alpha: 0.02),
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Default_Theme.primaryColor1.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(MingCute.music_2_fill, color: Default_Theme.accentColor2, size: 20),
                        ),
                        title: Text(
                          song['fileName'] ?? 'Unknown Song',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Default_Theme.secondoryTextStyleMedium.copyWith(color: Default_Theme.primaryColor1),
                        ),
                        subtitle: Text(
                          mediaId,
                          style: Default_Theme.secondoryTextStyle.copyWith(color: Default_Theme.primaryColor1.withValues(alpha: 0.4), fontSize: 11),
                        ),
                        trailing: (isRestored || isAlreadyDownloaded)
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : IconButton(
                                icon: const Icon(Icons.download_rounded, color: Default_Theme.primaryColor1),
                                onPressed: () => _restoreSong(song),
                              ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
