import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:beats_music/plugins/errors/plugin_exceptions.dart';
import 'package:beats_music/services/db/dao/settings_dao.dart';
import 'package:beats_music/services/db/db_provider.dart';
import 'package:beats_music/src/rust/api/bridge.dart' as bridge;
import 'package:beats_music/src/rust/api/plugin/commands.dart';
import 'package:beats_music/src/rust/api/plugin/manifest.dart';
import 'package:beats_music/src/rust/api/plugin/models.dart';
import 'package:beats_music/src/rust/api/plugin/plugin.dart';
import 'package:beats_music/src/rust/api/plugin/plugin_info.dart';
import 'package:beats_music/src/rust/api/plugin/types.dart';
import 'package:beats_music/services/plugin/plugin_event_bus.dart';
import 'package:beats_music/src/rust/api/plugin/events.dart';
import 'package:beats_music/utils/country_info.dart';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// The main Dart-side interface to the Rust plugin system.
///
/// This is the **single source of truth** for all plugin operations.
/// No other class should call Rust bridge functions directly.
///
/// Responsibilities:
///   - Create and own the [PluginManager] (Rust opaque handle).
///   - Execute typed [PluginRequest] commands and return [PluginResponse].
///   - Load / unload / install plugins.
///   - Expose discovery: available plugins, loaded plugins, plugin info.
///   - Map Rust error strings to typed [PluginException] hierarchy.
///
/// Thread safety: all operations are `async` and serialized by Rust.
/// The [PluginManager] itself is protected by `RwLock` on the Rust side.
class PluginService {
  PluginManager? _manager;
  Future<void>? _initializing;

  /// Whether the service has been initialized.
  bool get isInitialized => _manager != null;

  /// The Rust [PluginManager] handle. Throws if not initialized.
  PluginManager get manager {
    final m = _manager;
    if (m == null) {
      throw StateError(
          'PluginService not initialized or deactivated. Check isInitialized.');
    }
    return m;
  }

  bool _isDeactivated = false;
  bool get isDeactivated => _isDeactivated;

  // ── Simulated Plugin State (Safe Mode) ──────────────────────────────────────
  final Set<String> _simulatedInstalledIds = {};
  final Set<String> _simulatedLoadedIds = {};

  /// Get the set of currently simulated installed plugin IDs.
  Set<String> get simulatedInstalledIds => _simulatedInstalledIds;

  // ── Initialization ─────────────────────────────────────────────────────────

  /// Initialize the plugin service.
  ///
  /// Creates the Rust [PluginManager] with the given [pluginsDir].
  /// If [pluginsDir] is null, defaults to `{appSupport}/plugins/`.
  ///
  /// Must be called once during app startup, before any plugin operations.
  Future<void> initialize({String? pluginsDir}) async {
    if (_manager != null) {
      log('PluginService already initialized', name: 'PluginService');
      return;
    }

    final inFlight = _initializing;
    if (inFlight != null) {
      await inFlight;
      return;
    }

    final future = _initializeInternal(pluginsDir: pluginsDir);
    _initializing = future;

    try {
      await future;
    } finally {
      if (identical(_initializing, future)) {
        _initializing = null;
      }
    }
  }

  Future<void> _initializeInternal({String? pluginsDir}) async {
    if (_manager != null) {
      return;
    }

    final dir = pluginsDir ?? await _defaultPluginsDir();

    // Ensure directory exists.
    final pluginDir = Directory(dir);
    if (!await pluginDir.exists()) {
      await pluginDir.create(recursive: true);
      log('Created plugins directory: $dir', name: 'PluginService');
    }

    try {
      _manager = await bridge.createPluginManager(pluginsDir: dir);
      log('PluginService initialized (pluginsDir: $dir)', name: 'PluginService');
    } catch (e) {
      _isDeactivated = true;
      log('PluginService deactivating: Rust bridge failed to initialize. $e',
          name: 'PluginService');
    }
  }

  Future<String> _defaultPluginsDir() async {
    final appSupportDir = await getApplicationSupportDirectory();
    return p.join(appSupportDir.path, 'plugins');
  }

  // ── Command Execution ──────────────────────────────────────────────────────

