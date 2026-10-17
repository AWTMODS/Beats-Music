part of 'history_cubit.dart';

class HistoryState {
  final List<Track> tracks;
  final bool hasMore;
  final bool isLoadingMore;

  const HistoryState({
    required this.tracks,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  HistoryState copyWith({
    List<Track>? tracks,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return HistoryState(
      tracks: tracks ?? this.tracks,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class HistoryInitial extends HistoryState {
  const HistoryInitial() : super(tracks: const [], hasMore: true, isLoadingMore: false);
}
