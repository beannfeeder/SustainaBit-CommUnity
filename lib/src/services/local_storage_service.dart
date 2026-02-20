import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  SharedPreferences? _prefs;

  // Keys
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyUserRole = 'userRole';
  static const String _keyUserId = 'userId';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Auth State
  bool get isLoggedIn => _prefs?.getBool(_keyIsLoggedIn) ?? false;
  
  Future<void> setIsLoggedIn(bool value) async {
    await _prefs?.setBool(_keyIsLoggedIn, value);
  }

  // User Role (default to 'user' if not set)
  String get userRole => _prefs?.getString(_keyUserRole) ?? 'user';

  Future<void> setUserRole(String role) async {
    await _prefs?.setString(_keyUserRole, role);
  }

  // User ID
  String? get userId => _prefs?.getString(_keyUserId);

  Future<void> setUserId(String id) async {
    await _prefs?.setString(_keyUserId, id);
  }

  // Clear all auth data
  Future<void> clearAuthData() async {
    await _prefs?.remove(_keyIsLoggedIn);
    await _prefs?.remove(_keyUserRole);
    await _prefs?.remove(_keyUserId);
  }
}
