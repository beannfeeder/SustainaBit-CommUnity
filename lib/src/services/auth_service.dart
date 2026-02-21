import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'local_storage_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  /// Sign in with Google, mirror the profile photo to Firebase Storage,
  /// upsert the user doc in Firestore, and cache all fields locally.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      UserCredential credential;
      if (kIsWeb) {
        final authProvider = GoogleAuthProvider();
        credential = await _auth.signInWithPopup(authProvider);
      } else {
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null;
        final googleAuth = await googleUser.authentication;
        final oAuthCredential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        credential = await _auth.signInWithCredential(oAuthCredential);
      }

      final user = credential.user;
      if (user != null) {
        // Mirror the Google photo to Firebase Storage (avoids CORS on web)
        final storedPhotoUrl = await _mirrorProfilePhoto(user);

        // Upsert Firestore user document
        await _upsertUserProfile(user, storedPhotoUrl);

        // Fetch role from Firestore
        final role = await _fetchUserRole(user.uid);

        // Cache everything locally
        final storage = LocalStorageService();
        await storage.setIsLoggedIn(true);
        await storage.setUserId(user.uid);
        await storage.setUserRole(role);
        if (user.displayName != null) {
          await storage.setDisplayName(user.displayName!);
        }
        if (user.email != null) {
          await storage.setEmail(user.email!);
        }
        // Use our own Storage URL so there are no CORS issues on web
        final photoToStore = storedPhotoUrl ?? user.photoURL ?? '';
        if (photoToStore.isNotEmpty) {
          await storage.setPhotoUrl(photoToStore);
        }
      }

      return credential;
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      rethrow;
    }
  }

  /// Downloads the Google profile photo and re-uploads it to
  /// `profile_photos/{uid}.jpg` in Firebase Storage.
  /// Returns the Firebase Storage download URL, or null on failure.
  Future<String?> _mirrorProfilePhoto(User user) async {
    if (user.photoURL == null || user.photoURL!.isEmpty) return null;

    // Check if we already have a mirrored copy
    final ref = _storage.ref().child('profile_photos/${user.uid}.jpg');
    try {
      final existingUrl = await ref.getDownloadURL();
      if (existingUrl.isNotEmpty) return existingUrl; // already uploaded
    } catch (_) {
      // File doesn't exist yet — continue to upload
    }

    try {
      // Download the Google photo bytes
      final response = await http.get(Uri.parse(user.photoURL!));
      if (response.statusCode != 200) return null;

      // Upload to Firebase Storage
      await ref.putData(
        response.bodyBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Could not mirror profile photo: $e');
      return null;
    }
  }

  /// Creates or updates a `users/{uid}` document in Firestore.
  /// For first-time sign-ups the role is set to 'user'.
  /// For returning users only profile fields are updated — role is preserved.
  Future<void> _upsertUserProfile(User user, String? storedPhotoUrl) async {
    final ref = _firestore.collection('users').doc(user.uid);
    final existing = await ref.get();

    final profileFields = {
      'uid': user.uid,
      'displayName': user.displayName ?? '',
      'email': user.email ?? '',
      'photoUrl': storedPhotoUrl ?? user.photoURL ?? '',
      'lastLoginAt': FieldValue.serverTimestamp(),
    };

    if (!existing.exists) {
      // First sign-up: create the doc with an explicit default role
      await ref.set({...profileFields, 'role': 'user'});
    } else {
      // Returning user: only update profile fields, leave 'role' untouched
      await ref.set(profileFields, SetOptions(merge: true));
    }
  }

  /// Reads the role field from Firestore; returns 'user' if not set.
  Future<String> _fetchUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return (doc.data()?['role'] as String?) ?? 'user';
      }
    } catch (e) {
      debugPrint('Could not fetch role: $e');
    }
    return 'user';
  }

  Future<void> signOut() async {
    try {
      if (!kIsWeb) await _googleSignIn.signOut();
      await _auth.signOut();
      await LocalStorageService().clearAuthData();
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }
}
