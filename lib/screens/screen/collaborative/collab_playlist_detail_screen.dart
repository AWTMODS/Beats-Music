import 'dart:async';
import 'dart:ui';

import 'package:beats_music/blocs/collaborative_playlist/collab_playlist_cubit.dart';
import 'package:beats_music/blocs/history/cubit/history_cubit.dart';
import 'package:beats_music/blocs/media_player/beats_player_cubit.dart';
import 'package:beats_music/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:beats_music/core/di/service_locator.dart';
import 'package:beats_music/core/models/exported.dart';
import 'package:beats_music/core/models/media_playlist_model.dart';
import 'package:beats_music/core/theme/app_theme.dart';
import 'package:beats_music/plugins/blocs/plugin/plugin_bloc.dart';
import 'package:beats_music/screens/screen/collaborative/widgets/collab_track_tile.dart';
import 'package:beats_music/screens/screen/collaborative/widgets/invite_sheet.dart';
import 'package:beats_music/screens/screen/collaborative/widgets/member_avatar_row.dart';
import 'package:beats_music/screens/widgets/snackbar.dart';
import 'package:beats_music/services/collaborative_playlist_service.dart';
import 'package:beats_music/services/db/dao/history_dao.dart';
import 'package:beats_music/services/db/dao/track_dao.dart';
import 'package:beats_music/services/db/db_provider.dart';
import 'package:beats_music/services/db/mappers/media_item_mapper.dart';
import 'package:beats_music/src/rust/api/plugin/commands.dart';
import 'package:beats_music/src/rust/api/plugin/models.dart';
import 'package:beats_music/utils/load_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';

enum _SortMode { topVoted, recentlyAdded }

/// Full detail view for a single collaborative playlist.
/// Streams tracks and members from Firestore in real-time.
class CollabPlaylistDetailScreen extends StatefulWidget {
  final String playlistId;

  const CollabPlaylistDetailScreen({super.key, required this.playlistId});

  @override
  State<CollabPlaylistDetailScreen> createState() =>
      _CollabPlaylistDetailScreenState();
}

