import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Access and refresh tokens in the platform's secure store
/// (Android: EncryptedSharedPreferences; web: browser storage).
class TokenStorage {
  TokenStorage({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? defaultSecureStorage;

  static const FlutterSecureStorage defaultSecureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  final FlutterSecureStorage _secureStorage;

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> getAccessToken() => _secureStorage.read(key: _accessTokenKey);

  Future<String?> getRefreshToken() =>
      _secureStorage.read(key: _refreshTokenKey);

  Future<bool> hasAccessToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearTokens() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }
}
