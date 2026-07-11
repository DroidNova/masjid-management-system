import 'package:dio/dio.dart';
import 'package:platform_core_frontend/core/session/session_expired_handler.dart';
import 'package:platform_core_frontend/core/storage/session_storage.dart';
import 'package:platform_core_frontend/core/storage/token_storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required Dio dio,
    TokenStorage? tokenStorage,
    SessionStorage? sessionStorage,
  })  : _dio = dio,
        _refreshDio = Dio(dio.options),
        _tokenStorage = tokenStorage ?? TokenStorage(),
        _sessionStorage = sessionStorage ?? SessionStorage();

  final Dio _dio;
  final Dio _refreshDio;
  final TokenStorage _tokenStorage;
  final SessionStorage _sessionStorage;

  static const String _retriedKey = 'retried';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_shouldSkipAuthHeader(options.path)) {
      final accessToken = await _tokenStorage.getAccessToken();

      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
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
    final statusCode = err.response?.statusCode;
    final alreadyRetried = options.extra[_retriedKey] == true;

    if (statusCode != 401 ||
        alreadyRetried ||
        _shouldSkipRefresh(options.path)) {
      handler.next(err);
      return;
    }

    try {
      final newAccessToken = await _refreshAccessToken();
      if (newAccessToken == null || newAccessToken.isEmpty) {
        await _clearLocalSession();
        SessionExpiredHandler.showDialogAndRedirect();
        handler.next(_sessionExpiredError(options));
        return;
      }

      final headers = Map<String, dynamic>.from(options.headers);
      headers['Authorization'] = 'Bearer $newAccessToken';

      final response = await _dio.fetch<dynamic>(
        options.copyWith(
          headers: headers,
          extra: <String, dynamic>{
            ...options.extra,
            _retriedKey: true,
          },
        ),
      );

      handler.resolve(response);
    } catch (_) {
      await _clearLocalSession();
      SessionExpiredHandler.showDialogAndRedirect();
      handler.next(_sessionExpiredError(options));
    }
  }

  Future<String?> _refreshAccessToken() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return null;

    final response = await _refreshDio.post<Object?>(
      '/auth/refresh',
      data: <String, dynamic>{'refreshToken': refreshToken},
      options: Options(extra: <String, dynamic>{_retriedKey: true}),
    );

    final tokenData = _extractMapData(response.data);
    final accessToken = tokenData['accessToken']?.toString() ?? '';
    final newRefreshToken = tokenData['refreshToken']?.toString() ?? '';

    if (accessToken.isEmpty || newRefreshToken.isEmpty) return null;

    await _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: newRefreshToken,
    );
    return accessToken;
  }

  Map<String, dynamic> _extractMapData(Object? responseData) {
    if (responseData is Map<String, dynamic>) {
      final data = responseData['data'];
      if (data is Map<String, dynamic>) return data;
      return responseData;
    }
    return <String, dynamic>{};
  }

  Future<void> _clearLocalSession() async {
    await _tokenStorage.clearTokens();
    await _sessionStorage.clearUser();
  }

  DioException _sessionExpiredError(RequestOptions options) {
    return DioException(
      requestOptions: options,
      type: DioExceptionType.badResponse,
      response: Response<String>(
        requestOptions: options,
        statusCode: 401,
        data: 'Session expired. Please login again.',
      ),
      message: 'Session expired. Please login again.',
    );
  }

  bool _shouldSkipAuthHeader(String path) {
    final normalizedPath = path.toLowerCase();
    return normalizedPath.contains('/auth/refresh') ||
        normalizedPath.contains('/auth/login/start') ||
        normalizedPath.contains('/auth/login/password') ||
        normalizedPath.contains('/auth/login/verify-otp');
  }

  bool _shouldSkipRefresh(String path) {
    final normalizedPath = path.toLowerCase();
    return _shouldSkipAuthHeader(path) ||
        normalizedPath.contains('/auth/logout');
  }
}
