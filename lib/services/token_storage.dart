import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();
  static const _keyAccess = 'tlb_access_token';
  static const _keyRefresh = 'tlb_refresh_token';
  static const _keyUser = 'tlb_user_json';

  static Future<void> saveTokens(
      String access, String refresh, String userJson) async {
    await _storage.write(key: _keyAccess, value: access);
    await _storage.write(key: _keyRefresh, value: refresh);
    await _storage.write(key: _keyUser, value: userJson);
  }

  static Future<Map<String, String?>> loadTokens() async {
    return {
      'access': await _storage.read(key: _keyAccess),
      'refresh': await _storage.read(key: _keyRefresh),
      'user_json': await _storage.read(key: _keyUser),
    };
  }

  static Future<void> clearTokens() async {
    await _storage.delete(key: _keyAccess);
    await _storage.delete(key: _keyRefresh);
    await _storage.delete(key: _keyUser);
  }
}
