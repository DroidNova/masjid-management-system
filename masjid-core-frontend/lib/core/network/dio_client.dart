import 'dart:io';

import 'package:dio/dio.dart';
import 'package:platform_core_frontend/core/config/app_config.dart';
import 'package:platform_core_frontend/core/constants/api_endpoints.dart';
import 'package:platform_core_frontend/core/network/api_exception.dart';
import 'package:platform_core_frontend/core/network/api_response.dart';
import 'package:platform_core_frontend/core/network/api_result.dart';
import 'package:platform_core_frontend/core/network/interceptors/auth_interceptor.dart';
import 'package:platform_core_frontend/core/storage/token_storage.dart';
import 'package:platform_core_frontend/features/auth/data/models/auth_tokens_model.dart';
import 'package:platform_core_frontend/shared/types/json_types.dart';

class DioClient {
  DioClient({required AppConfig config, required TokenStorage tokenStorage})
      : _tokenStorage = tokenStorage,
        _dio = Dio(BaseOptions(baseUrl: config.apiBaseUrl, connectTimeout: config.requestTimeout, receiveTimeout: config.requestTimeout, headers: const {'Accept': 'application/json', 'Content-Type': 'application/json'})),
        _refreshDio = Dio(BaseOptions(baseUrl: config.apiBaseUrl, connectTimeout: config.requestTimeout, receiveTimeout: config.requestTimeout, headers: const {'Accept': 'application/json', 'Content-Type': 'application/json'})) {
    _dio.interceptors.add(
      AuthInterceptor(
        dio: _dio,
        tokenStorage: _tokenStorage,
        refreshTokens: _refreshTokens,
        clearSession: _tokenStorage.clearTokens,
      ),
    );
  }

  final Dio _dio;
  final Dio _refreshDio;
  final TokenStorage _tokenStorage;

  Future<ApiResult<T>> get<T>(String path, {JsonMap? queryParameters, T Function(dynamic json)? parser, bool requiresAuth = true}) {
    return _request<T>(() => _dio.get<dynamic>(path, queryParameters: queryParameters, options: Options(extra: {'requiresAuth': requiresAuth})), parser);
  }

  Future<ApiResult<T>> post<T>(String path, {Object? data, JsonMap? queryParameters, T Function(dynamic json)? parser, bool requiresAuth = true}) {
    return _request<T>(() => _dio.post<dynamic>(path, data: data, queryParameters: queryParameters, options: Options(extra: {'requiresAuth': requiresAuth})), parser);
  }

  Future<ApiResult<T>> patch<T>(String path, {Object? data, JsonMap? queryParameters, T Function(dynamic json)? parser, bool requiresAuth = true}) {
    return _request<T>(() => _dio.patch<dynamic>(path, data: data, queryParameters: queryParameters, options: Options(extra: {'requiresAuth': requiresAuth})), parser);
  }

  Future<ApiResult<T>> _request<T>(Future<Response<dynamic>> Function() call, T Function(dynamic json)? parser) async {
    try {
      final response = await call();
      return ApiSuccess<T>(_mapSuccessResponse(response, parser));
    } on DioException catch (error) {
      return ApiFailure<T>(_mapDioException(error));
    } on ApiException catch (error) {
      return ApiFailure<T>(error);
    } catch (_) {
      return ApiFailure<T>(const ApiException(message: 'Something went wrong. Please try again later.'));
    }
  }

  T _mapSuccessResponse<T>(Response<dynamic> response, T Function(dynamic json)? parser) {
    final payload = response.data;
    if (payload is! Map<String, dynamic>) {
      throw const ApiException(message: 'Something went wrong. Please try again later.');
    }

    final apiResponse = ApiResponse<dynamic>.fromJson(payload, (json) => json);
    if (!apiResponse.success) {
      throw ApiException(message: apiResponse.message, errorCode: apiResponse.errorCode, statusCode: response.statusCode, errors: apiResponse.errors);
    }

    if (parser != null) {
      return parser(apiResponse.data);
    }

    return apiResponse.data as T;
  }

  Future<bool> _refreshTokens() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    try {
      final response = await _refreshDio.post<dynamic>(ApiEndpoints.authRefresh, data: {'refreshToken': refreshToken});
      final tokens = AuthTokensModel.fromResponse((response.data as Map<String, dynamic>)['data']);
      if (tokens.accessToken.isEmpty || tokens.refreshToken.isEmpty) {
        return false;
      }
      await _tokenStorage.saveAccessToken(tokens.accessToken);
      await _tokenStorage.saveRefreshToken(tokens.refreshToken);
      return true;
    } catch (_) {
      return false;
    }
  }

  ApiException _mapDioException(DioException exception) {
    final statusCode = exception.response?.statusCode;
    final responseData = exception.response?.data;

    if (responseData is Map<String, dynamic>) {
      final apiResponse = ApiResponse<dynamic>.fromJson(responseData, null);
      if (!apiResponse.success) {
        return ApiException(message: apiResponse.message, errorCode: apiResponse.errorCode, statusCode: statusCode, errors: apiResponse.errors);
      }
    }

    if (exception.type == DioExceptionType.connectionTimeout || exception.type == DioExceptionType.receiveTimeout || exception.type == DioExceptionType.sendTimeout) {
      return const ApiException(message: 'Connection timed out. Please try again.');
    }

    if (exception.type == DioExceptionType.connectionError || exception.error is SocketException) {
      return const ApiException(message: 'No internet connection. Please check your network.');
    }

    if (statusCode != null && statusCode >= 500) {
      return const ApiException(message: 'Something went wrong. Please try again later.');
    }

    return const ApiException(message: 'Something went wrong. Please try again.');
  }
}
