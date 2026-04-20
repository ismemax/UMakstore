# Release & Deployment Guide: UMAS Android

This guide outlines the process for building and deploying a new version of the UMAS (UMak App Store) application for Android.

## 📦 Versioning Strategy

UMAS follows Semantic Versioning (`major.minor.patch+build`).
- **Major**: Breaking changes or major overhauls.
- **Minor**: New features (e.g., adding Cloudinary support).
- **Patch**: Bug fixes and minor UI tweaks.
- **Build Number**: Increments with every release to track internal builds (managed in `pubspec.yaml`).

Example: `version: 1.4.0+2`

## 🔑 Signing the App

To distribute the APK, it must be signed with the official UMak Keystore.

1. **Keystore Location**: `android/app/key.jks` (Keep this file out of source control!)
2. **Key Properties**: Create or update `android/key.properties`:
   ```properties
   storePassword=your_password
   keyPassword=your_password
   keyAlias=upload
   storeFile=../app/key.jks
   ```

## 🏗 Build Process

### 1. Pre-build checks
- Ensure `flutter analyze` passes with no issues.
- Update the version in `pubspec.yaml`.
- Run `flutter clean` then `flutter pub get`.

### 2. Generate the APK
To generate a release APK for distribution:
```bash
flutter build apk --release --split-per-abi
```
*Note: Using `--split-per-abi` reduces the file size for target devices.*

### 3. Generate the App Bundle (AAB)
If publishing to the Google Play Store (optional for university internal use):
```bash
flutter build appbundle --release
```

## 🚀 Deployment Steps

1. **Internal Distribution**:
   - Upload the generated APK (found in `build/app/outputs/flutter-apk/`) to the UMAS Admin Dashboard's "UMAS Update" section.
   - Update the `latest_version` field in the Firestore `system_config` (if applicable) to trigger update prompts for users.

2. **Firebase App Check**:
   - For every new release, ensure the SHA-256 fingerprint of your signing key is registered in the Firebase Console under App Check. This prevents the "Unauthorized Request" error in production.

## 🛠 Troubleshooting Builds

- **Multidex Issues**: If the build fails with a "Dex" error, ensure `multiDexEnabled true` is set in `android/app/build.gradle`.
- **R8/ProGuard**: If the app crashes in release but works in debug, check the R8 shrinking rules in `android/app/proguard-rules.pro` to ensure Firebase and Cloudinary classes aren't being stripped.

---
*Last Updated: April 2026*
