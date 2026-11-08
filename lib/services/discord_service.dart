import 'dart:developer';
import 'dart:io';
import 'package:beats_music/core/models/exported.dart';
import 'package:beats_music/core/constants/sentinel_values.dart';
import 'package:dart_discord_rpc/dart_discord_rpc.dart';

class DiscordService {
  static DiscordRPC? _discordRPC;
  static String? _activeTrackId;
  static int? _trackStartEpochSec;
  static _LastSent? _lastSent;

  /// Initializes Discord RPC once.
  static void initialize() {
    if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) return;
    if (_discordRPC != null) return;
    try {
      DiscordRPC.initialize();
      _discordRPC = DiscordRPC(applicationId: '1339113296405725235');
      _discordRPC?.start(autoRegister: true);
      log('Discord RPC initialized', name: 'DiscordService');
    } catch (e) {
      log('Discord RPC init failed: $e', name: 'DiscordService');
    }
  }

  /// Updates the Discord presence for [track].
  ///
  /// [isPlaying] toggles the time bar (Discord only renders it when both
  /// `startTimeStamp` and `endTimeStamp` are set). [position] is the
  /// current playback position; [duration] is the total track length.
  static void updatePresence({
    required Track track,
    required bool isPlaying,
    Duration position = Duration.zero,
    Duration duration = Duration.zero,
  }) {
    final rpc = _discordRPC;
    if (rpc == null || isTrackNull(track)) return;

    try {
      // Track change -> reset start anchor, force IPC send
      if (_activeTrackId != track.id) {
        _activeTrackId = track.id;
        _trackStartEpochSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        _lastSent = null;
      }

      final artistStr = track.artists.isNotEmpty
          ? track.artists.map((a) => a.name).join(', ')
          : 'Unknown Artist';

      // Spotify-style: details = title, state = artist.
      final details = track.title;
      final state = artistStr;

      // Timestamps: Time bar only renders when BOTH start and end are set.
      // Omit endTimeStamp on pause so the bar disappears.
      final startTs = _trackStartEpochSec;
      int? endTs;
      if (isPlaying && duration > Duration.zero && position >= Duration.zero) {
        final remaining = duration - position;
        if (remaining > Duration.zero) {
          endTs = DateTime.now().millisecondsSinceEpoch ~/ 1000 +
              remaining.inSeconds;
        }
      }

      // Per-track album art via Discord's media proxy
      final cover = _bestCover(track);
      final largeImageKey = cover == null ? 'Beats_logo' : 'mp:$cover';
      final largeImageText = track.album?.title ?? track.title;

      // Play/pause small image
      final smallImageKey = isPlaying ? 'play' : 'pause';
      final smallImageText = isPlaying ? 'Playing' : 'Paused';

      final candidate = _LastSent(
        details: details,
        state: state,
        isPlaying: isPlaying,
        startTs: startTs,
        endTs: endTs,
        largeImageKey: largeImageKey,
        largeImageText: largeImageText,
        smallImageKey: smallImageKey,
        smallImageText: smallImageText,
      );
      if (_lastSent != null && _lastSent! == candidate) return;
      _lastSent = candidate;

      rpc.updatePresence(
        DiscordPresence(
          details: candidate.details,
          state: candidate.state,
          startTimeStamp: candidate.startTs,
          endTimeStamp: candidate.endTs,
          largeImageKey: candidate.largeImageKey,
          largeImageText: candidate.largeImageText,
          smallImageKey: candidate.smallImageKey,
          smallImageText: candidate.smallImageText,
        ),
      );
    } catch (e) {
      log('Discord RPC error: $e', name: 'DiscordService');
    }
  }

  /// Picks the best available cover URL for the track, or null.
  /// Prefers high-res -> standard -> low-res. Requires HTTPS.
  static String? _bestCover(Track track) {
    final t = track.thumbnail;
    String? pick = (t.urlHigh != null && t.urlHigh!.isNotEmpty)
        ? t.urlHigh
        : (t.url.isNotEmpty ? t.url : null);
    pick ??= (t.urlLow != null && t.urlLow!.isNotEmpty) ? t.urlLow : null;
    if (pick == null) return null;
    if (!pick.startsWith('https://')) return null;
    return pick;
  }

  /// Clears Discord presence.
  static void clearPresence() {
    _activeTrackId = null;
    _trackStartEpochSec = null;
    _lastSent = null;
    final rpc = _discordRPC;
    if (rpc == null) return;
    if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) return;
    try {
      rpc.clearPresence();
    } catch (e) {
      log('Discord clearPresence failed: $e', name: 'DiscordService');
    }
  }
}

/// Fields whose values actually affect what Discord renders.
class _LastSent {
  final String? details;
  final String? state;
  final bool isPlaying;
  final int? startTs;
  final int? endTs;
  final String? largeImageKey;
  final String? largeImageText;
  final String? smallImageKey;
  final String? smallImageText;

  const _LastSent({
    required this.details,
    required this.state,
    required this.isPlaying,
    required this.startTs,
    required this.endTs,
    required this.largeImageKey,
    required this.largeImageText,
    required this.smallImageKey,
    required this.smallImageText,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _LastSent &&
          details == other.details &&
          state == other.state &&
          isPlaying == other.isPlaying &&
          startTs == other.startTs &&
          endTs == other.endTs &&
          largeImageKey == other.largeImageKey &&
          largeImageText == other.largeImageText &&
          smallImageKey == other.smallImageKey &&
          smallImageText == other.smallImageText;

  @override
  int get hashCode => Object.hash(
        details,
        state,
        isPlaying,
        startTs,
        endTs,
        largeImageKey,
        largeImageText,
        smallImageKey,
        smallImageText,
      );
}
