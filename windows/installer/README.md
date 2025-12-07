# Beats Music - Windows Installer Setup

This guide will help you create a professional Windows installer for Beats Music using Inno Setup.

## Prerequisites

1. **Download Inno Setup**
   - Go to: https://jrsoftware.org/isdl.php
   - Download: **Inno Setup 6.x** (latest version)
   - Install it on your Windows machine

## Creating the Installer

### Step 1: Build the Windows App
```bash
flutter clean
flutter build windows --release
```

### Step 2: Create App Icon (Optional but Recommended)
1. You need an `.ico` file for the installer icon
2. Convert your logo to `.ico` format using: https://convertio.co/png-ico/
3. Save it as: `assets/icons/beats_music_logo.ico`

### Step 3: Compile the Installer

**Option A: Using Inno Setup GUI**
1. Open **Inno Setup Compiler**
2. Click **File** → **Open**
3. Navigate to: `d:\Beats-Music\windows\installer\beats_music_setup.iss`
4. Click **Build** → **Compile** (or press F9)
5. Wait for compilation to complete

**Option B: Using Command Line**
```bash
"C:\Program Files (x86)\Inno Setup 6\ISCC.exe" "d:\Beats-Music\windows\installer\beats_music_setup.iss"
```

### Step 4: Find Your Installer
After compilation, the installer will be created at:
```
d:\Beats-Music\build\windows\installer\BeatsMusic_Setup_v1.0.0.exe
```

## What the Installer Does

✅ **Installation Features:**
- Installs to `C:\Program Files\Beats Music\`
- Creates Start Menu shortcuts
- Optional Desktop icon
- Optional Quick Launch icon (Windows 7)
- Professional uninstaller
- Requires admin privileges for proper installation

✅ **User Experience:**
- Modern wizard-style interface
- License agreement display
- Custom installation directory option
- Launch app after installation option
- Clean uninstall process

## Customization

### Change App Version
Edit line 5 in `beats_music_setup.iss`:
```iss
#define MyAppVersion "1.0.0"
```

### Change Publisher Name
Edit line 6:
```iss
#define MyAppPublisher "Your Name"
```

### Add/Remove Desktop Icon by Default
Edit line 50 (remove `unchecked` to make it default):
```iss
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}";
```

## Distribution

Once you have the installer:
1. **Test it** on a clean Windows machine
2. **Upload to GitHub Releases**
3. **Share the download link** with users

The installer is a single `.exe` file that users can download and run!

## Troubleshooting

### "Cannot find LICENSE file"
- Create a `LICENSE` file in the root directory, or
- Remove line 36 from the script:
  ```iss
  LicenseFile=..\..\LICENSE
  ```

### "Cannot find icon file"
- Create an `.ico` file, or
- Remove line 27:
  ```iss
  SetupIconFile=..\..\assets\icons\beats_music_logo.ico
  ```

### Installer size is too large
- The installer includes all DLLs and dependencies (normal for Flutter apps)
- Typical size: 40-60MB
- This is expected and cannot be reduced significantly

## Advanced: Code Signing (Optional)

For a professional release, consider code signing:
1. Purchase a code signing certificate (~$100-300/year)
2. Add to the script:
   ```iss
   SignTool=signtool sign /f "path\to\certificate.pfx" /p "password" $f
   ```

This removes the "Unknown Publisher" warning during installation.

---

**Need Help?** Check the Inno Setup documentation: https://jrsoftware.org/ishelp/
