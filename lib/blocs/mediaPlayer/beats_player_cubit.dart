import 'package:beats_music/services/audio_service_initializer.dart';
import 'package:bloc/bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:beats_music/services/beats_music_player.dart';
part 'beats_player_state.dart';

enum PlayerInitState { initializing, initialized, intial }

class BeatsPlayerCubit extends Cubit<BeatsPlayerState> {
  late BeatsMusicPlayer beatsMusicPlayer;
  PlayerInitState playerInitState = PlayerInitState.intial;
  // late AudioSession audioSession;
  late Stream<ProgressBarStreams> progressStreams;
  BeatsPlayerCubit() : super(BeatsPlayerInitial()) {
    setupPlayer().then((value) => emit(BeatsPlayerState(isReady: true)));
  }

  void switchShowLyrics({bool? value}) {
    emit(BeatsPlayerState(
        isReady: true, showLyrics: value ?? !state.showLyrics));
  }

  Future<void> setupPlayer() async {
    playerInitState = PlayerInitState.initializing;
    beatsMusicPlayer = await PlayerInitializer().getBeatsMusicPlayer();
    playerInitState = PlayerInitState.initialized;
    progressStreams = Rx.defer(
      () => Rx.combineLatest3(
          beatsMusicPlayer.audioPlayer.positionStream,
          beatsMusicPlayer.audioPlayer.playbackEventStream,
          beatsMusicPlayer.audioPlayer.playerStateStream,
          (Duration a, PlaybackEvent b, PlayerState c) => ProgressBarStreams(
              currentPos: a, currentPlaybackState: b, currentPlayerState: c)),
      reusable: true,
    );
  }

  @override
  Future<void> close() {
    // EasyDebounce.cancelAll();
    beatsMusicPlayer.stop();
    beatsMusicPlayer.audioPlayer.dispose();
    return super.close();
  }
}
