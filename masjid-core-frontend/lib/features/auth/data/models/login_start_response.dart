class LoginStartResponse {
  const LoginStartResponse({
    required this.nextStep,
    required this.phone,
    this.challengeId,
    this.otpLength = defaultOtpLength,
    this.message,
  });

  /// Matches the backend's development OTP (1111). The server sends the real
  /// value as `otpLength`; this is only a fallback.
  static const int defaultOtpLength = 4;

  factory LoginStartResponse.fromJson(Map<String, dynamic> json) {
    return LoginStartResponse(
      nextStep: json['nextStep']?.toString() ?? '',
      challengeId: json['challengeId']?.toString(),
      otpLength:
          int.tryParse(json['otpLength']?.toString() ?? '') ?? defaultOtpLength,
      phone: json['phone']?.toString() ?? '',
      message: json['message']?.toString(),
    );
  }

  final String nextStep;
  final String? challengeId;
  final int otpLength;
  final String phone;
  final String? message;

  bool get requiresOtp => nextStep == 'OTP_REQUIRED';
  bool get requiresPassword => nextStep == 'PASSWORD_REQUIRED';
}