  /// Execute a typed plugin command and return the response.
  ///
  /// This is the primary API for all plugin interactions.
  /// Throws [PluginNotLoadedException] if the plugin is not loaded.
  /// Throws [PluginExecutionException] if the command fails.
  Future<PluginResponse> execute({
    required String pluginId,
    required PluginRequest request,
  }) async {
    if (_isDeactivated) {
      return _executeSimulated(pluginId, request);
    }
    try {
      final response = await bridge.handlePluginRequest(
        manager: manager,
        pluginId: pluginId,
        request: request,
      );
      // IDs are stamped on the Rust side before crossing the FRB boundary.
      return response;
    } catch (e) {
      throw _mapError(pluginId, e);
    }
  }

  Future<PluginResponse> _executeSimulated(
      String pluginId, PluginRequest request) async {
    log('PluginService (Simulated): Executing for $pluginId',
        name: 'PluginService');

    return request.when(
      contentResolver: (cmd) => cmd.when(
        search: (query, filter, pageToken) async {
          try {
            final encodedQuery = Uri.encodeComponent(query);
            final url =
                'https://itunes.apple.com/search?term=$encodedQuery&media=music&limit=25';
            final response = await http.get(Uri.parse(url));
            if (response.statusCode == 200) {
              final data = jsonDecode(response.body);
              final results = (data['results'] as List).map((item) {
                final artworkUrl = (item['artworkUrl100'] as String?)
                    ?.replaceAll('100x100', '500x500');
                final artwork = artworkUrl != null
                    ? Artwork(url: artworkUrl, layout: ImageLayout.square)
                    : const Artwork(url: '', layout: ImageLayout.square);
                return MediaItem.track(Track(
                  id: 'itunes::${item['trackId']}',
                  title: item['trackName'] ?? 'Unknown',
                  artists: [
                    ArtistSummary(
                        id: 'itunes::${item['artistId']}',
                        name: item['artistName'] ?? 'Unknown'),
                  ],
                  album: AlbumSummary(
                    id: 'itunes::${item['collectionId']}',
                    title: item['collectionName'] ?? 'Unknown',
                    artists: [],
                    thumbnail: artwork,
                  ),
                  thumbnail: artwork,
                  durationMs: BigInt.from(
                      (item['trackTimeMillis'] ?? 0) as int),
                  isExplicit: false,
                  url: item['trackViewUrl'],
                ));
              }).toList();
              return PluginResponse.search(
                  PagedMediaItems(items: results, nextPageToken: null));
            }
          } catch (e) {
            log('Simulated Search Error: $e');
          }
          return PluginResponse.search(
              const PagedMediaItems(items: [], nextPageToken: null));
        },
        getAlbumDetails: (id) async =>
            throw const PluginExecutionException(pluginId: 'simulated', message: 'Not implemented'),
        getArtistDetails: (id) async =>
            throw const PluginExecutionException(pluginId: 'simulated', message: 'Not implemented'),
        getPlaylistDetails: (id) async =>
            throw const PluginExecutionException(pluginId: 'simulated', message: 'Not implemented'),
        getStreams: (id) async => PluginResponse.streams(const []),
        getHomeSections: () async {
          try {
            final url =
                'https://itunes.apple.com/us/rss/topsongs/limit=20/json';
            final response = await http.get(Uri.parse(url));
            if (response.statusCode == 200) {
              final data = jsonDecode(response.body);
              final entries = (data['feed']['entry'] as List);
              final items = entries.map((e) {
                final imageUrl = (e['im:image'] as List).last['label'] as String;
                final trackId = e['id']['attributes']['im:id'] as String;
                final artistName = e['im:artist']['label'] as String;
                final albumTitle = e['im:collection']['im:name']['label'] as String;
                return MediaItem.track(Track(
                  id: 'itunes::$trackId',
                  title: e['im:name']['label'] as String,
                  artists: [ArtistSummary(id: 'itunes::artist', name: artistName)],
                  album: AlbumSummary(
                    id: 'itunes::album',
                    title: albumTitle,
                    artists: [],
                    thumbnail: Artwork(url: imageUrl, layout: ImageLayout.square),
                  ),
                  thumbnail: Artwork(url: imageUrl, layout: ImageLayout.square),
                  durationMs: BigInt.zero,
                  isExplicit: false,
                ));
              }).toList();

              return PluginResponse.homeSections([
                Section(
                  id: 'simulated_trending',
                  title: 'Top Hits (Safe Mode)',
                  cardType: CardType.carousel,
                  items: items,
                )
              ]);
            }
          } catch (e) {
            log('Simulated Home Sections Error: $e');
          }

          return PluginResponse.homeSections([
            const Section(
              id: 'mock_trending',
              title: 'Welcome to Beats (Safe Mode)',
              cardType: CardType.carousel,
              items: [],
            )
          ]);
        },
        moreAlbumTracks: (id, pageToken) async =>
            PluginResponse.moreTracks(const PagedTracks(items: [])),
        moreArtistAlbums: (id, pageToken) async =>
            PluginResponse.moreAlbums(const PagedAlbums(items: [])),
        morePlaylistTracks: (id, pageToken) async =>
            PluginResponse.moreTracks(const PagedTracks(items: [])),
        getRadioTracks: (id, pageToken) async =>
            PluginResponse.moreTracks(const PagedTracks(items: [])),
        loadMore: (id, moreLink) async =>
            PluginResponse.loadMoreItems(const []),
        getTrackDetails: (id) async =>
            throw const PluginExecutionException(pluginId: 'simulated', message: 'Not implemented'),
        getSegmentsForTrack: (id) async => PluginResponse.segments(const []),
      ),
      chartProvider: (cmd) async => PluginResponse.charts(const []),
      lyricsProvider: (cmd) async => throw const PluginExecutionException(pluginId: 'simulated', message: 'Not implemented'),
      searchSuggestionProvider: (cmd) async =>
          PluginResponse.suggestions(const []),
      contentImporter: (cmd) async =>
          throw const PluginExecutionException(pluginId: 'simulated', message: 'Not implemented'),
    );
  }

