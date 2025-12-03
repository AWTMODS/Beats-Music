// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'beats_player_cubit.dart';

class BeatsPlayerState {
  bool isReady;
  bool showLyrics;
  BeatsPlayerState({required this.isReady, this.showLyrics = false});
}

final class BeatsPlayerInitial extends BeatsPlayerState {
  BeatsPlayerInitial() : super(isReady: false);
}

class ProgressBarStreams {
  late Duration currentPos;
  late PlaybackEvent currentPlaybackState;
  late PlayerState currentPlayerState;
  ProgressBarStreams({
    required this.currentPos,
    required this.currentPlaybackState,
    required this.currentPlayerState,
  });
}
