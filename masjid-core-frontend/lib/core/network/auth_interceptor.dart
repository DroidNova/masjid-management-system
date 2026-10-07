import 'dart:async';

import 'package:dio/dio.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/core/storage/token_storage.dart';

/// Called when the refresh token is rejected: the user must log in again.
typedef SessionExpiredCallback = FutureOr<void> Function();

/// Adds the access token to requests and renews it on 401.
///
/// Only one refresh runs at a time: requests that fail while a refresh is in
/// flight wait for it and then retry with the new token. The backend rotates
/// refresh tokens and revokes the session if an old one is reused, so two
/// parallel refreshes would log the user out.
///
/// A network failure during refresh does NOT log the user out; only a
/// rejected refresh token does.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required Dio dio,
    required Dio refreshDio,
    required TokenStorage tokenStorage,
    required SessionExpiredCallback onSessionExpired,
  }) : _dio = dio,
       _refreshDio = refreshDio,
       _tokenStorage = tokenStorage,
       _onSessionExpired = onSessionExpired;

  final Dio _dio;
  final Dio _refreshDio;
  final TokenStorage _tokenStorage;
  final SessionExpiredCallback _onSessionExpired;

  Completer<String?>? _refreshing;

  static const String _retriedKey = 'auth_retried';
  static const List<String> _publicPaths = <String>[
    '/auth/refresh',
    '/auth/login/start',
    '/auth/login/password',
    '/auth/login/verify-otp',
    '/masjid-requests',
    '/masjid-requests/track',
  ];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isPublic(options)) {
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
    final options = err.requestOptions;
    final shouldRefresh =
        err.response?.statusCode == 401 &&
        options.extra[_retriedKey] != true &&
        !_isPublic(options) &&
        !options.path.contains('/auth/logout');

    if (!shouldRefresh) {
      handler.next(_withApiException(err));
      return;
    }

    try {
      final token = await _freshAccessToken(options);
      if (token == null) {
        handler.next(_sessionExpired(err));
        return;
      }
      final retried = await _dio.fetch<dynamic>(
        options.copyWith(
          headers: <String, dynamic>{
            ...options.headers,
            'Authorization': 'Bearer $token',
          },
          extra: <String, dynamic>{...options.extra, _retriedKey: true},
        ),
      );
      handler.resolve(retried);
    } on DioException catch (retryError) {
      handler.next(_withApiException(retryError));
    }
  }

  /// Returns a usable access token, refreshing at most once at a time.
  Future<String?> _freshAccessToken(RequestOptions failed) async {
    // Another request may already have refreshed while this one was in flight.
    final sent = (failed.headers['Authorization'] as String?)?.replaceFirst(
      'Bearer ',
      '',
    );
    final current = await _tokenStorage.getAccessToken();
    if (current != null && current.isNotEmpty && current != sent) {
      return current;
    }

    final inFlight = _refreshing;
    if (inFlight != null) return inFlight.future;

    final completer = Completer<String?>();
    // Waiters may not exist; don't let a failed refresh become an
    // unhandled async error. Each caller still sees the error.
    completer.future.ignore();
    _refreshing = completer;
    try {
      final token = await _refresh();
      completer.complete(token);
      return token;
    } catch (error) {
      completer.completeError(error);
      rethrow;
    } finally {
      _refreshing = null;
    }
  }

  /// null = refresh token rejected (session over). Throws on network errors.
  Future<String?> _refresh() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _expire();
      return null;
    }

    try {
      final response = await _refreshDio.post<Object?>(
        '/auth/refresh',
        data: <String, dynamic>{'refreshToken': refreshToken},
      );
      final body = response.data;
      final data = body is Map<String, dynamic> ? body['data'] : null;
      final tokens = data is Map<String, dynamic> ? data['tokens'] : null;
      final access = tokens is Map<String, dynamic>
          ? tokens['accessToken']?.toString()
          : null;
      final refresh = tokens is Map<String, dynamic>
          ? tokens['refreshToken']?.toString()
          : null;
      if (access == null || access.isEmpty || refresh == null) {
        await _expire();
        return null;
      }
      await _tokenStorage.saveTokens(
        accessToken: access,
        refreshToken: refresh,
      );
      return access;
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status == 400 || status == 401 || status == 403) {
        await _expire();
        return null;
      }
      rethrow; // offline or server error: keep the session.
    }
  }

  Future<void> _expire() async {
    await _tokenStorage.clearTokens();
    await _onSessionExpired();
  }

  bool _isPublic(RequestOptions options) {
    final path = options.path.toLowerCase();
    if (path.contains('/auth/')) {
      return _publicPaths.any(path.endsWith);
    }
    // Submitting and tracking a masjid request need no login.
    return options.method == 'POST' &&
        (path.endsWith('/masjid-requests') ||
            path.endsWith('/masjid-requests/track'));
  }

  DioException _withApiException(DioException err) =>
      err.copyWith(error: ApiException.fromDio(err));

  DioException _sessionExpired(DioException err) => err.copyWith(
    error: const ApiException(
      message: 'Your session has expired. Please login again.',
      code: ApiErrorCodes.sessionExpired,
      statusCode: 401,
    ),
  );
}
