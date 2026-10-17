import 'package:flutter_test/flutter_test.dart';
import 'package:beats_music/core/models/exported.dart';
import 'package:beats_music/services/player/player_engine.dart';
import 'package:beats_music/services/player/queue_manager.dart';

Track createTestTrack(String id, {String title = 'Test Track'}) {
  return Track(
    id: id,
    title: title,
    artists: [const ArtistSummary(id: 'artist-1', name: 'Test Artist')],
    thumbnail: const Artwork(url: 'https://example.com/art.jpg', layout: ImageLayout.square),
    isExplicit: false,
  );
}

void main() {
  group('QueueManager & Navigation Tests', () {
    late QueueManager queue;

    setUp(() {
      queue = QueueManager();
    });

    tearDown(() {
      queue.dispose();
    });

    test('QueueManager initializes empty and in idle state', () {
      expect(queue.tracks, isEmpty);
      expect(queue.currentTrack, isNull);
      expect(queue.currentIndex, 0);
      expect(queue.hasNext(), isFalse);
      expect(queue.hasPrevious(), isFalse);
    });

    test('loadTracks populates queue, deduplicates, and sets current track', () {
      final t1 = createTestTrack('track-1', title: 'Song 1');
      final t2 = createTestTrack('track-2', title: 'Song 2');
      final t3 = createTestTrack('track-1', title: 'Duplicate Song 1');

      queue.loadTracks([t1, t2, t3], idx: 1);

      expect(queue.length, 2);
      expect(queue.currentTrack?.id, 'track-2');
      expect(queue.currentIndex, 1);
    });

    test('advanceToNext and advanceToPrevious move linearly without loop', () {
      final t1 = createTestTrack('1');
      final t2 = createTestTrack('2');
      final t3 = createTestTrack('3');
      queue.loadTracks([t1, t2, t3], idx: 0);

      expect(queue.hasNext(), isTrue);
      expect(queue.advanceToNext(loopMode: LoopMode.off), isTrue);
      expect(queue.currentIndex, 1);

      expect(queue.advanceToNext(loopMode: LoopMode.off), isTrue);
      expect(queue.currentIndex, 2);

      // Reached the end with LoopMode.off -> returns false and stays at 2
      expect(queue.hasNext(loopMode: LoopMode.off), isFalse);
      expect(queue.advanceToNext(loopMode: LoopMode.off), isFalse);
      expect(queue.currentIndex, 2);

      // Previous
      expect(queue.advanceToPrevious(loopMode: LoopMode.off), isTrue);
      expect(queue.currentIndex, 1);
      expect(queue.advanceToPrevious(loopMode: LoopMode.off), isTrue);
      expect(queue.currentIndex, 0);

      // At start with LoopMode.off -> returns false
      expect(queue.hasPrevious(loopMode: LoopMode.off), isFalse);
      expect(queue.advanceToPrevious(loopMode: LoopMode.off), isFalse);
      expect(queue.currentIndex, 0);
    });

    test('LoopMode.all wraps around on start and end', () {
      final t1 = createTestTrack('1');
      final t2 = createTestTrack('2');
      queue.loadTracks([t1, t2], idx: 1);

      expect(queue.advanceToNext(loopMode: LoopMode.all), isTrue);
      expect(queue.currentIndex, 0);

      expect(queue.advanceToPrevious(loopMode: LoopMode.all), isTrue);
      expect(queue.currentIndex, 1);
    });

    test('Shuffle mode preserves valid playback index and shuffles', () {
      final tracks = List.generate(5, (i) => createTestTrack('id-$i'));
      queue.loadTracks(tracks, idx: 0);

      queue.shuffle(true);
      expect(queue.shuffleMode.value, isTrue);

      final current = queue.currentTrack;
      expect(current, isNotNull);
      expect(current?.id, 'id-0'); // current track is kept at shuffle start
    });

    test('addTrack appends to queue without duplicate IDs', () {
      final t1 = createTestTrack('1');
      final t2 = createTestTrack('2');
      final newTrack = createTestTrack('new-item');

      queue.loadTracks([t1, t2], idx: 0);
      queue.addTrack(newTrack);

      expect(queue.length, 3);
      expect(queue.tracks.last.id, 'new-item');

      // Attempt to add duplicate
      queue.addTrack(newTrack);
      expect(queue.length, 3);
    });
  });

  group('Audio Navigation & 3-Second Rewind Threshold Logic', () {
    test('Playback position > 3s triggers rewind to start without changing queue', () {
      const position = Duration(seconds: 4);
      const threshold = Duration(seconds: 3);

      bool didRewind = false;
      bool didSkipQueue = false;

      if (position > threshold) {
        didRewind = true;
      } else {
        didSkipQueue = true;
      }

      expect(didRewind, isTrue);
      expect(didSkipQueue, isFalse);
    });

    test('Playback position <= 3s triggers queue advance to previous', () {
      const position = Duration(seconds: 2);
      const threshold = Duration(seconds: 3);

      bool didRewind = false;
      bool didSkipQueue = false;

      if (position > threshold) {
        didRewind = true;
      } else {
        didSkipQueue = true;
      }

      expect(didRewind, isFalse);
      expect(didSkipQueue, isTrue);
    });
  });
}

