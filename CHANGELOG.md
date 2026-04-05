# 📝 Development Log - UMak Store

This document tracks major changes, optimizations, and bug fixes implemented during the development of the University of Makati App Store.

---

## 📅 April 5, 2026

### 🚀 New Features & Enhancements

#### 🔔 Dual Notification System
- **System Alerts**: Integrated `flutter_local_notifications` to provide native Android/iOS status updates.
  - **Download Complete Alert**: Notifies students when an APK is ready to install.
    ```dart
    await (_notificationsPlugin as dynamic).show(
      id: 1002, // Unique ID for install
      title: 'Installation Successful',
      body: '$appName has been installed and is ready to use!',
      notificationDetails: platformChannelSpecifics,
    );
    ```
  - **Installation Success Alert**: Notifies students exactly when an app is ready to launch, even if the store is in the background.
- **In-App Alerts**: Restored Firestore-based notification streams for "Welcome" messages and personalized student alerts.
  ```dart
  // Bypassing specific type issues for initialization while troubleshooting API versions
  await (_notificationsPlugin as dynamic).initialize(
    initializationSettings: initializationSettings,
  );
  ```
- **Async Initialization**: Optimized the notification startup to be non-blocking, preventing splash-screen hangs.

#### 🏗️ Android Build & Compatibility
- **Core Library Desugaring**: Enabled Java 8+ feature support in `build.gradle.kts` using `desugar_jdk_libs:2.1.4`. This was required for modern plugin compatibility.
- **Kotlin Script Migration**: Cleaned and fixed syntax errors in the `android/app/build.gradle.kts` file.
- **Firebase Lifecycle**: Moved `Firebase.initializeApp()` to the `main()` entry point to ensure all dependent services (Firestore, Auth) are ready before the UI renders.

#### 📦 Installation Experience ("Native Feel")
- **Haptic Feedback**: Added refined vibrations for "Download Finished" and "Successfully Installed" events.
- **Smart Polling**: Implemented a background timer that monitors the device for newly installed apps, automatically turning the "Installing" button into an **"Open"** button.
- **Status Persistence**: Corrected a bug where the installer status would "flicker" between states due to local cache conflicts.

---

### 🐛 Bug Fixes
- **Fixed**: "[core/no-app] No Firebase App [DEFAULT] has been created" error during service initialization.
- **Fixed**: "Too many positional arguments" and "No named parameter" errors caused by version 21.0.0 of the notification plugin.
  ```dart
  // Using named parameters for v21.0.0 API
  await (_notificationsPlugin as dynamic).show(
    id: 1001, // Unique ID for download
    title: 'Download Complete',
    body: '$appName is ready to install',
    notificationDetails: platformChannelSpecifics,
  );
  ```
- **Fixed**: AAR Metadata checking failure in Gradle by enabling desugaring.
- **Fixed**: App Details button stuck on "Installing" by adding `notifyListeners()` to the status polling loop.

---

### 📂 Files Modified
- `lib/main.dart`: Boot sequence and Firebase initialization.
- `lib/services/notification_service.dart`: Restored Firestore methods and implemented system alerts.
- `lib/services/installer_service.dart`: Polling logic, haptic feedback, and install alerts.
- `lib/app_details_screen.dart`: UI state handling for installation transitions.
- `android/app/build.gradle.kts`: Desugaring and build dependencies.

---

## 🕒 Previous Milestones

### 🤖 Functional Automation & Integration Testing
- Implemented robust automated integration tests for multi-language localization and navigation flows.
- Added unique keys to UI components to support automated verification.
- Established a protocol for clearing storage and cache during test runs.

### 🛡️ App Installation & Authentication Fixes
- **Package Identity**: Migrated the package ID to `com.tbl.makstore` to resolve uniqueness conflicts.
- **Domain Restricted Auth**: Updated Firebase Auth to permit only `@umak.edu.ph` email addresses.
- **Google Sign-In**: Fixed the persistent "Continue with Google" flow and configured production signing to bypass Play Protect warnings.

### 🎨 UI/UX Optimization & Theming
- **Theme-Aware Refactoring**: Replaced all hardcoded colors with dynamic `ColorScheme` tokens, ensuring full support for high-contrast Light and Dark modes.
- **Visual Polish**: Implemented skeleton loading animations, pull-to-refresh, and pre-caching for app icons/images.
- **Figma Fidelity**: Optimized the **Manage Apps & Device** screen to achieve pixel-perfect alignment with design mockups.

### 🛠️ Developer Ecosystem & Features
- **Developer Portal**: Created a secure, role-based dashboard for students to submit and manage their own apps.
- **Submission Workflow**: Integrated a multi-step form with Firestore for app metadata and APK hosting.
- **Ratings & Reviews**: Developed a real-time review system with average rating calculations and duplicate review prevention.

### 💾 Storage & Native Integration
- **Storage Metrics**: Integrated native system channels to fetch real-time device storage data.
- **App Uninstallation**: Implemented a state machine to track uninstallation progress reliably across reboots.

---
*End of log.*
