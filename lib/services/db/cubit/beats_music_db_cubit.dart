import 'dart:developer';
import 'package:beats_music/screens/widgets/snackbar.dart';
import 'package:beats_music/theme_data/default.dart';
import 'package:audio_service/audio_service.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:beats_music/model/MediaPlaylistModel.dart';
import 'package:beats_music/model/songModel.dart';
import 'package:beats_music/services/db/GlobalDB.dart';
import 'package:beats_music/services/db/beats_music_db_service.dart';

part 'beats_music_db_state.dart';

class BeatsMusicDBCubit extends Cubit<MediadbState> {
  // BehaviorSubject<bool> refreshLibrary = BehaviorSubject<bool>.seeded(false);
  // BeatsMusicDBService beatsMusicDBService = BeatsMusicDBService();
  BeatsMusicDBCubit() : super(MediadbInitial()) {
    addNewPlaylistToDB(MediaPlaylistDB(playlistName: "Liked"));
  }

  Future<void> addNewPlaylistToDB(MediaPlaylistDB mediaPlaylistDB,
      {bool undo = false}) async {
    List<String> _list = await getListOfPlaylists();
    if (!_list.contains(mediaPlaylistDB.playlistName)) {
      BeatsMusicDBService.addPlaylist(mediaPlaylistDB);
      // refreshLibrary.add(true);
      if (!undo) {
        SnackbarService.showMessage(
            "Playlist ${mediaPlaylistDB.playlistName} added");
      }
    }
  }

  Future<void> setLike(MediaItem mediaItem, {isLiked = false}) async {
    BeatsMusicDBService.addMediaItem(MediaItem2MediaItemDB(mediaItem), "Liked");
    // refreshLibrary.add(true);
    BeatsMusicDBService.likeMediaItem(MediaItem2MediaItemDB(mediaItem),
        isLiked: isLiked);
    if (isLiked) {
      SnackbarService.showMessage("${mediaItem.title} is Liked!!");
    } else {
      SnackbarService.showMessage("${mediaItem.title} is Unliked!!");
    }
  }

  Future<bool> isLiked(MediaItem mediaItem) {
    // bool res = true;
    return BeatsMusicDBService.isMediaLiked(MediaItem2MediaItemDB(mediaItem));
  }

  List<MediaItemDB> reorderByRank(
      List<MediaItemDB> orgMediaList, List<int> rankIndex) {
    // Ensure rankIndex and orgMediaList are unique and non-null
    if (orgMediaList.isEmpty || rankIndex.isEmpty) {
      log('Error: One or both input lists are empty.', name: "BeatsMusicDBCubit");
      return orgMediaList;
    }

    if (rankIndex.length != orgMediaList.length) {
      log('Error: Mismatch in lengths of rankIndex and orgMediaList.',
          name: "BeatsMusicDBCubit");
      return orgMediaList;
    }

    try {
      // Create a map for quick lookup of MediaItemDB by id
      final mediaMap = {for (var item in orgMediaList) item.id: item};

      // Reorder the list based on rankIndex
      final reorderedList = rankIndex.map((id) {
        if (!mediaMap.containsKey(id)) {
          throw StateError('ID $id not found in orgMediaList.');
        }
        return mediaMap[id]!;
      }).toList();

      log('Reordered list created successfully.', name: "BeatsMusicDBCubit");
      return reorderedList;
    } catch (e, stackTrace) {
      log('Error during reordering: $e',
          name: "BeatsMusicDBCubit", stackTrace: stackTrace);
      return orgMediaList;
    }
  }

  Future<MediaPlaylist> getPlaylistItems(
      MediaPlaylistDB mediaPlaylistDB) async {
    MediaPlaylist _mediaPlaylist = MediaPlaylist(
        mediaItems: [], playlistName: mediaPlaylistDB.playlistName);

    var _dbList = await BeatsMusicDBService.getPlaylistItems(mediaPlaylistDB);
    final playlist =
        await BeatsMusicDBService.getPlaylist(mediaPlaylistDB.playlistName);
    final info =
        await BeatsMusicDBService.getPlaylistInfo(mediaPlaylistDB.playlistName);
    if (playlist != null) {
      _mediaPlaylist =
          fromPlaylistDB2MediaPlaylist(mediaPlaylistDB, playlistsInfoDB: info);

      if (_dbList != null) {
        List<int> _rankList =
            await BeatsMusicDBService.getPlaylistItemsRank(mediaPlaylistDB);

        if (_rankList.isNotEmpty) {
          _dbList = reorderByRank(_dbList, _rankList);
        }
        _mediaPlaylist.mediaItems.clear();

        for (var element in _dbList) {
          _mediaPlaylist.mediaItems.add(MediaItemDB2MediaItem(element));
        }
      }
    }
    return _mediaPlaylist;
  }

