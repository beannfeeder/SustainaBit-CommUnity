import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Service for operations that should be validated server-side.
///
/// These methods write to Firestore with the authenticated user's context,
/// relying on Firestore Security Rules to enforce authorization.
/// For truly sensitive operations, deploy corresponding Firebase Cloud Functions
/// and call them via HTTPS callable instead.
class CloudFunctionService {
  static final CloudFunctionService _instance = CloudFunctionService._internal();
  factory CloudFunctionService() => _instance;
  CloudFunctionService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Updates a community zone boundary.
  /// This writes to Firestore under the authenticated user's context.
  /// Firestore Security Rules should verify the user has 'management' role.
  ///
  /// For production, replace with a Cloud Function callable:
  /// ```
  /// final callable = FirebaseFunctions.instance.httpsCallable('updateZone');
  /// await callable.call({'points': points});
  /// ```
  Future<void> updateZone(List<Map<String, double>> points) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User must be authenticated to update zones');
    }

    await _firestore.collection('zones').add({
      'points': points,
      'updatedBy': user.uid,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    debugPrint('Zone update submitted via Firestore');
  }
}
