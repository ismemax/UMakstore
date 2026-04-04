import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // Required for debugPrint

class BookmarkService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Toggles the bookmark status of an app for the current user
  Future<bool> toggleBookmark(String appId) async {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('Bookmark toggle failed: No user authenticated');
      return false;
    }

    try {
      final bookmarkRef = _db
          .collection('users')
          .doc(user.uid)
          .collection('bookmarks')
          .doc(appId);

      final doc = await bookmarkRef.get().timeout(const Duration(seconds: 5));
      if (doc.exists) {
        await bookmarkRef.delete();
      } else {
        await bookmarkRef.set({
          'appId': appId,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
      return true;
    } catch (e) {
      debugPrint('Firestore Bookmark Error: $e');
      return false;
    }
  }

  /// Checks if an app is bookmarked by the current user
  Stream<bool> isBookmarked(String appId) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(false);

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .doc(appId)
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }

  /// Fetches all bookmarked app IDs for the current user
  Stream<List<String>> getBookmarkedAppIds() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }
}
