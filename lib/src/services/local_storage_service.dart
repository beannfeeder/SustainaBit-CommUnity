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
  static const String _keyDisplayName = 'displayName';
  static const String _keyEmail = 'email';
  static const String _keyPhotoUrl = 'photoUrl';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Auth State
  bool get isLoggedIn => _prefs?.getBool(_keyIsLoggedIn) ?? false;
  Future<void> setIsLoggedIn(bool value) async =>
      await _prefs?.setBool(_keyIsLoggedIn, value);

  // User Role
  String get userRole => _prefs?.getString(_keyUserRole) ?? 'user';
  Future<void> setUserRole(String role) async =>
      await _prefs?.setString(_keyUserRole, role);

  // User ID
  String? get userId => _prefs?.getString(_keyUserId);
  Future<void> setUserId(String id) async =>
      await _prefs?.setString(_keyUserId, id);

  // Display Name
  String? get displayName => _prefs?.getString(_keyDisplayName);
  Future<void> setDisplayName(String name) async =>
      await _prefs?.setString(_keyDisplayName, name);

  // Email
  String? get email => _prefs?.getString(_keyEmail);
  Future<void> setEmail(String email) async =>
      await _prefs?.setString(_keyEmail, email);

  // Photo URL
  String? get photoUrl => _prefs?.getString(_keyPhotoUrl);
  Future<void> setPhotoUrl(String url) async =>
      await _prefs?.setString(_keyPhotoUrl, url);

  // Clear all auth data
  Future<void> clearAuthData() async {
    await _prefs?.remove(_keyIsLoggedIn);
    await _prefs?.remove(_keyUserRole);
    await _prefs?.remove(_keyUserId);
    await _prefs?.remove(_keyDisplayName);
    await _prefs?.remove(_keyEmail);
    await _prefs?.remove(_keyPhotoUrl);
  }
}
