import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_strings.dart';

class SecureStorage {
  final FlutterSecureStorage _storage;

  SecureStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: AppStrings.tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return _storage.read(key: AppStrings.tokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: AppStrings.refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: AppStrings.refreshTokenKey);
  }

  Future<void> saveUser(Map<String, dynamic> user) async {
    await _storage.write(key: AppStrings.userKey, value: jsonEncode(user));
  }

  Future<Map<String, dynamic>?> getUser() async {
    final data = await _storage.read(key: AppStrings.userKey);
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> setRememberMe(bool value) async {
    await _storage.write(key: AppStrings.rememberMeKey, value: value.toString());
  }

  Future<bool> getRememberMe() async {
    final value = await _storage.read(key: AppStrings.rememberMeKey);
    return value == 'true';
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
