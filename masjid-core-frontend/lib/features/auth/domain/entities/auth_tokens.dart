import 'package:platform_core_frontend/features/auth/domain/entities/current_user.dart';

class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    this.user,
  });

  final String accessToken;
  final String refreshToken;
  final CurrentUser? user;
}
