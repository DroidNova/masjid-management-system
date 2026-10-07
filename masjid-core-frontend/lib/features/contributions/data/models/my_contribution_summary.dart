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
  }) = _ImamSalaryContributionSummary;

  factory ImamSalaryContributionSummary.fromJson(Map<String, dynamic> json) =>
      _$ImamSalaryContributionSummaryFromJson(json);
}
