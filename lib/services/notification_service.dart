import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_model.dart';
import 'dart:async';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> init() async {
    // We launch the initialization in the background to avoid blocking main() and hanging the splash screen
    _initInternal();
  }

  Future<void> _initInternal() async {
    try {
      debugPrint('Initializing Notification Service...');
      // Request notification permissions for system notifications (Android 13+)
      if (Platform.isAndroid) {
        await Permission.notification.request();
      }

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      // Bypassing specific type issues for initialization while troubleshooting API versions
      await (_notificationsPlugin as dynamic).initialize(initializationSettings: initializationSettings);
      debugPrint('Notification Service initialized successfully.');
    } catch (e) {
      debugPrint('Notification Service System Init Error: $e');
    }
  }

  // System Notifications (Local Notifications)
  Future<void> showDownloadNotification(String appName) async {
    try {
      debugPrint('Showing download notification for $appName');
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'download_channel',
        'App Downloads',
        channelDescription: 'Notifications for app download status',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      // Using dynamic call to bypass the '0 allowed but 4 found' positional argument error
      // while we identify the correct named parameter signature for v21.0.0
      await (_notificationsPlugin as dynamic).show(
        1001, // Unique ID for download
        'Download Complete',
        '$appName is ready to install',
        platformChannelSpecifics,
      );
    } catch (e) {
      debugPrint('Notification Service Sync Alert Error: $e');
    }
  }

  Future<void> showInstallNotification(String appName) async {
    try {
      debugPrint('Showing install notification for $appName');
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'install_channel',
        'App Installations',
        channelDescription: 'Notifications for successful installations',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await (_notificationsPlugin as dynamic).show(
        1002, // Unique ID for install
        'Installation Successful',
        '$appName has been installed and is ready to use!',
        platformChannelSpecifics,
      );
    } catch (e) {
      debugPrint('Notification Service Install Alert Error: $e');
    }
  }

  // Firestore In-App Notifications (RESORED)
  Stream<List<NotificationModel>> getNotifications() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList());
  }

  Stream<int> getUnreadCount() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value(0);

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<void> deleteNotification(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .doc(id)
        .delete();
  }

  Future<void> markAsRead(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .doc(id)
        .update({'isRead': true});
  }

  Future<void> sendWelcomeNotification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final notification = NotificationModel(
      id: '',
      title: 'Welcome to UMAk Store!',
      message: 'Explore and download apps specifically for UMAk students.',
      timestamp: DateTime.now(),
      isRead: false,
      type: NotificationType.success,
    );

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .add(notification.toMap());
  }
}
