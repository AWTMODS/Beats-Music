# Beats-Music Future Features Roadmap

Saved feature ideas & improvements analyzed from **Metrolist**, **Vivi-Music**, and **Mochy Music** for upcoming releases (after `v1.8.0`).

---

## 1. Lyrics Enhancements
- **Word-by-Word Karaoke Lyrics** *(Vivi-Music / Metrolist)*
  - Extend `LyricsLine` in `lib/core/models/lyrics_models.dart` to support word/syllable timestamps (`LyricsWord(text, startTime, endTime)`).
  - Support Enhanced LRC (`<mm:ss.xx>word`), TTML, and Better Lyrics / YouLyPlus JSON formats, with smooth line-level fallback.
  - Render smooth progressive word fill (`ShaderMask` / animated spans) in `fullscreen_lyrics_view.dart` driven by player position + `_lyricOffset`.
- **Lyrics Romanization & Translation** *(Metrolist / Mochy)*
  - **Romanization**: Offline transliteration (Hangul, Kana, Devanagari, Arabic, Cyrillic, etc.) in Rust (`rust/src/api/`) with a toggle to show/hide beneath non-Latin lines.
  - **Translation**: On-demand line-by-line translation into the user's app locale, cached in `LyricsDAO` (Isar) per `mediaID`.
- **Lyrics Export & Share Cards** *(Mochy)*
  - Export `.lrc` / `.txt` files or generate shareable lyric quote image cards from selected lines.
- **Floating Lyrics Overlay** *(Mochy)*
  - Optional PiP / floating lyrics window while using other apps.

## 2. Song Recognition (Shazam-style)
- **Identify Song** *(Metrolist / Vivi-Music)*
  - Mic button in Search to capture ~5–8s of `16kHz` mono PCM audio (`RECORD_AUDIO` permission, auto-pausing Beats playback while listening).
  - Generate audio fingerprint in Rust or query Shazam-compatible recognition endpoint, then open/play the matched track via active content plugins.

## 3. In-App Proxy Settings
- **HTTP / HTTPS / SOCKS5 Proxy** *(Metrolist / Mochy)*
  - Add proxy host/port/auth settings + "Test Connection" button in Settings.
  - Wire across all 3 layers:
    1. Rust `reqwest` pool (`rust/src/utils/http.rs` using `RwLock<reqwest::Client>` + `reqwest::Proxy::all`).
    2. Dart `HttpOverrides.global` / `Dio` adapter for Last.fm, OTA updates, and artwork.
    3. `media_kit` / `mpv` `http-proxy` property in `player_engine.dart`.

## 4. Audio Lab & Equalizer Presets
- **Audio Normalization / Loudness Equalization** *(Metrolist)* — `mpv` `loudnorm` / `dynaudnorm` filter.
- **Independent Pitch & Tempo Control** *(Metrolist)* — Separate pitch shifting and `scaletempo2` toggle.
- **AutoEQ Headphone Profiles** *(Mochy)* — Bundled/searchable AutoEQ 10-band presets for popular headphones/earbuds in `EqualizerView`.
- **Audio Lab Effects** *(Mochy)* — Stereo crossmix/crossfeed, bass boost, and spatial/reverb filters.

## 5. Visuals, Themes & Player Styles
- **Multiple Player Styles & Cover Gestures** *(Mochy)* — Standard, squared-artwork with cover gestures, and minimal/immersive modes.
- **Animated Motion Canvas** *(Vivi-Music)* — Subtle animated gradient motion behind player artwork (`ArtworkAmbientBackground`).
- **Blur & Animation Speed Toggle** *(Mochy)* — Performance toggle to disable heavy blurs and speed up/reduce animations on low-end devices.
- **AMOLED Pure Black, Light Mode & Preset Palettes** *(Metrolist)* — True `#000000` AMOLED mode, Light theme, and curated color palettes.

## 6. Platform & Integrations
- **Android Home Screen Widget** *(Metrolist)* — Now-playing widget with cover art, play/pause, next/prev, and like.
- **Android Auto Media Browser** *(Vivi-Music / Mochy)* — Implement `getChildren` in `BeatsMusicPlayer` (`BaseAudioHandler`) for Liked, Playlists, and Recents.
- **SponsorBlock Auto-Skip** *(Vivi-Music)* — Extend `segments_sheet.dart` to auto-skip sponsors, intros, outros, and non-music segments.
- **Libre.fm Scrobbling** *(Mochy)* — Add Libre.fm alongside Last.fm in `lib/services/scrobble/`.
