import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

/// Provides authentication state and user role information to the widget tree.
///
/// Listens to Firebase Auth state changes and fetches the user's role
/// from Firestore whenever the auth state changes.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  firebase_auth.User? _firebaseUser;
  UserRole _userRole = UserRole.user;
  bool _isLoading = true;
  StreamSubscription<firebase_auth.User?>? _authSubscription;

  AuthProvider() {
    _authSubscription = _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  firebase_auth.User? get firebaseUser => _firebaseUser;
  UserRole get userRole => _userRole;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _firebaseUser != null;
  bool get isManagement => _userRole == UserRole.management;

  Future<void> _onAuthStateChanged(firebase_auth.User? user) async {
    _firebaseUser = user;
    if (user != null) {
      _userRole = await _userService.getUserRole(user.uid);
    } else {
      _userRole = UserRole.user;
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Sign in with Google and create/fetch user document in Firestore.
  Future<UserRole?> signInWithGoogle() async {
    try {
      final credential = await _authService.signInWithGoogle();
      if (credential?.user != null) {
        final role = await _userService.ensureUserDocument(credential!.user!);
        _firebaseUser = credential.user;
        _userRole = role;
        notifyListeners();
        return role;
      }
      return null;
    } catch (e) {
      debugPrint('Error during sign in: $e');
      rethrow;
    }
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await _authService.signOut();
    _firebaseUser = null;
    _userRole = UserRole.user;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
