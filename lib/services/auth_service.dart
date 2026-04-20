import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'notification_service.dart';
import 'device_service.dart';
import 'role_management_service.dart';

/// Handles all user authentication flows, profile management, and device-locking logic.
/// 
/// This service acts as the bridge between [FirebaseAuth], [FirebaseFirestore], 
/// and the custom backend API for role assignment and device validation.
class AuthService {
  // IMPORTANT: For Android Emulator, use 10.0.2.2.
  // FOR PHYSICAL DEVICES (like your SM S908E), you must use your computer's
  // local IP address (e.g., 192.168.1.XX) instead of 10.0.2.2/localhost.
  static const String _apiBaseUrl = 'https://makstore-api.vercel.app/api';

  static String? _simulatedCode; // Fallback for demo
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Helper to check if email belongs to allowed domain.
  bool _isAllowedDomain(String email) {
    return email.toLowerCase().trim().endsWith('@umak.edu.ph');
  }

  /// Sign up a new user with email and password.
  /// 
  /// Automatically sends a verification email upon successful creation.
  /// Throws an error if the email domain is not [@umak.edu.ph].
  Future<void> signUpUser({
    required String email,
    required String password,
  }) async {
    final sanitizedEmail = email.toLowerCase().trim();
    if (!_isAllowedDomain(sanitizedEmail)) {
      throw 'Only @umak.edu.ph email addresses are allowed to register.';
    }
    // Check if email already exists in Firestore users collection
    if (await isEmailRegistered(sanitizedEmail)) {
      throw 'This email is already registered with an account.';
    }
    try {
      await _auth.createUserWithEmailAndPassword(
        email: sanitizedEmail,
        password: password,
      );
      // Standard Firebase sends a verification link to email
      await _auth.currentUser?.sendEmailVerification();
      if (kDebugMode) {
        print('Sign up initiated for $email. Verification email sent.');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw 'This email is already registered. Please sign in instead.';
      }
      if (kDebugMode) {
        print('Firebase Auth error during sign-up: ${e.code} - ${e.message}');
      }
      rethrow;
    }
  }

