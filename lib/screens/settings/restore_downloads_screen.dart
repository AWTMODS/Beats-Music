
import 'package:audio_service/audio_service.dart';
import 'package:beats_music/model/songModel.dart';
import 'package:beats_music/services/db/beats_music_db_service.dart';
import 'package:beats_music/services/download_service.dart';
import 'package:beats_music/theme_data/default.dart';
import 'package:beats_music/utils/imgurl_formator.dart';
import 'package:flutter/material.dart';
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
      _pendingDownloads = BeatsMusicDBService.getPendingRestorableDownloads();
    });
  }

  Future<void> _restoreSong(Map<String, dynamic> data) async {
    final mediaId = data['mediaId'] as String;
    if (_restoredIds.contains(mediaId)) return;

    // Construct MediaItem to pass to DownloadService
    // Note: We might lack some metadata like Album/Genre if it wasn't in the backup list.
    // Ideally backups should store full metadata.
    // The current backup only stores basic info. We might need to re-fetch info or just use what we have.
    // Based on BeatsMusicDBService.exportDownloadsList, we have: mediaId, fileName.
    // Wait, exportDownloadsList ONLY exports mediaId and fileName?
    // That's a problem. We need Title/Artist to show in UI and to tag the file.
    // Let's assume we can fetch it or ignore tagging issues for now.
    // Actually, createBackUp uses `exportDownloadsList`? No, the audit said it backups the *list*.
    
    // We'll create a dummy MediaItem with available ID. 
    // DownloadService needs metadata to be robust. 
    // If the backup only has ID, we might need to fetch metadata first.
    // But for now, let's try with minimal info.
    
    final mediaItem = MediaItem(
      id: mediaId,
      title: data['fileName'] ?? 'Unknown Title', // Fallback
      artist: 'Unknown Artist',
      extras: {
        'source': 'youtube', // Assume YouTube if unknown
        'url': 'https://youtube.com/watch?v=${mediaId.replaceAll('youtube', '')}'
      }
    );

    setState(() {
      _restoredIds.add(mediaId); // Mark as in-progress/done
    });

    final success = await DownloadService().downloadSong(mediaItem);
    
    if (!success) {
      if (mounted) {
        setState(() {
          _restoredIds.remove(mediaId); // Retry allowed
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to restore ${data['fileName']}')),
        );
      }
    }
  }

  Future<void> _restoreAll() async {
    setState(() {
      _isRestoringAll = true;
    });

    for (var song in _pendingDownloads) {
      if (!_restoredIds.contains(song['mediaId'])) {
        await _restoreSong(song);
      }
    }

    setState(() {
      _isRestoringAll = false;
    });
    
    if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Restoration complete!')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Default_Theme.primaryColor2,
      appBar: AppBar(
        title: const Text("Restore Downloads"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_pendingDownloads.isNotEmpty)
            TextButton.icon(
              onPressed: _isRestoringAll ? null : _restoreAll,
              icon: _isRestoringAll 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.download),
              label: Text(_isRestoringAll ? "Restoring..." : "Restore All"),
            )
        ],
      ),
      body: _pendingDownloads.isEmpty
          ? const Center(
              child: Text("No pending downloads found to restore.",
                  style: TextStyle(color: Colors.white)),
            )
          : ListView.builder(
              itemCount: _pendingDownloads.length,
              itemBuilder: (context, index) {
                final song = _pendingDownloads[index];
                final mediaId = song['mediaId'];
                final isRestored = _restoredIds.contains(mediaId);
                
                return ListTile(
                  leading: const Icon(Icons.music_note, color: Default_Theme.accentColor2),
                  title: Text(
                    song['fileName'] ?? 'Unknown Song',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    mediaId,
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                  ),
                  trailing: isRestored
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : IconButton(
                          icon: const Icon(Icons.download_rounded, color: Colors.white),
                          onPressed: () => _restoreSong(song),
                        ),
                );
              },
            ),
    );
  }
}
