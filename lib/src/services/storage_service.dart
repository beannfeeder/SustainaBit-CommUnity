import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_constants.dart';

/// Service for managing local storage
class StorageService {
  static SharedPreferences? _prefs;

  /// Initialize the storage service
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get SharedPreferences instance
  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('StorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  /// Save a string value
  static Future<bool> setString(String key, String value) async {
    return await prefs.setString(key, value);
  }

  /// Get a string value
  static String? getString(String key) {
    return prefs.getString(key);
  }

  /// Save an integer value
  static Future<bool> setInt(String key, int value) async {
    return await prefs.setInt(key, value);
  }

  /// Get an integer value
  static int? getInt(String key) {
    return prefs.getInt(key);
  }

  /// Save a boolean value
  static Future<bool> setBool(String key, bool value) async {
    return await prefs.setBool(key, value);
  }

  /// Get a boolean value
  static bool? getBool(String key) {
    return prefs.getBool(key);
  }

  /// Save a double value
  static Future<bool> setDouble(String key, double value) async {
    return await prefs.setDouble(key, value);
  }

  /// Get a double value
  static double? getDouble(String key) {
    return prefs.getDouble(key);
  }

  /// Remove a value
  static Future<bool> remove(String key) async {
    return await prefs.remove(key);
  }

  /// Clear all values
  static Future<bool> clear() async {
    return await prefs.clear();
  }

  /// Check if a key exists
  static bool containsKey(String key) {
    return prefs.containsKey(key);
  }

  // Convenience methods for common keys

  /// Save user token
  static Future<bool> saveUserToken(String token) async {
    return await setString(AppConstants.userTokenKey, token);
  }

  /// Get user token
  static String? getUserToken() {
    return getString(AppConstants.userTokenKey);
  }

  /// Remove user token
  static Future<bool> removeUserToken() async {
    return await remove(AppConstants.userTokenKey);
  }
}
