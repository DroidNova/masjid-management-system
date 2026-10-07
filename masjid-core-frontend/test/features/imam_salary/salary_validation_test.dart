import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:masjid_core_frontend/core/errors/user_message.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/features/imam_salary/application/salary_validation.dart';

void main() {
  setUpAll(() => initializeDateFormatting('en_IN'));

  group('validatePaymentAmount', () {
    test('accepts an amount up to the due amount', () {
      expect(validatePaymentAmount('250', due: 600), isNull);
      expect(validatePaymentAmount('600', due: 600), isNull);
      expect(validatePaymentAmount(' 600.00 ', due: 600), isNull);
    });

    test('rejects an amount above the due amount', () {
      expect(
        validatePaymentAmount('600.01', due: 600),
        'Payment cannot exceed the due amount (₹600)',
      );
    });

    test('compares in paise, so float noise does not block a payment', () {
      // 0.1 + 0.2 == 0.30000000000000004 in doubles.
      expect(validatePaymentAmount('0.3', due: 0.1 + 0.2), isNull);
    });

    test('rejects empty, zero, negative and non-numeric input', () {
      for (final text in <String?>[null, '', '0', '-5', 'abc']) {
        expect(
          validatePaymentAmount(text, due: 600),
          'Enter a valid amount',
          reason: 'input "$text"',
        );
      }
    });

    test('rejects more than 2 decimal places', () {
      expect(
        validatePaymentAmount('10.005', due: 600),
        'Use at most 2 decimal places',
      );
      expect(validatePaymentAmount('10.05', due: 600), isNull);
    });
  });

  group('validateIncreasedAmount', () {
    test('allows the same or a higher amount', () {
      expect(validateIncreasedAmount('600', current: 600), isNull);
      expect(validateIncreasedAmount('700', current: 600), isNull);
    });

    test('rejects a lower amount', () {
      expect(
        validateIncreasedAmount('500', current: 600),
        'Amount can only be increased (now ₹600)',
      );
    });
  });

  test('validateAmountPerHead needs a positive amount', () {
    expect(validateAmountPerHead('600'), isNull);
    expect(validateAmountPerHead('0'), 'Enter a valid amount');
  });

  test('invalidInput reads like a server validation error', () {
    final error = invalidInput('amount', 'Too much');
    expect(error.code, ApiErrorCodes.validation);
    expect(userMessage(error), 'Too much');
    expect(fieldError(error, 'amount'), 'Too much');
  });
}
