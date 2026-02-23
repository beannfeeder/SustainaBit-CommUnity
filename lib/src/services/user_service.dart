import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Provides user profile data (display name, photo) from Firestore.
class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// In-memory cache so we don't repeat reads for the same user during a session.
  final Map<String, Map<String, dynamic>> _cache = {};

  /// Returns the display name for a given [uid], falling back to the UID itself.
  Future<String> getDisplayName(String uid) async {
    if (_cache.containsKey(uid)) {
      return (_cache[uid]!['displayName'] as String?)?.isNotEmpty == true
          ? _cache[uid]!['displayName'] as String
          : uid;
    }
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _cache[uid] = doc.data() ?? {};
        final name = _cache[uid]!['displayName'] as String?;
        if (name != null && name.isNotEmpty) return name;
      }
    } catch (e) {
      debugPrint('UserService.getDisplayName error: $e');
    }
    return uid; // fallback
  }

  /// Returns the photo URL for a given [uid], or null.
  Future<String?> getPhotoUrl(String uid) async {
    if (!_cache.containsKey(uid)) await getDisplayName(uid); // populates cache
    return _cache[uid]?['photoUrl'] as String?;
  }

  /// Clears the in-memory cache (e.g. on logout).
  void clearCache() => _cache.clear();
}