  /// Sends a simulated 6-digit verification code to the email.
  Future<void> sendVerificationCode(String email) async {
    try {
      // 1. Attempt to call the API
      final response = await http
          .post(
            Uri.parse('$_apiBaseUrl/send-otp'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        if (kDebugMode) print('OTP sent via API successfully');
        return;
      }

      // 2. FALLBACK to Simulation if API fails (Local Dev)
      debugPrint(
        'API failed (${response.statusCode}), falling back to simulated code.',
      );
      _simulatedCode =
          (100000 + (DateTime.now().millisecondsSinceEpoch % 900000))
              .toString();
      debugPrint('------------------------------------------');
      debugPrint('VERIFICATION CODE FOR $email: $_simulatedCode');
      debugPrint('------------------------------------------');
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      // 3. FALLBACK to Simulation if API is unreachable
      debugPrint('API unreachable, falling back to simulated code: $e');
      _simulatedCode =
          (100000 + (DateTime.now().millisecondsSinceEpoch % 900000))
              .toString();
      debugPrint('------------------------------------------');
      debugPrint('VERIFICATION CODE FOR $email: $_simulatedCode');
      debugPrint('------------------------------------------');
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  /// Confirms the simulated 6-digit code.
  Future<void> confirmUser({
    required String email,
    required String confirmationCode,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': confirmationCode}),
      );

      if (response.statusCode == 200) {
        return;
      }

      // Check fallback if API was unreachable
      if (_simulatedCode != null && confirmationCode == _simulatedCode) {
        return;
      }

      throw 'Invalid verification code. Please check your console/email.';
    } catch (e) {
      if (_simulatedCode != null && confirmationCode == _simulatedCode) {
        return;
      }
      throw 'Invalid verification code or API error. $e';
    }
  }

  /// Sign in an existing user with email and password.
  /// 
  /// Validates the university domain before attempting the Firebase login.
  Future<void> signInUser(String email, String password) async {
    try {
      final sanitizedEmail = email.toLowerCase().trim();
      if (!_isAllowedDomain(sanitizedEmail)) {
        throw 'Access denied. Please use your @umak.edu.ph email.';
      }
      await _auth.signInWithEmailAndPassword(
        email: sanitizedEmail,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Firebase Auth error during sign-in: ${e.code} - ${e.message}');
      }
      rethrow;
    }
  }

  /// Authenticate using Google Sign-In.
  /// 
  /// Restricts access to students with university accounts and creates a 
  /// basic profile in Firestore upon the first successful login.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User canceled the sign-in

      // Domain restriction check
      if (!_isAllowedDomain(googleUser.email)) {
        await _googleSignIn.signOut();
        throw 'Only @umak.edu.ph accounts are allowed to sign in.';
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      // Check if user exists in Firestore, if not create basic entry
      final userDoc = await _db
          .collection('users')
          .doc(userCredential.user?.uid)
          .get();
      if (!userDoc.exists && userCredential.user != null) {
        await _db.collection('users').doc(userCredential.user!.uid).set({
          'email': userCredential.user!.email,
          'firstName': googleUser.displayName?.split(' ').first ?? '',
          'lastName': googleUser.displayName?.split(' ').last ?? '',
          'studentId':
              'PENDING', // Google doesn't provide this, user will need to update
          'createdAt': FieldValue.serverTimestamp(),
        });
        // Send a welcome notification for first-time Google sign-ins
        await NotificationService().sendWelcomeNotification();
      }

      return userCredential;
    } catch (e) {
      if (kDebugMode) {
        print('Error during Google Sign-In: $e');
      }
      rethrow;
    }
  }

  /// Sign out.
  Future<void> signOutUser() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('Error during sign-out: $e');
      }
      rethrow;
    }
  }

  /// Registers the current physical device to the user's account via the API.
  /// 
  /// This is used to enforce single-device session policies or trusted device access.
  Future<bool> registerDevice() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final idToken = await user.getIdToken();
      final deviceId = await DeviceService().getDeviceId();
      final deviceInfo = await DeviceService().getDeviceInfo();

      final response = await http.post(
        Uri.parse('$_apiBaseUrl/register-device'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'deviceId': deviceId,
          'deviceInfo': deviceInfo,
        }),
      );

      if (response.statusCode == 200) {
        await DeviceService().markDeviceAsRegistered();
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw errorData['error'] ?? 'Device registration failed';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error registering device: $e');
      }
      return false;
    }
  }

  /// Validate device for session continuation
  Future<bool> validateDevice() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final idToken = await user.getIdToken();
      final deviceId = await DeviceService().getDeviceId();

      final response = await http.post(
        Uri.parse('$_apiBaseUrl/validate-device'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'deviceId': deviceId,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw errorData['error'] ?? 'Device validation failed';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error validating device: $e');
      }
      return false;
    }
  }

  /// Revoke all devices
  Future<bool> revokeAllDevices() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final idToken = await user.getIdToken();

      final response = await http.post(
        Uri.parse('$_apiBaseUrl/revoke-all-devices'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        await DeviceService().clearDeviceRegistration();
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw errorData['error'] ?? 'Device revocation failed';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error revoking devices: $e');
      }
      return false;
    }
  }

  /// Checks if an email is already associated with a profile in Firestore.
  /// NOTE: This may fail with "Permission Denied" if the user is not signed in
  /// and Firestore rules are restrictive. We catch this and return false to
  /// allow the registration flow to proceed to FirebaseAuth, which handles
  /// uniqueness check natively.
  Future<bool> isEmailRegistered(String email) async {
    try {
      final sanitizedEmail = email.toLowerCase().trim();
      
      // If no user is signed in, some Firestore rules might block this query.
      if (_auth.currentUser == null) {
        return false;
      }

      final query = await _db
          .collection('users')
          .where('email', isEqualTo: sanitizedEmail)
          .limit(1)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('Firestore query error (usually permission related): $e');
      }
      // Return false to let the Auth flow handle it. 
      return false;
    }
  }

  /// Initiate password reset.
  /// Initiate password reset and try to redirect back to the app.
  Future<void> resetPassword(String email) async {
    try {
      final sanitizedEmail = email.toLowerCase().trim();
      if (!_isAllowedDomain(sanitizedEmail)) {
        throw 'Access denied. Please use your @umak.edu.ph email address.';
      }

      // ActionCodeSettings enables "deep linking" where clicking the reset link
      // can open the app directly instead of a web page if configured.
      final actionCodeSettings = ActionCodeSettings(
        url:
            'https://makstore-826a4.firebaseapp.com/reset-password?email=$sanitizedEmail',
        handleCodeInApp: true,
        androidPackageName: 'com.tbl.makstore',
        androidInstallApp: true,
        androidMinimumVersion: '1',
      );

      await _auth.sendPasswordResetEmail(
        email: sanitizedEmail,
        actionCodeSettings: actionCodeSettings,
      );
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Firebase Auth error during reset: ${e.code} - ${e.message}');
      }
      rethrow;
    }
  }

  /// Confirm password reset using our custom API and OTP verification.
  Future<void> confirmResetPassword({
    required String email,
    required String newPassword,
    required String
    confirmationCode, // Not strictly needed here as we verify it in the previous step
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/update-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.toLowerCase().trim(),
          'newPassword': newPassword,
        }),
      );

      // Handle cases where the server might return an HTML error page (like a 404 or 500)
      if (response.headers['content-type']?.contains('html') ?? false) {
        throw 'The server is currently unavailable or the path is incorrect. Please ensure you have re-deployed your Node.js API.';
      }

      final data = jsonDecode(response.body);
      if (response.statusCode != 200) {
        final errorMsg =
            data['details'] ?? data['error'] ?? 'Failed to update password';
        throw errorMsg;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Custom Password Reset Error: $e');
      }
      rethrow;
    }
  }

  /// Gets the user profile data from Firestore.
  Future<DocumentSnapshot<Map<String, dynamic>>?> getUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      return await _db.collection('users').doc(user.uid).get();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user profile from Firestore: $e');
      }
      rethrow;
    }
  }

  /// Extracts student ID from email
  String extractStudentId(String email) {
    if (email.isEmpty) return 'UNKNOWN';
    final parts = email.split('@');
    if (parts.length < 2) return 'UNKNOWN';
    final subParts = parts[0].split('.');
    if (subParts.length < 2) return subParts[0].toUpperCase();
    return subParts.last.toUpperCase();
  }

  /// Saves or overwrites the full user profile data to the Firestore 'users' collection.
  /// 
  /// Triggers a welcome notification upon completion.
  Future<void> saveUserProfile({
    required String email,
    required String studentId,
    required String lastName,
    required String firstName,
    required String middleName,
    required String college,
    required String course,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user signed in');

      final sanitizedEmail = email.toLowerCase().trim();
      await _db.collection('users').doc(user.uid).set({
        'email': sanitizedEmail,
        'studentId': studentId,
        'lastName': lastName,
        'firstName': firstName,
        'middleName': middleName,
        'college': college,
        'course': course,
        'createdAt': FieldValue.serverTimestamp(),
      });
      // Send a welcome notification after saving profile (successful signup)
      await NotificationService().sendWelcomeNotification();
    } catch (e) {
      if (kDebugMode) {
        print('Firestore Error: $e');
      }
      rethrow;
    }
  }

  /// Updates the user profile data in Firestore.
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'User not authenticated';

      await _db.collection('users').doc(user.uid).update(data);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user profile: $e');
      }
      rethrow;
    }
  }

  /// Updates the current user's role via the secure API bypass.
  /// 
  /// This method is primarily used for testing or emergency role escalation
  /// using a developmental master key.
  Future<void> updateCurrentUserRole(String newRole) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'No user signed in';
      
      final idToken = await user.getIdToken();
      
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/assign-role'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'targetEmail': user.email,
          'targetRole': newRole.toLowerCase().trim(),
          'reason': 'Debug/Bypass used in-app',
          'masterKey': 'UMAK_ADMIN_BYPASS_2024', // Dev-only key for bypass
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw 'API Error (${response.statusCode}): ${response.body}';
      }
      
      if (kDebugMode) {
        print('Role updated successfully via API bypass');
      }
    } catch (e) {
      if (kDebugMode) print('Error sending verification code: $e');
      rethrow;
    }
  }

  /// Verifies the code and prepares for password reset
  Future<void> verifyCodeAndResetPassword(String email, String code) async {
    try {
      // 1. Attempt to call the API
      final response = await http
          .post(
            Uri.parse('$_apiBaseUrl/verify-otp'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'code': code}),
          )
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        if (kDebugMode) print('Code verified via API successfully');
        return;
      }

      // 2. FALLBACK to Simulation if API fails (Local Dev)
      debugPrint(
        'API failed (${response.statusCode}), falling back to simulated verification.',
      );
      
      if (_simulatedCode != null && code == _simulatedCode) {
        debugPrint('Code verified successfully');
        return;
      }
      
      throw Exception('Invalid verification code');
    } catch (e) {
      if (kDebugMode) print('Error verifying code: $e');
      rethrow;
    }
  }

  /// Updates the user password after re-authenticating.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) throw 'User not authenticated';

      // Re-authenticate first
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } catch (e) {
      if (kDebugMode) {
        print('Error changing password: $e');
      }
      rethrow;
    }
  }

  /// Saves a profile photo locally on the device (bypassing Firebase Storage).
  Future<String> saveProfilePhotoLocally(File image) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'User not authenticated';

      final appDir = await getApplicationDocumentsDirectory();

      // 1. Cleanup old profile photos for this user to save space
      final List<FileSystemEntity> files = appDir.listSync();
      for (var file in files) {
        if (file.path.contains('profile_${user.uid}')) {
          try {
            await file.delete();
          } catch (_) {
            // Ignore if file was already gone or locked
          }
        }
      }

      // 2. Generate a unique filename using a timestamp to force UI refresh
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final String fileName =
          'profile_${user.uid}_$timestamp${path.extension(image.path)}';
      final File localImage = await image.copy('${appDir.path}/$fileName');

      // 3. Save path in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_photo_${user.uid}', localImage.path);

      return localImage.path;
    } catch (e) {
      if (kDebugMode) {
        print('Error saving profile photo locally: $e');
      }
      rethrow;
    }
  }

  /// Saves a profile photo as a Base64 string in Firestore.
  /// Note: Browsers and Firestore have limits, so this is best for small images only.
  Future<void> updateProfilePhotoBase64(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'User not authenticated';

      // 1. Read bytes from file
      final bytes = await imageFile.readAsBytes();
      
      // 2. Convert to Base64 string
      final String base64Image = base64Encode(bytes);
      
      // 3. Save to Firestore
      await _db.collection('users').doc(user.uid).update({
        'photoBase64': base64Image,
        'hasCustomPhoto': true,
        'photoUpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error saving base64 profile photo: $e');
      }
      rethrow;
    }
  }

  /// Removes the base64 profile photo from Firestore.
  Future<void> removeProfilePhotoBase64() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'User not authenticated';

      await _db.collection('users').doc(user.uid).update({
        'photoBase64': FieldValue.delete(),
        'hasCustomPhoto': false,
        'photoUpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error removing base64 profile photo: $e');
      }
      rethrow;
    }
  }

  /// Gets the Base64 profile photo string from Firestore.
  Future<String?> getBase64ProfilePhoto() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return doc.data()?['photoBase64'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
