import 'package:flutter/material.dart';

enum AppStatus {
  notInstalled,
  downloading,
  installing,
  installed,
  updateAvailable,
}

class AppModel {
  final String id;
  final String title;
  final String publisher;
  final String description;
  final String iconAsset;
  final String downloadUrl;
  final String? packageName; // e.g. com.example.app
  final String version;
  final String size;
  final String rating;
  final String reviews;
  final Color? themeColor;
  final IconData? iconData;

  AppStatus status;
  double progress;
  String? errorMessage;

  AppModel({
    required this.id,
    required this.title,
    required this.publisher,
    required this.description,
    required this.iconAsset,
    required this.downloadUrl,
    this.packageName,
    required this.version,
    required this.size,
    required this.rating,
    required this.reviews,
    this.themeColor,
    this.iconData,
    this.status = AppStatus.notInstalled,
    this.progress = 0.0,
    this.errorMessage,
  });

  // Helper for static data in the UI
  static final List<AppModel> sampleApps = [
    AppModel(
      id: 'scamester',
      title: 'Scamester',
      publisher: 'Security Dept',
      description: 'Detect scams & stay secure on campus...',
      iconAsset: 'assets/logo.svg',
      downloadUrl: "https://github.com/ismemax/scamester_apk/releases/download/Test/ScamesterV.0.1.2.4a.apk",
      packageName: 'com.karterion.scamester',
      version: '1.2.4',
      size: '37 MB',
      rating: '4.9',
      reviews: '12k',
      themeColor: const Color(0xffef4444),
      iconData: Icons.shield_rounded,
    ),
  ];
}
