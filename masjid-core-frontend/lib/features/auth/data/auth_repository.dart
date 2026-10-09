import 'package:masjid_core_frontend/core/storage/session_storage.dart';
import 'package:masjid_core_frontend/core/storage/token_storage.dart';
import 'package:masjid_core_frontend/features/auth/data/auth_api.dart';
import 'package:masjid_core_frontend/features/auth/data/models/app_user.dart';
import 'package:masjid_core_frontend/features/auth/data/models/auth_session.dart';
import 'package:masjid_core_frontend/features/auth/data/models/login_start_response.dart';

class AuthRepository {
  AuthRepository({
    AuthApi? authApi,
    TokenStorage? tokenStorage,
    SessionStorage? sessionStorage,
  }) : _authApi = authApi ?? AuthApi(),
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

  /// Loads `/auth/me` and keeps the stored copy in sync.
  Future<AppUser> fetchCurrentUser() async {
    final user = await _authApi.fetchCurrentUser();
    await _sessionStorage.saveUser(user);
    return user;
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => _authApi.changePassword(
    currentPassword: currentPassword,
    newPassword: newPassword,
  );

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
