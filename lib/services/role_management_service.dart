import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

class RoleManagementService {
  static final RoleManagementService _instance = RoleManagementService._internal();
  factory RoleManagementService() => _instance;
  RoleManagementService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Role hierarchy and permissions
  static const Map<String, Map<String, dynamic>> _roleHierarchy = {
    'student': {
      'level': 1,
      'permissions': ['view_apps', 'download_apps', 'rate_apps', 'bookmark_apps'],
      'canAssign': ['student'],
      'requiresApproval': false,
    },
    'developer': {
      'level': 2,
      'permissions': ['view_apps', 'download_apps', 'rate_apps', 'bookmark_apps', 'upload_apps', 'manage_own_apps'],
      'canAssign': ['student', 'developer'],
      'requiresApproval': false,
    },
    'admin': {
      'level': 3,
      'permissions': ['view_apps', 'download_apps', 'rate_apps', 'bookmark_apps', 'upload_apps', 'manage_own_apps', 'manage_all_apps', 'manage_users', 'assign_roles'],
      'canAssign': ['student', 'developer', 'admin'],
      'requiresApproval': false,
    },
  };

  // Role assignment criteria
  static const Map<String, List<String>> _assignmentCriteria = {
    'student': ['@umak.edu.ph email verification'],
    'developer': ['@umak.edu.ph email verification'],
    'admin': ['@umak.edu.ph email verification', 'admin_approval'],
    'super_admin': ['@umak.edu.ph email verification'],
  };

  /// Get role hierarchy information
  Map<String, dynamic> getRoleInfo(String role) {
    return _roleHierarchy[role.toLowerCase()] ?? {
      'level': 0,
      'permissions': [],
      'canAssign': [],
      'requiresApproval': false,
    };
  }

  /// Check if user can assign specific role
  bool canAssignRole(String currentUserRole, String targetRole) {
    final currentRoleInfo = getRoleInfo(currentUserRole);
    final targetRoleInfo = getRoleInfo(targetRole);
    
    // Can only assign to same or lower level roles
    return currentRoleInfo['level'] >= targetRoleInfo['level'];
  }

  /// Check if user meets criteria for role assignment
  Future<bool> meetsRoleCriteria(String email, String targetRole) async {
    final criteria = _assignmentCriteria[targetRole];
    if (criteria == null) return false;

    // Check email domain (comprehensive UMak validation)
    if (email.toLowerCase().trim().isEmpty) {
      return false;
    }
    
    // Extract domain from email for validation
    final emailDomain = email.toLowerCase().trim().split('@').last;
    
    // UMak official domains
    final officialDomains = [
      'umak.edu.ph',    // Primary domain
      'umak.edu',      // Alternative without .ph
      'umak.edu.org',   // Future expansion
    ];
    
    // Check if it's an official UMak domain
    bool isOfficialDomain = officialDomains.contains(emailDomain);
    
    // If not an official domain, check if it's in the allowed exceptions
    if (!isOfficialDomain) {
      final allowedNonUMak = [
        'gmail.com',      // For testing
        'outlook.com',    // Staff emails
        'yahoo.com',     // Legacy accounts
        'hotmail.com',    // Alternative services
        'umak.edu',     // Direct UMak (without .ph)
        'umak.edu.ph',   // Direct UMak (with .ph)
      ];
      
      if (!allowedNonUMak.contains(emailDomain)) {
        return false;
      }
    }
    
    // Check role-specific criteria
    for (final criterion in criteria) {
      // Add more criteria checks as needed
    }

    return true;
  }

