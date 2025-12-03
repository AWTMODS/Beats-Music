# Beats Music Update System

This file (`update.json`) controls the automatic update system for Beats Music across all platforms.

## 📋 How It Works

The app checks this file on startup to determine if a newer version is available. It compares:
- **Version numbers** (e.g., `1.0.2` vs `1.0.1`)
- **Build numbers** (e.g., `102` vs `101`)

If a newer version is found, the app shows an update dialog with a download link.

---

## 🔧 File Structure

```json
{
  "platform_releases": {
    "android": { ... },    // Android-specific release
    "windows": { ... },    // Windows-specific release
    "linux": { ... },      // Linux-specific release
    "mac": { ... }         // macOS-specific release
  },
  "release": { ... },      // Fallback/default release
  "metadata": { ... }      // Additional information
}
```

---

## 📝 How to Update This File

### When Releasing a New Version (e.g., v1.0.3):

1. **Update `pubspec.yaml`**:
   ```yaml
   version: 1.0.3+103
   ```

2. **Build for all platforms** (or just the ones you support):
   ```bash
   # Android
   flutter build apk --release
   
   # Windows
   flutter build windows --release
   
   # Linux
   flutter build linux --release
   
   # macOS
   flutter build macos --release
   ```

3. **Create a GitHub Release**:
   - Go to: https://github.com/AWTMODS/Beats-Music/releases
   - Click "Create a new release"
   - Tag: `v1.0.3`
   - Title: `Beats Music v1.0.3`
   - Upload all platform builds
   - Publish

4. **Update this `update.json` file**:
   - Change all version numbers from `1.0.2` to `1.0.3`
   - Change all build numbers from `102` to `103`
   - Update URLs to point to the new release tag
   - Update `release_date`

5. **Commit and push**:
   ```bash
   git add update.json CHANGELOG.md
   git commit -m "Release v1.0.3"
   git push
   ```

---

## 🎯 Platform-Specific Notes

### Android
- **File format**: `.apk`
- **Build command**: `flutter build apk --release`
- **Output**: `build/app/outputs/flutter-apk/app-release.apk`
- **Rename to**: `beats-music-v1.0.2+102-android.apk`

### Windows
- **File format**: `.exe` or `.msix`
- **Build command**: `flutter build windows --release`
- **Output**: `build/windows/runner/Release/`
- **Package**: Use Inno Setup or similar to create installer
- **Rename to**: `beats-music-v1.0.2+102-windows-x64.exe`

### Linux
- **File format**: `.AppImage`, `.deb`, or `.tar.gz`
- **Build command**: `flutter build linux --release`
- **Output**: `build/linux/x64/release/bundle/`
- **Package**: Use AppImageTool or create .deb package
- **Rename to**: `beats-music-v1.0.2+102-linux-x64.AppImage`

### macOS
- **File format**: `.dmg` or `.app`
- **Build command**: `flutter build macos --release`
- **Output**: `build/macos/Build/Products/Release/`
- **Package**: Create DMG using Disk Utility
- **Rename to**: `beats-music-v1.0.2+102-macos.dmg`

---

## 🔍 Version Extraction

The updater extracts version and build from the `filename` field using regex:
- **Version**: Matches `v1.0.2` → extracts `1.0.2`
- **Build**: Matches `+102` → extracts `102`

**Important**: Always include version and build in the filename!

---

## ✅ Quick Checklist for New Release

- [ ] Update version in `pubspec.yaml`
- [ ] Update `CHANGELOG.md`
- [ ] Build for all platforms
- [ ] Create GitHub Release with tag `vX.X.X`
- [ ] Upload all platform builds
- [ ] Update `update.json` with new version/build/URLs
- [ ] Update `release_date` in metadata
- [ ] Commit and push changes
- [ ] Test update detection in app

---

## 🚨 Common Issues

### Update not detected?
- Check that version/build in `filename` is higher than current
- Verify `update.json` is accessible at the URL
- Check app logs for update check errors

### Wrong platform download?
- Ensure platform-specific URLs are correct
- Verify filename contains platform identifier

### Changelog not showing?
- Ensure `CHANGELOG.md` is in repository root
- Verify it's accessible at: https://raw.githubusercontent.com/AWTMODS/Beats-Music/main/CHANGELOG.md

---

## 📚 Resources

- **Repository**: https://github.com/AWTMODS/Beats-Music
- **Releases**: https://github.com/AWTMODS/Beats-Music/releases
- **Changelog**: https://raw.githubusercontent.com/AWTMODS/Beats-Music/main/CHANGELOG.md
- **Update JSON**: https://raw.githubusercontent.com/AWTMODS/Beats-Music/main/update.json

---

## 💡 Pro Tips

1. **Test locally first**: Build and test on each platform before releasing
2. **Use consistent naming**: Keep the filename format consistent
3. **Update changelog**: Users appreciate knowing what's new
4. **Semantic versioning**: Use `MAJOR.MINOR.PATCH` format
5. **Keep old releases**: Don't delete old GitHub releases (users might need them)

---

Last updated: 2025-12-01
