import 'package:masjid_core_frontend/core/network/api_client.dart';
import 'package:masjid_core_frontend/features/auth/data/models/app_user.dart';
import 'package:masjid_core_frontend/features/auth/data/models/auth_session.dart';
import 'package:masjid_core_frontend/features/auth/data/models/login_start_response.dart';

/// Auth endpoints. Errors surface as ApiException (with `code`).
class AuthApi {
  AuthApi({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<LoginStartResponse> startLogin(String phone) async {
    final data = await _apiClient.post<Map<String, dynamic>>(
      '/auth/login/start',
      body: <String, dynamic>{'phone': phone},
    );
    return LoginStartResponse.fromJson(data);
  }

  Future<LoginStartResponse> submitPassword({
    required String phone,
    required String password,
  }) async {
    final data = await _apiClient.post<Map<String, dynamic>>(
      '/auth/login/password',
      body: <String, dynamic>{'phone': phone, 'password': password},
    );
    return LoginStartResponse.fromJson(data);
  }

  Future<AuthSession> verifyOtp({
    required String phone,
    required String challengeId,
    required String otp,
  }) async {
    final data = await _apiClient.post<Map<String, dynamic>>(
      '/auth/login/verify-otp',
      body: <String, dynamic>{
        'phone': phone,
        'challengeId': challengeId,
        'otp': otp,
      },
    );
    return AuthSession.fromJson(data);
  }

  /// The signed-in user with current roles and permissions.
  Future<AppUser> fetchCurrentUser() async {
    final data = await _apiClient.get<Map<String, dynamic>>('/auth/me');
    return AppUser.fromJson(data);
  }

  Future<void> logout({String? refreshToken}) async {
    await _apiClient.post<Object?>(
      '/auth/logout',
      body: <String, dynamic>{
        if (refreshToken != null && refreshToken.isNotEmpty)
          'refreshToken': refreshToken,
      },
    );
  }
}
