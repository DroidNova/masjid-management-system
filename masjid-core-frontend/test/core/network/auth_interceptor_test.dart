import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/network/api_client.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/core/storage/token_storage.dart';

/// In-memory token store.
class _FakeTokens extends TokenStorage {
  _FakeTokens({this.access, this.refresh});

  String? access;
  String? refresh;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    access = accessToken;
    refresh = refreshToken;
  }

  @override
  Future<String?> getAccessToken() async => access;

  @override
  Future<String?> getRefreshToken() async => refresh;

  @override
  Future<void> clearTokens() async {
    access = null;
    refresh = null;
  }
}

/// Fake server: protected routes need `Bearer <validToken>`.
class _FakeServer implements HttpClientAdapter {
  String validToken = 'access-2';
  int refreshCalls = 0;

  /// What /auth/refresh does: 'ok', 'reject' or 'offline'.
  String refreshMode = 'ok';

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path == '/auth/refresh') {
      refreshCalls++;
      // Let concurrent 401s pile up while this refresh is "in flight".
      await Future<void>.delayed(const Duration(milliseconds: 20));
      if (refreshMode == 'offline') {
        throw DioException.connectionError(
          requestOptions: options,
          reason: 'offline',
        );
      }
      if (refreshMode == 'reject') {
        return _json(401, {
          'success': false,
          'message': 'Session revoked',
          'errorCode': 'SESSION_REVOKED',
        });
      }
      return _json(200, {
        'success': true,
        'data': {
          'tokens': {'accessToken': validToken, 'refreshToken': 'refresh-2'},
        },
      });
    }

    final auth = options.headers['Authorization'];
    if (auth != 'Bearer $validToken') {
      return _json(401, {
        'success': false,
        'message': 'Expired',
        'errorCode': 'SESSION_EXPIRED',
      });
    }
    return _json(200, {
      'success': true,
      'data': {'path': options.path},
    });
  }

  ResponseBody _json(int status, Map<String, dynamic> body) =>
      ResponseBody.fromString(
        jsonEncode(body),
        status,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );

  @override
  void close({bool force = false}) {}
}

void main() {
  late _FakeTokens tokens;
  late _FakeServer server;
  late int expiredCalls;
  late ApiClient client;

  setUp(() {
    tokens = _FakeTokens(access: 'access-1', refresh: 'refresh-1');
    server = _FakeServer();
    expiredCalls = 0;
    client = ApiClient.configure(
      tokenStorage: tokens,
      onSessionExpired: () => expiredCalls++,
      baseUrl: 'http://test',
      adapter: server,
    );
  });

  test('refreshes once for many parallel 401s and retries them all', () async {
    final results = await Future.wait([
      for (var i = 0; i < 5; i++) client.get<Map<String, dynamic>>('/thing/$i'),
    ]);

    expect(server.refreshCalls, 1);
    expect(results.map((r) => r['path']), [
      for (var i = 0; i < 5; i++) '/thing/$i',
    ]);
    expect(tokens.access, 'access-2');
    expect(tokens.refresh, 'refresh-2');
    expect(expiredCalls, 0);
  });

  test('ends the session when the refresh token is rejected', () async {
    server.refreshMode = 'reject';

    await expectLater(
      client.get<Object?>('/thing'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.code,
          'code',
          ApiErrorCodes.sessionExpired,
        ),
      ),
    );
    expect(expiredCalls, 1);
    expect(tokens.access, isNull);
    expect(tokens.refresh, isNull);
  });

  test('keeps the session when the network drops during refresh', () async {
    server.refreshMode = 'offline';

    await expectLater(
      client.get<Object?>('/thing'),
      throwsA(
        isA<ApiException>().having((e) => e.isNetworkError, 'network', true),
      ),
    );
    expect(expiredCalls, 0);
    expect(tokens.refresh, 'refresh-1');
  });

  test('does not attach tokens to login requests', () async {
    server.validToken = 'access-1';
    final options = RequestOptions(path: '/auth/login/start', method: 'POST');
    final captured = <String, dynamic>{};
    final dio = client.dio;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (o, handler) {
          captured.addAll(o.headers);
          handler.reject(DioException(requestOptions: o));
        },
      ),
    );
    try {
      await dio.fetch<Object?>(options);
    } on DioException catch (_) {}
    expect(captured.containsKey('Authorization'), isFalse);
  });
}
