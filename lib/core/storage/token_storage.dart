import 'package:flutter/services.dart';
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
    int? teacherId,
  });
  Future<Map<String, dynamic>?> getUserData();
  Future<void> deleteUserData();

  Future<int?> getActiveBranchFilterId();
  int? getActiveBranchFilterIdSync();
  Future<void> setActiveBranchFilterId(int? id);
  Future<String?> getActiveBranchFilterName();
  Future<void> setActiveBranchFilterName(String? name);

  Map<String, dynamic>? getUserDataSync();

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
  static const _teacherIdKey = 'user_teacher_id';
  static const _activeBranchFilterIdKey = 'active_branch_filter_id';
  static const _activeBranchFilterNameKey = 'active_branch_filter_name';

  final FlutterSecureStorage? _secureStorage;
  final SharedPreferences _prefs;

  TokenStorageImpl(this._prefs)
      : _secureStorage = kIsWeb ? null : const FlutterSecureStorage();

  // ── Access token ──────────────────────────────────────────────────────────

  @override
  Future<String?> getToken() async {
    if (kIsWeb) return _prefs.getString(_accessTokenKey);
    try {
      return await _secureStorage!.read(key: _accessTokenKey);
    } on PlatformException {
      // Keystore key invalidated — e.g. app re-signed (debug→release),
      // new biometric enrolled, or device restored.
      // Wipe all secure storage and force re-login.
      await _secureStorage!.deleteAll();
      return null;
    }
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
    try {
      return await _secureStorage!.read(key: _refreshTokenKey);
    } on PlatformException {
      await _secureStorage!.deleteAll();
      return null;
    }
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
    int? teacherId,
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
    if (teacherId != null) {
      await _prefs.setInt(_teacherIdKey, teacherId);
    } else {
      await _prefs.remove(_teacherIdKey);
    }
  }

  @override
  Map<String, dynamic>? getUserDataSync() {
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
      'teacherId': _prefs.getInt(_teacherIdKey),
    };
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
      'teacherId': _prefs.getInt(_teacherIdKey),
    };
  }

  @override
  Future<void> deleteUserData() async {
    await _prefs.remove(_usernameKey);
    await _prefs.remove(_roleKey);
    await _prefs.remove(_adminIdKey);
    await _prefs.remove(_branchIdKey);
    await _prefs.remove(_branchNameKey);
    await _prefs.remove(_teacherIdKey);
  }

  // ── Active branch filter (super admin branch switching) ───────────────────

  @override
  Future<int?> getActiveBranchFilterId() async =>
      _prefs.getInt(_activeBranchFilterIdKey);

  @override
  int? getActiveBranchFilterIdSync() => _prefs.getInt(_activeBranchFilterIdKey);

  @override
  Future<void> setActiveBranchFilterId(int? id) async {
    if (id != null) {
      await _prefs.setInt(_activeBranchFilterIdKey, id);
    } else {
      await _prefs.remove(_activeBranchFilterIdKey);
    }
  }

  @override
  Future<String?> getActiveBranchFilterName() async =>
      _prefs.getString(_activeBranchFilterNameKey);

  @override
  Future<void> setActiveBranchFilterName(String? name) async {
    if (name != null) {
      await _prefs.setString(_activeBranchFilterNameKey, name);
    } else {
      await _prefs.remove(_activeBranchFilterNameKey);
    }
  }

  // ── Delete all ────────────────────────────────────────────────────────────

  @override
  Future<void> deleteAll() async {
    await deleteToken();
    await deleteRefreshToken();
    await deleteUserData();
    await _prefs.remove(_activeBranchFilterIdKey);
    await _prefs.remove(_activeBranchFilterNameKey);
  }
}
