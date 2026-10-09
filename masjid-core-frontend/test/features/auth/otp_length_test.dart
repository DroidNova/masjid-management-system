import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/features/auth/data/models/login_start_response.dart';
import 'package:masjid_core_frontend/features/auth/presentation/otp_screen.dart';

import '../../shared/ui/ui_test_helpers.dart';

void main() {
  group('LoginStartResponse.otpLength', () {
    test('reads otpLength sent by the server', () {
      final response = LoginStartResponse.fromJson(const {
        'nextStep': 'OTP_REQUIRED',
        'challengeId': 'abc',
        'phone': '9876543210',
        'otpLength': 6,
      });
      expect(response.otpLength, 6);
    });

    test('falls back to 4 digits (dev OTP 1111) when missing', () {
      final response = LoginStartResponse.fromJson(const {
        'nextStep': 'OTP_REQUIRED',
        'phone': '9876543210',
      });
      expect(response.otpLength, LoginStartResponse.defaultOtpLength);
      expect(LoginStartResponse.defaultOtpLength, 4);
    });
  });

  testWidgets('OtpScreen shows one box per expected digit', (tester) async {
    await pumpUi(
      tester,
      const OtpScreen(phone: '9876543210', challengeId: 'abc', otpLength: 6),
    );

    expect(tester.widget<CodeBoxes>(find.byType(CodeBoxes)).length, 6);
  });
}
