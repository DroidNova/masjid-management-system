class AppException implements Exception {
  const AppException(this.message, {this.code});

  final String message;
  final int? code;

  @override
  String toString() => 'AppException(message: $message, code: $code)';
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Network request failed']);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Unauthorized request'])
      : super(code: 401);
}

class ServerException extends AppException {
  const ServerException({required String message, int? code})
      : super(message, code: code);
}

class UnknownException extends AppException {
  const UnknownException([super.message = 'Unknown application error']);
}
