import 'package:dio/dio.dart';
import 'package:platform_core_frontend/core/config/api_config.dart';
import 'package:platform_core_frontend/core/network/auth_interceptor.dart';
import 'package:platform_core_frontend/core/storage/session_storage.dart';
import 'package:platform_core_frontend/core/storage/token_storage.dart';

class ApiClient {
  ApiClient({
    Dio? dio,
    TokenStorage? tokenStorage,
    SessionStorage? sessionStorage,
  }) : dio = dio ?? Dio() {
    this.dio.options = BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: const <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    this.dio.interceptors.add(
          AuthInterceptor(
            dio: this.dio,
            tokenStorage: tokenStorage,
            sessionStorage: sessionStorage,
          ),
        );
  }

  final Dio dio;
}
