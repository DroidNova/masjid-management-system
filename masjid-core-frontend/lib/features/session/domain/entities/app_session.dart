import 'package:platform_core_frontend/features/auth/domain/entities/auth_tokens.dart';
import 'package:platform_core_frontend/features/auth/domain/entities/current_user.dart';

class AppSession {
  const AppSession({
    this.user,
    this.tokens,
  });

  final CurrentUser? user;
  final AuthTokens? tokens;

  bool get isAuthenticated {
    return tokens?.accessToken.isNotEmpty == true;
  }
}
