## [1.6.0] - 2026-06-01

### Improvements & Fixes
- **Plugin Loading & Playback Resolution**: Fixed the critical song playback issue ("Unable to start playback for this playlist") affecting remote tracks (JioSaavn / YTMusic) by expanding Dart success checks to include `PluginInstallStatus.pluginLoaded` so loaded plugins register correctly in global runtime state.
- **Persistent Plugin States**: Fixed an issue where the plugin installation state reverted from "Installed" to "Install" on exiting the repository detail screen. Plugin auto-load states are now safely written to persistence regardless of transient failures.
- **Default Plugin Auto-Healing**: Implemented self-healing startup logic that automatically registers currently selected default plugins (Home, Search, and Suggestion providers) into the startup auto-load list, ensuring seamless out-of-the-box performance.
- **YTMusic Sync Loop Resolution**: Corrected version checker logic to look for version `>= 1` instead of `2` to match the official remote repository metadata, ending infinite background repository sync cycles.
- **Premium Lottie Equalizer Animation**: Integrated an eye-catching, high-quality Lottie equalizer animation during startup and plugin setup views, transitioning into a seamless checkmark on success.
- **Instant Cold Startup**: Tuned session restore delays, shortening launch times from 500ms to a snappy 100ms.
- **Restored Playback Activation**: Resolved an issue where a restored song from a previous session would fail to start playing on app launch. The playback engine now automatically resolves and loads the track metadata and stream on initial play command.
- **Bypass Plugin Country Restrictions**: Enhanced the Rust-side plugin unpacker to bypass country allowlist checks when the policy country code is empty, enabling successful installation of plugins with country restrictions (e.g., JioSaavn restricted to IN).
- **Accurate Plugin Installation Reporting**: Fixed state propagation in `PluginBloc` so that installation failures are correctly reported as errors. This prevents the repository detail screen from falsely showing a failed installation as "Installed".

## [1.5.1] - 2026-04-11

### New Features
- **Turbo APK Updates**: Implemented Parallel Chunked Downloading for in-app updates, boosting speeds by up to 3x using concurrent range requests.
- **Premium Update Experience**: Redesigned the update notification into a high-end, glassmorphic bottom sheet with neon accents and blur effects.
- **"Tap to Play" Notifications**: Tapping a smart suggestion notification now launches the app and immediately starts playing the suggested track.
- **Interactive Playlist Generation**:
  - Added a **Track Count Slider** (10-50 songs) to let users choose the length of their AI-generated playlists.
  - Added a **Real-time Percentage Progress** animation during song resolution.
- **Gemini "Safe Mode"**: Stabilized the Generative AI service by migrating to an internal model-agnostic regex parser, resolving persistent API 400 errors.
- **Smart Re-engagement Notifications**: Implemented a local "Smart Suggestions" engine that invites users back if they've been away for 48+ hours.
  - **7-Day Trending Logic**: Dynamically identifies and suggests the user's #1 most-played song from the last 7 days.
  - **BigPicture Artistic Notifications**: High-quality, full-width album artwork displayed directly in the notification drawer for a premium look.
  - **Genre-Aware Dynamic Messaging**: Notification text changes based on the song's "vibe" (e.g., Rock: *"Ready to rock? 🤘"*, Lofi: *"Relax and unwind... 🌸"*) to feel personal and fresh.
  - **Auto-Cancellation**: Intelligent background management ensures notifications are automatically cancelled as soon as you re-open the app.
- **Expanded Authentication Suite**: Complete overhaul of the sign-in experience.
  - **Email & Password Support**: Full support for traditional account creation and login.
  - **Passwordless "Magic Links"**: Users can sign in securely with one tap via their email inbox.
  - **Temp Mail Blocker**: Security layer that rejects registration from hundreds of known disposable email providers (e.g., @mailinator.com).
  - **Integrated Recovery**: Self-service "Forgot Password" flow for effortless account recovery.

### Improvements
- **GitHub-First Strategy**: Migrated the default update source from SourceForge to GitHub for enhanced reliability and faster releases.
- **Auth Reliability**: Resolved "Site Not Found" errors in the Magic Link flow by switching to the official Firebase Auth Action Handler.
- **Smart Quota Handling**: Added user-friendly error messages and advice for Gemini API 429 (Quota Exceeded) errors.

