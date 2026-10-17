import 'dart:async';
import 'dart:developer';
import 'package:beats_music/core/models/exported.dart';
import 'package:beats_music/services/db/dao/history_dao.dart';
import 'package:bloc/bloc.dart';

part 'history_state.dart';

/// Cubit for the full playback history screen with efficient pagination.
class HistoryCubit extends Cubit<HistoryState> {
  final HistoryDAO _historyDao;
  StreamSubscription<void>? _watcher;
  static const int _pageSize = 50;
  int _currentLimit = _pageSize;

  HistoryCubit({required HistoryDAO historyDao})
      : _historyDao = historyDao,
        super(const HistoryInitial()) {
    _fetchHistory();
    _watchHistory();
  }

  Future<void> _watchHistory() async {
    _watcher = (await _historyDao.watchHistory()).listen((_) {
      _fetchHistory();
      log('History Updated', name: 'HistoryCubit');
    });
  }

  Future<void> _fetchHistory() async {
    final tracks = await _historyDao.getHistory(limit: _currentLimit);
    emit(state.copyWith(
      tracks: tracks,
      hasMore: tracks.length >= _currentLimit,
      isLoadingMore: false,
    ));
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    emit(state.copyWith(isLoadingMore: true));
    _currentLimit += _pageSize;
    final tracks = await _historyDao.getHistory(limit: _currentLimit);
    emit(state.copyWith(
      tracks: tracks,
      hasMore: tracks.length >= _currentLimit,
      isLoadingMore: false,
    ));
  }

  @override
  Future<void> close() {
    _watcher?.cancel();
    return super.close();
  }
}



