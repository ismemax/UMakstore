import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DeveloperService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Submits a new app to Firestore
  Future<void> submitApp({
    required String title,
    required String publisher,
    required String description,
    required String category,
    required String apkUrl,
    required String packageName,
    required String version,
    String? iconUrl,
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
    try {
      return _db
          .collection('submitted_apps')
          .snapshots(includeMetadataChanges: true)
          .map((snapshot) {
            debugPrint('Firestore: Received ${snapshot.docs.length} docs (FromCache: ${snapshot.metadata.isFromCache})');
            return snapshot.docs.map((doc) {
              final data = doc.data();
              return AppModel(
                id: doc.id,
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
                reviews: data['reviews']?.toString() ?? '0',
                iconData: Icons.apps_rounded,
              );
            }).toList();
          });
    } catch (e) {
      debugPrint('Error creating storeapps stream: $e');
      return Stream.error(e);
    }
  }

  /// Submits a review for an app
  Future<void> submitReview({
    required String appId,
    required double rating,
    required String comment,
    required bool isAnonymous,
  }) async {
    final user = _auth.currentUser;

    final reviewData = {
      'rating': rating,
      'comment': comment,
      'isAnonymous': isAnonymous,
      'userId': isAnonymous ? 'Anonymous' : user?.uid,
      'userName': isAnonymous ? 'UMak User' : (user?.displayName ?? 'UMak Student'),
      'createdAt': FieldValue.serverTimestamp(),
    };

    final appRef = _db.collection('submitted_apps').doc(appId);
    
    // Use a transaction to update the app's stats and add the review
    await _db.runTransaction((transaction) async {
      // 1. READ FIRST: Get the app's summary stats
      DocumentSnapshot snapshot = await transaction.get(appRef);
      if (!snapshot.exists) return;

      // 2. WRITE SECOND: Add the review to the sub-collection
      final newReviewRef = appRef.collection('reviews').doc();
      transaction.set(newReviewRef, reviewData);

      // 3. WRITE THIRD: Update the app's summary stats
      int currentReviews = int.tryParse(snapshot['reviews']?.toString() ?? '0') ?? 0;
      double currentRating = double.tryParse(snapshot['rating']?.toString() ?? '0.0') ?? 0.0;

      double newRating = ((currentRating * currentReviews) + rating) / (currentReviews + 1);
      
      transaction.update(appRef, {
        'reviews': (currentReviews + 1).toString(),
        'rating': newRating.toStringAsFixed(1),
      });
    });
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
}
