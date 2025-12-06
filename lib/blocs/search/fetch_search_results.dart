// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'package:beats_music/model/playlist_onl_model.dart';
import 'package:beats_music/model/spotifyModel.dart';
import 'package:beats_music/repository/Spotify/aswin_sparky_api.dart';
import 'package:beats_music/repository/Youtube/ytm/ytmusic.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:beats_music/model/album_onl_model.dart';
import 'package:beats_music/model/artist_onl_model.dart';
import 'package:beats_music/model/saavnModel.dart';
import 'package:beats_music/model/songModel.dart';
import 'package:beats_music/model/source_engines.dart';
import 'package:beats_music/model/youtube_vid_model.dart';
import 'package:beats_music/model/yt_music_model.dart';
import 'package:beats_music/repository/Saavn/saavn_api.dart';
import 'package:beats_music/repository/Youtube/youtube_api.dart';

enum LoadingState { initial, loading, loaded, noInternet }

enum ResultTypes {
  // all(val: 'All'),
  songs(val: 'Songs'),
  playlists(val: 'Playlists'),
  albums(val: 'Albums'),
  artists(val: 'Artists');

  final String val;
  const ResultTypes({required this.val});
}

class LastSearch {
  String query;
  int page = 1;
  final SourceEngine sourceEngine;
  bool hasReachedMax = false;
  List<MediaItemModel> mediaItemList = List.empty(growable: true);
  LastSearch({required this.query, required this.sourceEngine});
}

class FetchSearchResultsState extends Equatable {
  final LoadingState loadingState;
  final List<MediaItemModel> mediaItems;
  final List<AlbumModel> albumItems;
  final List<PlaylistOnlModel> playlistItems;
  final List<ArtistModel> artistItems;
  final SourceEngine? sourceEngine;
  final ResultTypes resultType;
  final bool hasReachedMax;
  const FetchSearchResultsState({
    required this.loadingState,
    required this.mediaItems,
    required this.albumItems,
    required this.artistItems,
    required this.playlistItems,
    required this.hasReachedMax,
    required this.resultType,
    this.sourceEngine,
  });

  @override
  List<Object?> get props => [
        loadingState,
        mediaItems,
        hasReachedMax,
        albumItems,
        artistItems,
        playlistItems,
        sourceEngine,
        resultType,
      ];

