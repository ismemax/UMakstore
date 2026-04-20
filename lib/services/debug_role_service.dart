import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'role_management_service.dart';

class DebugRoleService {
  static const bool _debugMode = true;

  /// Temporarily bypass role validation for debugging
  static Future<void> enableDebugMode() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Set debug flag in user document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'debugMode': true});

      print('DEBUG MODE ENABLED: Role validation bypassed');
    } catch (e) {
      print('Error enabling debug mode: $e');
    }
  }

  /// Disable debug mode and restore normal validation
  static Future<void> disableDebugMode() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Remove debug flag from user document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'debugMode': FieldValue.delete()});

      print('DEBUG MODE DISABLED: Role validation restored');
    } catch (e) {
      print('Error disabling debug mode: $e');
    }
  }

  /// Check if debug mode is enabled for current user
  static Future<bool> isDebugModeEnabled() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        return userData['debugMode'] == true;
      }
      return false;
    } catch (e) {
      print('Error checking debug mode: $e');
      return false;
    }
  }

  /// Assign any role without validation (debug only)
  static Future<void> assignAnyRole(String role) async {
    if (!_debugMode) {
      throw 'Debug mode is not enabled';
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'No user signed in';

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'role': role});

      print('DEBUG: Assigned role "$role" without validation');
    } catch (e) {
      print('Error assigning debug role: $e');
    }
  }
}
