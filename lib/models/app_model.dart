import 'package:flutter/material.dart';

enum AppStatus {
  notInstalled,
  downloading,
  installing,
  uninstalling,
  installed,
  updateAvailable,
}

class AppModel {
  final String id;
  final String title;
  final String publisher;
  final String description;
  final String iconAsset;
  final String category;
  final String downloadUrl;
  final String? packageName; // e.g. com.example.app
  final String version;
  final String size;
  final String rating;
  final String reviews;
  final Color? themeColor;
  final IconData? iconData;

  final List<String> screenshots;

  AppStatus status;
  double progress;
  String? errorMessage;
  bool isInLibrary;
  final List<String> permissions;

  AppModel({
    required this.id,
    required this.title,
    required this.publisher,
    required this.description,
    required this.iconAsset,
    required this.category,
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
