import 'package:beats_music/services/beats_player.dart';
import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';
part 'beats_player_state.dart';

class BeatsPlayerCubit extends Cubit<BeatsPlayerState> {
  final BeatsMusicPlayer BeatsPlayer;
  late ValueStream<ProgressBarStreams> progressStreams;

  BeatsPlayerCubit(this.BeatsPlayer)
      : super(BeatsPlayerState(isReady: true)) {
    BeatsPlayer.syncPublicState();
    _setupProgressStreams();
  }

  void switchShowLyrics({bool? value}) {
    emit(BeatsPlayerState(
        isReady: true, showLyrics: value ?? !state.showLyrics));
  }

  void _setupProgressStreams() {
    progressStreams = Rx.combineLatest4(
      Rx.defer(() => BeatsPlayer.engine.positionStream, reusable: true),
      Rx.defer(() => BeatsPlayer.engine.durationStream, reusable: true),
      Rx.defer(() => BeatsPlayer.engine.bufferedStream, reusable: true),
      Rx.defer(() => BeatsPlayer.engine.playingStream, reusable: true),
      (Duration position, Duration duration, Duration buffered, bool playing) =>
          ProgressBarStreams(
        position: position,
        duration: duration,
        buffered: buffered,
        isPlaying: playing,
      ),
    ).shareValueSeeded(
      ProgressBarStreams(
        position: Duration.zero,
        duration: Duration.zero,
        buffered: Duration.zero,
        isPlaying: false,
      ),
    );
  }

  @override
  Future<void> close() {
    // Intentionally does NOT stop the player.
    // The AudioService foreground service manages its own lifecycle via
    // onTaskRemoved() / onNotificationDeleted().
    return super.close();
  }
}


