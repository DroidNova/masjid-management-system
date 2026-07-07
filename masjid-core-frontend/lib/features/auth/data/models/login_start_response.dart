class LoginStartResponse {
  const LoginStartResponse({
    required this.nextStep,
    required this.phone,
    this.challengeId,
    this.message,
  });

  factory LoginStartResponse.fromJson(Map<String, dynamic> json) {
    return LoginStartResponse(
      nextStep: json['nextStep']?.toString() ?? '',
      challengeId: json['challengeId']?.toString(),
      phone: json['phone']?.toString() ?? '',
      message: json['message']?.toString(),
    );
  }

  final String nextStep;
  final String? challengeId;
  final String phone;
  final String? message;

  bool get requiresOtp => nextStep == 'OTP_REQUIRED';
  bool get requiresPassword => nextStep == 'PASSWORD_REQUIRED';
}
