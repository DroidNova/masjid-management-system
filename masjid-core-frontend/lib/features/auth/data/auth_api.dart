import 'package:dio/dio.dart';
import 'package:platform_core_frontend/core/network/api_client.dart';
import 'package:platform_core_frontend/features/auth/data/models/auth_session.dart';
import 'package:platform_core_frontend/features/auth/data/models/auth_tokens.dart';
import 'package:platform_core_frontend/features/auth/data/models/login_start_response.dart';

class AuthApi {
  AuthApi({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<LoginStartResponse> startLogin(String phone) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/auth/login/start',
        data: <String, dynamic>{'phone': phone},
      );

      return LoginStartResponse.fromJson(_extractData(response.data));
    } on DioException catch (error) {
      throw Exception(_readErrorMessage(error));
    }
  }

  Future<LoginStartResponse> submitPassword({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/auth/login/password',
        data: <String, dynamic>{
          'phone': phone,
          'password': password,
        },
      );

      return LoginStartResponse.fromJson(_extractData(response.data));
    } on DioException catch (error) {
      throw Exception(_readErrorMessage(error));
    }
  }

  Future<AuthSession> verifyOtp({
    required String phone,
    required String challengeId,
    required String otp,
  }) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/auth/login/verify-otp',
        data: <String, dynamic>{
          'phone': phone,
          'challengeId': challengeId,
          'otp': otp,
        },
      );

      return AuthSession.fromJson(_extractData(response.data));
    } on DioException catch (error) {
      throw Exception(_readErrorMessage(error));
    }
  }

  Future<AuthTokens> refreshToken(String refreshToken) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: <String, dynamic>{'refreshToken': refreshToken},
      );

      return AuthTokens.fromJson(_extractData(response.data));
    } on DioException catch (error) {
      throw Exception(_readErrorMessage(error));
    }
  }

  Future<void> logout({String? refreshToken}) async {
    try {
      await _apiClient.dio.post<Map<String, dynamic>>(
        '/auth/logout',
        data: <String, dynamic>{
          if (refreshToken != null && refreshToken.isNotEmpty)
            'refreshToken': refreshToken,
        },
      );
    } on DioException catch (error) {
      throw Exception(_readErrorMessage(error));
    }
  }

  Map<String, dynamic> _extractData(Object? responseData) {
    if (responseData is Map<String, dynamic>) {
      final wrappedData = responseData['data'];
      if (wrappedData is Map<String, dynamic>) {
        return wrappedData;
      }

      return responseData;
    }

    throw const FormatException('Unexpected response from server.');
  }

  String _readErrorMessage(DioException error) {
    final responseData = error.response?.data;

    if (responseData is Map<String, dynamic>) {
      final message = responseData['message'];
      if (message is String && message.isNotEmpty) return message;

      final responseError = responseData['error'];
      if (responseError is Map<String, dynamic>) {
        final errorMessage = responseError['message'];
        if (errorMessage is String && errorMessage.isNotEmpty) {
          return errorMessage;
        }
      }
    }

    return error.message ?? 'Something went wrong. Please try again.';
  }
}
