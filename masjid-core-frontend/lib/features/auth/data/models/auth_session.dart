import 'package:platform_core_frontend/features/auth/data/models/app_user.dart';

class AuthSession {
  const AuthSession({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final tokenJson = json['tokens'];
    final tokenSource = tokenJson is Map<String, dynamic> ? tokenJson : json;
    final userJson = json['user'] is Map<String, dynamic>
        ? json['user']
        : tokenSource['user'];

    if (userJson is! Map<String, dynamic>) {
      throw const FormatException('User information is missing from response.');
    }

    return AuthSession(
      user: AppUser.fromJson(userJson),
      accessToken: _readToken(tokenSource, 'accessToken', 'access_token'),
      refreshToken: _readToken(tokenSource, 'refreshToken', 'refresh_token'),
    );
  }

  static String _readToken(
    Map<String, dynamic> json,
    String camelCaseKey,
    String snakeCaseKey,
  ) {
    return (json[camelCaseKey] ?? json[snakeCaseKey])?.toString() ?? '';
  }

  final AppUser user;
  final String accessToken;
  final String refreshToken;
}
