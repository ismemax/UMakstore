import 'package:flutter/material.dart';

/// Represents the current physical state of the application on the user's device.
enum AppStatus {
  notInstalled,
  downloading,
  installing,
  uninstalling,
  installed,
  updateAvailable,
}

/// The core data structure representing an application in the store.
/// 
/// This model encapsulates both metadata from Firestore (like [title] and [downloadUrl])
/// and local state information (like [status] and [progress]).
class AppModel {
  final String id;
  final String title;
  final String publisher;
  final String description;
  final String iconAsset;
  final String category;
  final String college;
  final String downloadUrl;
  final String? packageName; // e.g. com.example.app
  final String version;
  final String size;
  final String rating;
  final String reviews;
  final Color? themeColor;
  final IconData? iconData;

  final List<String> screenshots;

  /// The current installation status of the app.
  AppStatus status;

  /// Download progress as a value between 0.0 and 1.0.
  double progress;

  /// Error message captured during failed downloads or installations.
  String? errorMessage;

  /// Whether the app is bookmarked or added to the user's personal context.
  bool isInLibrary;

  /// List of Android permissions required by the app.
  final List<String> permissions;

  AppModel({
    required this.id,
    required this.title,
    required this.publisher,
    required this.description,
    required this.iconAsset,
    required this.category,
    required this.college,
    required this.downloadUrl,
    this.packageName,
    required this.version,
    required this.size,
    required this.rating,
    required this.reviews,
    this.themeColor,
    this.iconData,
    this.screenshots = const [],
    this.status = AppStatus.notInstalled,
    this.progress = 0.0,
    this.errorMessage,
    this.isInLibrary = false,
    this.permissions = const [],
  });

  // Empty list for dynamic data from Firestore
  static final List<AppModel> sampleApps = [];
}
