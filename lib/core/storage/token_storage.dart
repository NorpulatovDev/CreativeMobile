import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

abstract class TokenStorage {
  Future<String?> getToken();
  Future<void> saveToken(String token);
  Future<void> deleteToken();

  Future<String?> getRefreshToken();
  Future<void> saveRefreshToken(String token);
  Future<void> deleteRefreshToken();

  Future<void> saveUserData({
    required int adminId,
    required String username,
    required String role,
    int? branchId,
    String? branchName,
  });
  Future<Map<String, dynamic>?> getUserData();
  Future<void> deleteUserData();

  Future<void> deleteAll();
}

class TokenStorageImpl implements TokenStorage {
  static const _accessTokenKey = 'auth_token';
  static const _refreshTokenKey = 'auth_refresh_token';
  static const _adminIdKey = 'user_admin_id';
  static const _usernameKey = 'user_username';
  static const _roleKey = 'user_role';
  static const _branchIdKey = 'user_branch_id';
  static const _branchNameKey = 'user_branch_name';

  final FlutterSecureStorage? _secureStorage;
  final SharedPreferences _prefs;

  TokenStorageImpl(this._prefs)
      : _secureStorage = kIsWeb ? null : const FlutterSecureStorage();

  // ── Access token ──────────────────────────────────────────────────────────

  @override
  Future<String?> getToken() async {
    if (kIsWeb) return _prefs.getString(_accessTokenKey);
    return _secureStorage!.read(key: _accessTokenKey);
  }

  @override
  Future<void> saveToken(String token) async {
    if (kIsWeb) {
      await _prefs.setString(_accessTokenKey, token);
    } else {
      await _secureStorage!.write(key: _accessTokenKey, value: token);
    }
  }

  @override
  Future<void> deleteToken() async {
    if (kIsWeb) {
      await _prefs.remove(_accessTokenKey);
    } else {
      await _secureStorage!.delete(key: _accessTokenKey);
    }
  }

  // ── Refresh token ─────────────────────────────────────────────────────────

  @override
  Future<String?> getRefreshToken() async {
    if (kIsWeb) return _prefs.getString(_refreshTokenKey);
    return _secureStorage!.read(key: _refreshTokenKey);
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    if (kIsWeb) {
      await _prefs.setString(_refreshTokenKey, token);
    } else {
      await _secureStorage!.write(key: _refreshTokenKey, value: token);
    }
  }

  @override
  Future<void> deleteRefreshToken() async {
    if (kIsWeb) {
      await _prefs.remove(_refreshTokenKey);
    } else {
      await _secureStorage!.delete(key: _refreshTokenKey);
    }
  }

  // ── User metadata (non-sensitive, SharedPreferences on all platforms) ─────

  @override
  Future<void> saveUserData({
    required int adminId,
    required String username,
    required String role,
    int? branchId,
    String? branchName,
  }) async {
    await _prefs.setInt(_adminIdKey, adminId);
    await _prefs.setString(_usernameKey, username);
    await _prefs.setString(_roleKey, role);
    if (branchId != null) {
      await _prefs.setInt(_branchIdKey, branchId);
    } else {
      await _prefs.remove(_branchIdKey);
    }
    if (branchName != null) {
      await _prefs.setString(_branchNameKey, branchName);
    } else {
      await _prefs.remove(_branchNameKey);
    }
  }

  @override
  Future<Map<String, dynamic>?> getUserData() async {
    final username = _prefs.getString(_usernameKey);
    final role = _prefs.getString(_roleKey);
    final adminId = _prefs.getInt(_adminIdKey);
    if (username == null || role == null || adminId == null) return null;
    return {
      'username': username,
      'role': role,
      'adminId': adminId,
      'branchId': _prefs.getInt(_branchIdKey),
      'branchName': _prefs.getString(_branchNameKey),
    };
  }

  @override
  Future<void> deleteUserData() async {
    await _prefs.remove(_usernameKey);
    await _prefs.remove(_roleKey);
    await _prefs.remove(_adminIdKey);
    await _prefs.remove(_branchIdKey);
    await _prefs.remove(_branchNameKey);
  }

  // ── Delete all ────────────────────────────────────────────────────────────

  @override
  Future<void> deleteAll() async {
    await deleteToken();
    await deleteRefreshToken();
    await deleteUserData();
  }
}
