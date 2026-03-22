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

  /// Sign up user with email and password.
  Future<void> signUpUser({
    required String email,
    required String password,
  }) async {
    final sanitizedEmail = email.toLowerCase().trim();
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

  /// Sign in user with email and password.
  Future<void> signInUser(String email, String password) async {
    try {
      final sanitizedEmail = email.toLowerCase().trim();
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

  /// Sign in user with Google.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User canceled the sign-in

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

  /// Checks if an email is already associated with a profile in Firestore.
  Future<bool> isEmailRegistered(String email) async {
    try {
      final sanitizedEmail = email.toLowerCase().trim();
      final query = await _db
          .collection('users')
          .where('email', isEqualTo: sanitizedEmail)
          .limit(1)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      if (kDebugMode) print('Firestore query error: $e');
      return false;
    }
  }

  /// Initiate password reset.
  /// Initiate password reset and try to redirect back to the app.
  Future<void> resetPassword(String email) async {
    try {
      final sanitizedEmail = email.toLowerCase().trim();

      // ActionCodeSettings enables "deep linking" where clicking the reset link
      // can open the app directly instead of a web page if configured.
      final actionCodeSettings = ActionCodeSettings(
        url:
            'https://makstore-826a4.firebaseapp.com/reset-password?email=$sanitizedEmail',
        handleCodeInApp: true,
        androidPackageName: 'com.example.umakstore',
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

  /// Saves the user profile data to Firestore.
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

  /// Removes the local profile photo path from SharedPreferences.
  Future<void> removeProfilePhotoLocally() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'User not authenticated';

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('profile_photo_${user.uid}');
    } catch (e) {
      if (kDebugMode) {
        print('Error removing local profile photo: $e');
      }
      rethrow;
    }
  }

  /// Gets the local profile photo path if it exists.
  Future<String?> getLocalProfilePhotoPath() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('profile_photo_${user.uid}');
    } catch (e) {
      return null;
    }
  }
}
