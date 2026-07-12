import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const String _accessTokenKey = 'jwt_access_token';
  static const String _refreshTokenKey = 'jwt_refresh_token';
  static const String _userDataKey = 'jwt_user_data';

  /// Save access token
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  /// Read access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Delete access token
  Future<void> deleteAccessToken() async {
    await _storage.delete(key: _accessTokenKey);
  }

  /// Save refresh token
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  /// Read refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Delete refresh token
  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
  }

  /// Save user data json string
  Future<void> saveUserData(String userDataJson) async {
    await _storage.write(key: _userDataKey, value: userDataJson);
  }

  /// Read user data json string
  Future<String?> getUserData() async {
    return await _storage.read(key: _userDataKey);
  }

  /// Delete user data json string
  Future<void> deleteUserData() async {
    await _storage.delete(key: _userDataKey);
  }

  /// Clear all stored secure data
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
