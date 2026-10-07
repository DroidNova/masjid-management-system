import 'package:masjid_core_frontend/core/format/formatters.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';

/// Input rules for the imam salary forms. The server enforces the same rules
/// (it answers BAD_REQUEST); checking here gives the message before a round
/// trip. Amounts are compared in paise so 0.1 + 0.2 style errors never block
/// a valid payment.

int _paise(double amount) => (amount * 100).round();

/// Parses a rupee amount typed by the user, or null if it is not a number.
double? parseRupees(String? text) => double.tryParse(text?.trim() ?? '');

/// Problem with a positive money amount (2 decimals at most), or null.
String? amountError(double? amount) {
  if (amount == null || amount.isNaN || amount.isInfinite || amount <= 0) {
    return 'Enter a valid amount';
  }
  if ((amount * 100 - _paise(amount)).abs() > 1e-6) {
    return 'Use at most 2 decimal places';
  }
  return null;
}

/// Amount per family head when starting a month.
String? validateAmountPerHead(String? text) => amountError(parseRupees(text));

/// New amount per head: may only go up (equal is allowed, like the server).
String? increasedAmountError(double? amount, {required double current}) {
  final basic = amountError(amount);
  if (basic != null) return basic;
  if (_paise(amount!) < _paise(current)) {
    return 'Amount can only be increased (now ${AppFormat.rupees(current)})';
  }
  return null;
}

String? validateIncreasedAmount(String? text, {required double current}) =>
    increasedAmountError(parseRupees(text), current: current);

/// A payment must be positive and must not exceed what is still due.
String? paymentAmountError(double? amount, {required double due}) {
  final basic = amountError(amount);
  if (basic != null) return basic;
  if (_paise(amount!) > _paise(due)) {
    return 'Payment cannot exceed the due amount (${AppFormat.rupees(due)})';
  }
  return null;
}

String? validatePaymentAmount(String? text, {required double due}) =>
    paymentAmountError(parseRupees(text), due: due);

/// A local validation failure, shaped like the server's 400 so screens
/// handle both with `userMessage` / `fieldError`.
ApiException invalidInput(String field, String message) => ApiException(
  message: message,
  code: ApiErrorCodes.validation,
  statusCode: 400,
  fieldErrors: <String, List<String>>{
    field: <String>[message],
  },
);