  // ── Plugin Lifecycle ───────────────────────────────────────────────────────

  /// Load a plugin by ID and type.
  ///
  /// Throws [PluginExecutionException] if loading fails.
  Future<void> loadPlugin({
    required String pluginId,
    required PluginType pluginType,
  }) async {
    if (_isDeactivated) {
      _simulatedLoadedIds.add(pluginId);
      PluginEventBus.instance.broadcast(
          PluginManagerEvent.pluginLoaded(id: pluginId, pluginType: pluginType));
      return;
    }
    try {
      await bridge.loadPlugin(
        manager: manager,
        pluginId: pluginId,
        pluginType: pluginType,
      );
      log('Loaded plugin: $pluginId ($pluginType)', name: 'PluginService');
    } catch (e) {
      throw PluginExecutionException(
        pluginId: pluginId,
        message: 'Failed to load plugin: $e',
        cause: e,
      );
    }
  }

  /// Unload a plugin by ID and type.
  Future<void> unloadPlugin({
    required String pluginId,
    required PluginType pluginType,
  }) async {
    if (_isDeactivated) {
      _simulatedLoadedIds.remove(pluginId);
      PluginEventBus.instance
          .broadcast(PluginManagerEvent.pluginUnloaded(id: pluginId));
      return;
    }
    try {
      await bridge.unloadPlugin(
        manager: manager,
        pluginId: pluginId,
        pluginType: pluginType,
      );
      log('Unloaded plugin: $pluginId ($pluginType)', name: 'PluginService');
    } catch (e) {
      throw PluginExecutionException(
        pluginId: pluginId,
        message: 'Failed to unload plugin: $e',
        cause: e,
      );
    }
  }

