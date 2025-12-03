import 'dart:async';
import 'dart:developer';
import 'package:beats_music/services/db/beats_music_db_service.dart';
import 'package:bloc/bloc.dart';
import 'package:beats_music/model/MediaPlaylistModel.dart';
part 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  StreamSubscription<void>? watcher;
  HistoryCubit() : super(HistoryInitial()) {
    getRecentlyPlayed();
    watchRecentlyPlayed();
  }
  Future<void> watchRecentlyPlayed() async {
    watcher = (await BeatsMusicDBService.watchRecentlyPlayed()).listen((event) {
      getRecentlyPlayed();
      log("History Updated");
    });
  }

  void getRecentlyPlayed() async {
    final mediaPlaylist = await BeatsMusicDBService.getRecentlyPlayed();
    emit(state.copyWith(mediaPlaylist: mediaPlaylist));
  }

  @override
  Future<void> close() {
    watcher?.cancel();
    return super.close();
  }
}
