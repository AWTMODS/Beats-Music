
## v1.1.0 - 2025-12-14

## v1.1.0 - 2025-12-14

### ✨ New Features
- **Cloud Sync Evolution**:
  - **Two-Way Sync**: Now properly syncs "Liked Songs" and "Downloads List" across all your devices, not just playlists.
  - **Smart Device Recognition**: Identifies and logs the specific model name of the device syncing data.
  - **Restore Downloads**: New dedicated screen to easily re-download songs that were backed up to the cloud.
- **Local Music Integration**:
  - **Import from Storage**: Bulk import your local MP3s directly into a "Local Imports" playlist.
  - **Save Queue**: Added long-requested ability to save your current Now Playing queue as a new playlist.
- **Privacy & Security**:
  - Added a dedicated, in-app **Privacy Policy** screen (accessible from Drawer).
  - Improved data transparency for connected services.

### 🐛 Bug Fixes & Improvements
- **Build & Stability**:
  - Fixed compilation errors in Download Service and Restore workflow.
  - Resolved application crash when importing files with special characters in paths.
  - Standardized package versions to resolve build conflicts.
- **Logic Improvements**:
  - **Statistics**: Fixed an issue where listening stats could be undercounted during sync; now uses a smarter merge strategy.
  - **UI/UX**: Standardized toggle switch styling across all settings for better visibility and consistency.
  - **Download Manager**: Fixed metadata handling where artwork URI was causing database mismatches.
  - **UI/UX**: Corrected typos and layout issues in the Settings >> Restore menu.

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