  /// Install a packed plugin (.bex file).
  ///
  /// Returns [PluginInstallResult] with status and plugin ID.
  /// Throws [PluginInstallException] on failure.
  Future<PluginInstallResult> installPlugin({
    required String packedFilePath,
    bool shouldLoad = true,
    String? policyCountryCode,
  }) async {
    try {
      final packedManifest = await _readPackedManifest(packedFilePath);
      var countryCode =
          CountryInfoService.normalizeCountryCode(policyCountryCode);
      if (countryCode.isEmpty) {
        countryCode = await CountryInfoService.resolveCountryCodeForPolicyCheck(
          settingsDao: SettingsDAO(DBProvider.db),
        );
      }

      if (packedManifest.countryAllowlist.isNotEmpty &&
          (countryCode.isEmpty ||
              !packedManifest.countryAllowlist.contains(countryCode))) {
        throw PluginCountryRestrictedException(
          pluginId: packedManifest.pluginId,
          countryCode: countryCode,
          allowlist: packedManifest.countryAllowlist,
        );
      }

      if (_isDeactivated) {
        log('PluginService (Degraded): Simulating installation for ${packedManifest.pluginId}',
            name: 'PluginService');
        _simulatedInstalledIds.add(packedManifest.pluginId);
        if (shouldLoad) {
          _simulatedLoadedIds.add(packedManifest.pluginId);
        }
        // Broadcast events so PluginBloc state updates correctly
        PluginEventBus.instance
            .broadcast(PluginManagerEvent.pluginInstalled(id: packedManifest.pluginId));
        if (shouldLoad) {
          PluginEventBus.instance.broadcast(PluginManagerEvent.pluginLoaded(
              id: packedManifest.pluginId,
              pluginType: PluginType.contentResolver));
        }
        return PluginInstallResult(
          status: PluginInstallStatus.installed,
          pluginId: packedManifest.pluginId,
        );
      }

      final tempDir = (await getTemporaryDirectory()).path;
      final pluginsDir = await bridge.getPluginsDir(manager: manager);

      final result = await bridge.installPackedPlugin(
        packedFilePath: packedFilePath,
        pluginsDir: pluginsDir,
        tempDir: tempDir,
        shouldLoad: shouldLoad,
        policyCountryCode: countryCode,
        manager: manager,
      );

      if (result.status == PluginInstallStatus.failed &&
          (result.error?.contains('country') ?? false)) {
        throw PluginCountryRestrictedException(
          pluginId: result.pluginId,
          countryCode: countryCode,
          allowlist: packedManifest.countryAllowlist,
        );
      }

      log('Installed plugin: ${result.pluginId} (status: ${result.status})',
          name: 'PluginService');
      return result;
    } on PluginInstallException {
      rethrow;
    } catch (e) {
      throw PluginInstallException(
        message: 'Failed to install plugin from $packedFilePath: $e',
        cause: e,
      );
    }
  }

  /// Inspect a packed plugin (.bex file) without installing.
  ///
  /// Returns the plugin's [Manifest] for pre-install verification.
  Future<Manifest> inspectPlugin({required String packedFilePath}) async {
    final tempDir = (await getTemporaryDirectory()).path;
    return bridge.inspectPackedPlugin(
      packedFilePath: packedFilePath,
      tempDir: tempDir,
    );
  }

  // ── Discovery ──────────────────────────────────────────────────────────────

  /// Get all available plugins (scanned from plugins directory).
  Future<List<PluginInfo>> getAvailablePlugins() async {
    if (_isDeactivated) {
      // In safe mode, we can't return PluginInfo objects (Rust opaque).
      // Return empty list; simulate shows plugins as loaded via events only.
      return [];
    }
    return bridge.getAvailablePlugins(manager: manager);
  }

  /// Get IDs of currently loaded plugins (synchronous — no FFI overhead).
  List<String> getLoadedPlugins() {
    if (_isDeactivated) {
      return _simulatedLoadedIds.toList();
    }
    return bridge.getLoadedPlugins(manager: manager);
  }

  /// Check if a specific plugin is loaded.
  Future<bool> isPluginLoaded({
    required String pluginId,
    required PluginType pluginType,
  }) async {
    if (_isDeactivated) {
      return _simulatedLoadedIds.contains(pluginId);
    }
    return bridge.isPluginLoaded(
      manager: manager,
      pluginId: pluginId,
      pluginType: pluginType,
    );
  }

  /// Refresh the available plugins list (re-scan directory).
  Future<void> refreshPlugins() async {
    if (_isDeactivated) return;
    await bridge.refreshAvailablePlugins(manager: manager);
  }

