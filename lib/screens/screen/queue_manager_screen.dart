import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audio_service/audio_service.dart';
import 'package:beats_music/blocs/mediaPlayer/beats_player_cubit.dart';
import 'package:beats_music/services/beats_music_player.dart';
import 'package:beats_music/theme_data/default.dart';
import 'package:beats_music/utils/imgurl_formator.dart';
import 'package:beats_music/screens/widgets/more_bottom_sheet.dart';
import 'package:beats_music/utils/load_Image.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:beats_music/screens/widgets/song_tile.dart';
import 'package:beats_music/services/db/beats_music_db_service.dart';
import 'package:beats_music/model/songModel.dart';

/// Enhanced queue manager screen with drag-to-reorder and quick actions
class QueueManagerScreen extends StatefulWidget {
  const QueueManagerScreen({super.key});

  @override
  State<QueueManagerScreen> createState() => _QueueManagerScreenState();
}

class _QueueManagerScreenState extends State<QueueManagerScreen> {
  @override
  Widget build(BuildContext context) {
    final musicPlayer = context.read<BeatsPlayerCubit>().beatsMusicPlayer;

    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      appBar: AppBar(
        backgroundColor: Default_Theme.themeColor,
        surfaceTintColor: Default_Theme.themeColor,
        foregroundColor: Default_Theme.primaryColor1,
        title: const Text(
          'Queue',
          style: TextStyle(
            color: Default_Theme.primaryColor1,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Clear Queue Button
          IconButton(
            icon: const Icon(MingCute.delete_2_line),
            tooltip: 'Clear Queue',
            onPressed: () => _showClearQueueDialog(context, musicPlayer),
          ),
          // Save Queue as Playlist
          IconButton(
            icon: const Icon(MingCute.save_2_line),
            tooltip: 'Save Queue as Playlist',
            onPressed: () => _showSaveQueueDialog(context, musicPlayer),
          ),
        ],
      ),
      body: StreamBuilder<List<MediaItem>>(
        stream: musicPlayer.queue,
        builder: (context, queueSnapshot) {
          final queue = queueSnapshot.data ?? [];
          
          if (queue.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.queue_music_rounded,
                    size: 80,
                    color: Default_Theme.primaryColor1,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Queue is empty',
                    style: TextStyle(
                      color: Default_Theme.primaryColor1,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            );
          }

          return StreamBuilder<MediaItem?>(
            stream: musicPlayer.mediaItem,
            builder: (context, currentSnapshot) {
              final currentMedia = currentSnapshot.data;
              final currentIndex = queue.indexWhere(
                (item) => item.id == currentMedia?.id,
              );

              return ReorderableListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: queue.length,
                onReorder: (oldIndex, newIndex) {
                  _reorderQueue(musicPlayer, oldIndex, newIndex);
                },
                itemBuilder: (context, index) {
                  final item = queue[index];
                  final isCurrentlyPlaying = index == currentIndex;

                  return _QueueItemTile(
                    key: ValueKey(item.id),
                    item: item,
                    index: index,
                    isCurrentlyPlaying: isCurrentlyPlaying,
                    musicPlayer: musicPlayer,
                    onPlayNext: () => _playNext(musicPlayer, index),
                    onRemove: () => _removeFromQueue(musicPlayer, index),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _reorderQueue(BeatsMusicPlayer player, int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    player.moveQueueItem(oldIndex, newIndex);
  }

  void _playNext(BeatsMusicPlayer player, int currentIndex) {
    // Get current playing index
    final queue = player.queue.value;
    final currentMedia = player.mediaItem.value;
    final playingIndex = queue.indexWhere((item) => item.id == currentMedia?.id);
    
    if (playingIndex != -1 && currentIndex != playingIndex) {
      // Move the item to right after the currently playing song
      final newIndex = playingIndex + 1;
      player.moveQueueItem(currentIndex, newIndex);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Moved to play next'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _removeFromQueue(BeatsMusicPlayer player, int index) {
    player.removeQueueItemAt(index);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Removed from queue'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showClearQueueDialog(BuildContext context, BeatsMusicPlayer player) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Default_Theme.themeColor,
        title: const Text(
          'Clear Queue?',
          style: TextStyle(color: Default_Theme.primaryColor1),
        ),
        content: const Text(
          'This will remove all songs from the queue.',
          style: TextStyle(color: Default_Theme.primaryColor1),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Default_Theme.primaryColor1),
            ),
          ),
          TextButton(
            onPressed: () {
              // Clear queue except currently playing
              final queue = player.queue.value;
              for (int i = queue.length - 1; i >= 0; i--) {
                if (i != 0) { // Keep the first item (currently playing)
                  player.removeQueueItemAt(i);
                }
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Queue cleared')),
              );
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: Default_Theme.accentColor2),
            ),
          ),
        ],
      ),
    );
  }

  void _showSaveQueueDialog(BuildContext context, BeatsMusicPlayer player) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Default_Theme.themeColor,
        title: const Text(
          'Save Queue as Playlist',
          style: TextStyle(color: Default_Theme.primaryColor1),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Default_Theme.primaryColor1),
          decoration: const InputDecoration(
            hintText: 'Playlist name',
            hintStyle: TextStyle(color: Default_Theme.primaryColor1),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Default_Theme.primaryColor1),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Default_Theme.accentColor2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Default_Theme.primaryColor1),
            ),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final queue = player.queue.value;
                if (queue.isEmpty) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Queue is empty')),
                  );
                  return;
                }

                // Convert to MediaItemDB list
                final mediaItemsDB = queue
                    .map((item) => MediaItem2MediaItemDB(item))
                    .toList();

                // Save to DB
                BeatsMusicDBService.createPlaylist(
                  controller.text,
                  mediaItems: mediaItemsDB,
                ).then((_) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Saved queue as "${controller.text}"')),
                    );
                  }
                });
              }
            },
            child: const Text(
              'Save',
              style: TextStyle(color: Default_Theme.accentColor2),
            ),
          ),
        ],
      ),
    );
  }
}

