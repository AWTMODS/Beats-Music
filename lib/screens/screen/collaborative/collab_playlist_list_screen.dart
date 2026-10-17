import 'package:beats_music/blocs/collaborative_playlist/collab_playlist_cubit.dart';
import 'package:beats_music/core/theme/app_theme.dart';
import 'package:beats_music/screens/screen/collaborative/collab_playlist_detail_screen.dart';
import 'package:beats_music/services/collaborative_playlist_service.dart';
import 'package:beats_music/screens/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';

/// Top-level screen showing all collaborative playlists the user belongs to.
class CollabPlaylistListScreen extends StatefulWidget {
  const CollabPlaylistListScreen({super.key});

  @override
  State<CollabPlaylistListScreen> createState() =>
      _CollabPlaylistListScreenState();
}

class _CollabPlaylistListScreenState extends State<CollabPlaylistListScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    context.read<CollabPlaylistCubit>().loadMyPlaylists();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _showCreateDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '🎵 New Shared Playlist',
          style: TextStyle(
            color: Default_Theme.primaryColor1,
            fontFamily: 'Gilroy',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 50,
          style: const TextStyle(color: Default_Theme.primaryColor1),
          decoration: InputDecoration(
            hintText: 'e.g. Road Trip 2026 🚗',
            hintStyle: TextStyle(
              color: Default_Theme.primaryColor1.withValues(alpha: 0.4),
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.06),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            counterStyle: TextStyle(
              color: Default_Theme.primaryColor1.withValues(alpha: 0.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(
                  color: Default_Theme.primaryColor1.withValues(alpha: 0.6)),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.successAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(ctx);
              context.read<CollabPlaylistCubit>().createPlaylist(name);
            },
            child: const Text('Create',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showJoinDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '🔗 Join a Playlist',
          style: TextStyle(
            color: Default_Theme.primaryColor1,
            fontFamily: 'Gilroy',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          style: const TextStyle(
            color: Default_Theme.primaryColor1,
            fontFamily: 'CodePro',
            fontSize: 20,
            letterSpacing: 3,
          ),
          decoration: InputDecoration(
            hintText: 'INVITE CODE',
            hintStyle: TextStyle(
              color: Default_Theme.primaryColor1.withValues(alpha: 0.3),
              fontFamily: 'CodePro',
              letterSpacing: 3,
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.06),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(
                    color: Default_Theme.primaryColor1.withValues(alpha: 0.6))),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.accentColor1,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final code = controller.text.trim();
              if (code.isEmpty) return;
              Navigator.pop(ctx);
              context.read<CollabPlaylistCubit>().joinByCode(code);
            },
            child: const Text('Join',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      body: FadeTransition(
        opacity: _fadeController,
        child: BlocConsumer<CollabPlaylistCubit, CollabPlaylistState>(
          listener: (context, state) {
            if (state is CollabPlaylistActionSuccess) {
              SnackbarService.showMessage(state.message);
              if (state.playlistId != null) {
                // Navigate into the newly created/joined playlist
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<CollabPlaylistCubit>(),
                      child: CollabPlaylistDetailScreen(
                          playlistId: state.playlistId!),
                    ),
                  ),
                );
              }
            } else if (state is CollabPlaylistError) {
              SnackbarService.showMessage(state.message);
            }
          },
          builder: (context, state) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── App Bar ──────────────────────────────────────────────
                SliverAppBar(
                  expandedHeight: 160,
                  pinned: true,
                  backgroundColor: Default_Theme.themeColor,
                  surfaceTintColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding:
                        const EdgeInsets.only(left: 20, bottom: 16),
                    title: const Text(
                      'Shared Playlists',
                      style: TextStyle(
                        fontFamily: 'Fjalla',
                        fontSize: 22,
                        color: Default_Theme.primaryColor1,
                      ),
                    ),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.accentColor1.withValues(alpha: 0.25),
                            AppTheme.successAccent.withValues(alpha: 0.10),
                            Default_Theme.themeColor,
                          ],
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Icon(
                            MingCute.group_line,
                            size: 72,
                            color: AppTheme.accentColor1
                                .withValues(alpha: 0.15),
                          ),
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    // Join button
                    IconButton(
                      onPressed: () => _showJoinDialog(context),
                      icon: const Icon(MingCute.link_line,
                          color: Default_Theme.primaryColor1),
                      tooltip: 'Join with code',
                    ),
                    // Create button
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.successAccent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                        ),
                        onPressed: () => _showCreateDialog(context),
                        icon: const Icon(Icons.add, color: Colors.black, size: 18),
                        label: const Text(
                          'New',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),

                // ── Body ──────────────────────────────────────────────────
                if (state is CollabPlaylistListLoading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state is CollabPlaylistListLoaded &&
                    state.playlists.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            MingCute.group_line,
                            size: 64,
                            color: Default_Theme.primaryColor1
                                .withValues(alpha: 0.2),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No shared playlists yet',
                            style: TextStyle(
                              fontFamily: 'Gilroy',
                              fontSize: 17,
                              color: Default_Theme.primaryColor1
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create one or join with a friend\'s invite code',
                            style: TextStyle(
                              fontSize: 13,
                              color: Default_Theme.primaryColor1
                                  .withValues(alpha: 0.35),
                            ),
                          ),
                          const SizedBox(height: 28),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                      color: AppTheme.accentColor1
                                          .withValues(alpha: 0.6)),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () => _showJoinDialog(context),
                                icon: const Icon(MingCute.link_line,
                                    color: AppTheme.accentColor1, size: 16),
                                label: const Text('Join',
                                    style: TextStyle(
                                        color: AppTheme.accentColor1)),
                              ),
                              const SizedBox(width: 12),
                              FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppTheme.successAccent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () => _showCreateDialog(context),
                                icon: const Icon(Icons.add,
                                    color: Colors.black, size: 16),
                                label: const Text('Create',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                else if (state is CollabPlaylistListLoaded)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    sliver: SliverList.builder(
                      itemCount: state.playlists.length,
                      itemBuilder: (ctx, i) => _PlaylistListTile(
                        meta: state.playlists[i],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<CollabPlaylistCubit>(),
                              child: CollabPlaylistDetailScreen(
                                  playlistId: state.playlists[i].playlistId),
                            ),
                          ),
                        ).then((_) {
                          if (context.mounted) {
                            context.read<CollabPlaylistCubit>().loadMyPlaylists();
                          }
                        }),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PlaylistListTile extends StatelessWidget {
  final CollabPlaylistMeta meta;
  final VoidCallback onTap;

  const _PlaylistListTile({required this.meta, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accentColor1.withValues(alpha: 0.12),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: AppTheme.accentColor1.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Cover
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.accentColor1.withValues(alpha: 0.8),
                        AppTheme.successAccent.withValues(alpha: 0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(MingCute.group_line,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meta.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Gilroy',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Default_Theme.primaryColor1,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${meta.trackCount} songs · by ${meta.ownerName}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Default_Theme.primaryColor1
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Default_Theme.primaryColor1.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