  /// Delete a plugin by removing its directory from disk.
  ///
  /// If the plugin is currently loaded, it will be unloaded first.
  /// After deletion, the available plugins list is refreshed automatically.
  Future<void> deletePlugin({
    required String pluginId,
    required PluginType pluginType,
  }) async {
    if (_isDeactivated) {
      _simulatedInstalledIds.remove(pluginId);
      _simulatedLoadedIds.remove(pluginId);
      return;
    }
    final loaded = await bridge.isPluginLoaded(
      manager: manager,
      pluginId: pluginId,
      pluginType: pluginType,
    );
    if (loaded) {
      await unloadPlugin(pluginId: pluginId, pluginType: pluginType);
    }

    final info =
        await getPluginInfo(pluginId: pluginId, pluginType: pluginType);
    if (info == null) {
      throw PluginExecutionException(
        pluginId: pluginId,
        message: 'Cannot delete: plugin not found in available list',
      );
    }

    final pluginDir = Directory(info.pluginPath);
    if (await pluginDir.exists()) {
      await pluginDir.delete(recursive: true);
      log('Deleted plugin directory: ${info.pluginPath}',
          name: 'PluginService');
    }

    await refreshPlugins();
    log('Plugin deleted: $pluginId', name: 'PluginService');
  }

  /// Scan a directory for .bex (packed plugin) files.
  Future<List<String>> scanBexFiles(String directory) async {
    if (_isDeactivated) return [];
    return bridge.scanBexFiles(directory: directory);
  }

  /// Get info for a specific plugin.
  Future<PluginInfo?> getPluginInfo({
    required String pluginId,
    required PluginType pluginType,
  }) {
    return bridge.getPluginInfo(
      manager: manager,
      pluginId: pluginId,
      pluginType: pluginType,
    );
  }

  // ── Shutdown ───────────────────────────────────────────────────────────────

  /// Gracefully shut down the plugin system.
  ///
  /// Unloads all plugins and releases the Rust [PluginManager].
  Future<void> dispose() async {
    final m = _manager;
    if (m != null) {
      await bridge.shutdownPluginManager(manager: m);
      _manager = null;
    }
    _initializing = null;
    log('PluginService disposed', name: 'PluginService');
  }

  // ── Error Mapping ──────────────────────────────────────────────────────────

  /// Map raw errors from the Rust bridge to typed [PluginException].
  PluginException _mapError(String pluginId, Object error) {
    final message = error.toString();

    // Rust bridge encodes errors as "PLUGIN_ERROR::{variant}::{message}"
    if (message.contains('PLUGIN_ERROR::PluginNotLoaded')) {
      return PluginNotLoadedException(pluginId: pluginId);
    }
    if (message.contains('PLUGIN_ERROR::PluginNotFound')) {
      return PluginNotFoundException(pluginId: pluginId);
    }

    return PluginExecutionException(
      pluginId: pluginId,
      message: 'Command execution failed',
      errorCode: message,
      cause: error,
    );
  }
}

class _PackedPluginManifest {
  final String pluginId;
  final List<String> countryAllowlist;

  const _PackedPluginManifest({
    required this.pluginId,
    required this.countryAllowlist,
  });
}

Future<_PackedPluginManifest> _readPackedManifest(String packedFilePath) async {
  final bytes = await File(packedFilePath).readAsBytes();
  final archive = ZipDecoder().decodeBytes(bytes, verify: false);
  final manifestFile = archive.files.cast<ArchiveFile?>().firstWhere(
        (file) =>
            file != null &&
            file.isFile &&
            p.basename(file.name).toLowerCase() == 'manifest.json',
        orElse: () => null,
      );

  if (manifestFile == null) {
    return const _PackedPluginManifest(
        pluginId: 'unknown', countryAllowlist: []);
  }

  final manifestBytes = manifestFile.content as List<int>;
  if (manifestBytes.isEmpty) {
    return const _PackedPluginManifest(
        pluginId: 'unknown', countryAllowlist: []);
  }

  final decoded = jsonDecode(utf8.decode(manifestBytes));
  if (decoded is! Map) {
    return const _PackedPluginManifest(
        pluginId: 'unknown', countryAllowlist: []);
  }

  final json = Map<String, dynamic>.from(decoded);
  final pluginId = json['id']?.toString() ?? 'unknown';
  final countryAllowlist = (json['country_allowlist'] as List<dynamic>? ??
          const [])
      .map(
          (value) => CountryInfoService.normalizeCountryCode(value?.toString()))
      .where((value) => value.isNotEmpty)
      .toSet()
      .toList()
    ..sort();

  return _PackedPluginManifest(
    pluginId: pluginId,
    countryAllowlist: countryAllowlist,
  );
}