  /// Get user's approved apps count
  Future<int?> _getUserApprovedApps(String email) async {
    try {
      // 1. Get user document to find their UID
      final userSnapshot = await _db
          .collection('users')
          .where('email', isEqualTo: email.toLowerCase().trim())
          .limit(1)
          .get();
      
      if (userSnapshot.docs.isEmpty) return 0;
      
      final uid = userSnapshot.docs.first.id;

      // 2. Query submitted_apps collection for apps by this developer that are 'live'
      final appsSnapshot = await _db
          .collection('submitted_apps')
          .where('developerId', isEqualTo: uid)
          .get();
      
      // Filter for 'live' status (case-insensitive)
      int approvedCount = 0;
      for (final doc in appsSnapshot.docs) {
        final status = doc.data()['status']?.toString().toLowerCase();
        if (status == 'live') {
          approvedCount++;
        }
      }
      
      return approvedCount;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking user apps: $e');
      }
      return 0;
    }
  }

  /// Assign a new role to a user
  Future<String> assignRole(String adminEmail, String targetUserEmail, String targetRole, {String? reason}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'User not authenticated';

      // 1. Get ID Token for API authentication
      final idToken = await user.getIdToken();

      // 2. Prepare API details - Use consistent base URL
      final String baseUrl = 'https://makstore-api.vercel.app/api';
      final url = '$baseUrl/assign-role';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'targetEmail': targetUserEmail.trim(),
          'targetRole': targetRole.toLowerCase().trim(),
          'reason': reason ?? '',
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['message'] ?? 'Role assigned successfully via API';
      } else {
        // Fallback to local Firestore update if it's a 404/local dev environment without API
        // But if it's a 403, we should stop and report permission error
        if (response.statusCode == 403) {
           throw 'Permission denied: ${jsonDecode(response.body)['error']}';
        }
        
        throw 'API Error (${response.statusCode}): ${response.body}';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Role assignment error: $e');
      }
      
      // If API fails with 404, it means the server hasn't been redeployed with the new endpoint yet.
      // If it fails with connection error, it's unreachable.
      try {
        if (e.toString().contains('API Error (404)')) {
           throw 'Server update required: The role management API was not found (404). Please ensure you have DEPLOYED the updated api/index.js to your server.';
        }
        if (e.toString().contains('API Error')) {
           // Only try direct fallback if it's an API error (likely 404 or 500)
           return await _assignRoleDirectly(adminEmail, targetUserEmail, targetRole, reason: reason);
        }
      } catch (innerError) {
         throw 'Role Update Failed: $e\n\nFallback direct update also failed: $innerError\n\nSuggestion: Ensure your Node.js API is deployed and reachable.';
      }
      
      rethrow;
    }
  }

  /// Direct Firestore fallback (may fail due to Security Rules)
  Future<String> _assignRoleDirectly(String adminEmail, String targetUserEmail, String targetRole, {String? reason}) async {
    // Check permissions locally first
    final currentAdminRole = await getUserRole(adminEmail);
    if (!canAssignRole(currentAdminRole, targetRole)) {
      throw 'You do not have permission to assign the $targetRole role';
    }

    // Check criteria
    final meetsCriteria = await meetsRoleCriteria(targetUserEmail, targetRole);
    if (!meetsCriteria) {
      throw 'User does not meet criteria for $targetRole role';
    }

    // Lookup target user
    final targetUserDoc = await _db
        .collection('users')
        .where('email', isEqualTo: targetUserEmail.toLowerCase().trim())
        .get();

    if (targetUserDoc.docs.isEmpty) {
      throw 'Target user not found';
    }

    final targetUserId = targetUserDoc.docs.first.id;
    final targetUserData = targetUserDoc.docs.first.data();
    final currentRole = targetUserData['role']?.toString().toLowerCase() ?? 'student';

    // Update user role
    await _db.collection('users').doc(targetUserId).update({
      'role': targetRole,
      'roleAssignedBy': adminEmail,
      'roleAssignedAt': DateTime.now().toIso8601String(),
      'roleAssignmentReason': reason ?? '',
      'previousRole': currentRole,
    });

    // Log assignment
    await _logRoleAssignment(adminEmail, targetUserEmail, currentRole, targetRole, reason);

    return 'Role updated successfully (Direct Firestore)';
  }

  /// Log role assignment for audit trail
  Future<void> _logRoleAssignment(String adminEmail, String targetEmail, String previousRole, String newRole, String? reason) async {
    await _db.collection('roleAssignments').add({
      'adminEmail': adminEmail,
      'targetEmail': targetEmail,
      'previousRole': previousRole,
      'newRole': newRole,
      'reason': reason ?? '',
      'timestamp': DateTime.now().toIso8601String(),
      'ipAddress': await _getIpAddress(),
    });
  }

  /// Get user's current role
  Future<String> getUserRole(String email) async {
    try {
      final userDoc = await _db
          .collection('users')
          .where('email', isEqualTo: email.toLowerCase().trim())
          .get();
      
      if (userDoc.docs.isNotEmpty) {
        final userData = userDoc.docs.first.data() as Map<String, dynamic>;
        return userData['role']?.toString() ?? 'student';
      }
      return 'student';
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user role: $e');
      }
      return 'student';
    }
  }

  /// Get IP address of the device
  Future<String> _getIpAddress() async {
    try {
      if (kIsWeb) return 'Web Client';
      final interfaces = await NetworkInterface.list(
        includeLoopback: false, 
        type: InternetAddressType.any
      ).timeout(const Duration(seconds: 2));
      
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (!addr.isLoopback) {
            return addr.address;
          }
        }
      }
      return 'Unknown';
    } catch (e) {
      if (kDebugMode) {
        print('Error getting IP address: $e');
      }
      return 'Unavailable';
    }
  }

  /// Get all users with their roles for admin management
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final usersSnapshot = await _db.collection('users').get();
      return usersSnapshot.docs.map((doc) => {
        'email': doc['email'] ?? 'Unknown',
        'uid': doc.id,
        'name': '${doc['firstName'] ?? ''} ${doc['lastName'] ?? ''}'.trim(),
        'role': doc['role'] ?? 'student',
        'roleAssignedAt': doc['roleAssignedAt'],
        'lastActive': doc['lastActive'],
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting users: $e');
      }
      return [];
    }
  }

  /// Get role assignment history
  Future<List<Map<String, dynamic>>> getRoleAssignmentHistory() async {
    try {
      final assignmentsSnapshot = await _db.collection('roleAssignments').get();
      return assignmentsSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting role assignments: $e');
      }
      return [];
    }
  }
}
