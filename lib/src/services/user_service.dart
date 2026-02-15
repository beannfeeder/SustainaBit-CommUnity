import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import '../models/user.dart';

/// Service for managing user data in Firestore.
///
/// User roles are stored in Firestore at: `users/{uid}`
/// The `role` field can be manually changed in Firebase Console to 'management'.
/// Default role for new users is 'user'.
class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Creates a user document in Firestore after first sign-in.
  /// If the document already exists, it will not be overwritten.
  /// Returns the user's role.
  Future<UserRole> ensureUserDocument(firebase_auth.User firebaseUser) async {
    final docRef = _firestore.collection('users').doc(firebaseUser.uid);
    final doc = await docRef.get();

    if (doc.exists) {
      final data = doc.data();
      return UserRole.fromString(data?['role'] as String?);
    }

    // Create new user document with default 'user' role
    final now = DateTime.now().toIso8601String();
    await docRef.set({
      'name': firebaseUser.displayName ?? '',
      'email': firebaseUser.email ?? '',
      'avatar': firebaseUser.photoURL,
      'role': UserRole.user.name,
      'impactScore': 0,
      'createdAt': now,
    });

    return UserRole.user;
  }

  /// Fetches the current user's role from Firestore.
  Future<UserRole> getUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserRole.fromString(doc.data()?['role'] as String?);
      }
      return UserRole.user;
    } catch (e) {
      debugPrint('Error fetching user role: $e');
      return UserRole.user;
    }
  }

  /// Fetches the full user profile from Firestore.
  Future<User?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        return User(
          id: uid,
          name: data['name'] as String? ?? '',
          email: data['email'] as String? ?? '',
          avatar: data['avatar'] as String?,
          impactScore: data['impactScore'] as int? ?? 0,
          createdAt: data['createdAt'] != null
              ? DateTime.parse(data['createdAt'] as String)
              : DateTime.now(),
          role: UserRole.fromString(data['role'] as String?),
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return null;
    }
  }
}