class _CollabPlaylistDetailScreenState
    extends State<CollabPlaylistDetailScreen>
    with SingleTickerProviderStateMixin {
  _SortMode _sortMode = _SortMode.topVoted;
  late AnimationController _headerAnim;

  String get _myUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    context.read<CollabPlaylistCubit>().openPlaylist(widget.playlistId);
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    super.dispose();
  }

  List<CollabTrack> _sortedTracks(List<CollabTrack> tracks) {
    final copy = List<CollabTrack>.from(tracks);
    if (_sortMode == _SortMode.topVoted) {
      copy.sort((a, b) => b.score.compareTo(a.score));
    } else {
      copy.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    }
    return copy;
  }

  void _playAllTracks(CollabPlaylistDetailLoaded state) {
    if (state.tracks.isEmpty) return;
    final trackList = _sortedTracks(state.tracks).map((ct) => ct.track).toList();
    context.read<BeatsPlayerCubit>().BeatsPlayer.loadPlaylist(
          Playlist(tracks: trackList, title: state.meta.name),
          idx: 0,
          doPlay: true,
        );
  }

  void _showSortMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SortBottomSheet(
        current: _sortMode,
        onSelected: (mode) {
          setState(() => _sortMode = mode);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      body: BlocConsumer<CollabPlaylistCubit, CollabPlaylistState>(
        listener: (context, state) {
          if (state is CollabPlaylistError) {
            SnackbarService.showMessage(state.message);
          }
        },
        builder: (context, state) {
          if (state is CollabPlaylistDetailLoading ||
              state is CollabPlaylistListLoading ||
              state is CollabPlaylistInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is! CollabPlaylistDetailLoaded) {
            return const Center(
              child: Text('Something went wrong.',
                  style: TextStyle(color: Default_Theme.primaryColor1)),
            );
          }

          final sortedTracks = _sortedTracks(state.tracks);
          final canEdit = state.myRole == CollabRole.owner ||
              state.myRole == CollabRole.editor;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Collapsing Header ─────────────────────────────────────
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: Default_Theme.themeColor,
                surfaceTintColor: Colors.transparent,
                leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Default_Theme.primaryColor1, size: 20),
                ),
                actions: [
                  // Sort
                  IconButton(
                    onPressed: _showSortMenu,
                    icon: const Icon(MingCute.sort_descending_line,
                        color: Default_Theme.primaryColor1),
                    tooltip: 'Sort',
                  ),
                  // Invite
                  if (canEdit)
                    IconButton(
                      onPressed: () => showInviteSheet(
                          context, state.meta.inviteCode, state.meta.name),
                      icon: const Icon(MingCute.link_line,
                          color: AppTheme.accentColor1),
                      tooltip: 'Invite friends',
                    ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
                  title: Text(
                    state.meta.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Fjalla',
                      fontSize: 18,
                      color: Default_Theme.primaryColor1,
                    ),
                  ),
                  background: FadeTransition(
                    opacity: _headerAnim,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Gradient background
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppTheme.accentColor1.withValues(alpha: 0.35),
                                AppTheme.successAccent
                                    .withValues(alpha: 0.10),
                                Default_Theme.themeColor,
                              ],
                            ),
                          ),
                        ),
                        // Decorative large icon
                        Positioned(
                          right: 20,
                          top: 20,
                          child: Icon(
                            MingCute.group_line,
                            size: 90,
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                        // Info overlay at the bottom
                        Positioned(
                          left: 20,
                          bottom: 52,
                          right: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Members row
                              MemberAvatarRow(members: state.members),
                              const SizedBox(height: 8),
                              // Track count + sort pill
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${state.meta.trackCount} songs',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Default_Theme.primaryColor1
                                            .withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentColor1
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: AppTheme.accentColor1
                                              .withValues(alpha: 0.3)),
                                    ),
                                    child: Text(
                                      _sortMode == _SortMode.topVoted
                                          ? '🔥 Top Voted'
                                          : '🕐 Recent',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.accentColor1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Play All + Add Track bar ───────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Row(
                    children: [
                      // Play All
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.successAccent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: state.tracks.isEmpty
                              ? null
                              : () => _playAllTracks(state),
                          icon: const Icon(Icons.play_arrow_rounded,
                              color: Colors.black),
                          label: const Text(
                            'Play All',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                                fontSize: 15),
                          ),
                        ),
                      ),
                      if (canEdit) ...[
                        const SizedBox(width: 10),
                        // Add track — navigates to search and returns
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color:
                                    AppTheme.accentColor1.withValues(alpha: 0.6)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                          ),
                          onPressed: state.isAddingTrack
                              ? null
                              : () => _openAddTrackFlow(context),
                          icon: state.isAddingTrack
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppTheme.accentColor1),
                                )
                              : const Icon(Icons.add, color: AppTheme.accentColor1),
                          label: const Text('Add',
                              style: TextStyle(color: AppTheme.accentColor1)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // ── Tracks List ───────────────────────────────────────────
              if (sortedTracks.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(MingCute.music_2_line,
                            size: 52,
                            color: Default_Theme.primaryColor1
                                .withValues(alpha: 0.2)),
                        const SizedBox(height: 12),
                        Text(
                          canEdit
                              ? 'Tap "+ Add" to add the first song!'
                              : 'No songs yet. Ask an editor to add some!',
                          style: TextStyle(
                            color: Default_Theme.primaryColor1
                                .withValues(alpha: 0.45),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  sliver: SliverList.builder(
                    itemCount: sortedTracks.length,
                    itemBuilder: (ctx, i) {
                      final ct = sortedTracks[i];
                      final canRemove = canEdit ||
                          ct.addedByUid == _myUid;
                      return CollabTrackTile(
                        collabTrack: ct,
                        myUid: _myUid,
                        rank: i + 1,
                        canRemove: canRemove,
                        onPlay: () {
                          final trackList = sortedTracks
                              .map((t) => t.track)
                              .toList();
                          context
                              .read<BeatsPlayerCubit>()
                              .BeatsPlayer
                              .loadPlaylist(
                                Playlist(
                                    tracks: trackList,
                                    title: state.meta.name),
                                idx: i,
                                doPlay: true,
                              );
                        },
                        onUpvote: () => context
                            .read<CollabPlaylistCubit>()
                            .vote(ct.trackId, upvote: true),
                        onDownvote: () => context
                            .read<CollabPlaylistCubit>()
                            .vote(ct.trackId, upvote: false),
                        onRemove: canRemove
                            ? () => context
                                .read<CollabPlaylistCubit>()
                                .removeTrack(ct.trackId)
                            : null,
                      );
                    },
                  ),
                ),

              // Bottom padding for mini-player
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          );
        },
      ),
    );
  }

  void _openAddTrackFlow(BuildContext context) {
    final cubit = context.read<CollabPlaylistCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => BlocProvider.value(
        value: cubit,
        child: _AddTrackSheet(
          playlistId: widget.playlistId,
          onTrackSelected: (track) async {
            final success = await cubit.addTrack(track);
            if (!success) {
              SnackbarService.showMessage('Track already in this playlist!');
            } else {
              SnackbarService.showMessage('${track.title} added! 🎵');
            }
          },
        ),
      ),
    );
  }
}

