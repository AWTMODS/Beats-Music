import 'dart:developer' as developer;
import 'dart:ui';
import 'package:beats_music/blocs/jam_session/jam_session_cubit.dart';

import 'package:beats_music/blocs/media_player/beats_player_cubit.dart';
import 'package:beats_music/plugins/blocs/import/content_import_cubit.dart';
import 'package:beats_music/plugins/blocs/import/content_import_state.dart';
import 'package:beats_music/core/models/media_playlist_model.dart';
import 'package:beats_music/screens/screen/library_views/more_opts_sheet.dart';
import 'package:beats_music/screens/screen/common_views/album_view.dart';
import 'package:beats_music/screens/screen/common_views/artist_view.dart';
import 'package:beats_music/screens/screen/common_views/playlist_view.dart';
import 'package:beats_music/screens/screen/library_views/generative_playlist_sheet.dart';
import 'package:beats_music/screens/widgets/more_bottom_sheet.dart';
import 'package:beats_music/screens/widgets/sign_board_widget.dart';
import 'package:beats_music/screens/widgets/song_tile.dart';
import 'package:beats_music/plugins/utils/media_id.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:beats_music/blocs/library/cubit/library_items_cubit.dart';
import 'package:beats_music/core/constants/route_paths.dart';
import 'package:beats_music/screens/widgets/create_playlist_bottomsheet.dart';
import 'package:beats_music/screens/widgets/libitem_tile.dart';
import 'package:beats_music/core/theme/app_theme.dart';
import 'package:beats_music/l10n/app_localizations.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:beats_music/blocs/library/search_cubit/library_search_cubit.dart';
import 'package:beats_music/core/models/library_search_result.dart';
import 'package:beats_music/screens/widgets/animated_list_item.dart';
import 'package:beats_music/blocs/downloader/cubit/downloader_cubit.dart';
import 'package:beats_music/screens/widgets/thumbnail_grid.dart';

enum LibraryFilter { playlists, albums, artists, downloaded }

enum LibrarySort { recents, recentlyAdded, alphabetical, creator }

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LibrarySearchCubit(
        searchTracks: context.read<LibraryItemsCubit>().searchTracks,
      ),
      child: const _LibraryScreenView(),
    );
  }
}

class _LibraryScreenView extends StatefulWidget {
  const _LibraryScreenView();

  @override
  State<_LibraryScreenView> createState() => _LibraryScreenViewState();
}

class _LibraryScreenViewState extends State<_LibraryScreenView> {
  final ValueNotifier<String> _searchQuery = ValueNotifier('');
  bool _isSearching = false;
  bool _isReordering = false;
  LibraryFilter? _activeFilter;
  LibrarySort _currentSort = LibrarySort.recents;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchQuery.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    _searchQuery.value = query;

