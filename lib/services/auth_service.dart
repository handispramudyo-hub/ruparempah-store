import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

class AuthService {
  AuthService(this._prefs);

  final SharedPreferences _prefs;

  static Future<AuthService> create() async {
    final prefs = await SharedPreferences.getInstance();
    final service = AuthService(prefs);
    await service._ensureDefaultAccount();
    return service;
  }

  Future<void> _ensureDefaultAccount() async {
    final username = _prefs.getString(AppConfig.keyUsername);
    if (username == null || username.isEmpty) {
      await _prefs.setString(AppConfig.keyUsername, AppConfig.defaultUsername);
      await _prefs.setString(
        AppConfig.keyPasswordHash,
        hashPassword(AppConfig.defaultPassword),
      );
    }
  }

  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<bool> login(String username, String password) async {
    final storedUser = _prefs.getString(AppConfig.keyUsername);
    final storedHash = _prefs.getString(AppConfig.keyPasswordHash);
    if (storedUser == null || storedHash == null) return false;
    if (username.trim() != storedUser) return false;
    return hashPassword(password) == storedHash;
  }

  Future<void> setLoggedIn(bool value) async {
    await _prefs.setBool(AppConfig.keyIsLoggedIn, value);
  }

  bool isLoggedIn() => _prefs.getBool(AppConfig.keyIsLoggedIn) ?? false;

  String? getUsername() => _prefs.getString(AppConfig.keyUsername);

  Future<void> updateCredentials({
    required String username,
    required String password,
  }) async {
    await _prefs.setString(AppConfig.keyUsername, username.trim());
    await _prefs.setString(AppConfig.keyPasswordHash, hashPassword(password));
  }

  Future<void> logout() async {
    await _prefs.setBool(AppConfig.keyIsLoggedIn, false);
  }
}
