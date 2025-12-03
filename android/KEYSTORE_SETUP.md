# Keystore Setup Guide for Beats Music
# =====================================
# Developer: Aadith C V
# =====================================

## Step 1: Generate Your Keystore

Run this command in the `android/app` directory:

```bash
keytool -genkey -v -keystore beats-music-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias beats-music-key
```

You will be prompted to enter:
- Keystore password (remember this!)
- Key password (remember this!)
- Your name
- Organization
- City/Locality
- State/Province
- Country code

## Step 2: Create key.properties File

1. Copy the template:
   ```bash
   cp key.properties.template key.properties
   ```

2. Edit `key.properties` with your actual values:
   ```properties
   storePassword=YOUR_KEYSTORE_PASSWORD
   keyPassword=YOUR_KEY_PASSWORD
   keyAlias=beats-music-key
   storeFile=beats-music-keystore.jks
   ```

## Step 3: Place Your Keystore

Move your generated `.jks` file to the `android/app` directory:
```bash
mv beats-music-keystore.jks android/app/
```

## Step 4: Build Release APK

Now you can build a signed release APK:
```bash
flutter build apk --release
```

## Important Notes

⚠️ **SECURITY**:
- Never commit `key.properties` to Git (it's in .gitignore)
- Never commit your `.jks` keystore file to Git
- Keep backups of both files in a secure location
- If you lose your keystore, you cannot update your app on Play Store

✅ **VERIFIED**:
- The build.gradle.kts now reads from key.properties
- No hardcoded credentials
- Your custom signature is in all configuration files

## Troubleshooting

If build fails:
1. Check that `key.properties` exists in `android/` directory
2. Verify all passwords are correct
3. Ensure keystore file path is correct
4. Check that keystore file exists in specified location

## Current Configuration

Your build.gradle.kts will now:
- ✅ Read keystore path from key.properties
- ✅ Read passwords from key.properties  
- ✅ Read key alias from key.properties
- ✅ Show helpful messages during build
- ✅ Fall back to debug signing if key.properties not found
