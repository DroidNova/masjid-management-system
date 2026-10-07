import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_start_response.freezed.dart';
part 'login_start_response.g.dart';

/// Next login step from `/auth/login/start` and `/auth/login/password`.
@freezed
abstract class LoginStartResponse with _$LoginStartResponse {
  const factory LoginStartResponse({
    /// `OTP_REQUIRED` or `PASSWORD_REQUIRED`.
    required String nextStep,
    required String phone,
    String? challengeId,

    /// Digits the server expects; falls back to [defaultOtpLength].
    @Default(LoginStartResponse.defaultOtpLength) int otpLength,
    String? message,
  }) = _LoginStartResponse;

  const LoginStartResponse._();

  factory LoginStartResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginStartResponseFromJson(json);

  /// Matches the backend's development OTP (1111). The server sends the real
  /// value as `otpLength`; this is only a fallback.
  static const int defaultOtpLength = 4;

  bool get requiresOtp => nextStep == 'OTP_REQUIRED';
  bool get requiresPassword => nextStep == 'PASSWORD_REQUIRED';
}
