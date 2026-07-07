import 'package:platform_core_frontend/core/storage/session_storage.dart';
import 'package:platform_core_frontend/core/storage/token_storage.dart';
import 'package:platform_core_frontend/features/auth/data/auth_api.dart';
import 'package:platform_core_frontend/features/auth/data/models/auth_session.dart';
import 'package:platform_core_frontend/features/auth/data/models/auth_tokens.dart';
import 'package:platform_core_frontend/features/auth/data/models/login_start_response.dart';

class AuthRepository {
  AuthRepository({
    AuthApi? authApi,
    TokenStorage? tokenStorage,
    SessionStorage? sessionStorage,
  })  : _authApi = authApi ?? AuthApi(),
        _tokenStorage = tokenStorage ?? TokenStorage(),
        _sessionStorage = sessionStorage ?? SessionStorage();

  final AuthApi _authApi;
  final TokenStorage _tokenStorage;
  final SessionStorage _sessionStorage;

  Future<LoginStartResponse> startLogin(String phone) {
    return _authApi.startLogin(phone);
  }

  Future<LoginStartResponse> submitPassword(String phone, String password) {
    return _authApi.submitPassword(phone: phone, password: password);
  }

  Future<AuthSession> verifyOtp(
    String phone,
    String challengeId,
    String otp,
  ) async {
    final session = await _authApi.verifyOtp(
      phone: phone,
      challengeId: challengeId,
      otp: otp,
    );

    if (session.accessToken.isEmpty || session.refreshToken.isEmpty) {
      throw const FormatException('Authentication token is missing.');
    }

    await _tokenStorage.saveTokens(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
    );
    await _sessionStorage.saveUser(session.user);

    return session;
  }

  Future<AuthTokens> refreshSession() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await clearLocalSession();
      throw Exception('Session expired. Please login again.');
    }

    try {
      final tokens = await _authApi.refreshToken(refreshToken);
      if (tokens.accessToken.isEmpty || tokens.refreshToken.isEmpty) {
        await clearLocalSession();
        throw Exception('Session expired. Please login again.');
      }

      await _tokenStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      return tokens;
    } catch (_) {
      await clearLocalSession();
      throw Exception('Session expired. Please login again.');
    }
  }

  Future<void> logout() async {
    final refreshToken = await _tokenStorage.getRefreshToken();

    try {
      await _authApi.logout(refreshToken: refreshToken);
    } catch (_) {
      // Local logout must still happen even if the backend logout call fails.
    } finally {
      await clearLocalSession();
    }
  }

  Future<void> clearLocalSession() async {
    await _tokenStorage.clearTokens();
    await _sessionStorage.clearUser();
  }
}
