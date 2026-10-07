import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_imam_salary_payment.freezed.dart';
part 'my_imam_salary_payment.g.dart';

/// One imam salary payment made by the signed-in member
/// (`GET /contributions/my/imam-salary/:month/:year/payments`).
@freezed
abstract class MyImamSalaryPayment with _$MyImamSalaryPayment {
  const factory MyImamSalaryPayment({
    required String id,
    @Default(0) double amount,
    @Default('') String paymentMode,
    DateTime? paidAt,
    @Default('Not available') String collectedByName,
    String? note,
  }) = _MyImamSalaryPayment;

  factory MyImamSalaryPayment.fromJson(Map<String, dynamic> json) =>
      _$MyImamSalaryPaymentFromJson(json);
}
