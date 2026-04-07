import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:convert';
import 'dart:io';
import '../models/app_model.dart';

class DeveloperService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Checks if a package name is already taken by another app
  Future<bool> isPackageNameTaken(String packageName, {String? excludeAppId}) async {
    if (packageName.isEmpty) return false;
    
    final query = _db.collection('submitted_apps')
        .where('packageName', isEqualTo: packageName);
        
    final snapshot = await query.get();
    
    if (excludeAppId != null) {
      return snapshot.docs.any((doc) => doc.id != excludeAppId);
    }
    
    return snapshot.docs.isNotEmpty;
  }

  /// Submits a new app to Firestore
  Future<void> submitApp({
    required String title,
    required String publisher,
    required String description,
    required String category,
    required String apkUrl,
    String? packageName,
    required String version,
    String? iconUrl,
    List<String> screenshotUrls = const [],
    List<String> permissions = const [],
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw 'User not authenticated';

    String sizeString = 'Unknown MB';
    
    try {
      final response = await http.head(Uri.parse(apkUrl));
      if (response.headers.containsKey('content-length')) {
        final bytes = int.parse(response.headers['content-length']!);
        if (bytes > 1024 * 1024) {
          sizeString = '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
        } else {
          sizeString = '${(bytes / 1024).toStringAsFixed(1)} KB';
        }
      }
    } catch (e) {
      debugPrint('Error fetching app size: $e');
    }

    final appData = {
      'title': title,
      'publisher': publisher,
      'description': description,
      'category': category,
      'downloadUrl': apkUrl,
      'packageName': packageName,
      'version': version,
      'size': sizeString,
      'iconUrl': iconUrl ?? '',
      'developerId': user.uid,
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
      'rating': '0.0',
      'reviews': '0',
      'screenshots': screenshotUrls,
      'permissions': permissions,
    };

    await _db.collection('submitted_apps').add(appData);
  }

  /// Fetches apps submitted by the current developer
  Stream<List<Map<String, dynamic>>> getDeveloperApps() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _db
        .collection('submitted_apps')
        .where('developerId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  /// Fetches all approved apps for the store
  Stream<List<AppModel>> getStoreApps() {
    return _db
        .collection('submitted_apps')
        .orderBy('createdAt', descending: true) // MAK Guard: Newest apps first
        .snapshots(includeMetadataChanges: true)
        .handleError((error) {
          debugPrint('CRITICAL: Firestore Store Stream Error: $error');
        })
        .map((snapshot) {
          debugPrint('Firestore: Received ${snapshot.docs.length} docs (FromCache: ${snapshot.metadata.isFromCache})');
          return snapshot.docs
              .map((doc) => {...doc.data(), 'id': doc.id})
              .where((data) {
                final s = data['status']?.toString().toLowerCase();
                return s == 'live'; // Case-insensitive check
              }) 
              .map((data) {
            return AppModel(
              id: data['id'],
              title: data['title']?.toString() ?? 'Unnamed App',
              publisher: data['publisher']?.toString() ?? 'Anonymous',
              description: data['description']?.toString() ?? '',
              iconAsset: data['iconUrl']?.toString() ?? 'assets/logo.svg',
              category: data['category']?.toString() ?? 'App',
              downloadUrl: data['downloadUrl']?.toString() ?? '',
              packageName: data['packageName']?.toString(),
              version: data['version']?.toString() ?? '1.0.0',
              size: data['size']?.toString() ?? '0 MB',
              rating: data['rating']?.toString() ?? '0.0',
              reviews: data['reviews'] ?? '0',
              iconData: Icons.apps_rounded,
              screenshots: (data['screenshots'] is List) 
                  ? List<String>.from((data['screenshots'] as List).map((e) => e.toString()))
                  : [],
              permissions: (data['permissions'] is List)
                  ? List<String>.from((data['permissions'] as List).map((e) => e.toString()))
                  : [],
            );
          }).toList();
        });
  }

  /// Submits or updates a review for an app
  Future<void> submitReview({
    required String appId,
    required double rating,
    required String comment,
    required bool isAnonymous,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw 'Authentication required to submit review';

    final reviewData = {
      'rating': rating,
      'comment': comment,
      'isAnonymous': isAnonymous,
      'userId': user.uid,
      'userName': isAnonymous ? 'UMak User' : (user.displayName ?? 'UMak Student'),
      'createdAt': FieldValue.serverTimestamp(),
    };

    final appRef = _db.collection('submitted_apps').doc(appId);
    final reviewRef = appRef.collection('reviews').doc(user.uid);
    
    await _db.runTransaction((transaction) async {
      // 1. Get app and check if review exists
      DocumentSnapshot appSnapshot = await transaction.get(appRef);
      if (!appSnapshot.exists) throw 'App not found';

      DocumentSnapshot reviewSnapshot = await transaction.get(reviewRef);
      bool isUpdate = reviewSnapshot.exists;

      // 2. Set/Update the review
      transaction.set(reviewRef, reviewData, SetOptions(merge: true));

      // 3. Update app stats
      int currentReviews = int.tryParse(appSnapshot['reviews']?.toString() ?? '0') ?? 0;
      double currentRating = double.tryParse(appSnapshot['rating']?.toString() ?? '0.0') ?? 0.0;

      if (isUpdate) {
        // UPDATE CASE: Recalculate without increasing count
        double oldRating = (reviewSnapshot.data() as Map<String, dynamic>)['rating']?.toDouble() ?? 0.0;
        
        // Safety check for divide by zero, though reviews should be > 0 if update
        if (currentReviews > 0) {
          double newRating = ((currentRating * currentReviews) - oldRating + rating) / currentReviews;
          transaction.update(appRef, {
            'rating': newRating.toStringAsFixed(1),
          });
        }
      } else {
        // NEW CASE: Regular average calculation
        double newRating = ((currentRating * currentReviews) + rating) / (currentReviews + 1);
        
        transaction.update(appRef, {
          'reviews': (currentReviews + 1).toString(),
          'rating': newRating.toStringAsFixed(1),
        });
      }
    });
  }

  /// Checks if the current user has already reviewed the app and returns the review if so
  Future<Map<String, dynamic>?> getUserReview(String appId) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _db
        .collection('submitted_apps')
        .doc(appId)
        .collection('reviews')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      data['id'] = doc.id;
      return data;
    }
    return null;
  }

  /// Fetches reviews for a specific app
  Stream<List<Map<String, dynamic>>> getAppReviews(String appId) {
    return _db
        .collection('submitted_apps')
        .doc(appId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Updates an existing app in Firestore
  Future<void> updateApp({
    required String appId,
    required String title,
    required String publisher,
    required String description,
    required String category,
    required String apkUrl,
    required String packageName,
    required String version,
    String? iconUrl,
    List<String> screenshotUrls = const [],
    List<String> permissions = const [],
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw 'User not authenticated';

    String sizeString = 'Unknown MB';
    
    try {
      final response = await http.head(Uri.parse(apkUrl));
      if (response.headers.containsKey('content-length')) {
        final bytes = int.parse(response.headers['content-length']!);
        if (bytes > 1024 * 1024) {
          sizeString = '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
        } else {
          sizeString = '${(bytes / 1024).toStringAsFixed(1)} KB';
        }
      }
    } catch (e) {
      debugPrint('Error fetching app size: $e');
    }

    final appData = {
      'title': title,
      'publisher': publisher,
      'description': description,
      'category': category,
      'downloadUrl': apkUrl,
      'packageName': packageName,
      'version': version,
      'size': sizeString,
      'iconUrl': iconUrl ?? '',
      'screenshots': screenshotUrls,
      'permissions': permissions,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _db.collection('submitted_apps').doc(appId).update(appData);
  }

  /// ADMIN: Gets all applications across all developers to approve/reject
  Stream<List<Map<String, dynamic>>> getAllAppsAdmin() {
    return _db.collection('submitted_apps')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {
              ...doc.data(),
              'id': doc.id,
            }).toList());
  }

  /// ADMIN: Updates an application's status (Live, Rejected, Pending)
  Future<void> updateAppStatus(String appId, String newStatus, {String? reason}) async {
    debugPrint('Firestore: Attempting to update app $appId to status $newStatus (Reason: $reason)...');
    try {
      final docRef = _db.collection('submitted_apps').doc(appId);
      final Map<String, dynamic> updateData = {
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (reason != null && reason.isNotEmpty) {
        updateData['rejectionReason'] = reason;
      }

      await docRef.update(updateData);
      debugPrint('Firestore: App $appId status updated SUCCESSFULLY to $newStatus.');
    } catch (e) {
      debugPrint('CRITICAL: Firestore error updating app $appId status: $e');
      rethrow;
    }
  }

  /// Deletes an app from Firestore
  Future<void> deleteApp(String appId) async {
    final user = _auth.currentUser;
    if (user == null) throw 'User not authenticated';
    
    await _db.collection('submitted_apps').doc(appId).delete();
  }

  // --- CLOUDINARY SUPPORT ---
  
  // NOTE: You'll need to create a free Cloudinary account and get these values.
  // Using placeholders for now - Replace these with your actual Cloudinary values.
  static const String _cloudinaryCloudName = 'dkgrsvydx'; // Default for UMak
  static const String _cloudinaryUploadPreset = 'makstore'; // Default for UMak

  /// Uploads a file to Cloudinary and returns the secure URL.
  Future<String> uploadToCloudinary(File file) async {
    try {
      // 0. Compress the image before uploading to save credits/data
      final compressedFile = await compressImage(file);
      
      final url = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudinaryCloudName/image/upload');
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = _cloudinaryUploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', compressedFile.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(responseBody);
        return decoded['secure_url'];
      } else {
        debugPrint('Cloudinary Upload Error: $responseBody');
        throw 'Failed to upload image to Cloudinary ($responseBody)';
      }
    } catch (e) {
      debugPrint('Error uploading to Cloudinary: $e');
      rethrow;
    }
  }

  /// Helper to convert a normal Cloudinary URL to an optimized one with transformations
  static String getOptimizedUrl(String url, {int? width, int? height, int quality = 80}) {
    if (!url.contains('cloudinary.com')) return url;
    
    // Insert the transformation into the URL (after /upload/)
    // Auto format (f_auto) and Auto quality (q_auto)
    String transform = 'f_auto,q_auto';
    if (width != null) transform += ',w_$width';
    if (height != null) transform += ',h_$height,c_fill';

    return url.replaceFirst('/upload/', '/upload/$transform/');
  }

  /// Compresses an image before upload to save bandwidth and credits
  Future<File> compressImage(File file) async {
    final tempDir = await getTemporaryDirectory();
    final fileName = p.basenameWithoutExtension(file.path);
    final targetPath = p.join(tempDir.path, "compressed_${fileName}_${DateTime.now().millisecondsSinceEpoch}.jpg");

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70, // Sufficient for mobile
      minWidth: 1080,
      minHeight: 1080,
      format: CompressFormat.jpeg,
    );

    if (result == null) return file;
    return File(result.path);
  }
}