  FetchSearchResultsState copyWith({
    LoadingState? loadingState,
    List<MediaItemModel>? mediaItems,
    List<AlbumModel>? albumItems,
    List<PlaylistOnlModel>? playlistItems,
    List<ArtistModel>? artistItems,
    ResultTypes? resultType,
    SourceEngine? sourceEngine,
    bool? hasReachedMax,
  }) {
    return FetchSearchResultsState(
      loadingState: loadingState ?? this.loadingState,
      mediaItems: mediaItems ?? this.mediaItems,
      albumItems: albumItems ?? this.albumItems,
      playlistItems: playlistItems ?? this.playlistItems,
      artistItems: artistItems ?? this.artistItems,
      resultType: resultType ?? this.resultType,
      sourceEngine: sourceEngine ?? this.sourceEngine,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

final class FetchSearchResultsInitial extends FetchSearchResultsState {
  FetchSearchResultsInitial()
      : super(
          mediaItems: [],
          loadingState: LoadingState.initial,
          hasReachedMax: false,
          albumItems: [],
          artistItems: [],
          playlistItems: [],
          resultType: ResultTypes.songs,
        );
}

final class FetchSearchResultsLoading extends FetchSearchResultsState {
  final ResultTypes resultType;
  FetchSearchResultsLoading({
    this.resultType = ResultTypes.songs,
  }) : super(
          mediaItems: [],
          loadingState: LoadingState.loading,
          hasReachedMax: false,
          albumItems: [],
          artistItems: [],
          playlistItems: [],
          resultType: resultType,
        );
}

final class FetchSearchResultsLoaded extends FetchSearchResultsState {
  final ResultTypes resultType;
  FetchSearchResultsLoaded({
    this.resultType = ResultTypes.songs,
  }) : super(
          mediaItems: [],
          loadingState: LoadingState.loaded,
          hasReachedMax: false,
          albumItems: [],
          artistItems: [],
          playlistItems: [],
          resultType: resultType,
        );
}
//------------------------------------------------------------------------

class FetchSearchResultsCubit extends Cubit<FetchSearchResultsState> {
  FetchSearchResultsCubit() : super(FetchSearchResultsInitial()) {
    YTMusic();
  }

  LastSearch last_YTM_search =
      LastSearch(query: "", sourceEngine: SourceEngine.eng_YTM);
  LastSearch last_YTV_search =
      LastSearch(query: "", sourceEngine: SourceEngine.eng_YTV);
  LastSearch last_JIS_search =
      LastSearch(query: "", sourceEngine: SourceEngine.eng_JIS);
  LastSearch last_Spotify_search =
      LastSearch(query: "", sourceEngine: SourceEngine.eng_Spotify);

  List<MediaItemModel> _mediaItemList = List.empty(growable: true);

  // check if the search is already loaded and if not then load it (when resultType or sourceEngine is changed)
  Future<void> checkAndRefreshSearch(
      {required String query,
      required SourceEngine sE,
      required ResultTypes rT}) async {
    if ((state.sourceEngine != sE || state.resultType != rT) &&
        state is! FetchSearchResultsLoading &&
        query.isNotEmpty) {
      log("Refreshing Search", name: "FetchSearchRes");
      search(query, sourceEngine: sE, resultType: rT);
    }
  }

  Future<void> searchYTMTracks(
    String query, {
    ResultTypes resultType = ResultTypes.songs,
  }) async {
    log("Youtube Music Search", name: "FetchSearchRes");

    last_YTM_search.query = query;
    emit(FetchSearchResultsLoading(resultType: resultType));
    switch (resultType) {
      case ResultTypes.songs:
        final searchResults = await YTMusic().searchYtm(query, type: "songs");
        if (searchResults == null) {
          emit(state.copyWith(
            mediaItems: [],
            loadingState: LoadingState.loaded,
            hasReachedMax: true,
            resultType: ResultTypes.songs,
            sourceEngine: SourceEngine.eng_YTM,
          ));
          return;
        } else {
          last_YTM_search.mediaItemList =
              ytmMapList2MediaItemList(searchResults['songs']);
          emit(state.copyWith(
            mediaItems:
                List<MediaItemModel>.from(last_YTM_search.mediaItemList),
            loadingState: LoadingState.loaded,
            hasReachedMax: true,
            resultType: ResultTypes.songs,
            sourceEngine: SourceEngine.eng_YTM,
          ));
        }
        break;
      case ResultTypes.playlists:
        final res = await YTMusic().searchYtm(query, type: "playlists");
        if (res == null) {
          emit(state.copyWith(
            playlistItems: [],
            loadingState: LoadingState.loaded,
            hasReachedMax: true,
            resultType: ResultTypes.playlists,
            sourceEngine: SourceEngine.eng_YTM,
          ));
          return;
        }
        final playlist = ytmMap2Playlists(res['playlists']);
        emit(state.copyWith(
          playlistItems: List<PlaylistOnlModel>.from(playlist),
          loadingState: LoadingState.loaded,
          hasReachedMax: true,
          resultType: ResultTypes.playlists,
          sourceEngine: SourceEngine.eng_YTM,
        ));
        log("Got results: ${playlist.length}", name: "FetchSearchRes");
        break;
      case ResultTypes.albums:
        final res = await YTMusic().searchYtm(query, type: "albums");
        if (res == null) {
          emit(state.copyWith(
            albumItems: [],
            loadingState: LoadingState.loaded,
            hasReachedMax: true,
            resultType: ResultTypes.albums,
            sourceEngine: SourceEngine.eng_YTM,
          ));
          return;
        }
        final albums = ytmMap2Albums(res['albums']);
        emit(state.copyWith(
          albumItems: List<AlbumModel>.from(albums),
          loadingState: LoadingState.loaded,
          hasReachedMax: true,
          resultType: ResultTypes.albums,
          sourceEngine: SourceEngine.eng_YTM,
        ));
        log("Got results: ${albums.length}", name: "FetchSearchRes");
        break;
      case ResultTypes.artists:
        final res = await YTMusic().searchYtm(query, type: "artists");
        if (res == null) {
          emit(state.copyWith(
            artistItems: [],
            loadingState: LoadingState.loaded,
            hasReachedMax: true,
            resultType: ResultTypes.artists,
            sourceEngine: SourceEngine.eng_YTM,
          ));
          return;
        }
        final artists = ytmMap2Artists(res['artists']);
        emit(state.copyWith(
          artistItems: List<ArtistModel>.from(artists),
          loadingState: LoadingState.loaded,
          hasReachedMax: true,
          resultType: ResultTypes.artists,
          sourceEngine: SourceEngine.eng_YTM,
        ));
        log("Got results: ${artists.length}", name: "FetchSearchRes");
        break;
    }

    log("got all searches ${last_YTM_search.mediaItemList.length}",
        name: "FetchSearchRes");
  }

  Future<void> searchYTVTracks(String query,
      {ResultTypes resultType = ResultTypes.songs}) async {
    log("Youtube Video Search", name: "FetchSearchRes");

    last_YTV_search.query = query;
    emit(FetchSearchResultsLoading(resultType: resultType));

    switch (resultType) {
      case ResultTypes.playlists:
        final res =
            await YouTubeServices().fetchSearchResults(query, playlist: true);
        final List<PlaylistOnlModel> playlists = ytvMap2Playlists({
          'playlists': res[0]['items'],
        });
        emit(state.copyWith(
          playlistItems: List<PlaylistOnlModel>.from(playlists),
          resultType: ResultTypes.playlists,
          hasReachedMax: true,
          loadingState: LoadingState.loaded,
          sourceEngine: SourceEngine.eng_YTV,
        ));
        break;
      case ResultTypes.albums:
      case ResultTypes.artists:
      case ResultTypes.songs:
        final searchResults = await YouTubeServices().fetchSearchResults(query);
        last_YTV_search.mediaItemList =
            (fromYtVidSongMapList2MediaItemList(searchResults[0]['items']));
        emit(state.copyWith(
          mediaItems: List<MediaItemModel>.from(last_YTV_search.mediaItemList),
          loadingState: LoadingState.loaded,
          resultType: ResultTypes.songs,
          hasReachedMax: true,
          sourceEngine: SourceEngine.eng_YTV,
        ));
        log("got all searches ${last_YTV_search.mediaItemList.length}",
            name: "FetchSearchRes");
        break;
    }
  }

  Future<void> searchJISTracks(
    String query, {
    bool loadMore = false,
    ResultTypes resultType = ResultTypes.songs,
  }) async {
    switch (resultType) {
      case ResultTypes.songs:
        if (!loadMore) {
          emit(FetchSearchResultsLoading(resultType: resultType));
          last_JIS_search.query = query;
          last_JIS_search.mediaItemList.clear();
          last_JIS_search.hasReachedMax = false;
          last_JIS_search.page = 1;
        }
        log("JIOSaavn Search", name: "FetchSearchRes");
        final searchResults = await SaavnAPI().fetchSongSearchResults(
            searchQuery: query, page: last_JIS_search.page);
        last_JIS_search.page++;
        _mediaItemList =
            fromSaavnSongMapList2MediaItemList(searchResults['songs']);
        if (_mediaItemList.length < 20) {
          last_JIS_search.hasReachedMax = true;
        }
        last_JIS_search.mediaItemList.addAll(_mediaItemList);

        emit(state.copyWith(
          mediaItems: List<MediaItemModel>.from(last_JIS_search.mediaItemList),
          loadingState: LoadingState.loaded,
          hasReachedMax: last_JIS_search.hasReachedMax,
          resultType: ResultTypes.songs,
          sourceEngine: SourceEngine.eng_JIS,
        ));

        log("got all searches ${last_JIS_search.mediaItemList.length}",
            name: "FetchSearchRes");
        break;
      case ResultTypes.albums:
        emit(FetchSearchResultsLoading(resultType: resultType));
        final res = await SaavnAPI().fetchAlbumResults(query);
        final albumList = saavnMap2Albums({'Albums': res});
        log("Got results: ${albumList.length}", name: "FetchSearchRes");
        emit(state.copyWith(
          albumItems: List<AlbumModel>.from(albumList),
          loadingState: LoadingState.loaded,
          hasReachedMax: true,
          resultType: ResultTypes.albums,
          sourceEngine: SourceEngine.eng_JIS,
        ));
        break;
      case ResultTypes.playlists:
        emit(FetchSearchResultsLoading(resultType: resultType));
        final res = await SaavnAPI().fetchPlaylistResults(query);
        final playlistList = saavnMap2Playlists({'Playlists': res});
        log("Got results: ${playlistList.length}", name: "FetchSearchRes");
        emit(state.copyWith(
          playlistItems: List<PlaylistOnlModel>.from(playlistList),
          loadingState: LoadingState.loaded,
          hasReachedMax: true,
          resultType: ResultTypes.playlists,
          sourceEngine: SourceEngine.eng_JIS,
        ));
        break;
      case ResultTypes.artists:
        emit(FetchSearchResultsLoading(resultType: resultType));
        final res = await SaavnAPI().fetchArtistResults(query);
        final artistList = saavnMap2Artists({'Artists': res});
        log("Got results: ${artistList.length}", name: "FetchSearchRes");
        emit(state.copyWith(
          artistItems: List<ArtistModel>.from(artistList),
          loadingState: LoadingState.loaded,
          hasReachedMax: true,
          resultType: ResultTypes.artists,
          sourceEngine: SourceEngine.eng_JIS,
        ));
        break;
    }
  }

  Future<void> searchSpotifyTracks(
    String query, {
    ResultTypes resultType = ResultTypes.songs,
  }) async {
    log("Spotify Search", name: "FetchSearchRes");
    
    last_Spotify_search.query = query;
    emit(FetchSearchResultsLoading(resultType: resultType));
    
    // Check if query is a Spotify URL
    if (query.contains('open.spotify.com/track/')) {
      try {
        final track = await AswinSparkyAPI().getTrackFromUrl(query);
        
        if (track != null) {
          final mediaItem = fromSpotifyAswinMap2MediaItem(track, spotifyUrl: query);
          last_Spotify_search.mediaItemList = [mediaItem];
          
          emit(state.copyWith(
            mediaItems: [mediaItem],
            loadingState: LoadingState.loaded,
            hasReachedMax: true,
            resultType: ResultTypes.songs,
            sourceEngine: SourceEngine.eng_Spotify,
          ));
        } else {
          emit(state.copyWith(
            mediaItems: [],
            loadingState: LoadingState.loaded,
            hasReachedMax: true,
            resultType: ResultTypes.songs,
            sourceEngine: SourceEngine.eng_Spotify,
          ));
        }
      } catch (e) {
        log("Error fetching Spotify track: $e", name: "FetchSearchRes");
        emit(state.copyWith(
          mediaItems: [],
          loadingState: LoadingState.loaded,
          hasReachedMax: true,
          resultType: ResultTypes.songs,
          sourceEngine: SourceEngine.eng_Spotify,
        ));
      }
    } else {
      // Search Spotify by query using Aswin Sparky API
      try {
        final searchResults = await AswinSparkyAPI().searchSpotify(query);
        
        if (searchResults.isNotEmpty) {
          // Convert search results directly to MediaItems
          // Don't fetch download URLs yet - they'll be fetched in background
          List<MediaItemModel> mediaItems = [];
          
          for (var result in searchResults.take(10)) { // Limit to 10 results
            try {
              // Use search result data directly
              final title = result['name'] ?? result['title'] ?? 'Unknown Title';
              
              // Extract artist - API returns it as a string already (e.g., "ARJN, KDS, FIFTY4, RONN")
              final artist = result['artists'] ?? result['artist'] ?? 'Unknown Artist';
              
              final spotifyLink = result['link'] ?? '';
              
              // Search API doesn't provide image, duration, or album
              // We'll fetch these from the track details API in background
              
              // Create track ID from Spotify link
              String trackId = 'spotify_${title}_${artist}'
                  .replaceAll(' ', '_')
                  .replaceAll(RegExp(r'[^\w_]'), '');
              
              final mediaItem = MediaItemModel(
                id: trackId,
                title: title,
                artist: artist,
                album: artist, // Use artist as album for search results
                artUri: Uri.parse(''), // Will be fetched from track details
                duration: Duration.zero, // Will be fetched from track details
                genre: 'Spotify',
                extras: {
                  'url': '', // Will be fetched in background
                  'spotify_link': spotifyLink, // Store Spotify link for later
                  'language': 'Spotify',
                  'has_lyrics': 'false',
                  '320kbps': 'true',
                  'perma_url': spotifyLink,
                  'subtitle': artist,
                  'source': 'spotify_aswin',
                  'year': '',
                  'release_date': '',
                  'needs_url_fetch': 'true', // Flag to fetch URL before playing
                  'needs_metadata_fetch': 'true', // Flag to fetch image and duration
                },
              );
              
              mediaItems.add(mediaItem);
            } catch (e) {
              log("Error parsing Spotify search result: $e", name: "FetchSearchRes");
            }
          }
          
          last_Spotify_search.mediaItemList = mediaItems;
          
          emit(state.copyWith(
            mediaItems: List<MediaItemModel>.from(mediaItems),
            loadingState: LoadingState.loaded,
            hasReachedMax: true,
            resultType: ResultTypes.songs,
            sourceEngine: SourceEngine.eng_Spotify,
          ));
          
          log("Got ${mediaItems.length} Spotify results, preloading metadata in background...", name: "FetchSearchRes");
          
          // Preload download URLs and metadata (image, duration) in background (don't await)
          _preloadSpotifyUrls(mediaItems);
        } else {
          log("No Spotify results found for query: $query", name: "FetchSearchRes");
          emit(state.copyWith(
            mediaItems: [],
            loadingState: LoadingState.loaded,
            hasReachedMax: true,
            resultType: ResultTypes.songs,
            sourceEngine: SourceEngine.eng_Spotify,
          ));
        }
      } catch (e) {
        log("Error searching Spotify: $e", name: "FetchSearchRes");
        emit(state.copyWith(
          mediaItems: [],
          loadingState: LoadingState.loaded,
          hasReachedMax: true,
          resultType: ResultTypes.songs,
          sourceEngine: SourceEngine.eng_Spotify,
        ));
      }
    }
  }

  /// Preload Spotify download URLs and metadata in background
  Future<void> _preloadSpotifyUrls(List<MediaItemModel> mediaItems) async {
    // Process all items in parallel using Future.wait to avoid simplified sequential blocking
    // We update UI individually as they complete to give fast feedback
    
    // Create a list of futures, but we don't necessarily need to wait for all of them 
    // to finish before returning. However, we want to start them all at once.
    mediaItems.map((mediaItem) => _fetchSingleItemMetadata(mediaItem, mediaItems)).toList();
    
    log("Started parallel preload for ${mediaItems.length} Spotify tracks", name: "FetchSearchRes");
  }



  /// Helper to fetch metadata for a single item and update state
  Future<void> _fetchSingleItemMetadata(MediaItemModel mediaItem, List<MediaItemModel> allItems) async {
      try {
        final spotifyLink = mediaItem.extras?['spotify_link'];
        if (spotifyLink != null && spotifyLink.isNotEmpty) {
          
          // FAST PATH: Try to scrape the album image directly from the Spotify page first
          // This creates an immediate visual update while the heavy downloader runs
          if (!isClosed) {
             _fetchSpotifyImage(spotifyLink).then((imageUrl) {
               if (imageUrl != null && imageUrl.isNotEmpty && !isClosed) {
                 mediaItem.artUri = Uri.parse(imageUrl);
                 log("Fast-fetched image for: ${mediaItem.title}", name: "FetchSearchRes");
                 emiitState(allItems);
               }
             });
          }

          // SLOW PATH: Fetch download URL and full metadata (image, duration, album)
          final trackData = await AswinSparkyAPI().getTrackFromUrl(spotifyLink);
          
          if (trackData != null && !isClosed) {
            bool updated = false;
            
            // Update the mediaItem's extras with the download URL
            if (trackData['download'] != null) {
              mediaItem.extras?['url'] = trackData['download'];
              mediaItem.extras?['needs_url_fetch'] = 'false'; // Mark as preloaded
              updated = true;
            }
            
            // Update metadata (image, duration, album)
            if (trackData['cover'] != null) {
              // Only update if different or empty
              final newUri = Uri.parse(trackData['cover']);
              if (mediaItem.artUri != newUri) {
                mediaItem.artUri = newUri;
                updated = true;
              }
            }
            if (trackData['duration'] != null) {
              mediaItem.duration = Duration(seconds: int.tryParse(trackData['duration'].toString()) ?? 0);
              updated = true;
            }
            if (trackData['album'] != null) {
              mediaItem.album = trackData['album'];
              updated = true;
            }
            
            mediaItem.extras?['needs_metadata_fetch'] = 'false'; // Mark as preloaded
            
            if (updated) {
               log("Fully preloaded metadata for: ${mediaItem.title}", name: "FetchSearchRes");
               emiitState(allItems);
            }
          }
        }
      } catch (e) {
        log("Error preloading metadata for ${mediaItem.title}: $e", name: "FetchSearchRes");
      }
  }

  /// Helper for safe state emission
  void emiitState(List<MediaItemModel> allItems) {
     if (!isClosed) {
       emit(state.copyWith(
         mediaItems: List<MediaItemModel>.from(allItems),
       ));
     }
  }

  /// Quickly scrape the og:image from a Spotify URL
  Future<String?> _fetchSpotifyImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Regex to find <meta property="og:image" content="...">
        final RegExp exp = RegExp(r'<meta property="og:image" content="([^"]+)"');
        final match = exp.firstMatch(response.body);
        if (match != null) {
          return match.group(1);
        }
      }
    } catch (e) {
      // Ignore errors in fast path
    }
    return null;
  }

  Future<void> search(String query,
      {SourceEngine sourceEngine = SourceEngine.eng_YTM,
      ResultTypes resultType = ResultTypes.songs}) async {
    switch (sourceEngine) {
      case SourceEngine.eng_YTM:
        searchYTMTracks(query, resultType: resultType);
        break;
      case SourceEngine.eng_YTV:
        searchYTVTracks(query, resultType: resultType);
        break;
      case SourceEngine.eng_JIS:
        searchJISTracks(query, resultType: resultType);
        break;
      case SourceEngine.eng_Spotify:
        searchSpotifyTracks(query, resultType: resultType);
        break;
      default:
        log("Invalid Source Engine", name: "FetchSearchRes");
        searchYTMTracks(query);
    }
  }

  void clearSearch() {
    emit(FetchSearchResultsInitial());
  }
}
