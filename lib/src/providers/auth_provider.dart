import 'package:flutter/foundation.dart';
import '../services/local_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final LocalStorageService _storageService = LocalStorageService();

  bool get isLoggedIn => _storageService.isLoggedIn;
  String get userRole => _storageService.userRole;
  String? get userId => _storageService.userId;
  String? get displayName => _storageService.displayName;
  String? get email => _storageService.email;
  String? get photoUrl => _storageService.photoUrl;

  /// Returns displayName if available, otherwise falls back to the first
  /// part of the email, and finally to the userId.
  String get displayNameOrFallback {
    if (displayName != null && displayName!.isNotEmpty) return displayName!;
    if (email != null && email!.isNotEmpty) return email!.split('@').first;
    return userId ?? 'Unknown';
  }

  Future<void> login(
    String newUserId, {
    String?
        role, // null = keep whatever is already stored (e.g. from Firestore fetch)
    String? displayName,
    String? email,
    String? photoUrl,
  }) async {
    await _storageService.setIsLoggedIn(true);
    await _storageService.setUserId(newUserId);
    if (role != null)
      await _storageService.setUserRole(role); // only overwrite if explicit
    if (displayName != null) await _storageService.setDisplayName(displayName);
    if (email != null) await _storageService.setEmail(email);
    if (photoUrl != null) await _storageService.setPhotoUrl(photoUrl);
    notifyListeners();
  }

  Future<void> logout() async {
    await _storageService.clearAuthData();
    notifyListeners();
  }

  // Admin-only action: change a user's role locally
  Future<void> setRole(String role) async {
    await _storageService.setUserRole(role);
    notifyListeners();
  }
}
