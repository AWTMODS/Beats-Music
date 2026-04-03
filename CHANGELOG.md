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