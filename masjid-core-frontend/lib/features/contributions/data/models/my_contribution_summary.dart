import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_contribution_summary.freezed.dart';
part 'my_contribution_summary.g.dart';

/// `GET /contributions/my/summary`.
@freezed
abstract class MyContributionSummary with _$MyContributionSummary {
  const factory MyContributionSummary({
    required MyContributionUser user,
    required ImamSalaryContributionSummary imamSalary,
    @Default(0) double projectContributionTotal,
    @Default(0) double collectionContributionTotal,
    @Default(0) double totalContributionAmount,
  }) = _MyContributionSummary;

  factory MyContributionSummary.fromJson(Map<String, dynamic> json) =>
      _$MyContributionSummaryFromJson(json);
}

@freezed
abstract class MyContributionUser with _$MyContributionUser {
  const factory MyContributionUser({
    required String id,
    @Default('') String fullName,
    String? phone,
    @Default(false) bool isFamilyHead,
  }) = _MyContributionUser;

  factory MyContributionUser.fromJson(Map<String, dynamic> json) =>
      _$MyContributionUserFromJson(json);
}

@freezed
abstract class ImamSalaryContributionSummary
    with _$ImamSalaryContributionSummary {
  const factory ImamSalaryContributionSummary({
    @Default(0) int monthsShown,
    @Default(0) double totalExpected,
    @Default(0) double totalPaid,
    @Default(0) double totalDue,
    @Default(0) int paidMonths,
    @Default(0) int partialMonths,
    @Default(0) int unpaidMonths,

    /// This month's salary for this person (India time), or null when the
    /// committee has not opened this month yet.
    MySalaryThisMonth? currentMonth,
  }) = _ImamSalaryContributionSummary;

  factory ImamSalaryContributionSummary.fromJson(Map<String, dynamic> json) =>
      _$ImamSalaryContributionSummaryFromJson(json);
}

/// This month's salary: what is expected, paid, still due, and the status
/// (PAID, PARTIAL, UNPAID).
@freezed
abstract class MySalaryThisMonth with _$MySalaryThisMonth {
  const factory MySalaryThisMonth({
    required int month,
    required int year,
    @Default(0) double expectedAmount,
    @Default(0) double paidAmount,
    @Default(0) double dueAmount,
    @Default('UNPAID') String status,
  }) = _MySalaryThisMonth;

  factory MySalaryThisMonth.fromJson(Map<String, dynamic> json) =>
      _$MySalaryThisMonthFromJson(json);
}
