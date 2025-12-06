import 'dart:async';
import 'dart:developer';
import 'package:beats_music/blocs/mediaPlayer/beats_player_cubit.dart';
import 'package:beats_music/blocs/internet_connectivity/cubit/connectivity_cubit.dart';
import 'package:beats_music/blocs/search/fetch_search_results.dart';
import 'package:beats_music/blocs/search_suggestions/search_suggestion_bloc.dart';
import 'package:beats_music/model/source_engines.dart';
import 'package:beats_music/routes_and_consts/global_str_consts.dart';
import 'package:beats_music/screens/screen/search_views/search_page.dart';
import 'package:beats_music/screens/widgets/album_card.dart';
import 'package:beats_music/screens/widgets/artist_card.dart';
import 'package:beats_music/screens/widgets/genre_card.dart';
import 'package:beats_music/screens/widgets/more_bottom_sheet.dart';
import 'package:beats_music/screens/widgets/playlist_card.dart';
import 'package:beats_music/screens/widgets/sign_board_widget.dart';
import 'package:beats_music/screens/widgets/song_tile.dart';
import 'package:beats_music/services/db/beats_music_db_service.dart';
import 'package:beats_music/theme_data/default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';

class SearchScreen extends StatefulWidget {
  final String searchQuery;
  const SearchScreen({
    Key? key,
    this.searchQuery = "",
  }) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late List<SourceEngine> availSourceEngines;
  late SourceEngine _sourceEngine;
  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<ResultTypes> resultType =
      ValueNotifier(ResultTypes.songs);
  bool _isSearching = false;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.removeListener(loadMoreResults);
    _scrollController.dispose();
    _textEditingController.dispose();
    resultType.dispose();
    super.dispose();
  }

  void loadMoreResults() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        _sourceEngine == SourceEngine.eng_JIS &&
        context.read<FetchSearchResultsCubit>().state.hasReachedMax == false) {
      context
          .read<FetchSearchResultsCubit>()
          .searchJISTracks(_textEditingController.text, loadMore: true);
    }
  }

  @override
  void initState() {
    super.initState();
    availSourceEngines = SourceEngine.values;
    
    // Load default search engine from settings
    _loadDefaultSearchEngine();

    setState(() {
      availableSourceEngines().then((value) {
        availSourceEngines = value;
      });
    });
    _scrollController.addListener(loadMoreResults);
    
    // Load search history
    context.read<SearchSuggestionBloc>().add(SearchSuggestionFetch(''));
    
    if (widget.searchQuery != "") {
      _textEditingController.text = widget.searchQuery;
      _isSearching = true;
      context.read<FetchSearchResultsCubit>().search(
            widget.searchQuery.toString(),
            sourceEngine: _sourceEngine,
            resultType: resultType.value,
          );
    }
  }

  void _performSearch(String query) {
    if (query.isNotEmpty) {
      setState(() {
        _isSearching = true;
      });
      context.read<FetchSearchResultsCubit>().search(
            query,
            sourceEngine: _sourceEngine,
            resultType: resultType.value,
          );
    }
  }

  Widget _buildGenreGrid() {
    final genres = [
      {'name': 'Pop', 'colors': [const Color(0xFFAB47BC), const Color(0xFF8E24AA)]},
      {'name': 'Hip-Hop', 'colors': [const Color(0xFFE53935), const Color(0xFFD32F2F)]},
      {'name': 'Rock', 'colors': [const Color(0xFFFF9800), const Color(0xFFF57C00)]},
      {'name': 'Electronic', 'colors': [const Color(0xFF1E88E5), const Color(0xFF1565C0)]},
      {'name': 'Indie', 'colors': [const Color(0xFF43A047), const Color(0xFF388E3C)]},
      {'name': 'R&B', 'colors': [const Color(0xFF00897B), const Color(0xFF00695C)]},
      {'name': 'K-Pop', 'colors': [const Color(0xFFEC407A), const Color(0xFFD81B60)]},
      {'name': 'Country', 'colors': [const Color(0xFF5E35B1), const Color(0xFF4527A0)]},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.6,
      ),
      itemCount: genres.length,
      itemBuilder: (context, index) {
        final genre = genres[index];
        return GenreCard(
          genreName: genre['name'] as String,
          gradientColors: genre['colors'] as List<Color>,
          onTap: () {
            _textEditingController.text = genre['name'] as String;
            _performSearch(genre['name'] as String);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: Default_Theme.themeColor,
          body: CustomScrollView(
            slivers: [
              // Search Header
              SliverAppBar(
                floating: false,
                pinned: true,
                expandedHeight: 120,
                backgroundColor: Default_Theme.themeColor,
                surfaceTintColor: Default_Theme.themeColor,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  title: const Text(
                    "Search",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Default_Theme.primaryColor1,
                    ),
                  ),
                ),
              ),
              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Default_Theme.primaryColor2.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Icon(
                            MingCute.search_2_line,
                            color: Default_Theme.primaryColor1,
                            size: 24,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _textEditingController,
                            style: const TextStyle(
                              color: Default_Theme.primaryColor1,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              hintText: "What do you want to listen to?",
                              hintStyle: TextStyle(
                                color: Default_Theme.primaryColor1.withOpacity(0.5),
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onSubmitted: (value) {
                              if (value.isNotEmpty) {
                                _performSearch(value);
                              }
                            },
                            onChanged: (value) {
                              // Cancel previous timer
                              if (_debounce?.isActive ?? false) {
                                _debounce!.cancel();
                              }
                              
                              setState(() {});
                              
                              // Start new timer for debounced search
                              if (value.isNotEmpty) {
                                _debounce = Timer(const Duration(milliseconds: 300), () {
                                  _performSearch(value);
                                });
                              } else {
                                // Clear search if text is empty
                                setState(() {
                                  _isSearching = false;
                                });
                              }
                            },
                          ),
                        ),
                        if (_textEditingController.text.isNotEmpty)
                          IconButton(
                            icon: Icon(
                              MingCute.close_fill,
                              color: Default_Theme.primaryColor1.withOpacity(0.7),
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _textEditingController.clear();
                                _isSearching = false;
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              // Source Engine Selector
              SliverToBoxAdapter(
                child: FutureBuilder<List<Widget>>(
                  future: _buildVisibleSourceChips(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: snapshot.data!,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _isSearching
                      ? BlocBuilder<FetchSearchResultsCubit, FetchSearchResultsState>(
                          builder: (context, state) {
                            if (state is FetchSearchResultsLoading) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(40),
                                  child: CircularProgressIndicator(
                                    color: Default_Theme.accentColor2,
                                  ),
                                ),
                              );
                            } else if (state.loadingState == LoadingState.loaded) {
                              if (state.resultType == ResultTypes.songs &&
                                  state.mediaItems.isNotEmpty) {
                                return Column(
                                  children: [
                                    for (var item in state.mediaItems)
                                      SongCardWidget(
                                        song: item,
                                        onTap: () {
                                          // Add all search results to queue, starting from clicked song
                                          final clickedIndex = state.mediaItems.indexOf(item);
                                          final queueList = [
                                            ...state.mediaItems.sublist(clickedIndex),
                                            ...state.mediaItems.sublist(0, clickedIndex),
                                          ];
                                          context
                                              .read<BeatsPlayerCubit>()
                                              .beatsMusicPlayer
                                              .updateQueue(queueList, doPlay: true);
                                        },
                                        onOptionsTap: () => showMoreBottomSheet(context, item),
                                      ),
                                  ],
                                );
                              } else {
                                return const Padding(
                                  padding: EdgeInsets.all(40),
                                  child: SignBoardWidget(
                                    message: "No results found!",
                                    icon: MingCute.sweats_line,
                                  ),
                                );
                              }
                            } else {
                              return _buildSearchHistory();
                            }
                          },
                        )
                      : _buildSearchHistory(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHistory() {
    return BlocBuilder<SearchSuggestionBloc, SearchSuggestionState>(
      builder: (context, state) {
        if (state is SearchSuggestionLoaded && state.dbSuggestionList.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recent Searches",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Default_Theme.primaryColor1,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Clear all logic - assuming the bloc supports clearing all or we loop through
                      // Ideally, the bloc should have a ClearAll event.
                      // For now, we'll clear them one by one or if bloc supports it.
                      // Checking SearchSuggestionBloc... assuming we need to implement or use existing.
                      // If no clear all event, we might need to add it or just clear visible ones.
                      // Let's assume we can iterate and clear for now, or better, add a ClearAll event if possible.
                      // Since I can't see the bloc code fully, I'll try to clear visible ones.
                      for (var e in state.dbSuggestionList) {
                         context.read<SearchSuggestionBloc>().add(
                                SearchSuggestionClear(e.values.first));
                      }
                    },
                    child: Text(
                      "Clear All",
                      style: TextStyle(
                        color: Default_Theme.primaryColor1.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: state.dbSuggestionList
                    .map(
                      (e) => ListTile(
                        title: Text(
                          e.values.first,
                          style: const TextStyle(
                            color: Default_Theme.primaryColor1,
                          ).merge(Default_Theme.secondoryTextStyle),
                        ),
                        contentPadding: const EdgeInsets.only(left: 0, right: 8),
                        leading: Icon(
                          MingCute.history_line,
                          size: 22,
                          color: Default_Theme.primaryColor1.withOpacity(0.5),
                        ),
                        trailing: IconButton(
                          onPressed: () {
                            context.read<SearchSuggestionBloc>().add(
                                SearchSuggestionClear(e.values.first));
                          },
                          icon: Icon(
                            MingCute.close_fill,
                            color: Default_Theme.primaryColor1.withOpacity(0.5),
                            size: 22,
                          ),
                        ),
                        onTap: () {
                          _textEditingController.text = e.values.first;
                          _performSearch(e.values.first);
                        },
                      ),
                    )
                    .toList(),
              ),
            ],
          );
        } else {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: SignBoardWidget(
                message: "Start searching for your favorite music!",
                icon: MingCute.search_2_line,
              ),
            ),
          );
        }
      },
    );
  }

  Future<void> _loadDefaultSearchEngine() async {
    final defaultEngine = await BeatsMusicDBService.getSettingStr(
        GlobalStrConsts.defaultSearchEngine);
    
    if (defaultEngine != null) {
      switch (defaultEngine) {
        case 'YTMusic':
          _sourceEngine = SourceEngine.eng_YTM;
          break;
        case 'YouTube':
          _sourceEngine = SourceEngine.eng_YTV;
          break;
        case 'JioSaavn':
          _sourceEngine = SourceEngine.eng_JIS;
          break;
        case 'Spotify':
          _sourceEngine = SourceEngine.eng_Spotify;
          break;
        default:
          _sourceEngine = SourceEngine.eng_YTV; // Default to YouTube
      }
    } else {
      _sourceEngine = SourceEngine.eng_YTV; // Default to YouTube
    }
    setState(() {});
  }

  Future<List<Widget>> _buildVisibleSourceChips() async {
    List<Widget> chips = [];
    
    // Check visibility settings for each source
    final showYTMusic = await BeatsMusicDBService.getSettingBool(
        GlobalStrConsts.showYTMusicSearch) ?? true;
    final showYTVideo = await BeatsMusicDBService.getSettingBool(
        GlobalStrConsts.showYTVideoSearch) ?? true;
    final showJioSaavn = await BeatsMusicDBService.getSettingBool(
        GlobalStrConsts.showJioSaavnSearch) ?? true;
    final showSpotify = await BeatsMusicDBService.getSettingBool(
        GlobalStrConsts.showSpotifySearch) ?? true;
    
    if (showYTMusic) {
      chips.add(_buildSourceChip('YouTube Music', SourceEngine.eng_YTM));
      chips.add(const SizedBox(width: 8));
    }
    if (showYTVideo) {
      chips.add(_buildSourceChip('YouTube', SourceEngine.eng_YTV));
      chips.add(const SizedBox(width: 8));
    }
    if (showJioSaavn) {
      chips.add(_buildSourceChip('JioSaavn', SourceEngine.eng_JIS));
      chips.add(const SizedBox(width: 8));
    }
    if (showSpotify) {
      chips.add(_buildSourceChip('Spotify', SourceEngine.eng_Spotify));
      chips.add(const SizedBox(width: 8));
    }
    
    // Remove trailing SizedBox
    if (chips.isNotEmpty && chips.last is SizedBox) {
      chips.removeLast();
    }
    
    return chips;
  }

  Widget _buildSourceChip(String label, SourceEngine engine) {
    final isSelected = _sourceEngine == engine;
    return GestureDetector(
      onTap: () {
        if (engine == SourceEngine.eng_Spotify && _sourceEngine != SourceEngine.eng_Spotify) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Spotify search may have delays and incorrect matches",
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red.withOpacity(0.8),
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
        
        setState(() {
          _sourceEngine = engine;
        });
        // Re-search with new engine if there's an active search
        if (_textEditingController.text.isNotEmpty) {
          _performSearch(_textEditingController.text);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Default_Theme.accentColor2
              : Default_Theme.primaryColor2.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Default_Theme.accentColor2
                : Default_Theme.primaryColor2.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Default_Theme.themeColor
                : Default_Theme.primaryColor1,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
