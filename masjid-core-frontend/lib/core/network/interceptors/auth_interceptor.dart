import 'dart:async';

import 'package:dio/dio.dart';
import 'package:platform_core_frontend/core/session/session_expired_handler.dart';
import 'package:platform_core_frontend/core/storage/token_storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required Dio dio,
    required TokenStorage tokenStorage,
    required Future<bool> Function() refreshTokens,
    required Future<void> Function() clearSession,
  })  : _dio = dio,
        _tokenStorage = tokenStorage,
        _refreshTokens = refreshTokens,
        _clearSession = clearSession;

  final Dio _dio;
  final TokenStorage _tokenStorage;
  final Future<bool> Function() _refreshTokens;
  final Future<void> Function() _clearSession;

  Completer<bool>? _refreshCompleter;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final requiresAuth = options.extra['requiresAuth'] != false;
    if (requiresAuth) {
      final token = await _tokenStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final requiresAuth = err.requestOptions.extra['requiresAuth'] != false;
    final alreadyRetried = err.requestOptions.extra['authRetried'] == true;

    if (statusCode != 401 || !requiresAuth || alreadyRetried) {
      handler.next(err);
      return;
    }

    final refreshed = await _refreshOrWait();
    if (!refreshed) {
      await _clearSession();
      SessionExpiredHandler.showDialogAndRedirect();
      handler.next(err);
      return;
    }

    try {
      final retryHeaders = Map<String, dynamic>.from(err.requestOptions.headers);
      final latestToken = await _tokenStorage.getAccessToken();
      if (latestToken != null && latestToken.isNotEmpty) {
        retryHeaders['Authorization'] = 'Bearer $latestToken';
      }

      final retriedResponse = await _dio.fetch<dynamic>(
        err.requestOptions.copyWith(
          headers: retryHeaders,
          extra: {
            ...err.requestOptions.extra,
            'authRetried': true,
          },
        ),
      );

      handler.resolve(retriedResponse);
    } catch (retryError) {
      handler.next(err);
    }
  }

  Future<bool> _refreshOrWait() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<bool>();
    try {
      final refreshed = await _refreshTokens();
      _refreshCompleter!.complete(refreshed);
      return refreshed;
    } catch (_) {
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }
}
