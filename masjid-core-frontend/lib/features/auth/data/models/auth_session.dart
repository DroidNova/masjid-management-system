import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:masjid_core_frontend/features/auth/data/models/app_user.dart';

part 'auth_session.freezed.dart';
part 'auth_session.g.dart';

/// Tokens issued by `/auth/login/verify-otp` and `/auth/refresh`.
@freezed
abstract class AuthTokens with _$AuthTokens {
  const factory AuthTokens({
    required String accessToken,
    required String refreshToken,
    int? accessTokenExpiresIn,
  }) = _AuthTokens;

  factory AuthTokens.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensFromJson(json);
}

/// Result of a successful OTP verification: `{ user, tokens }`.
@freezed
abstract class AuthSession with _$AuthSession {
  const factory AuthSession({
    required AppUser user,
    required AuthTokens tokens,
  }) = _AuthSession;

  const AuthSession._();

  factory AuthSession.fromJson(Map<String, dynamic> json) =>
      _$AuthSessionFromJson(json);

  String get accessToken => tokens.accessToken;
  String get refreshToken => tokens.refreshToken;
}
