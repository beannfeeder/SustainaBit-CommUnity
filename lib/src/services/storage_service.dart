import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_constants.dart';

/// Service for managing local storage
/// Uses SharedPreferences for general data and FlutterSecureStorage for sensitive data
class StorageService {
  static SharedPreferences? _prefs;
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

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

  /// Save user token securely using platform Keychain/Keystore
  /// This ensures the token is encrypted and stored securely
  /// Throws an exception if the save operation fails
  static Future<void> saveUserToken(String token) async {
    try {
      await _secureStorage.write(
        key: AppConstants.userTokenKey,
        value: token,
      );
    } catch (e) {
      throw Exception('Failed to save user token: $e');
    }
  }

  /// Get user token from secure storage
  /// Returns null if no token is stored or if retrieval fails
  static Future<String?> getUserToken() async {
    try {
      return await _secureStorage.read(key: AppConstants.userTokenKey);
    } catch (e) {
      throw Exception('Failed to retrieve user token: $e');
    }
  }

  /// Remove user token from secure storage
  /// Throws an exception if the delete operation fails
  static Future<void> removeUserToken() async {
    try {
      await _secureStorage.delete(key: AppConstants.userTokenKey);
    } catch (e) {
      throw Exception('Failed to remove user token: $e');
    }
  }
}
