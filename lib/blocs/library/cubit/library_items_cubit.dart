// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:developer';
import 'package:beats_music/model/MediaPlaylistModel.dart';
import 'package:beats_music/model/album_onl_model.dart';
import 'package:beats_music/model/artist_onl_model.dart';
import 'package:beats_music/model/playlist_onl_model.dart';
import 'package:equatable/equatable.dart';
import 'package:beats_music/model/songModel.dart';
import 'package:beats_music/screens/widgets/snackbar.dart';
import 'package:beats_music/services/db/GlobalDB.dart';
import 'package:beats_music/services/db/beats_music_db_service.dart';
import 'package:beats_music/services/db/cubit/beats_music_db_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'library_items_state.dart';

class LibraryItemsCubit extends Cubit<LibraryItemsState> {
  StreamSubscription? playlistWatcherDB;
  StreamSubscription? savedCollecsWatcherDB;
  final BeatsMusicDBCubit beatsMusicDBCubit;

  LibraryItemsCubit({
    required this.beatsMusicDBCubit,
  }) : super(LibraryItemsLoading()) {
    // Start with a loading state
    _initialize();
  }

  @override
  Future<void> close() {
    playlistWatcherDB?.cancel();
    savedCollecsWatcherDB?.cancel();
    return super.close();
  }

  Future<void> _initialize() async {
    // Initial fetch
    await Future.wait([
      getAndEmitPlaylists(),
      getAndEmitSavedOnlCollections(),
    ]);

    // Setup watchers for subsequent updates
    _getDBWatchers();
  }

  Future<void> _getDBWatchers() async {
    playlistWatcherDB =
        (await BeatsMusicDBService.getPlaylistsWatcher()).listen((_) {
      getAndEmitPlaylists();
    });
    savedCollecsWatcherDB =
        (await BeatsMusicDBService.getSavedCollecsWatcher()).listen((_) {
      getAndEmitSavedOnlCollections();
    });
  }

  Future<void> getAndEmitPlaylists() async {
    try {
      final mediaPlaylists = await BeatsMusicDBService.getPlaylists4Library();
      final playlistItems = mediaPlaylistsDB2ItemProperties(mediaPlaylists);

      // When emitting, copy existing parts of the state to avoid losing data
      emit(state.copyWith(playlists: playlistItems));
    } catch (e) {
      log("Error fetching playlists: $e", name: "LibraryItemsCubit");
      emit(const LibraryItemsError("Failed to load your playlists."));
    }
  }

  Future<void> getAndEmitSavedOnlCollections() async {
    try {
      final collections = await BeatsMusicDBService.getSavedCollections();
      final artists = collections.whereType<ArtistModel>().toList();
      final albums = collections.whereType<AlbumModel>().toList();
      final onlinePlaylists =
          collections.whereType<PlaylistOnlModel>().toList();

      emit(state.copyWith(
        artists: artists,
        albums: albums,
        playlistsOnl: onlinePlaylists,
      ));
    } catch (e) {
      log("Error fetching saved collections: $e", name: "LibraryItemsCubit");
      emit(const LibraryItemsError("Failed to load your saved items."));
    }
  }

  List<PlaylistItemProperties> mediaPlaylistsDB2ItemProperties(
      List<MediaPlaylist> mediaPlaylists) {
    return mediaPlaylists
        .map((element) => PlaylistItemProperties(
              playlistName: element.playlistName,
              subTitle: "${element.mediaItems.length} Items",
              coverImgUrl: element.imgUrl ??
                  (element.mediaItems.isNotEmpty
                      ? element.mediaItems.first.artUri?.toString()
                      : null),
            ))
        .toList();
  }

  void removePlaylist(MediaPlaylistDB mediaPlaylistDB) {
    if (mediaPlaylistDB.playlistName != "Null") {
      BeatsMusicDBService.removePlaylist(mediaPlaylistDB);
      // The watcher will automatically trigger a state update.
      SnackbarService.showMessage(
          "Playlist ${mediaPlaylistDB.playlistName} removed");
    }
  }

  Future<void> addToPlaylist(
      MediaItemModel mediaItem, MediaPlaylistDB mediaPlaylistDB) async {
    if (mediaPlaylistDB.playlistName != "Null") {
      await beatsMusicDBCubit.addMediaItemToPlaylist(mediaItem, mediaPlaylistDB);
      // The watcher will automatically trigger a state update.
    }
  }

  void removeFromPlaylist(
      MediaItemModel mediaItem, MediaPlaylistDB mediaPlaylistDB) {
    if (mediaPlaylistDB.playlistName != "Null") {
      beatsMusicDBCubit.removeMediaFromPlaylist(mediaItem, mediaPlaylistDB);
      // The watcher will automatically trigger a state update.
      SnackbarService.showMessage(
          "Removed ${mediaItem.title} from ${mediaPlaylistDB.playlistName}");
    }
  }

  Future<List<MediaItemModel>?> getPlaylist(String playlistName) async {
    try {
      final playlist =
          await BeatsMusicDBService.getPlaylistItemsByName(playlistName);

      return playlist?.map((e) => MediaItemDB2MediaItem(e)).toList();
    } catch (e) {
      log("Error in getting playlist: $e", name: "libItemCubit");
      return null;
    }
  }
}
