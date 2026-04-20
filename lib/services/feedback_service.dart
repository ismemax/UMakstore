import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Collects and manages user feedback and bug reports.
/// 
/// Feedback is stored as an array within the user's primary document to 
/// simplify permissions while allowing for administrative aggregation.
class FeedbackService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Submits a new feedback entry by appending it to the user's document.
  /// 
  /// The entry includes a timestamp, a unique ID, and the initial 'New' status.
  Future<void> submitFeedback({
    required String category,
    required String subject,
    required String details,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User must be logged in to submit feedback');

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({
        'user_feedbacks': FieldValue.arrayUnion([{
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'userId': user.uid,
          'userEmail': user.email,
          'category': category,
          'subject': subject,
          'details': details,
          'timestamp': DateTime.now().toIso8601String(),
          'status': 'New',
        }])
      });
    } catch (e) {
      debugPrint('CRITICAL: Feedback Submission Error: $e');
      // If update fails, the document might not exist (first time)
      // Though for profile users it should.
      rethrow;
    }
  }

  /// Aggregate all feedback from every user in the system.
  /// 
  /// This method is designed for Admin consumption and returns a flattened 
  /// list sorted by submission date.
  Stream<List<Map<String, dynamic>>> getAllFeedback() {
    // Aggregating from all users who have the 'user_feedbacks' array
    return _firestore
        .collection('users')
        .where('user_feedbacks', isNull: false)
        .snapshots()
        .map((snapshot) {
          final List<Map<String, dynamic>> allFeedback = [];
          for (var userDoc in snapshot.docs) {
            final data = userDoc.data();
            if (data.containsKey('user_feedbacks')) {
              final feedbacks = List<dynamic>.from(data['user_feedbacks']);
              for (var f in feedbacks) {
                final feedbackData = Map<String, dynamic>.from(f);
                feedbackData['userDocId'] = userDoc.id; // Store for updates
                allFeedback.add(feedbackData);
              }
            }
          }
          // Sort by timestamp
          allFeedback.sort((a, b) => (b['timestamp'] ?? '').compareTo(a['timestamp'] ?? ''));
          return allFeedback;
        });
  }

  /// Updates the status (e.g., 'In Progress', 'Resolved') of a specific feedback entry.
  /// 
  /// Since feedback is in an array, this performs a retrieval-modification-write cycle.
  Future<void> updateFeedbackStatus(Map<String, dynamic> feedback, String status) async {
    final userDocId = feedback['userDocId'];
    final feedbackId = feedback['id'];
    
    final userRef = _firestore.collection('users').doc(userDocId);
    final userDoc = await userRef.get();
    
    if (userDoc.exists) {
      final data = userDoc.data()!;
      final List<dynamic> feedbacks = List.from(data['user_feedbacks'] ?? []);
      
      final index = feedbacks.indexWhere((f) => f['id'] == feedbackId);
      if (index != -1) {
        feedbacks[index]['status'] = status;
        await userRef.update({'user_feedbacks': feedbacks});
      }
    }
  }
}
