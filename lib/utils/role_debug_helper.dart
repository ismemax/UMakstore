import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/role_management_service.dart';
import 'package:flutter/foundation.dart';

class RoleDebugHelper {
  static Future<void> debugUserRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ No user is currently signed in');
        return;
      }

      print('🔍 Debugging User Role...');
      print('📧 Email: ${user.email}');
      
      // Get user's current role from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final currentRole = userData['role']?.toString().toLowerCase() ?? 'student';
        
        print('📋 Current Role: $currentRole');
        
        // Get role info
        final roleInfo = RoleManagementService().getRoleInfo(currentRole);
        print('📊 Role Level: ${roleInfo['level']}');
        print('🔑 Permissions: ${roleInfo['permissions']}');
        print('👥 Can Assign: ${roleInfo['canAssign']}');
        print('⚠️ Requires Approval: ${roleInfo['requiresApproval']}');
        
        // Test role assignment criteria
        final roleService = RoleManagementService();
        final criteria = roleService._assignmentCriteria[currentRole];
        
        if (criteria != null) {
          print('📋 Assignment Criteria:');
          for (final criterion in criteria!) {
            print('   • $criterion');
          }
          
          // Test criteria meeting
          final meetsCriteria = await roleService.meetsRoleCriteria(user.email!, currentRole);
          print('✅ Meets Criteria: $meetsCriteria');
        }
      }
      
      // Test assignment permissions
      final canAssignAdmin = roleService.canAssignRole(currentRole, 'admin');
      final canAssignDeveloper = roleService.canAssignRole(currentRole, 'developer');
      final canAssignStudent = roleService.canAssignRole(currentRole, 'student');
      
      print('🔐 Permission Test Results:');
      print('   Can assign Admin: $canAssignAdmin');
      print('   Can assign Developer: $canAssignDeveloper');
      print('   Can assign Student: $canAssignStudent');
      
    } catch (e) {
      print('❌ Error debugging role: $e');
    }
  }
}
