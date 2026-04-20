import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // Required for debugPrint

/// Manages the user's bookmarked applications using a Firestore sub-collection.
class BookmarkService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Toggles the bookmark status for a specific app ID.
  /// 
  /// If the bookmark exists, it is removed. If it does not, it is created
  /// with a server timestamp.
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

  /// Listens to the bookmark status of a specific app for the current user.
  /// 
  /// Returns a [Stream] of booleans that updates in real-time.
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

  /// Fetches the IDs of all apps currently bookmarked by the user.
  /// 
  /// Useful for filtering the store list or displaying the 'My Bookmarks' screen.
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
