import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

/// Provides hardware-level identification and tracks local device registration status.
/// 
/// This service is used to enforce security policies like single-device sessions.
class DeviceService {
  static final DeviceService _instance = DeviceService._internal();
  factory DeviceService() => _instance;
  DeviceService._internal();

  static const String _deviceIdKey = 'device_id';
  static const String _deviceRegisteredKey = 'device_registered';

  /// Retrieves a persistent, unique ID for the current device.
  /// 
  /// If no ID exists, one is generated using hardware fingerprints for consistency.
  Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if device ID already exists
    String? existingId = prefs.getString(_deviceIdKey);
    if (existingId != null) {
      return existingId;
    }

    // Generate new device ID
    String deviceId = await _generateDeviceId();
    
    // Store device ID
    await prefs.setString(_deviceIdKey, deviceId);
    
    return deviceId;
  }

  Future<String> _generateDeviceId() async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        final fingerprint = '${androidInfo.brand}-${androidInfo.model}-${androidInfo.id}-${androidInfo.version.release}';
        return _hashString(fingerprint);
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        final fingerprint = '${iosInfo.model}-${iosInfo.systemVersion}-${iosInfo.identifierForVendor}';
        return _hashString(fingerprint);
      } else {
        // Fallback for web or other platforms
        return const Uuid().v4();
      }
    } catch (e) {
      // Ultimate fallback
      return const Uuid().v4();
    }
  }

  String _hashString(String input) {
    var bytes = utf8.encode(input);
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('');
  }

  /// Collects detailed metadata about the current hardware and OS.
  /// 
  /// Used for providing diagnostic context during device registration.
  Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        return {
          'platform': 'Android',
          'brand': androidInfo.brand,
          'model': androidInfo.model,
          'version': androidInfo.version.release,
          'id': androidInfo.id,
        };
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        return {
          'platform': 'iOS',
          'model': iosInfo.model,
          'version': iosInfo.systemVersion,
          'identifier': iosInfo.identifierForVendor,
        };
      } else {
        return {
          'platform': Platform.operatingSystem,
          'version': Platform.operatingSystemVersion,
        };
      }
    } catch (e) {
      return {
        'platform': 'Unknown',
        'error': e.toString(),
      };
    }
  }

  Future<void> markDeviceAsRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_deviceRegisteredKey, true);
  }

  Future<bool> isDeviceRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_deviceRegisteredKey) ?? false;
  }

  /// Resets the local device identifiers and registration state.
  /// 
  /// Usually called during a deep logout or account reset flow.
  Future<void> clearDeviceRegistration() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_deviceRegisteredKey);
    await prefs.remove(_deviceIdKey);
  }
}
