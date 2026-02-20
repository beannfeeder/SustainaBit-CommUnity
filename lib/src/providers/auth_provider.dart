import 'package:flutter/foundation.dart';
import '../services/local_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final LocalStorageService _storageService = LocalStorageService();

  bool get isLoggedIn => _storageService.isLoggedIn;
  String get userRole => _storageService.userRole;
  String? get userId => _storageService.userId;

  Future<void> login(String newUserId, {String role = 'user'}) async {
    await _storageService.setIsLoggedIn(true);
    await _storageService.setUserId(newUserId);
    await _storageService.setUserRole(role);
    notifyListeners();
  }

  Future<void> logout() async {
    await _storageService.clearAuthData();
    notifyListeners();
  }

  // Admin-only action: change a user's role locally (mostly for debugging or switching roles)
  Future<void> setRole(String role) async {
    await _storageService.setUserRole(role);
    notifyListeners();
  }
}