  Future<void> setPlayListItemsRank(
      MediaPlaylistDB mediaPlaylistDB, List<int> rankList) async {
    BeatsMusicDBService.setPlaylistItemsRank(mediaPlaylistDB, rankList);
  }

  Future<Stream> getStreamOfPlaylist(MediaPlaylistDB mediaPlaylistDB) async {
    return await BeatsMusicDBService.getStream4MediaList(mediaPlaylistDB);
  }

  Future<List<String>> getListOfPlaylists() async {
    List<String> mediaPlaylists = [];
    final _albumList = await BeatsMusicDBService.getPlaylists4Library();
    if (_albumList.isNotEmpty) {
      _albumList.toList().forEach((element) {
        mediaPlaylists.add(element.playlistName);
      });
    }
    return mediaPlaylists;
  }

  Future<List<MediaPlaylist>> getListOfPlaylists2() async {
    List<MediaPlaylist> mediaPlaylists = [];
    final _albumList = await BeatsMusicDBService.getPlaylists4Library();
    if (_albumList.isNotEmpty) {
      _albumList.toList().forEach((element) {
        mediaPlaylists.add(element);
      });
    }
    return mediaPlaylists;
  }

  Future<void> reorderPositionOfItemInDB(
      String playlistName, int old_idx, int new_idx) async {
    BeatsMusicDBService.reorderItemPositionInPlaylist(
        MediaPlaylistDB(playlistName: playlistName), old_idx, new_idx);
  }

  Future<void> removePlaylist(MediaPlaylistDB mediaPlaylistDB) async {
    BeatsMusicDBService.removePlaylist(mediaPlaylistDB);
    SnackbarService.showMessage("${mediaPlaylistDB.playlistName} is Deleted!!",
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: "Undo",
          textColor: Default_Theme.accentColor2,
          onPressed: () => addNewPlaylistToDB(mediaPlaylistDB, undo: true),
        ));
  }

  Future<void> removeMediaFromPlaylist(
      MediaItem mediaItem, MediaPlaylistDB mediaPlaylistDB) async {
    MediaItemDB _mediaItemDB = MediaItem2MediaItemDB(mediaItem);
    BeatsMusicDBService.removeMediaItemFromPlaylist(_mediaItemDB, mediaPlaylistDB)
        .then((value) {
      SnackbarService.showMessage(
          "${mediaItem.title} is removed from ${mediaPlaylistDB.playlistName}!!",
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
              label: "Undo",
              textColor: Default_Theme.accentColor2,
              onPressed: () => addMediaItemToPlaylist(
                  MediaItemDB2MediaItem(_mediaItemDB), mediaPlaylistDB,
                  undo: true)));
    });
  }

  Future<int?> addMediaItemToPlaylist(
      MediaItemModel mediaItemModel, MediaPlaylistDB mediaPlaylistDB,
      {bool undo = false}) async {
    final _id = await BeatsMusicDBService.addMediaItem(
        MediaItem2MediaItemDB(mediaItemModel), mediaPlaylistDB.playlistName);
    // refreshLibrary.add(true);
    if (!undo) {
      SnackbarService.showMessage(
          "${mediaItemModel.title} is added to ${mediaPlaylistDB.playlistName}!!");
    }
    return _id;
  }

  Future<bool?> getSettingBool(String key) async {
    return await BeatsMusicDBService.getSettingBool(key);
  }

  Future<void> putSettingBool(String key, bool value) async {
    if (key.isNotEmpty) {
      BeatsMusicDBService.putSettingBool(key, value);
    }
  }

  Future<String?> getSettingStr(String key) async {
    return await BeatsMusicDBService.getSettingStr(key);
  }

  Future<void> putSettingStr(String key, String value) async {
    if (key.isNotEmpty && value.isNotEmpty) {
      BeatsMusicDBService.putSettingStr(key, value);
    }
  }

  Future<Stream<AppSettingsStrDB?>?> getWatcher4SettingStr(String key) async {
    if (key.isNotEmpty) {
      return await BeatsMusicDBService.getWatcher4SettingStr(key);
    } else {
      return null;
    }
  }

  Future<Stream<AppSettingsBoolDB?>?> getWatcher4SettingBool(String key) async {
    if (key.isNotEmpty) {
      var _watcher = await BeatsMusicDBService.getWatcher4SettingBool(key);
      if (_watcher != null) {
        return _watcher;
      } else {
        BeatsMusicDBService.putSettingBool(key, false);
        return BeatsMusicDBService.getWatcher4SettingBool(key);
      }
    } else {
      return null;
    }
  }

  @override
  Future<void> close() async {
    // refreshLibrary.close();
    super.close();
  }
}
