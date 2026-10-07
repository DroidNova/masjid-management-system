import 'package:freezed_annotation/freezed_annotation.dart';

part 'finance_summary_model.freezed.dart';
part 'finance_summary_model.g.dart';

/// `GET /finance/my-masjid/summary`.
///
/// `totalCollection` is all money received: general collections + project
/// contributions + imam salary payments. [breakdown] shows each part, for all
/// time (`total`) and for the requested period (`period`, default this month).
@freezed
abstract class FinanceSummaryModel with _$FinanceSummaryModel {
  const factory FinanceSummaryModel({
    @Default(0) double totalCollection,
    @Default(0) double totalExpense,
    @Default(0) double currentBalance,
    @Default(0) double thisMonthCollection,
    @Default(0) double thisMonthExpense,
    @Default(0) double thisMonthBalance,
    @Default(FinanceBreakdown()) FinanceBreakdown breakdown,
  }) = _FinanceSummaryModel;

  factory FinanceSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$FinanceSummaryModelFromJson(json);
}

@freezed
abstract class FinanceBreakdown with _$FinanceBreakdown {
  const factory FinanceBreakdown({
    @Default(FinanceTotals()) FinanceTotals total,
    @Default(FinanceTotals()) FinanceTotals period,
  }) = _FinanceBreakdown;

  factory FinanceBreakdown.fromJson(Map<String, dynamic> json) =>
      _$FinanceBreakdownFromJson(json);
}

/// One set of totals (masjid-core finance-calculator `totalsToResponse`).
@freezed
abstract class FinanceTotals with _$FinanceTotals {
  const factory FinanceTotals({
    @Default(0) double generalCollections,
    @Default(0) double projectContributions,
    @Default(0) double imamSalaryCollected,
    @Default(0) double income,
    @Default(0) double expenses,
    @Default(0) double balance,
  }) = _FinanceTotals;

  factory FinanceTotals.fromJson(Map<String, dynamic> json) =>
      _$FinanceTotalsFromJson(json);
}