// ─── Sort Sheet ──────────────────────────────────────────────────────────────

class _SortBottomSheet extends StatelessWidget {
  final _SortMode current;
  final void Function(_SortMode) onSelected;

  const _SortBottomSheet({required this.current, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: const Color(0xFF1A1A2E).withValues(alpha: 0.95),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sort tracks by',
                style: TextStyle(
                  fontFamily: 'Fjalla',
                  fontSize: 18,
                  color: Default_Theme.primaryColor1,
                ),
              ),
              const SizedBox(height: 16),
              _SortTile(
                icon: '🔥',
                label: 'Top Voted',
                subtitle: 'Most upvoted tracks first',
                selected: current == _SortMode.topVoted,
                onTap: () => onSelected(_SortMode.topVoted),
              ),
              const SizedBox(height: 8),
              _SortTile(
                icon: '🕐',
                label: 'Recently Added',
                subtitle: 'Newest additions first',
                selected: current == _SortMode.recentlyAdded,
                onTap: () => onSelected(_SortMode.recentlyAdded),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _SortTile extends StatelessWidget {
  final String icon;
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _SortTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppTheme.accentColor1.withValues(alpha: 0.15)
          : Colors.white.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: TextStyle(
                          fontFamily: 'Gilroy',
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? AppTheme.accentColor1
                              : Default_Theme.primaryColor1,
                          fontSize: 15,
                        )),
                    Text(subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Default_Theme.primaryColor1
                              .withValues(alpha: 0.5),
                        )),
                  ],
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle_rounded,
                    color: AppTheme.accentColor1, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Add Track Sheet ─────────────────────────────────────────────────────────

class _AddTrackSheet extends StatefulWidget {
  final String playlistId;
  final void Function(Track) onTrackSelected;

  const _AddTrackSheet({
    required this.playlistId,
    required this.onTrackSelected,
  });

  @override
  State<_AddTrackSheet> createState() => _AddTrackSheetState();
}

class _AddTrackSheetState extends State<_AddTrackSheet> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounceTimer;
  bool _isLoading = false;
  List<Track> _searchResults = [];
  List<Track> _recentTracks = [];
  final Set<String> _addedTrackIds = {};
  String? _activePluginId;

  @override
  void initState() {
    super.initState();
    _initPlugin();
    _loadRecentTracks();
  }

  void _initPlugin() {
    try {
      final pluginState = context.read<PluginBloc>().state;
      final resolvers = pluginState.loadedContentResolvers;
      if (resolvers.isNotEmpty) {
        final persistedId = context.read<SettingsCubit>().state.searchPluginId;
        final hasPersisted = persistedId.isNotEmpty &&
            resolvers.any((p) => p.manifest.id == persistedId);
        _activePluginId =
            hasPersisted ? persistedId : resolvers.first.manifest.id;
      }
    } catch (_) {}
  }

