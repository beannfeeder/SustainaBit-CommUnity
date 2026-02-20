import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'local_storage_service.dart'; // NEW

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Stream to listen to authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      UserCredential credential;
      if (kIsWeb) {
        // For web, use signInWithPopup
        GoogleAuthProvider authProvider = GoogleAuthProvider();
        credential = await _auth.signInWithPopup(authProvider);
      } else {
        // For Android and iOS
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        
        if (googleUser == null) {
          // User canceled the sign-in flow
          return null;
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final OAuthCredential oAuthCredential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        credential = await _auth.signInWithCredential(oAuthCredential);
      }

      // ── Save Local Login State ──
      if (credential.user != null) {
        final storage = LocalStorageService();
        await storage.setIsLoggedIn(true);
        await storage.setUserId(credential.user!.uid);
        // If it's a new login, default to 'user' role locally.
        // In a real app, you would fetch their actual role from Firestore here.
        if (storage.userRole.isEmpty) {
          await storage.setUserRole('user');
        }
      }

      return credential;
    } catch (e) {
      debugPrint("Error signing in with Google: $e");
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      // Clear local auth cache
      await LocalStorageService().clearAuthData();
    } catch (e) {
      debugPrint("Error signing out: $e");
      rethrow;
    }
  }
}
