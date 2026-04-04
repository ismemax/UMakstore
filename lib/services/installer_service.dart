import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/app_model.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:async';

class InstallerService with ChangeNotifier {
  // Singleton pattern
  static final InstallerService _instance = InstallerService._internal();
  factory InstallerService() => _instance;
  InstallerService._internal();

  final Dio _dio = Dio();
  final Map<String, AppModel> _apps = {};
  final Map<String, Timer?> _installationCheckers = {};
  final Set<String> _uninstallingIds = {}; // Tracks currently removing apps
  static const _channel = MethodChannel('com.example.umakstore/storage');

  AppModel? getApp(String id) => _apps[id];

  Future<void> installApp(AppModel app) async {
    if (app.status == AppStatus.downloading || app.status == AppStatus.installing) {
      return;
    }

    _apps[app.id] = app;
    app.status = AppStatus.downloading;
    app.progress = 0.0;
    notifyListeners();

    try {
      // 1. Check Permissions (Android Specific)
      if (Platform.isAndroid) {
        final status = await Permission.requestInstallPackages.request();
        if (status.isDenied) {
          app.status = AppStatus.notInstalled;
          notifyListeners();
          return;
        }
      }

      // 2. Setup Save Path
      final tempDir = await getTemporaryDirectory();
      final String savePath = "${tempDir.path}/${app.id}.apk";

      // CLEANUP: If an old APK exists, delete it first to avoid installing the wrong app
      final oldFile = File(savePath);
      if (await oldFile.exists()) {
        await oldFile.delete();
      }

      // 3. Download
      int lastUpdate = 0;
      await _dio.download(
        app.downloadUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            app.progress = received / total;
          } else {
            // If total is unknown, set progress to -1 to indicate indeterminate state
            app.progress = -1.0;
          }
          
          // Throttle UI updates to once every 100ms for performance
          final now = DateTime.now().millisecondsSinceEpoch;
          if (now - lastUpdate > 100) {
            lastUpdate = now;
            notifyListeners();
          }
        },
      );

      // 4. Installing
      app.status = AppStatus.installing;
      notifyListeners();

      // 5. Trigger Native Installation
      final result = await OpenFilex.open(savePath);

      if (result.type == ResultType.done) {
        app.status = AppStatus.installing; // Keep as installing until verified
        _startInstallationCheck(app); // Start polling
        await persistAppStatus(app.id, true);
      } else {
        app.status = AppStatus.notInstalled;
        debugPrint('Installation failed: ${result.message}');
      }
    } catch (e) {
      app.status = AppStatus.notInstalled;
      app.errorMessage = e.toString();
      debugPrint('Error during installation: $e');
    } finally {
      notifyListeners();
    }
  }

  void _startInstallationCheck(AppModel app) {
    if (_installationCheckers[app.id]?.isActive ?? false) return;
    
    int checks = 0;
    _installationCheckers[app.id] = Timer.periodic(const Duration(seconds: 3), (timer) async {
      checks++;
      await updateAppStatus(app);
      
      // Stop checking if installed or after 5 mins
      if (app.status == AppStatus.installed || checks > 100) {
        timer.cancel();
        _installationCheckers[app.id] = null;
      }
    });
  }

  void _startUninstallationCheck(AppModel app) {
    if (_installationCheckers[app.id]?.isActive ?? false) return;
    
    int checks = 0;
    _installationCheckers[app.id] = Timer.periodic(const Duration(seconds: 3), (timer) async {
      checks++;
      debugPrint('Polling for uninstallation of ${app.packageName} (Check $checks)...');
      await updateAppStatus(app);
      
      // Stop checking if NOT installed (uninstalled successful) or after 5 mins
      if (app.status == AppStatus.notInstalled || checks > 100) {
        _uninstallingIds.remove(app.id); // Guard against stuck status
        timer.cancel();
        _installationCheckers[app.id] = null;
        notifyListeners();
      }
    });
  }

  Future<String?> uninstallApp(AppModel app) async {
    if (app.packageName == null) return "Package name is missing.";
    
    _uninstallingIds.add(app.id); // Guard the status
    app.status = AppStatus.uninstalling;
    notifyListeners();

    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('uninstallApp', {'packageName': app.packageName});
        // Start checking for uninstallation status
        _startUninstallationCheck(app);
        return null;
      } on PlatformException catch (e) {
        debugPrint("Failed to uninstall app: '${e.message}'.");
        return e.message;
      }
    }
    return "Unsupported platform";
  }

  Future<void> launchApp(AppModel app) async {
    if (app.packageName != null) {
      await LaunchApp.openApp(
        androidPackageName: app.packageName!,
        iosUrlScheme: '', // Implement if needed
        appStoreLink: '',
      );
    }
  }

  Future<void> persistAppStatus(String id, bool installed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('installed_$id', installed);
    if (installed) {
      await persistLibraryStatus(id, true);
    }
  }

  Future<bool> getPersistedStatus(String id) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('installed_$id') ?? false;
  }

  Future<void> persistLibraryStatus(String id, bool inLibrary) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('library_$id', inLibrary);
  }

  Future<bool> getPersistedLibraryStatus(String id) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('library_$id') ?? false;
  }

  Future<void> updateAppStatus(AppModel app) async {
    // 1. Check persistent memory first for a quick answer (by ID)
    final persisted = await getPersistedStatus(app.id);
    final inLibrary = await getPersistedLibraryStatus(app.id);
    
    app.isInLibrary = inLibrary;

    if (persisted) {
      app.status = AppStatus.installed;
      // Note: We don't notifyListeners here yet to avoid excessive rebuilds if in a loop
    }

    if (app.packageName == null) return;
    
    try {
      // 2. Cross-reference with the ACTUAL device (Gold Standard)
      final isInstalled = await LaunchApp.isAppInstalled(
        androidPackageName: app.packageName!,
        iosUrlScheme: '',
      );
      
      if (isInstalled) {
        if (_uninstallingIds.contains(app.id)) {
           app.status = AppStatus.uninstalling;
        } else {
           app.status = AppStatus.installed;
           app.isInLibrary = true;
           // Ensure persistence is up to date
           if (!persisted) await persistAppStatus(app.id, true);
           if (!inLibrary) await persistLibraryStatus(app.id, true);
        }
      } else {
        // App is NOT installed on device
        _uninstallingIds.remove(app.id); // Done removing if it was in set
        
        // Only mark as not installed if we were NOT just installing it
        if (app.status != AppStatus.downloading && app.status != AppStatus.installing) {
          app.status = AppStatus.notInstalled;
          if (persisted) await persistAppStatus(app.id, false);
        }
      }
    } catch (e) {
      debugPrint('Error checking app status for ${app.packageName}: $e');
    }
  }

  Future<void> updateAllStatuses(List<AppModel> apps) async {
    for (var app in apps) {
      await updateAppStatus(app);
    }
    notifyListeners();
  }

  Future<void> removeFromLibrary(AppModel app) async {
    app.isInLibrary = false;
    await persistLibraryStatus(app.id, false);
    notifyListeners();
  }
}
