import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Access and refresh tokens in the platform's secure store
/// (Android: EncryptedSharedPreferences; web: browser storage).
///
/// The secure store is the source of truth across restarts; after the first
/// read the tokens are kept in memory, so attaching the token to each request
/// does not hit the secure store again.
class TokenStorage {
  TokenStorage({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? defaultSecureStorage;

  static const FlutterSecureStorage defaultSecureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  final FlutterSecureStorage _secureStorage;

  // Null until loaded from the secure store (or saved / cleared).
  ({String? access, String? refresh})? _cache;
  Future<({String? access, String? refresh})>? _loading;

  Future<({String? access, String? refresh})> _tokens() {
    final cached = _cache;
    if (cached != null) return Future.value(cached);
    // One secure-storage read even if several requests start at once.
    return _loading ??= _load();
  }

  Future<({String? access, String? refresh})> _load() async {
    try {
      final access = await _secureStorage.read(key: _accessTokenKey);
      final refresh = await _secureStorage.read(key: _refreshTokenKey);
      // A save or clear while loading wins over what was read.
      return _cache ??= (access: access, refresh: refresh);
    } finally {
      _loading = null;
    }
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _cache = (access: accessToken, refresh: refreshToken);
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> getAccessToken() async => (await _tokens()).access;

  Future<String?> getRefreshToken() async => (await _tokens()).refresh;

  Future<bool> hasAccessToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearTokens() async {
    _cache = (access: null, refresh: null);
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }
}