### Fixed
- **Build & Theme Stability**: Fixed static vs instance member access errors in the theme kit and internal RandomAccessFile method mismatches.
- **WASM Plugin Execution**: Fixed a critical execution crash ("WASM execution error / Cannot start a runtime from within a runtime") on Android when WASM plugins attempted to fetch external ciphers (e.g., YouTube `base.js`). This stabilizes network processing for the `contentResolver` and other plugins.
- **Startup Crash**: Fixed a critical Crashlytics exception (`Unable to detect current Android Activity`) occurring randomly on app launch caused by the notification permission dialog attempting to display before the UI was fully drawn.
- **False Fatal Crashes**: Fixed an issue where transient network errors (like failing to download album art or `HandshakeException`) were incorrectly reported to Firebase Crashlytics as fatal app crashes. These general socket exceptions are now properly logged as non-fatal events, while 404 image load errors are completely suppressed to reduce noise.
- **Cloud Sync Crash**: Fixed a state assertion crash that occurred when users exited the Cloud Sync settings page before an active synchronization completed.
- **High Refresh Rate Crash**: Fixed an `Activity not attached to plugin` exception occurring on start-up. The display mode adjustment now properly waits for the Android Activity to fully attach before executing.
- **Player State Crash**: Fixed a `Bad state: Cannot add new events after calling close` streaming state error in both the Player Error Handler and Queue Manager. This occurred if users rapidly tapped to play a track or load a queue immediately while or after the player engine was being destroyed.
- **Player Cleanup Crash**: Fixed a `Null check operator used on a null value` framework crash when the player screen was navigated away from. The UI component was attempting to resolve dependencies over a disconnected context tree.
- **Onboarding Navigation Crash**: Fixed a `RangeError (start): Invalid value: Not in inclusive range` crash in `go_router` occurring when a user finished the Initial Preferences setup. Navigating directly to the absolute destination path reliably bypasses an internal router substring mismatch bug.

## [1.5.0] - 2026-04-03

### New Features
- **Visual Overhaul (Previews)**: Implemented 4-image grid thumbnails for playlists and "Downloaded Songs" section for a more modern library feel.
- **Authentic Artists**: Replaced generic placeholders with high-quality, authentic artist portraits in preference selection.

### Improvements
- **Data Privacy & Performance**: Enhanced sign-out process with automatic local database and cache cleanup (Isar & system cache).
- **Dynamic Data Resolution**: Upgraded library engine to handle asynchronous multi-image resolution for playlist covers.
- **Visual Polish**: Removed unnecessary emojis and punctuation from update notifications for a cleaner UI.

### Fixed
- **Critical Navigation Fix**: Resolved issue where the login screen incorrectly appeared inside the Home tab navigation stack after sign-out.
- **Fixed Preference Selection**: Resolved issue where artist images weren't loading and improved "Skip/Finish" button reliability.
- **Local Storage**: Improved reliability of data purge operations when switching accounts.

## [1.4.0] - 2026-03-21


### Added
- **Local Music Support Available Now**: Introduced the local music playing in the device.
- **New Plugin Runtime [bex]**: Introduced a Rust-backed plugin system built with waclay + wasmi, loading, unloading, execution, and updates.
- **Lyrics Viewer + Lyrics Offset**: You can now offset lyrics if lyrics are not syncing up.
- **Equalizer support now available**: Equalizer support is now available for all devices😊.
- **Languages support is expanding**: Strings are localized so soon you will have Beats in your own languages.
- **Karaoke style Lyrics**: Bydefault we will now have karaoke style lyrics player.
- **Playlist ordering and pinning**: Playlists in library can now be pinned or reordered as user wants.
- **Crossfade support**: Crossfade is now supported for all device.
- **Smart Replace**: Sometimes some remote song may get dead to revive them using differnt song and replace in your playlist this feature will help you to replace the songs inside your playlist with working tracks.
- **Refresh Metadata**: Can now refresh the old metadata if the track metadata is fuzzy.
- **Plugin Types**:
    - `contentResolver`: search, details, media resolution, home/discover sections.
    - `chartProvider`: chart listings and chart detail feeds.
    - `lyricsProvider`: synced and plain lyrics providers.
    - `searchSuggestionProvider`: query suggestions/autocomplete.
    - `contentImporter`: plugin-driven import flows for external collections.
- **Plugin Repository Bootstrap**: Added hosted repository bootstrap, one-time setup flow, repository syncing, and install-on-bootstrap logic.
- **Plugin Auto-Update Pipeline**: Added background repository sync with semantic version comparison and automatic plugin updates.
- **Country-Aware Plugin Distribution**: Added `country_allowlist` support in repository manifests and packed plugin install validation.
- **Country Detection Service**: Added normalized country detection with caching and fallback strategy for first-run reliability.
- **Plugin Response Caching**: Added in-memory + persisted cache flow for plugin data (discover/charts/details).
- **Plugin Priority Controls**: Added resolver/lyrics priority settings and plugin default auto-selection.
- **Richer Plugin Commands**: Expanded plugin command surface (track/album/artist/playlist details, suggestions, lyrics, segments, import operations, collection metadata).
- **Plugin Importer Improvements**: Refactored importer flow to integrate plugin-backed source parsing and internal collection mapping.
- **Cross-Plugin Resolution**: Added fallback and replacement logic for unavailable tracks and dead source links.
- **Smart Playback Recovery**: Added stronger recovery and fallback paths for interrupted/failed streaming operations.
- **Local + Remote Unified Playback**: Added improved local content pathing and plugin-backed remote resolution coexistence.
- **Keyboard Shortcut Enhancements**: Added desktop-focused shortcut improvements and shortcut feedback indicator improvements.
- **UI/UX Refreshes**:
    - Redesigned mini-player and player settings surfaces.
    - Enhanced chart, search, and playlist browsing experiences.
    - Improved context actions and visual transitions.
