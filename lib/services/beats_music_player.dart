import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:async';
import 'package:beats_music/routes_and_consts/global_conts.dart';
import 'package:beats_music/services/player/audio_source_manager.dart';
import 'package:beats_music/services/player/player_error_handler.dart';
import 'package:beats_music/services/player/connectivity_manager.dart';
import 'package:beats_music/services/player/queue_manager.dart';
import 'package:beats_music/services/player/related_songs_manager.dart';
import 'package:beats_music/services/player/preload_manager.dart';
import 'package:beats_music/utils/imgurl_formator.dart';
import 'package:audio_service/audio_service.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:beats_music/model/songModel.dart';
import 'package:beats_music/model/MediaPlaylistModel.dart';
import 'package:beats_music/services/discord_service.dart';
import 'package:beats_music/services/player/recently_played_tracker.dart';
import 'package:beats_music/services/equalizer_service.dart';
import 'package:beats_music/services/listening_statistics_service.dart';
import 'package:beats_music/services/crossfade_service.dart';

class BeatsMusicPlayer extends BaseAudioHandler
    with SeekHandler, QueueHandler {
  late AudioPlayer audioPlayer;
  late AudioPlayer audioPlayer2;
  late AudioPlayer _activePlayer;
  late AudioPlayer _nextPlayer;
  
  final CrossfadeService _crossfadeService = CrossfadeService();

  // Modular components
  late AudioSourceManager _audioSourceManager;
  late PlayerErrorHandler _errorHandler;
  late ConnectivityManager _connectivityManager;
  late QueueManager _queueManager;
  late RelatedSongsManager _relatedSongsManager;
  late PreloadManager _preloadManager;

  BehaviorSubject<bool> fromPlaylist = BehaviorSubject<bool>.seeded(false);
  BehaviorSubject<bool> isOffline = BehaviorSubject<bool>.seeded(false);
  BehaviorSubject<LoopMode> loopMode =
      BehaviorSubject<LoopMode>.seeded(LoopMode.off);

  // Flag to track if player is disposed
  bool _isDisposed = false;

  // Recently played tracker: records plays only after a continuous
  // playback threshold (default 15s)
  late RecentlyPlayedTracker _recentlyPlayedTracker;

  // Stream subscriptions for proper cleanup
  StreamSubscription? _playbackEventSubscription;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _queueSubscription;
  StreamSubscription? _mediaItemSubscription;
  StreamSubscription? _connectivitySubscription;

  // Expose properties from modular components
  BehaviorSubject<bool> get shuffleMode => _queueManager.shuffleMode;
  BehaviorSubject<bool> get isConnected => _connectivityManager.isConnected;
  BehaviorSubject<PlayerError?> get lastError => _errorHandler.lastError;
  BehaviorSubject<List<MediaItem>> get relatedSongs =>
      _relatedSongsManager.relatedSongs;
  @override
  BehaviorSubject<String> get queueTitle => _queueManager.queueTitle;

  BeatsMusicPlayer() {
    // Create equalizer BEFORE AudioPlayer
    final equalizerService = EqualizerService();
    final androidEq = equalizerService.createAndroidEqualizer();

    // Initialize both players
    audioPlayer = _createPlayer(androidEq);
    audioPlayer2 = _createPlayer(androidEq);
    
    _activePlayer = audioPlayer;
    _nextPlayer = audioPlayer2;

    _initializeModules();
    _initializePlayer(audioPlayer);
    _initializePlayer(audioPlayer2);
    
    // Initialize equalizer after player is created
    equalizerService.initializeAfterPlayerCreated();
    
    // Initialize recently played tracker with default threshold
    _recentlyPlayedTracker = RecentlyPlayedTracker(
      _activePlayer,
      () => _queueManager.currentMediaItem,
    );

    // Refresh shuffle list when queue changes - delegate to queue manager
    _queueSubscription = _queueManager.queue.listen((e) {
      queue.add(e); // Sync with base audio handler queue
    });
  }

  /// Configure how many continuous seconds are required before a track is
  /// added to Recently Played. Default is 15.
  void setRecentlyPlayedThresholdSeconds(int seconds) {
    _recentlyPlayedTracker.setThresholdSeconds(seconds);
  }

  /// Configure percentage (0..1) of track duration required before a track
  /// is added to Recently Played. Default is 0.4 (40%).
  void setRecentlyPlayedPercentThreshold(double percent) {
    _recentlyPlayedTracker.setPercentThreshold(percent);
  }

  void _initializeModules() {
    // Initialize all modular components
    _audioSourceManager = AudioSourceManager();
    _errorHandler = PlayerErrorHandler();
    _connectivityManager = ConnectivityManager();
    _queueManager = QueueManager();
    _relatedSongsManager = RelatedSongsManager();
    _preloadManager = PreloadManager();

    // Setup callbacks between modules
    _errorHandler.onSkipToNext = () => skipToNext();
    _errorHandler.onRetryCurrentTrack = () => _retryCurrentTrack();
    // Provide connectivity check function so error handler can verify network
    // state before auto-skipping to the next track.
    _errorHandler.checkNetworkConnectivity =
        () => _connectivityManager.checkConnectivity();

    _connectivityManager.onNetworkReconnected =
        () => _handleNetworkReconnection();

    _queueManager.onPrepareToPlay =
        (idx, doPlay) => _prepare4play(idx: idx, doPlay: doPlay);

    _relatedSongsManager.onAddQueueItems =
        (items, {bool atLast = false}) => addQueueItems(items, atLast: atLast);

    _preloadManager.onPrepareSource = (mediaItem) => _audioSourceManager
        .ensureSourcePrepared(mediaItem,
            isConnected: _connectivityManager.isConnected.value);

    _preloadManager.onGetAudioSource = (mediaItem) => getAudioSource(mediaItem);
  }

  AudioPlayer _createPlayer(dynamic androidEq) {
    final player = androidEq != null
        ? AudioPlayer(
            handleInterruptions: true,
            androidApplyAudioAttributes: true,
            handleAudioSessionActivation: true,
            audioPipeline: AudioPipeline(androidAudioEffects: [androidEq]),
          )
        : AudioPlayer(
            handleInterruptions: true,
            androidApplyAudioAttributes: true,
            handleAudioSessionActivation: true,
          );
    player.setAutomaticallyWaitsToMinimizeStalling(true);
    return player;
  }

  void _initializePlayer(AudioPlayer player) {
    player.setVolume(1);
    player.setSpeed(1.0);
    
    // Only the active player should broadcast its events to the system handler
    player.playbackEventStream.listen((event) {
      if (player == _activePlayer) {
        _broadcastPlayerEvent(event);
      }
    });

    player.setLoopMode(LoopMode.off);

    // Enhanced error handling for player events + statistics tracking
    player.playerStateStream.listen((state) async {
      if (player != _activePlayer) return;

      if (state.processingState == ProcessingState.idle &&
          state.playing == false &&
          _errorHandler.lastError.value != null) {
        _handlePlaybackFailure();
      }
      
      // Track statistics when song completes
      if (state.processingState == ProcessingState.completed) {
        final statisticsService = ListeningStatisticsService();
        await statisticsService.trackSongEnd(wasCompleted: true);
      }
    });

    // Update the current media item when the audio player changes to the next
    Rx.combineLatest2(
      player.sequenceStream,
      player.currentIndexStream,
      (sequence, index) {
        if (player != _activePlayer) return null;
        try {
          if (sequence.isEmpty || index == null || index < 0 || index >= sequence.length) {
            return null;
          }
          final source = sequence[index];
          if (source.tag is! MediaItem) return null;
          
          MediaItem item = source.tag as MediaItem;
          final artUri = Uri.parse(
              formatImgURL(item.artUri.toString(), ImageQuality.medium));
          item = item.copyWith(artUri: artUri);
          return item;
        } catch (e) {
          return null;
        }
      },
    ).listen((item) async {
      if (player != _activePlayer || item == null) return;
      
      final currentItem = mediaItem.value;
      if (currentItem == null ||
          currentItem.id != item.id ||
          currentItem.artUri != item.artUri) {
            
        final statisticsService = ListeningStatisticsService();
        await statisticsService.trackSongEnd(
          wasCompleted: false,
          durationOverride: player.position.inSeconds,
        );
        
        mediaItem.add(item);
        statisticsService.trackSongStart(item);
      }
    });

    // Trigger skipToNext when the current song ends.
    final endingOffset =
        Platform.isWindows ? 200 : (Platform.isLinux ? 700 : 200);
    player.positionStream.listen((event) {
      if (player != _activePlayer) return;

      EasyThrottle.throttle('loadRelatedSongs', const Duration(seconds: 5),
          () async => check4RelatedSongs());
          
      // CROSSFADE LOGIC
      if (_crossfadeService.isEnabled &&
          player.duration != null &&
          player.duration!.inSeconds > 10 && // Only crossfade longer tracks
          event.inMilliseconds >
              player.duration!.inMilliseconds - (_crossfadeService.duration.inMilliseconds + 500)) {
        
        EasyThrottle.throttle('initiate-crossfade', const Duration(seconds: 2), () {
          _initiateCrossfade();
        });
        return;
      }

      if (((player.duration != null &&
              player.duration?.inSeconds != 0 &&
              event.inMilliseconds >
                  player.duration!.inMilliseconds - endingOffset)) &&
          loopMode.value != LoopMode.one &&
          _queueManager.queue.value.isNotEmpty) {
        EasyThrottle.throttle('skipNext', const Duration(milliseconds: 2000),
            () async => skipToNext());
      }
    });
  }

  void _handlePlaybackFailure() {
    if (_queueManager.queue.value.isNotEmpty &&
        _queueManager.currentPlayingIdx < _queueManager.queue.value.length) {
      final currentItem =
          _queueManager.queue.value[_queueManager.currentPlayingIdx];
      _errorHandler.handleError(PlayerErrorType.playbackError,
          'Playback failed unexpectedly', currentItem);
    }
  }

  void _handleNetworkReconnection() {
    if (_errorHandler.lastError.value?.type == PlayerErrorType.networkError &&
        _queueManager.queue.value.isNotEmpty) {
      _retryCurrentTrack();
    }
  }

  Future<void> _retryCurrentTrack() async {
    if (_queueManager.queue.value.isNotEmpty &&
        _queueManager.currentPlayingIdx < _queueManager.queue.value.length) {
      final currentItem =
          _queueManager.queue.value[_queueManager.currentPlayingIdx];
      final currentPosition = audioPlayer.position;
      debugPrint('Retrying current track: ${currentItem.title} at position $currentPosition');

      try {
        _errorHandler.clearError(); // Clear previous error
        await playMediaItem(currentItem,
            doPlay: true, initialPosition: currentPosition);
      } catch (e) {
        debugPrint('Retry failed: $e');
        _errorHandler.handleError(
            PlayerErrorType.playbackError, 'Retry failed: $e', currentItem, e);
      }
    }
  }

  void _broadcastPlayerEvent(PlaybackEvent event) {
    bool isPlaying = audioPlayer.playing;
    playbackState.add(PlaybackState(
      // Which buttons should appear in the notification now
      controls: [
        MediaControl.skipToPrevious,
        isPlaying ? MediaControl.pause : MediaControl.play,
        // MediaControl.stop,
        MediaControl.skipToNext,
      ],
      processingState: switch (event.processingState) {
        ProcessingState.idle => AudioProcessingState.idle,
        ProcessingState.loading => AudioProcessingState.loading,
        ProcessingState.buffering => AudioProcessingState.buffering,
        ProcessingState.ready => AudioProcessingState.ready,
        ProcessingState.completed => AudioProcessingState.completed,
      },
      // Which other actions should be enabled in the notification
      systemActions: const {
        MediaAction.skipToPrevious,
        MediaAction.playPause,
        MediaAction.skipToNext,
        MediaAction.seek,
      },
      androidCompactActionIndices: const [0, 1, 2],
      updatePosition: _activePlayer.position,
      playing: isPlaying,
      bufferedPosition: _activePlayer.bufferedPosition,
      speed: _activePlayer.speed,
    ));

    EasyThrottle.throttle(
      'discord-presence',
      const Duration(seconds: 10),
      () => DiscordService.updatePresence(
        mediaItem: currentMedia,
        isPlaying: isPlaying,
      ),
    );

    // Check if we should preload next song(s)
    EasyThrottle.throttle(
      'preload-check',
      const Duration(seconds: 2),
      () async {
        await _preloadManager.checkAndPreload(
          currentMedia: _queueManager.currentMediaItem,
          nextMedia: _queueManager.nextMediaItem,
          next2Media: _queueManager.next2MediaItem,
          next3Media: _queueManager.next3MediaItem,
          currentPosition: event.updatePosition,
          totalDuration: event.duration,
        );
      },
    );
  }

  MediaItemModel get currentMedia {
    if (_queueManager.queue.value.isEmpty ||
        _queueManager.currentPlayingIdx >= _queueManager.queue.value.length) {
      return mediaItemModelNull;
    }
    return mediaItem2MediaItemModel(
        _queueManager.queue.value[_queueManager.currentPlayingIdx]);
  }

  /// Preload a song's audio source for faster playback
  Future<void> preloadSong(MediaItem mediaItem) async {
    await _preloadManager.preloadSong(mediaItem);
  }

  @override
  Future<void> play() async {
    if (_isDisposed) {
      debugPrint('Cannot play: player is disposed');
      return;
    }
    await _activePlayer.play();
  }

  bool _isCrossfading = false;
  Future<void> _initiateCrossfade() async {
    if (_isCrossfading) return;
    if (_queueManager.nextMediaItem == null) return;

    _isCrossfading = true;
    debugPrint('--- INITIATING CROSSFADE ---');

    final nextMedia = _queueManager.nextMediaItem!;
    final crossfadeDuration = _crossfadeService.duration;

    try {
      // 1. Prepare next player
      final source = await _audioSourceManager.getAudioSource(nextMedia,
          isConnected: _connectivityManager.isConnected.value);
      if (source == null) {
        _isCrossfading = false;
        return;
      }

      await _nextPlayer.setAudioSource(source);
      
      // 2. Start overlapping playback
      _nextPlayer.setVolume(0);
      await _nextPlayer.play();

      // 3. Ramp volumes
      final steps = 20;
      final stepDuration = Duration(milliseconds: crossfadeDuration.inMilliseconds ~/ steps);
      
      for (var i = 1; i <= steps; i++) {
        final rampUp = i / steps;
        final rampDown = 1.0 - rampUp;
        
        _activePlayer.setVolume(rampDown);
        _nextPlayer.setVolume(rampUp);
        
        await Future.delayed(stepDuration);
      }

      // 4. Swap and cleanup
      await _activePlayer.stop();
      _activePlayer.setVolume(1); // Reset for next time

      final temp = _activePlayer;
      _activePlayer = _nextPlayer;
      _nextPlayer = temp;

      // Update tracker with the now active player
      _recentlyPlayedTracker.updatePlayer(_activePlayer);

      // Update pointers in queue manager since we manually handled the transition
      _queueManager.skipToNextOnly();
      
      // Notify listeners about the new player state
      _broadcastPlayerEvent(_activePlayer.playbackEvent);

    } catch (e) {
      debugPrint('Error during crossfade: $e');
    } finally {
      _isCrossfading = false;
    }
  }

  Future<void> check4RelatedSongs() async {
    if (_queueManager.currentMediaItem == null) {
      debugPrint('No current media item available for related songs check');
      return;
    }

    await _relatedSongsManager.checkForRelatedSongs(
      currentMedia: _queueManager.currentMediaItem!,
      queue: _queueManager.queue.value,
      currentPlayingIdx: _queueManager.currentPlayingIdx,
      loopMode: loopMode.value,
    );
  }

  @override
  Future<void> seek(Duration position) async {
    _activePlayer.seek(position);
  }

  Future<void> seekNSecForward(Duration n) async {
    if ((_activePlayer.duration ?? const Duration(seconds: 0)) >=
        _activePlayer.position + n) {
      await _activePlayer.seek(_activePlayer.position + n);
    } else {
      await _activePlayer
          .seek(_activePlayer.duration ?? const Duration(seconds: 0));
    }
  }

  Future<void> seekNSecBackward(Duration n) async {
    if (_activePlayer.position - n >= const Duration(seconds: 0)) {
      await _activePlayer.seek(_activePlayer.position - n);
    } else {
      await _activePlayer.seek(const Duration(seconds: 0));
    }
  }

  void setLoopMode(LoopMode loopMode) {
    _activePlayer.setLoopMode(loopMode);
    _nextPlayer.setLoopMode(loopMode);
    this.loopMode.add(loopMode);
  }

  Future<void> shuffle(bool shuffle) async {
    await _queueManager.shuffle(shuffle);
  }

  Future<void> loadPlaylist(MediaPlaylist mediaList,
      {int idx = 0, bool doPlay = false, bool shuffling = false}) async {
    fromPlaylist.add(true);
    _relatedSongsManager.clearRelatedSongs();
    await _queueManager.loadPlaylist(mediaList,
        idx: idx, doPlay: doPlay, shuffling: shuffling);
    queueTitle.add(mediaList.playlistName);
  }

  @override
  Future<void> pause() async {
    if (_isDisposed) {
      debugPrint('Cannot pause: player is disposed');
      return;
    }
    await _activePlayer.pause();
    // If the audio player is playing, pause it [Temporary bug]
    if (_activePlayer.playing) {
      _activePlayer.pause();
    }

    debugPrint("paused");
  }

  Future<AudioSource> getAudioSource(MediaItem mediaItem) async {
    try {
      final audioSource = await _audioSourceManager.getAudioSource(mediaItem,
          isConnected: _connectivityManager.isConnected.value);

      // Check if it's an offline source (file URI)
      if (audioSource.toString().contains('file://')) {
        isOffline.add(true);
      } else {
        isOffline.add(false);
      }

      return audioSource;
    } catch (e) {
      debugPrint('Error getting audio source for ${mediaItem.title}: $e');

      final errorType = _errorHandler.categorizeError(e);
      String errorMessage;

      switch (errorType) {
        case PlayerErrorType.networkError:
          errorMessage = 'Network error while loading song';
          break;
        case PlayerErrorType.sourceError:
          errorMessage = 'Song source unavailable';
          break;
        case PlayerErrorType.playbackError:
          errorMessage = 'Playback error occurred';
          break;
        case PlayerErrorType.bufferingError:
          errorMessage = 'Buffering error occurred';
          break;
        case PlayerErrorType.permissionError:
          errorMessage = 'Permission denied';
          break;
        default:
          errorMessage = 'Unknown error loading song';
      }

      _errorHandler.handleError(errorType, errorMessage, mediaItem, e);
      rethrow;
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    await _queueManager.skipToQueueItem(index);
    return super.skipToQueueItem(index);
  }

  Future<void> playAudioSource({
    required AudioSource audioSource,
    required String mediaId,
    Duration? initialPosition,
  }) async {
    try {
      await pause();
      await seek(initialPosition ?? Duration.zero);

      await _activePlayer.setAudioSource(audioSource);
      // Protect against hanging load calls (observed on Android when DNS fails).
      try {
        // Wait up to 12 seconds for load, otherwise treat as network error.
        await _activePlayer.load().timeout(const Duration(seconds: 12));
      } on TimeoutException catch (e) {
        debugPrint('audioPlayer.load() timed out: $e');
        final currentItem = _queueManager.currentMediaItem;
        _errorHandler.handleError(PlayerErrorType.networkError,
            'Network timeout while loading track', currentItem, e);
        try {
          await _activePlayer.stop();
        } catch (_) {}
        rethrow;
      }

      if (!_activePlayer.playing) {
        await play();
      }

      // Clear any previous errors on successful playback
      _errorHandler.clearError();
      _errorHandler.clearRetryAttempts(mediaId);

      debugPrint('Successfully started playback for $mediaId');
    } catch (e) {
      debugPrint("Error in playAudioSource: $e");

      PlayerErrorType errorType;
      String errorMessage;

      if (e is PlayerException) {
        if (e.message?.contains('network') == true ||
            e.message?.contains('connection') == true) {
          errorType = PlayerErrorType.networkError;
          errorMessage = 'Network error during playback';
        } else if (e.message?.contains('source') == true ||
            e.message?.contains('format') == true) {
          errorType = PlayerErrorType.sourceError;
          errorMessage = 'Audio source error';
        } else {
          errorType = PlayerErrorType.playbackError;
          errorMessage = 'Playback failed: ${e.message}';
        }

        final currentItem = _queueManager.currentMediaItem;
        _errorHandler.handleError(errorType, errorMessage, currentItem, e);

        // For critical errors, try to recover
        if (errorType == PlayerErrorType.sourceError) {
          _audioSourceManager.clearCachedSource(mediaId);
        }
      } else {
        final currentItem = _queueManager.currentMediaItem;
        _errorHandler.handleError(PlayerErrorType.unknownError,
            'Unexpected playback error', currentItem, e);
      }

      rethrow;
    }
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem,
      {bool doPlay = true, Duration? initialPosition}) async {
    try {
      debugPrint('Attempting to play: ${mediaItem.title}');

      // Check if we have a preloaded source
      AudioSource? audioSource = _preloadManager.getPreloadedSource(mediaItem.id);
      
      if (audioSource != null) {
        debugPrint('Using preloaded source for: ${mediaItem.title}');
        await _preloadManager.clearNextPreload();
      } else {
        debugPrint('Fetching audio source for: ${mediaItem.title}');
        audioSource = await getAudioSource(mediaItem);
      }
      await playAudioSource(
          audioSource: audioSource,
          mediaId: mediaItem.id,
          initialPosition: initialPosition);

      if (doPlay && !_activePlayer.playing) {
        await play();
      }

      await check4RelatedSongs();
    } catch (e) {
      debugPrint('Failed to play media item ${mediaItem.title}: $e');

      // Don't rethrow here, let the error handling system manage it
      // The error was already handled in getAudioSource or playAudioSource
    }
  }

  Future<void> _prepare4play({int idx = 0, bool doPlay = false}) async {
    final currentItem = _queueManager.currentMediaItem;
    if (currentItem == null) {
      debugPrint('Cannot prepare4play: no current media item');
      return;
    }

    // Explicitly broadcast the media item change to ensure UI updates immediately (fix for first song image)
    mediaItem.add(currentItem);

    await playMediaItem(currentItem, doPlay: doPlay);
  }



  @override
  Future<void> rewind() async {
    if (_activePlayer.processingState == ProcessingState.ready) {
      await _activePlayer.seek(Duration.zero);
    } else if (_activePlayer.processingState == ProcessingState.completed) {
      await _prepare4play(idx: _queueManager.currentPlayingIdx);
    }
  }

  @override
  Future<void> skipToNext() async {
    await _queueManager.skipToNext();
    // return super.skipToNext();
  }

  @override
  Future<void> stop() async {
    // Stop audio player and clear presence, then propagate stop to audio service
    playbackState.add(playbackState.value
        .copyWith(processingState: AudioProcessingState.idle));
    await playbackState.firstWhere(
        (state) => state.processingState == AudioProcessingState.idle);
        
    // Track stats before stopping
    final statisticsService = ListeningStatisticsService();
    await statisticsService.trackSongEnd(
      wasCompleted: false,
      durationOverride: _activePlayer.position.inSeconds,
    );
        
    await _activePlayer.stop();
    await _nextPlayer.stop();
    DiscordService.clearPresence();
    await super.stop();
  }

  @override
  Future<void> skipToPrevious() async {
    await _queueManager.skipToPrevious();
    // return super.skipToPrevious();
  }

  @override
  Future<void> onTaskRemoved() async {
    await _cleanup();
    return super.onTaskRemoved();
  }

  @override
  Future<void> onNotificationDeleted() async {
    await _cleanup();
    return super.onNotificationDeleted();
  }

  Future<void> _cleanup() async {
    if (_isDisposed) return; // Prevent multiple cleanup calls
    _isDisposed = true;

    debugPrint('Cleaning up player resources');

    // Cancel all stream subscriptions
    await _playbackEventSubscription?.cancel();
    await _playerStateSubscription?.cancel();
    await _positionSubscription?.cancel();
    await _queueSubscription?.cancel();
    await _mediaItemSubscription?.cancel();
    await _connectivitySubscription?.cancel();

    // Dispose modular components
    _errorHandler.dispose();
    _connectivityManager.dispose();
    _queueManager.dispose();
    _relatedSongsManager.dispose();
    await _preloadManager.dispose();
    await _recentlyPlayedTracker.dispose();

    // Clear Discord presence
    DiscordService.clearPresence();

    // Stop and dispose audio player
    try {
      await audioPlayer.stop();
      await audioPlayer.dispose();
      await audioPlayer2.stop();
      await audioPlayer2.dispose();
    } catch (e) {
      debugPrint('Error disposing audio players: $e');
    }

    // Close behavior subjects
    try {
      await fromPlaylist.close();
      await isOffline.close();
      await loopMode.close();
    } catch (e) {
      debugPrint('Error closing behavior subjects: $e');
    }

    await super.stop();
  }

  @override
  Future<void> insertQueueItem(int index, MediaItem mediaItem) async {
    await _queueManager.insertQueueItem(index, mediaItem);
    try {
      await super.insertQueueItem(index, mediaItem);
    } catch (e) {
      debugPrint('Error syncing insertQueueItem with audio service: $e');
    }
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    await _queueManager.addQueueItem(mediaItem);
  }

  @override
  Future<void> updateQueue(List<MediaItem> queue, {bool doPlay = false}) async {
    await _queueManager.updateQueue(queue, doPlay: doPlay);
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems,
      {String queueName = "Queue", bool atLast = false}) async {
    await _queueManager.addQueueItems(mediaItems,
        queueName: queueName, atLast: atLast);
  }

  Future<void> addPlayNextItem(MediaItem mediaItem) async {
    await _queueManager.addPlayNextItem(mediaItem);
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    await _queueManager.removeQueueItemAt(index);
  }

  Future<void> moveQueueItem(int oldIndex, int newIndex) async {
    await _queueManager.moveQueueItem(oldIndex, newIndex);
  }
}