    final itemsState = context.read<LibraryItemsCubit>().state;
    context.read<LibrarySearchCubit>().search(query, itemsState);
  }

  void _openSearch() {
    setState(() {
      _isSearching = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  void _closeSearch() {
    _searchController.clear();
    _searchQuery.value = '';
    context.read<LibrarySearchCubit>().clearSearch();
    setState(() {
      _isSearching = false;
    });
  }

  /// Dismiss keyboard when interacting with search results
  void _dismissKeyboard() {
    _searchFocusNode.unfocus();
  }

  List<PlaylistItemProperties> _applySort(List<PlaylistItemProperties> items) {
    final pinned = items.where((i) => i.isPinned).toList();
    final unpinned = items.where((i) => !i.isPinned).toList();

    switch (_currentSort) {
      case LibrarySort.recents:
        break;
      case LibrarySort.recentlyAdded:
        unpinned.sort((a, b) => b.playlistId.compareTo(a.playlistId));
        break;
      case LibrarySort.alphabetical:
        unpinned.sort((a, b) => a.playlistName
            .toLowerCase()
            .compareTo(b.playlistName.toLowerCase()));
        break;
      case LibrarySort.creator:
        unpinned.sort((a, b) => (a.subTitle ?? '')
            .toLowerCase()
            .compareTo((b.subTitle ?? '').toLowerCase()));
        break;
    }

    return [...pinned, ...unpinned];
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'Sort by',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Divider(color: Colors.white12),
                ...[
                  (LibrarySort.recents, 'Recents'),
                  (LibrarySort.recentlyAdded, 'Recently added'),
                  (LibrarySort.alphabetical, 'Alphabetical'),
                  (LibrarySort.creator, 'Creator / Artist'),
                ].map((entry) {
                  final isSelected = _currentSort == entry.$1;
                  return ListTile(
                    title: Text(
                      entry.$2,
                      style: TextStyle(
                        color: isSelected
                            ? Default_Theme.accentColor2
                            : Colors.white,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            color: Default_Theme.accentColor2,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        _currentSort = entry.$1;
                      });
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      (LibraryFilter.playlists, 'Playlists'),
      (LibraryFilter.albums, 'Albums'),
      (LibraryFilter.artists, 'Artists'),
      (LibraryFilter.downloaded, 'Downloaded'),
    ];

    return Container(
      padding: const EdgeInsets.only(top: 2, bottom: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: filters.map((item) {
            final isSelected = _activeFilter == item.$1;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _activeFilter = null;
                      } else {
                        _activeFilter = item.$1;
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSelected ? 12 : 16,
                      vertical: 7.5,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Default_Theme.accentColor2
                          : const Color(0xFF282828),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : Colors.white.withValues(alpha: 0.08),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected) ...[
                          const Icon(
                            Icons.close_rounded,
                            size: 14,
                            color: Colors.black,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          item.$2,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: isSelected ? Colors.black : Colors.white,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSortHeader(BuildContext context) {
    final sortLabel = switch (_currentSort) {
      LibrarySort.recents => 'Recents',
      LibrarySort.recentlyAdded => 'Recently added',
      LibrarySort.alphabetical => 'Alphabetical',
      LibrarySort.creator => 'Creator',
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 12, 4),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: _showSortBottomSheet,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.swap_vert_rounded,
                    size: 18,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    sortLabel,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          if (!_isSearching &&
              (_activeFilter == null ||
                  _activeFilter == LibraryFilter.playlists))
            IconButton(
              tooltip: _isReordering ? 'Done reordering' : 'Reorder',
              icon: Icon(
                _isReordering
                    ? Icons.check_circle_rounded
                    : Icons.format_list_bulleted_rounded,
                size: 20,
                color: _isReordering
                    ? Default_Theme.accentColor2
                    : Colors.white.withValues(alpha: 0.6),
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                setState(() {
                  _isReordering = !_isReordering;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildReorderTip(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.035),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Default_Theme.accentColor2.withValues(alpha: 0.22),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Default_Theme.accentColor2.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.drag_indicator_rounded,
                color: Default_Theme.accentColor2.withValues(alpha: 0.95),
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.importReorderTip,
                style: Default_Theme.secondoryTextStyle.merge(TextStyle(
                  color: Default_Theme.primaryColor2.withValues(alpha: 0.72),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                )),
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _isReordering = false),
              style: TextButton.styleFrom(
                foregroundColor: Default_Theme.accentColor2,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                AppLocalizations.of(context)!.importDone,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadedList(BuildContext context) {
    return BlocBuilder<DownloaderCubit, DownloaderState>(
      builder: (context, dlState) {
        var downloadedTracks = dlState.downloaded;
        final query = _searchController.text.trim().toLowerCase();
        if (_isSearching && query.isNotEmpty) {
          downloadedTracks = downloadedTracks
              .where((t) =>
                  "${t.title.toLowerCase()} ${t.artists.map((a) => a.name).join(', ').toLowerCase()}"
                      .contains(query))
              .toList();
        }

        if (downloadedTracks.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: SignBoardWidget(
                message: _isSearching
                    ? AppLocalizations.of(context)!.emptyNoResults
                    : 'No downloaded songs yet',
                icon: _isSearching
                    ? MingCute.search_line
                    : MingCute.folder_download_fill,
              ),
            ),
          );
        }

        return SliverList.builder(
          itemCount: downloadedTracks.length,
          itemBuilder: (context, index) {
            final track = downloadedTracks[index];
            return AnimatedListItem(
              key: ValueKey('downloaded_${track.id}'),
              index: index,
              child: Padding(
                padding: const EdgeInsets.only(left: 4, right: 0),
                child: SongCardWidget(
                  song: track,
                  showOptions: true,
                  onTap: () {
                    _dismissKeyboard();
                    final playIdx = dlState.downloaded
                        .indexWhere((t) => t.id == track.id);
                    context.read<BeatsPlayerCubit>().BeatsPlayer.loadPlaylist(
                          Playlist(
                            tracks: dlState.downloaded,
                            title: "Offline",
                          ),
                          idx: playIdx >= 0 ? playIdx : 0,
                          doPlay: true,
                        );
                  },
                  onOptionsTap: () {
                    showMoreBottomSheet(context, track, showDelete: false);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      body: SafeArea(
        child: BlocBuilder<LibraryItemsCubit, LibraryItemsState>(
          builder: (context, itemsState) {
            if (itemsState is LibraryItemsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (itemsState is LibraryItemsError) {
              return Center(
                child: SignBoardWidget(
                  message: itemsState.message,
                  icon: Icons.error_outline_rounded,
                ),
              );
            }

            return BlocBuilder<LibrarySearchCubit, LibrarySearchState>(
              builder: (context, searchState) {
                final isSearching = searchState is LibrarySearchSuccess;
                final isLoading = searchState is LibrarySearchLoading;

                final rawPlaylists = isSearching
                    ? searchState.filteredPlaylists
                    : itemsState.playlists;
                final filteredSongs = isSearching
                    ? searchState.songResults
                    : <SongSearchResult>[];

                // Filter by active category chip
                List<PlaylistItemProperties> displayPlaylists;
                switch (_activeFilter) {
                  case LibraryFilter.playlists:
                    displayPlaylists = rawPlaylists
                        .where((p) =>
                            p.type == PlaylistType.userPlaylist ||
                            p.type == PlaylistType.remotePlaylist)
                        .toList();
                    break;
                  case LibraryFilter.albums:
                    displayPlaylists = rawPlaylists
                        .where((p) => p.type == PlaylistType.album)
                        .toList();
                    break;
                  case LibraryFilter.artists:
                    displayPlaylists = rawPlaylists
                        .where((p) => p.type == PlaylistType.artist)
                        .toList();
                    break;
                  case LibraryFilter.downloaded:
                    displayPlaylists = const [];
                    break;
                  case null:
                    displayPlaylists = List.of(rawPlaylists);
                    break;
                }

                // Apply selected sort
                displayPlaylists = _applySort(displayPlaylists);

                final isDownloadedFilter =
                    _activeFilter == LibraryFilter.downloaded;

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    customDiscoverBar(context),
                    SliverToBoxAdapter(
                      child: _buildFilterChips(),
                    ),
                    if (_isSearching)
                      SliverToBoxAdapter(
                        child: _buildSearchBar(),
                      ),
                    if (!_isSearching && !isDownloadedFilter)
                      SliverToBoxAdapter(
                        child: _buildSortHeader(context),
                      ),
                    if (!_isSearching)
                      SliverToBoxAdapter(
                        child: _buildOfflineShortcutTile(
                          context,
                          showDownloaded: _activeFilter == null ||
                              _activeFilter == LibraryFilter.downloaded,
                          showShared: _activeFilter == null ||
                              _activeFilter == LibraryFilter.playlists,
                          showLiveRoom: _activeFilter == null,
                        ),
                      ),
                    if (isDownloadedFilter)
                      _buildDownloadedList(context),
                    if (!isDownloadedFilter) ...[
                      if (isLoading)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4, bottom: 8),
                            child: Center(
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Default_Theme.accentColor1
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (filteredSongs.isNotEmpty &&
                          (_activeFilter == null ||
                              _activeFilter == LibraryFilter.playlists))
                        _buildSongSearchResults(context, filteredSongs),
                      if (displayPlaylists.isNotEmpty) ...[
                        if (_isReordering && !isSearching)
                          SliverToBoxAdapter(
                            child: _buildReorderTip(context),
                          ),
                        _ListOfPlaylists(
                          playlists: displayPlaylists,
                          isReorderable: _isReordering && !isSearching,
                          onEnterReorder: isSearching
                              ? null
                              : () => setState(() => _isReordering = true),
                        ),
                      ],
                      if (displayPlaylists.isEmpty &&
                          filteredSongs.isEmpty &&
                          !isLoading)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: SignBoardWidget(
                              message: switch (_activeFilter) {
                                LibraryFilter.playlists =>
                                  'No playlists found',
                                LibraryFilter.albums =>
                                  'No albums in your library yet',
                                LibraryFilter.artists =>
                                  'No artists in your library yet',
                                _ => _isSearching
                                    ? AppLocalizations.of(context)!.emptyNoResults
                                    : AppLocalizations.of(context)!
                                        .libraryEmptyState,
                              },
                              icon: switch (_activeFilter) {
                                LibraryFilter.playlists =>
                                  MingCute.playlist_fill,
                                LibraryFilter.albums => MingCute.album_fill,
                                LibraryFilter.artists => MingCute.user_3_fill,
                                _ => _isSearching
                                    ? MingCute.search_line
                                    : MingCute.playlist_fill,
                              },
                            ),
                          ),
                        ),
                    ],
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Default_Theme.primaryColor1.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          autofocus: false,
          textInputAction: TextInputAction.search,
          style: Default_Theme.secondoryTextStyle.merge(
            const TextStyle(
              color: Default_Theme.primaryColor1,
              fontSize: 15,
            ),
          ),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.searchHintLibrary,
            hintStyle: Default_Theme.secondoryTextStyle.merge(
              TextStyle(
                color: Default_Theme.primaryColor1.withValues(alpha: 0.4),
                fontSize: 15,
              ),
            ),
            prefixIcon: Icon(
              MingCute.search_line,
              color: Default_Theme.primaryColor1.withValues(alpha: 0.5),
              size: 20,
            ),
            suffixIcon: ValueListenableBuilder<String>(
              valueListenable: _searchQuery,
              builder: (context, query, _) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  child: query.isEmpty
                      ? const SizedBox.shrink(key: ValueKey('empty'))
                      : IconButton(
                          key: const ValueKey('clear'),
                          icon: Icon(
                            MingCute.close_fill,
                            color: Default_Theme.primaryColor1
                                .withValues(alpha: 0.5),
                            size: 18,
                          ),
                          onPressed: () {
                            _searchController.clear();
                          },
                        ),
                );
              },
            ),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildSongSearchResults(
      BuildContext context, List<SongSearchResult> songs) {
    return SliverList.builder(
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final result = songs[index];
        return AnimatedListItem(
          key: ValueKey('song_${result.song.id}_${result.playlistName}'),
          index: index,
          child: Padding(
            padding: const EdgeInsets.only(left: 4, right: 0),
            child: SongCardWidget(
              song: result.song,
              showOptions: true,
              subtitleOverride:
                  AppLocalizations.of(context)!.libraryIn(result.playlistName),
              onTap: () async {
                _dismissKeyboard();
                final playlist = await context
                    .read<LibraryItemsCubit>()
                    .getPlaylistByName(result.playlistName);
                if (playlist != null && context.mounted) {
                  final songIdx =
                      playlist.tracks.indexWhere((s) => s.id == result.song.id);
                  context.read<BeatsPlayerCubit>().BeatsPlayer.loadPlaylist(
                        playlist,
                        idx: songIdx >= 0 ? songIdx : 0,
                        doPlay: true,
                      );
                }
              },
              onOptionsTap: () {
                showMoreBottomSheet(context, result.song);
              },
            ),
          ),
        );
      },
    );
  }

  SliverAppBar customDiscoverBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      pinned: false, // Set to false if you don't want it to stick at the top
      surfaceTintColor: Default_Theme.themeColor,
      backgroundColor: Default_Theme.themeColor,
      title: Row(
        children: [
          Text(
            AppLocalizations.of(context)!.libraryTitle,
            style: Default_Theme.primaryTextStyle.merge(
              const TextStyle(
                fontSize: 34,
                color: Default_Theme.primaryColor1,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            padding: const EdgeInsets.all(8),
            onPressed: () {
              if (_isSearching) {
                _closeSearch();
              } else {
                _openSearch();
              }
            },
            icon: Icon(
              _isSearching ? MingCute.close_fill : MingCute.search_line,
              size: 24,
              color: _isSearching
                  ? Default_Theme.accentColor2
                  : Default_Theme.primaryColor1,
            ),
          ),
          IconButton(
            padding: const EdgeInsets.all(8),
            onPressed: () => createPlaylistBottomSheet(context),
            icon: const Icon(MingCute.add_fill,
                size: 25, color: Default_Theme.primaryColor1),
          ),
          IconButton(
            padding: const EdgeInsets.all(8),
            onPressed: () => GenerativePlaylistSheet.show(context),
            icon: const Icon(MingCute.magic_3_fill,
                size: 22, color: Default_Theme.primaryColor1),
          ),
          IconButton(
            padding: const EdgeInsets.all(8),
            onPressed: () {
              final importPhase =
                  context.read<ContentImportCubit>().state.phase;
              final isOngoing = importPhase != ImportPhase.idle &&
                  importPhase != ImportPhase.done &&
                  importPhase != ImportPhase.error;
              if (isOngoing) {
                final pluginId =
                    context.read<ContentImportCubit>().state.pluginId ?? '';
                context.pushNamed(RoutePaths.importProcess,
                    queryParameters: {'pluginId': pluginId});
              } else {
                context.pushNamed(RoutePaths.importMediaFromPlatforms);
              }
            },
            icon: const Icon(FontAwesome.file_import_solid,
                size: 22, color: Default_Theme.primaryColor1),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineShortcutTile(
    BuildContext context, {
    bool showDownloaded = true,
    bool showShared = true,
    bool showLiveRoom = true,
  }) {
    if (!showDownloaded && !showShared && !showLiveRoom) {
      return const SizedBox.shrink();
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showDownloaded)
          BlocBuilder<DownloaderCubit, DownloaderState>(
            builder: (context, state) {
              final downloadedCount = state.downloaded.length;
              final thumbnails = state.downloaded
                  .take(4)
                  .map((t) => t.thumbnail.url)
                  .where((url) => url.isNotEmpty)
                  .toList();
              final subtitle =
                  '$downloadedCount ${downloadedCount == 1 ? 'track' : 'tracks'}';

              return Padding(
                padding:
                    const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                child: AnimatedListItem(
                  index: 0,
                  child: InkWell(
                    splashColor:
                        Default_Theme.primaryColor2.withValues(alpha: 0.1),
                    hoverColor: Colors.white.withValues(alpha: 0.05),
                    highlightColor:
                        Default_Theme.primaryColor2.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      context.pushNamed(RoutePaths.offlineScreen);
                    },
                    child: SizedBox(
                      height: 68,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: SizedBox.square(
                              dimension: 58,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: ThumbnailGrid(
                                  imageUrls: thumbnails,
                                  size: 58,
                                  fallbackIcon:
                                      MingCute.folder_download_fill,
                                  fallbackColor: const Color(0xFF2563EB),
                                  fallbackIconColor: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Downloaded Songs",
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: Default_Theme.secondoryTextStyle.merge(
                                    const TextStyle(
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w700,
                                      color: Default_Theme.primaryColor1,
                                    ),
                                  ),
                                ),
                                Text(
                                  subtitle,
                                  maxLines: 1,
                                  style: Default_Theme.secondoryTextStyle.merge(
                                    const TextStyle(
                                      fontSize: 14,
                                      overflow: TextOverflow.fade,
                                      fontWeight: FontWeight.w500,
                                      color: Default_Theme.primaryColor1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 14),
                            child: Icon(MingCute.right_line,
                                size: 20,
                                color: Default_Theme.primaryColor1
                                    .withValues(alpha: 0.3)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        if (showShared)
          // ── Shared Playlists shortcut ─────────────────────────────────────────
          Padding(
            padding:
                const EdgeInsets.only(left: 8, right: 8, top: 0, bottom: 4),
            child: AnimatedListItem(
              index: 1,
              child: InkWell(
                splashColor: AppTheme.successAccent.withValues(alpha: 0.08),
                hoverColor: Colors.white.withValues(alpha: 0.03),
                highlightColor: AppTheme.successAccent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                onTap: () => context.pushNamed(RoutePaths.collabPlaylistList),
                child: SizedBox(
                  height: 68,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF97316),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            MingCute.group_fill,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Shared Playlists',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: Default_Theme.secondoryTextStyle.merge(
                                const TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w700,
                                  color: Default_Theme.primaryColor1,
                                ),
                              ),
                            ),
                            Text(
                              'Collaborate with friends',
                              maxLines: 1,
                              style: Default_Theme.secondoryTextStyle.merge(
                                TextStyle(
                                  fontSize: 13,
                                  overflow: TextOverflow.fade,
                                  fontWeight: FontWeight.w500,
                                  color: Default_Theme.primaryColor1
                                      .withValues(alpha: 0.55),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 14),
                        child: Icon(MingCute.right_line,
                            size: 20,
                            color: Default_Theme.primaryColor1
                                .withValues(alpha: 0.3)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        if (showLiveRoom)
          // ── Live Room shortcut ────────────────────────────────────────────────
          Padding(
            padding:
                const EdgeInsets.only(left: 8, right: 8, top: 0, bottom: 4),
            child: AnimatedListItem(
              index: 2,
              child: InkWell(
                splashColor: AppTheme.successAccent.withValues(alpha: 0.08),
                hoverColor: Colors.white.withValues(alpha: 0.03),
                highlightColor: AppTheme.successAccent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                onTap: () => _showJamEntrySheet(context),
                child: SizedBox(
                  height: 68,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C3AED),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            MingCute.headphone_fill,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Live Room',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: Default_Theme.secondoryTextStyle.merge(
                                const TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w700,
                                  color: Default_Theme.primaryColor1,
                                ),
                              ),
                            ),
                            Text(
                              'Listen live with friends',
                              maxLines: 1,
                              style: Default_Theme.secondoryTextStyle.merge(
                                TextStyle(
                                  fontSize: 13,
                                  overflow: TextOverflow.fade,
                                  fontWeight: FontWeight.w500,
                                  color: Default_Theme.primaryColor1
                                      .withValues(alpha: 0.55),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 14),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.successAccent,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(MingCute.right_line,
                                size: 20,
                                color: Default_Theme.primaryColor1
                                    .withValues(alpha: 0.3)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showJamEntrySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _JamEntrySheet(parentContext: context),
    );
  }
}


class _ListOfPlaylists extends StatelessWidget {
  final List<PlaylistItemProperties> playlists;
  final bool isReorderable;
  final VoidCallback? onEnterReorder;
  const _ListOfPlaylists({
    required this.playlists,
    this.isReorderable = false,
    this.onEnterReorder,
  });

  static LibItemTypes _toCardType(PlaylistType type) {
    switch (type) {
      case PlaylistType.artist:
        return LibItemTypes.artist;
      case PlaylistType.album:
        return LibItemTypes.album;
      case PlaylistType.remotePlaylist:
        return LibItemTypes.onlPlaylist;
      case PlaylistType.userPlaylist:
        return LibItemTypes.userPlaylist;
    }
  }

  static Future<void> _openLibraryItem(
      BuildContext context, PlaylistItemProperties item) async {
    if (item.type == PlaylistType.userPlaylist) {
      context.pushNamed(
        RoutePaths.playlistView,
        extra: item.storageKey,
      );
      return;
    }

    // For remote collections, resolve via the cubit (domain-level, no DB types).
    final playlist = await context
        .read<LibraryItemsCubit>()
        .resolveLibraryItem(item.storageKey);
    if (!context.mounted || playlist == null) return;

    switch (playlist.type) {
      case PlaylistType.artist:
        if (playlist.artists == null || playlist.artists!.isEmpty) return;
        final artist = playlist.artists!.first;
        final pluginId = pluginIdOf(artist.id);
        if (pluginId == null || pluginId.isEmpty) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ArtistView(artist: artist, pluginId: pluginId),
          ),
        );
        return;
      case PlaylistType.album:
        if (playlist.album == null) return;
        final album = playlist.album!;
        final pluginId = pluginIdOf(album.id);
        if (pluginId == null || pluginId.isEmpty) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AlbumView(album: album, pluginId: pluginId),
          ),
        );
        return;
      case PlaylistType.remotePlaylist:
        if (playlist.remotePlaylist == null) return;
        final remote = playlist.remotePlaylist!;
        final pluginId = pluginIdOf(remote.id);
        if (pluginId == null || pluginId.isEmpty) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                OnlPlaylistView(playlist: remote, pluginId: pluginId),
          ),
        );
        return;
      case PlaylistType.userPlaylist:
        return;
    }
  }

  Widget _buildTile(BuildContext context, PlaylistItemProperties playlist) {
    void openMenu() {
      showPlaylistOptsExtSheet(
        context,
        playlist.playlistName,
        playlistId: playlist.playlistId,
        isPinned: playlist.isPinned,
      );
    }

    return LibItemCard(
      onTap: isReorderable ? null : () => _openLibraryItem(context, playlist),
      onSecondaryTap: isReorderable ? null : openMenu,
      onLongPress: isReorderable
          ? null
          : () => onEnterReorder != null ? onEnterReorder!() : openMenu,
      onMenuTap: isReorderable ? null : openMenu,
      showMenuButton: !isReorderable,
      title: playlist.playlistName,
      imageUrls: playlist.imageUrls,
      subtitle: playlist.subTitle ?? '',
      type: _toCardType(playlist.type),
      isPinned: playlist.isPinned,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isReorderable) {
      return SliverList.builder(
        itemCount: playlists.length,
        itemBuilder: (context, index) {
          return AnimatedListItem(
            index: index,
            child: _buildTile(context, playlists[index]),
          );
        },
      );
    }

    return SliverReorderableList(
      itemBuilder: (context, index) {
        return KeyedSubtree(
          key: ValueKey(playlists[index].playlistId),
          child: Stack(
            children: [
              IgnorePointer(
                ignoring: true,
                child: _buildTile(context, playlists[index]),
              ),
              Positioned(
                right: 14,
                top: 0,
                bottom: 0,
                child: Center(
                  child: ReorderableDragStartListener(
                    index: index,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color:
                            Default_Theme.accentColor2.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Default_Theme.accentColor2
                              .withValues(alpha: 0.20),
                        ),
                      ),
                      child: Icon(
                        Icons.drag_handle_rounded,
                        color:
                            Default_Theme.accentColor2.withValues(alpha: 0.90),
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      itemExtent: 80,
      itemCount: playlists.length,
      proxyDecorator: _proxyDecorator,
      onReorder: (oldIndex, newIndex) {
        context.read<LibraryItemsCubit>().reorderLibrary(oldIndex, newIndex);
      },
    );
  }
}

Widget _proxyDecorator(Widget child, int index, Animation<double> animation) {
  return AnimatedBuilder(
    animation: animation,
    builder: (BuildContext context, Widget? child) {
      final double animValue = Curves.easeInOut.transform(animation.value);
      final double elevation = lerpDouble(0, 6, animValue)!;
      return Material(
        elevation: elevation,
        color: Default_Theme.themeColor,
        borderRadius: BorderRadius.circular(12),
        shadowColor: Default_Theme.accentColor2.withValues(alpha: 0.25),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Default_Theme.accentColor2.withValues(alpha: 0.20),
            ),
          ),
          child: child,
        ),
      );
    },
    child: child,
  );
}


// ─── Jam Entry Sheet ─────────────────────────────────────────────────────────

class _JamEntrySheet extends StatefulWidget {
  final BuildContext parentContext;
  const _JamEntrySheet({required this.parentContext});

  @override
  State<_JamEntrySheet> createState() => _JamEntrySheetState();
}

class _JamEntrySheetState extends State<_JamEntrySheet> {
  bool _isLoading = false;
  String? _errorMessage;
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _hostRoom(BuildContext ctx) async {
    if (_isLoading) return;
    developer.log('[LIVE_ROOM] Host button clicked', name: 'LIVE_ROOM');
    debugPrint('[LIVE_ROOM] Host button clicked');
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final parentCtx = widget.parentContext;
      final cubit = parentCtx.read<JamSessionCubit>();
      final success = await cubit.createRoom();

      if (!mounted || !parentCtx.mounted) return;

      if (success) {
        developer.log('[LIVE_ROOM] Navigation started', name: 'LIVE_ROOM');
        debugPrint('[LIVE_ROOM] Navigation started');
        Navigator.pop(ctx);
        parentCtx.pushNamed(RoutePaths.jamRoom);
      } else {
        final errorMsg = cubit.state is JamSessionError
            ? (cubit.state as JamSessionError).message
            : 'Failed to create room. Please try again.';
        developer.log('[LIVE_ROOM][ERROR] Host room failed: $errorMsg', name: 'LIVE_ROOM');
        debugPrint('[LIVE_ROOM][ERROR] Host room failed: $errorMsg');
        setState(() {
          _errorMessage = errorMsg;
        });
        ScaffoldMessenger.maybeOf(parentCtx)?.showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      developer.log('[LIVE_ROOM][ERROR] Host room unhandled exception: $e', name: 'LIVE_ROOM');
      debugPrint('[LIVE_ROOM][ERROR] Host room unhandled exception: $e');
      if (mounted) {
        final msg = 'Error hosting room: $e';
        setState(() {
          _errorMessage = msg;
        });
        final parentCtx = widget.parentContext;
        if (parentCtx.mounted) {
          ScaffoldMessenger.maybeOf(parentCtx)?.showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _joinRoom(BuildContext ctx) async {
    final code = _codeController.text.trim();
    if (code.isEmpty || _isLoading) return;
    developer.log('[LIVE_ROOM] Join button clicked with code: $code', name: 'LIVE_ROOM');
    debugPrint('[LIVE_ROOM] Join button clicked with code: $code');
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final parentCtx = widget.parentContext;
      final cubit = parentCtx.read<JamSessionCubit>();
      final success = await cubit.joinRoom(code);

      if (!mounted || !parentCtx.mounted) return;

      if (success) {
        developer.log('[LIVE_ROOM] Join success - navigation started', name: 'LIVE_ROOM');
        debugPrint('[LIVE_ROOM] Join success - navigation started');
        Navigator.pop(ctx);
        parentCtx.pushNamed(RoutePaths.jamRoom);
      } else {
        final errorMsg = cubit.state is JamSessionError
            ? (cubit.state as JamSessionError).message
            : 'Failed to join room. Check the code and try again.';
        developer.log('[LIVE_ROOM][ERROR] Join room failed: $errorMsg', name: 'LIVE_ROOM');
        debugPrint('[LIVE_ROOM][ERROR] Join room failed: $errorMsg');
        setState(() {
          _errorMessage = errorMsg;
        });
        ScaffoldMessenger.maybeOf(parentCtx)?.showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      developer.log('[LIVE_ROOM][ERROR] Join room unhandled exception: $e', name: 'LIVE_ROOM');
      debugPrint('[LIVE_ROOM][ERROR] Join room unhandled exception: $e');
      if (mounted) {
        final msg = 'Error joining room: $e';
        setState(() {
          _errorMessage = msg;
        });
        final parentCtx = widget.parentContext;
        if (parentCtx.mounted) {
          ScaffoldMessenger.maybeOf(parentCtx)?.showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          color: const Color(0xFF0A0A1E).withValues(alpha: 0.97),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
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
              const SizedBox(height: 24),
              const Text(
                '🎧 Live Room',
                style: TextStyle(
                  fontFamily: 'Fjalla',
                  fontSize: 24,
                  color: Default_Theme.primaryColor1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Listen to music live with your friends',
                style: TextStyle(
                  color: Default_Theme.primaryColor1.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 28),
              if (_errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
              // Host room button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.successAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _isLoading ? null : () => _hostRoom(context),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        )
                      : const Icon(MingCute.headphone_fill,
                          color: Colors.black, size: 20),
                  label: Text(
                    _isLoading ? 'Creating Room...' : 'Host a Live Room',
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Divider
              Row(
                children: [
                  Expanded(
                      child: Divider(
                          color: Colors.white.withValues(alpha: 0.1))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'or join with a code',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.35),
                          fontSize: 12),
                    ),
                  ),
                  Expanded(
                      child: Divider(
                          color: Colors.white.withValues(alpha: 0.1))),
                ],
              ),
              const SizedBox(height: 16),
              // Code input
              TextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(
                  color: Default_Theme.primaryColor1,
                  fontFamily: 'CodePro',
                  fontSize: 20,
                  letterSpacing: 4,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'ROOM CODE',
                  hintStyle: TextStyle(
                    color: Default_Theme.primaryColor1.withValues(alpha: 0.25),
                    fontFamily: 'CodePro',
                    letterSpacing: 4,
                    fontSize: 18,
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: AppTheme.successAccent.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _isLoading ? null : () => _joinRoom(context),
                  child: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(AppTheme.successAccent),
                          ),
                        )
                      : const Text(
                          'Join Room',
                          style: TextStyle(
                              color: AppTheme.successAccent,
                              fontWeight: FontWeight.w700,
                              fontSize: 15),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
