import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static final TokenStorage instance = TokenStorage._internal();

  TokenStorage._internal();

  static const String _tokenKey = 'auth_token';
  static const String _backendUrlKey = 'backend_url';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(
      key: _tokenKey,
      value: token,
    );
  }

  Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  Future<void> saveBackendUrl(String backendUrl) async {
    await _storage.write(
      key: _backendUrlKey,
      value: backendUrl,
    );
  }

  Future<String?> getBackendUrl() async {
    return _storage.read(key: _backendUrlKey);
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _backendUrlKey);
  }

  Future<void> clearToken() async {
    await clearSession();
  }
}