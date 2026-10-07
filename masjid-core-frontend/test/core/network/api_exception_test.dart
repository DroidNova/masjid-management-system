import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';

DioException _error(int status, Object? body) {
  final options = RequestOptions(path: '/x');
  return DioException(
    requestOptions: options,
    response: Response<Object?>(
      requestOptions: options,
      statusCode: status,
      data: body,
    ),
    type: DioExceptionType.badResponse,
  );
}

void main() {
  test('reads message, code, field errors and request id', () {
    final e = ApiException.fromDio(
      _error(400, {
        'success': false,
        'message': 'Validation failed',
        'errorCode': 'VALIDATION_ERROR',
        'errors': {
          'otp': ['OTP must be 4 to 8 digits'],
        },
        'requestId': 'r1',
      }),
    );

    expect(e.message, 'Validation failed');
    expect(e.code, ApiErrorCodes.validation);
    expect(e.statusCode, 400);
    expect(e.fieldErrors['otp'], ['OTP must be 4 to 8 digits']);
    expect(e.requestId, 'r1');
    expect(e.toString(), 'Validation failed');
  });

  test('maps a missing response to a network error', () {
    final e = ApiException.fromDio(
      DioException.connectionError(
        requestOptions: RequestOptions(path: '/x'),
        reason: 'offline',
      ),
    );
    expect(e.isNetworkError, isTrue);
    expect(e.statusCode, isNull);
  });

  test('falls back to a generic message for unexpected bodies', () {
    final e = ApiException.fromDio(_error(500, '<html>'));
    expect(e.code, ApiErrorCodes.unknown);
    expect(e.statusCode, 500);
    expect(e.message, isNotEmpty);
  });
}
