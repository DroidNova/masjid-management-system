import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_imam_salary_month.freezed.dart';
part 'my_imam_salary_month.g.dart';

/// One month of the signed-in member's imam salary dues
/// (`GET /contributions/my/imam-salary`).
@freezed
abstract class MyImamSalaryMonth with _$MyImamSalaryMonth {
  const factory MyImamSalaryMonth({
    required int month,
    required int year,
    @Default(0) double expectedAmount,
    @Default(0) double paidAmount,
    @Default(0) double dueAmount,
    @Default('UNPAID') String status,
    @Default(0) int paymentsCount,
    DateTime? lastPaidAt,
  }) = _MyImamSalaryMonth;

  factory MyImamSalaryMonth.fromJson(Map<String, dynamic> json) =>
      _$MyImamSalaryMonthFromJson(json);
}
