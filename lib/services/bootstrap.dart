import 'dart:developer';
import 'dart:io' as io;

import 'package:beats_music/core/constants/setting_keys.dart';
import 'package:beats_music/core/di/service_locator.dart';
import 'package:beats_music/services/db/dao/settings_dao.dart';
import 'package:beats_music/services/local_music_service.dart';
import 'package:beats_music/services/plugin_bootstrap_service.dart';
import 'package:beats_music/services/onboarding_service.dart';
import 'package:beats_music/src/rust/frb_generated.dart';
import 'package:beats_music/services/db/db_provider.dart';
import 'package:path_provider/path_provider.dart';

void _log(String msg) {
  log(msg, name: 'BOOTSTRAP');
  io.stderr.writeln(msg);
}

/// Application bootstrap — run once before [runApp].
///
/// Responsibilities:
/// - Initialize platform path constants.
/// - Open the Isar database via [DBProvider].
/// - Schedule periodic DB maintenance tasks.
/// - Wire the [ServiceLocator] and initialize the plugin system.
Future<void> bootstrapApp() async {
  _log('[BOOTSTRAP] 1. Initializing RustLib...');
  // Initialize flutter_rust_bridge before any Rust API call.
  try {
    await RustLib.init();
    _log('[BOOTSTRAP] 1b. RustLib.init completed');
  } catch (e) {
    _log('[BOOTSTRAP] 1c. RustLib.init error: $e');
    log('Rust library initialization failed (non-fatal)',
        error: e, name: 'Bootstrap');
  }

  _log('[BOOTSTRAP] 2. Getting application paths...');
  final String appDocPath = (await getApplicationDocumentsDirectory()).path;
  final String appSuppPath = (await getApplicationSupportDirectory()).path;
  _log('[BOOTSTRAP] 2b. Paths: doc=$appDocPath, supp=$appSuppPath');

  _log('[BOOTSTRAP] 3. Initializing DBProvider...');
  // Open DB and schedule maintenance.
  await DBProvider.init(
      appSupportPath: appSuppPath, appDocumentsPath: appDocPath);
  _log('[BOOTSTRAP] 3b. DBProvider.init completed');
  DBProvider.scheduleMaintenance();

  _log('[BOOTSTRAP] 4. Wiring ServiceLocator.setup()...');
  // DI wiring (registers singletons).
  await ServiceLocator.setup();
  _log('[BOOTSTRAP] 4b. ServiceLocator.setup() completed');

  // Ensure hosted repositories are persisted in settings (idempotent).
  // Missing URLs are added, existing ones are left untouched.
  _log('[BOOTSTRAP] 5. Ensuring hosted repositories...');
  try {
    await PluginBootstrapService.ensureHostedRepositoriesPresent(
      repositoryService: ServiceLocator.pluginRepositoryService,
    );
    _log('[BOOTSTRAP] 5b. ensureHostedRepositoriesPresent completed');
  } catch (e) {
    _log('[BOOTSTRAP] 5c. ensureHostedRepositoriesPresent error: $e');
    log('Hosted repository reconciliation skipped',
        error: e, name: 'Bootstrap');
  }

  // Initialize plugin system:
  //   Creates Rust PluginManager → connects event bus →
  //   preloads storage from Isar → starts storage event handler.
  _log('[BOOTSTRAP] 6. Initializing plugin system...');
  try {
    await ServiceLocator.initializePluginSystem();
    _log('[BOOTSTRAP] 6b. initializePluginSystem completed');
    log('Plugin system initialized successfully', name: 'Bootstrap');
  } catch (e, stack) {
    _log('[BOOTSTRAP] 6c. initializePluginSystem error: $e');
    // Plugin system failure is non-fatal — the app can still run
    // with degraded functionality (no plugin content).
    log('Plugin system initialization failed (non-fatal)',
        error: e, stackTrace: stack, name: 'Bootstrap');
  }

  // Auto-scan local music folders if enabled (fire-and-forget).
  _log('[BOOTSTRAP] 7. Checking local music auto-scan...');
  try {
    final settingsDao = SettingsDAO(DBProvider.db);
    final autoScan =
        await settingsDao.getSettingBool(SettingKeys.localMusicAutoScan) ??
            true;
    if (autoScan) {
      LocalMusicService.create().scanAndPersist();
    }
    _log('[BOOTSTRAP] 7b. Local music auto-scan done');
  } catch (e) {
    _log('[BOOTSTRAP] 7c. Local music auto-scan error: $e');
    log('Local music auto-scan skipped', error: e, name: 'Bootstrap');
  }

  // Pre-load the plugin-bootstrap done-flag so that _MyAppState can check
  // it synchronously in initState() without an async call.
  _log('[BOOTSTRAP] 8. Pre-loading bootstrap flags...');
  try {
    final settingsDao = SettingsDAO(DBProvider.db);
    await OnboardingService.checkAndCacheDone(settingsDao);
    await PluginBootstrapService.checkAndCacheDone(settingsDao);
    _log('[BOOTSTRAP] 8b. Bootstrap flags pre-loaded');
  } catch (e) {
    _log('[BOOTSTRAP] 8c. Bootstrap flags error: $e');
    log('Could not load bootstrap flag (will re-run bootstrap)',
        error: e, name: 'Bootstrap');
  }
  _log('[BOOTSTRAP] 9. bootstrapApp finished completely!');
}