class _QueueItemTile extends StatelessWidget {
  final MediaItem item;
  final int index;
  final bool isCurrentlyPlaying;
  final BeatsMusicPlayer musicPlayer;
  final VoidCallback onPlayNext;
  final VoidCallback onRemove;

  const _QueueItemTile({
    required super.key,
    required this.item,
    required this.index,
    required this.isCurrentlyPlaying,
    required this.musicPlayer,
    required this.onPlayNext,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCurrentlyPlaying
            ? Default_Theme.accentColor2.withOpacity(0.1)
            : Default_Theme.themeColor,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentlyPlaying
            ? Border.all(color: Default_Theme.accentColor2, width: 2)
            : null,
      ),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Icon(
              Icons.drag_handle,
              color: Default_Theme.primaryColor1.withOpacity(0.5),
            ),
            const SizedBox(width: 8),
            // Album art
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 50,
                height: 50,
                child: LoadImageCached(
                  imageUrl: formatImgURL(
                    item.artUri?.toString() ?? '',
                    ImageQuality.low,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
        title: Text(
          item.title,
          style: TextStyle(
            color: isCurrentlyPlaying
                ? Default_Theme.accentColor2
                : Default_Theme.primaryColor1,
            fontWeight: isCurrentlyPlaying ? FontWeight.bold : FontWeight.normal,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          item.artist ?? 'Unknown Artist',
          style: TextStyle(
            color: Default_Theme.primaryColor1.withOpacity(0.6),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton(
          icon: Icon(
            MingCute.more_2_fill,
            color: Default_Theme.primaryColor1,
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              onTap: () => musicPlayer.skipToQueueItem(index),
              child: const Row(
                children: [
                  Icon(MingCute.play_fill, size: 20),
                  SizedBox(width: 8),
                  Text('Play Now'),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: onPlayNext,
              child: const Row(
                children: [
                  Icon(MingCute.skip_forward_fill, size: 20),
                  SizedBox(width: 8),
                  Text('Play Next'),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: onRemove,
              child: const Row(
                children: [
                  Icon(MingCute.delete_2_line, size: 20),
                  SizedBox(width: 8),
                  Text('Remove'),
                ],
              ),
            ),
          ],
        ),
        onTap: () => musicPlayer.skipToQueueItem(index),
      ),
    );
  }
}
