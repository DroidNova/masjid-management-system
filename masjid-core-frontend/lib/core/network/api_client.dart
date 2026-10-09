import 'package:dio/dio.dart';
import 'package:masjid_core_frontend/core/config/api_config.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/core/network/auth_interceptor.dart';
import 'package:masjid_core_frontend/core/storage/token_storage.dart';

/// The app's single HTTP client.
///
/// Create it once at startup with [ApiClient.configure]; everything else gets
/// the same instance (via `apiClientProvider`, or `ApiClient()` in code from
/// before M4), so all requests share one token-refresh lock.
class ApiClient {
  ApiClient._(this.dio);

  /// Returns the shared client. Code written before M4 calls `ApiClient()`.
  factory ApiClient() {
    final shared = _shared;
    if (shared == null) {
      throw StateError(
        'ApiClient.configure() must run before use (main.dart).',
      );
    }
    return shared;
  }

  static ApiClient? _shared;

  /// Builds the shared client. Call once in main(); tests may call it again.
  static ApiClient configure({
    required TokenStorage tokenStorage,
    required SessionExpiredCallback onSessionExpired,
    String? baseUrl,
    HttpClientAdapter? adapter,
  }) {
    final options = BaseOptions(
      baseUrl: baseUrl ?? ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: const <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );
    final dio = Dio(options);
    final refreshDio = Dio(options);
    if (adapter != null) {
      dio.httpClientAdapter = adapter;
      refreshDio.httpClientAdapter = adapter;
    }
    dio.interceptors.add(
      AuthInterceptor(
        dio: dio,
        refreshDio: refreshDio,
        tokenStorage: tokenStorage,
        onSessionExpired: onSessionExpired,
      ),
    );
    return _shared = ApiClient._(dio);
  }

  final Dio dio;

  /// GET and return the `data` field of the success envelope.
  Future<T> get<T>(String path, {Map<String, dynamic>? query}) =>
      _send<T>(() => dio.get<Object?>(path, queryParameters: query));

  Future<T> post<T>(String path, {Object? body}) =>
      _send<T>(() => dio.post<Object?>(path, data: body));

  Future<T> patch<T>(String path, {Object? body}) =>
      _send<T>(() => dio.patch<Object?>(path, data: body));

  Future<T> put<T>(String path, {Object? body}) =>
      _send<T>(() => dio.put<Object?>(path, data: body));

  Future<T> delete<T>(String path) => _send<T>(() => dio.delete<Object?>(path));

  Future<T> _send<T>(Future<Response<Object?>> Function() request) async {
    try {
      final response = await request();
      final body = response.data;
      final data = body is Map<String, dynamic> && body.containsKey('data')
          ? body['data']
          : body;
      return data as T;
    } on DioException catch (error) {
      final mapped = error.error;
      throw mapped is ApiException ? mapped : ApiException.fromDio(error);
    }
  }
}
