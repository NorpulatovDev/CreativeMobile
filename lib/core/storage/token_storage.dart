import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

abstract class TokenStorage {
  Future<String?> getToken();
  Future<void> saveToken(String token);
  Future<void> deleteToken();
}

class TokenStorageImpl implements TokenStorage {
  static const _tokenKey = 'auth_token';
  
  final FlutterSecureStorage? _secureStorage;
  final SharedPreferences _prefs;

  TokenStorageImpl(this._prefs)
      : _secureStorage = kIsWeb ? null : const FlutterSecureStorage();

  @override
  Future<String?> getToken() async {
    if (kIsWeb) {
      return _prefs.getString(_tokenKey);
    }
    return _secureStorage!.read(key: _tokenKey);
  }

  @override
  Future<void> saveToken(String token) async {
    if (kIsWeb) {
      await _prefs.setString(_tokenKey, token);
    } else {
      await _secureStorage!.write(key: _tokenKey, value: token);
    }
  }

  @override
  Future<void> deleteToken() async {
    if (kIsWeb) {
      await _prefs.remove(_tokenKey);
    } else {
      await _secureStorage!.delete(key: _tokenKey);
    }
  }
}