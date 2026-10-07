import 'package:freezed_annotation/freezed_annotation.dart';

part 'imam_salary_models.freezed.dart';
part 'imam_salary_models.g.dart';

/// Assignment / month status values sent by the server.
class SalaryStatus {
  const SalaryStatus._();

  static const String paid = 'PAID';
  static const String partial = 'PARTIAL';
  static const String unpaid = 'UNPAID';
}

/// One salary month of the masjid (`/imam-salaries/months`).
@freezed
abstract class ImamSalaryMonth with _$ImamSalaryMonth {
  const factory ImamSalaryMonth({
    required String id,
    required int month,
    required int year,
    @Default(0) double amountPerHead,
    @Default(0) double totalExpected,
    @Default(0) double totalCollected,
    @Default(0) double totalDue,
    @Default(0) int paidCount,
    @Default(0) int partialCount,
    @Default(0) int unpaidCount,
    @Default(SalaryStatus.unpaid) String status,
    String? note,
  }) = _ImamSalaryMonth;

  factory ImamSalaryMonth.fromJson(Map<String, dynamic> json) =>
      _$ImamSalaryMonthFromJson(json);
}

/// What one family head owes for a month
/// (`/imam-salaries/months/:id/assignments`).
@freezed
abstract class SalaryAssignment with _$SalaryAssignment {
  const factory SalaryAssignment({
    required String id,
    @Default('') String memberId,
    @Default('') String memberName,
    @Default('') String memberPhone,
    @Default(0) double expectedAmount,
    @Default(0) double paidAmount,
    @Default(0) double dueAmount,
    @Default(SalaryStatus.unpaid) String status,
  }) = _SalaryAssignment;

  factory SalaryAssignment.fromJson(Map<String, dynamic> json) =>
      _$SalaryAssignmentFromJson(json);
}

/// One recorded salary payment (`/imam-salaries/payments`).
@freezed
abstract class SalaryPayment with _$SalaryPayment {
  const factory SalaryPayment({
    required String id,
    @Default('') String memberId,
    @Default('') String memberName,
    @Default('') String memberPhone,
    @Default(0) double amount,
    @Default('') String paymentMode,
    DateTime? paidAt,
    @Default('') String collectedByName,
    String? note,
    @Default(0) int paymentForMonth,
    @Default(0) int paymentForYear,
  }) = _SalaryPayment;

  factory SalaryPayment.fromJson(Map<String, dynamic> json) =>
      _$SalaryPaymentFromJson(json);
}

/// One month of the signed-in member's own dues
/// (`GET /imam-salaries/my-history`, returns `{ items }`).
@freezed
abstract class MySalaryHistoryMonth with _$MySalaryHistoryMonth {
  const factory MySalaryHistoryMonth({
    required int month,
    required int year,
    @Default(0) double expectedAmount,
    @Default(0) double paidAmount,
    @Default(0) double dueAmount,
    @Default(SalaryStatus.unpaid) String status,
    @Default(<MySalaryHistoryPayment>[]) List<MySalaryHistoryPayment> payments,
  }) = _MySalaryHistoryMonth;

  factory MySalaryHistoryMonth.fromJson(Map<String, dynamic> json) =>
      _$MySalaryHistoryMonthFromJson(json);
}

@freezed
abstract class MySalaryHistoryPayment with _$MySalaryHistoryPayment {
  const factory MySalaryHistoryPayment({
    required String id,
    @Default(0) double amount,
    @Default('') String paymentMode,
    DateTime? paidAt,
    String? note,
  }) = _MySalaryHistoryPayment;

  factory MySalaryHistoryPayment.fromJson(Map<String, dynamic> json) =>
      _$MySalaryHistoryPaymentFromJson(json);
}