  Future<void> _loadRecentTracks() async {
    try {
      final historyCubit = context.read<HistoryCubit>();
      if (historyCubit.state.tracks.isNotEmpty) {
        if (mounted) {
          setState(() {
            _recentTracks = historyCubit.state.tracks.take(25).toList();
          });
        }
        return;
      }
      final trackDao = TrackDAO(DBProvider.db);
      final historyDao = HistoryDAO(DBProvider.db, trackDao);
      final tracks = await historyDao.getHistory(limit: 25);
      if (mounted) {
        setState(() {
          _recentTracks = tracks;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    final q = query.trim();
    if (q.isEmpty) {
      setState(() {
        _isLoading = false;
        _searchResults = [];
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      _performSearch(q);
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
    });

    final results = <Track>[];
    try {
      if (_activePluginId != null) {
        final response = await ServiceLocator.pluginService.execute(
          pluginId: _activePluginId!,
          request: PluginRequest.contentResolver(
            ContentResolverCommand.search(
              query: query,
              filter: ContentSearchFilter.track,
            ),
          ),
        );

        if (response is PluginResponse_Search) {
          for (final item in response.field0.items) {
            if (item is MediaItem_Track) {
              results.add(item.field0);
            }
          }
        }
      }
    } catch (_) {}

    // Fallback to local tracks if online search returned nothing
    if (results.isEmpty) {
      try {
        final trackDao = TrackDAO(DBProvider.db);
        final localTracks = await trackDao.searchTracks(query, limit: 30);
        results.addAll(localTracks.map(trackDBToTrack));
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _searchResults = results;
      });
    }
  }

  void _handleAddTrack(Track track) {
    setState(() {
      _addedTrackIds.add(track.id);
    });
    widget.onTrackSelected(track);
  }

  @override
  Widget build(BuildContext context) {
    final cubitState = context.watch<CollabPlaylistCubit>().state;
    final existingTrackIds = cubitState is CollabPlaylistDetailLoaded
        ? cubitState.tracks.map((t) => t.track.id).toSet()
        : <String>{};

    final isSearching = _searchController.text.trim().isNotEmpty;
    final displayTracks = isSearching ? _searchResults : _recentTracks;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (ctx, scrollController) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.97),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Text(
                        '🎵 Add a Song',
                        style: TextStyle(
                          fontFamily: 'Fjalla',
                          fontSize: 18,
                          color: Default_Theme.primaryColor1,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: Colors.white70, size: 22),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // Search Input
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      style: const TextStyle(
                        color: Default_Theme.primaryColor1,
                        fontSize: 14,
                      ),
                      cursorColor: AppTheme.accentColor1,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppTheme.accentColor1,
                          size: 20,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded,
                                    size: 18, color: Colors.white54),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                },
                              )
                            : null,
                        hintText: 'Search songs or artists...',
                        hintStyle: TextStyle(
                          color:
                              Default_Theme.primaryColor1.withValues(alpha: 0.4),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                // Section Title (when showing recents)
                if (!isSearching && _recentTracks.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'RECENT & LIBRARY SONGS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color:
                              Default_Theme.primaryColor1.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                // Content area
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppTheme.accentColor1,
                          ),
                        )
                      : displayTracks.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Text(
                                  isSearching
                                      ? 'No songs found for "${_searchController.text.trim()}"'
                                      : 'Type a song or artist name above to search and add tracks.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Default_Theme.primaryColor1
                                        .withValues(alpha: 0.5),
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              itemCount: displayTracks.length,
                              itemBuilder: (ctx, index) {
                                final track = displayTracks[index];
                                final isAdded =
                                    existingTrackIds.contains(track.id) ||
                                        _addedTrackIds.contains(track.id);

                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: isAdded
                                          ? null
                                          : () => _handleAddTrack(track),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Padding(
                                        padding: const EdgeInsets.all(6),
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: LoadImageCached(
                                                imageUrl:
                                                    track.thumbnail.urlLow ??
                                                        track.thumbnail.url,
                                                width: 48,
                                                height: 48,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    track.title,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                      color: Default_Theme
                                                          .primaryColor1,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    track.artists
                                                        .map((a) => a.name)
                                                        .join(', '),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Default_Theme
                                                          .primaryColor1
                                                          .withValues(
                                                              alpha: 0.55),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            if (isAdded)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.successAccent
                                                      .withValues(alpha: 0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                child: const Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.check_rounded,
                                                      size: 16,
                                                      color: AppTheme
                                                          .successAccent,
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      'Added',
                                                      style: TextStyle(
                                                        color: AppTheme
                                                            .successAccent,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            else
                                              InkWell(
                                                onTap: () =>
                                                    _handleAddTrack(track),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: AppTheme.accentColor1
                                                        .withValues(
                                                            alpha: 0.15),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    border: Border.all(
                                                      color:
                                                          AppTheme.accentColor1
                                                              .withValues(
                                                                  alpha: 0.35),
                                                    ),
                                                  ),
                                                  child: const Row(
                                                    mainAxisSize:
                                                      MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.add_rounded,
                                                        size: 16,
                                                        color: AppTheme
                                                            .accentColor1,
                                                      ),
                                                      SizedBox(width: 4),
                                                      Text(
                                                        'Add',
                                                        style: TextStyle(
                                                          color: AppTheme
                                                              .accentColor1,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