- **Localization Expansion**: Added/updated large batches of localized strings for plugin and setup workflows.

### Changed
- **Architecture Migration (v3 line)**: Shifted from tightly coupled source integrations to a plugin-first modular architecture.
- **Data/Storage Refactors**: Large refactor across repository/DAO/state boundaries to support plugin-native IDs and content abstractions.
- **Downloader Evolution**: Moved major parts of downloading workflow toward Rust-backed internals and improved tracking pipeline.
- **Player Engine Stability**: Refactored queue, transitions, crossfade flow, and error handling to reduce edge-case dead states.
- **Settings Defaults & Normalization**:
    - Crossfade default aligned to `2s` across UI + runtime restore paths.
    - Streaming quality default aligned to `High` across settings + resolver usage.
    - Country default standardized to `US` with one-time normalization and persistence.
- **Bootstrap Reliability**: Removed fragile reachability gate that could produce false "offline" setup failures.
- **Manifest Compatibility**: Improved manifest-version parsing and compatibility handling in update checks.
- **Theme/Style Modernization**: Completed broad `withOpacity` migration to `withValues` and related visual consistency cleanups.

### Fixed
- Fixed plugin setup stalls around early bootstrap progress caused by strict network/country resolution paths.
- Fixed auto-update gating that skipped valid plugin updates under older manifest value formats.
- Fixed defaults mismatch where settings UI values could differ from runtime player behavior until manual toggle.
- Fixed crossfade runtime restore fallback inconsistency that could disable crossfade on first launch.
- Fixed stream quality fallback inconsistency causing startup playback to prefer lower quality than settings state.
- Fixed multiple queue/player edge cases: skip/advance races, dead loading states, and stale resolver transitions.
- Fixed repository/bootstrap failure handling and improved retry resilience for plugin setup/update flows.
- Fixed numerous UI state sync issues in search, playlist, and details surfaces.
-Resolved a delay issue where the mini-player would sometimes fail to appear; it now opens instantly when music starts.
- Fixed an issue where plugins would occasionally turn off automatically; enabled state is now correctly persisted.

### Removed
- Legacy migration scripts and redundant casing-fix utilities.

### Developer Notes
- Legacy source-specific identifiers are retained only where required for migration compatibility and old data mapping.
- The recommended integration path is now fully plugin-based through repository manifests and `.bex` package installation.

## v1.2.0 - 2026-01-02

### 🚀 Performance & Playback
- **High-Speed Preloading**: Dramatically reduced latency by preloading up to 3 tracks in the queue.
- **Deep Buffering**: Configured aggressive buffering logic to prevent playback interruptions in low-signal areas.
- **Local Stream Caching**: Implemented `LockCachingAudioSource` to save bandwidth and enable offline-ready replays of recently streamed tracks.
- **Equalizer Pro**: Re-engineered the audio pipeline for zero-latency equalizer updates and smoother sound processing.

### ✨ AI & Discovery
- **Smart Recommendations**: A new recommendation engine that learns from your skips and plays.
- **Trending 2.0**: Enhanced trending algorithm with localized chart support and genre-based popularity scoring.
- **Refined Suggestions**: Improved search auto-complete with better relevance and faster response times.

### 🎨 UI & UX Improvements
- **Animated Shimmers**: Replaced static loaders with smooth, modern shimmering effects.
- **Player Redesign**: Micro-animations on play/pause and like buttons, and refined album art scaling.
- **Library Sync**: Faster DB queries for "Liked Songs" and "Recently Played" sections.

---

## v1.1.0 - 2025-12-17

### 🚀 Performance & Connectivity
- **Telegram Integration**: Added official "Join Channel" button in About screen.
- **Login Fix**: Resolved startup hang on Pixel 5a devices (Async Sync).
- **Lag-Free Scroll**: Optimized memory usage for high-quality images.
- **Storage Optimization**: Implemented auto-cleaning cache (Max 200 items).

### ✨ Enhancements
- **Trending**: Smarter algorithm with diverse song suggestions.
- **Equalizer**: Real-time slider updates (Fixed UI lag).
- **UI**: Added Copyright 2025 to About screen.

---

## v1.0.0 - 2025-12-06

### ✨ Features
- **Smart Discovery**:
  - Instant access to "Your Top Mix", "Discover Weekly", and "Release Radar"
  - Quick Access grid for Liked Songs and Recently Played
  - AI-powered "Made For You" mixes based on listening history
- **Universal Search**:
  - Unified search across YouTube Music, Spotify, and JioSaavn
  - Search by Song, Album, Artist, or Playlist
  - Import external playlists via URL
- **Premium Library**:
  - Organized "Liked Songs" with one-tap access
  - Dedicated "Downloads" section for offline playback
  - Local music support
- **Advanced Player**:
  - High-quality streaming (up to 320kbps)
  - Synchronized Lyrics support
  - Sleep Timer (15min to 1 hour)
  - Background playback with notification controls
- **Customization & UI**:
  - Floating iOS-style "Bubble" notifications
  - Modern "Beats Green" dark theme
  - Smooth animations and transitions
  - Data saver options for streaming and downloading

---