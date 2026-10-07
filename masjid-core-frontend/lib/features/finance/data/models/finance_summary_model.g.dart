// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finance_summary_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FinanceSummaryModel _$FinanceSummaryModelFromJson(
  Map<String, dynamic> json,
) => _FinanceSummaryModel(
  totalCollection: (json['totalCollection'] as num?)?.toDouble() ?? 0,
  totalExpense: (json['totalExpense'] as num?)?.toDouble() ?? 0,
  currentBalance: (json['currentBalance'] as num?)?.toDouble() ?? 0,
  thisMonthCollection: (json['thisMonthCollection'] as num?)?.toDouble() ?? 0,
  thisMonthExpense: (json['thisMonthExpense'] as num?)?.toDouble() ?? 0,
  thisMonthBalance: (json['thisMonthBalance'] as num?)?.toDouble() ?? 0,
  breakdown: json['breakdown'] == null
      ? const FinanceBreakdown()
      : FinanceBreakdown.fromJson(json['breakdown'] as Map<String, dynamic>),
);

Map<String, dynamic> _$FinanceSummaryModelToJson(
  _FinanceSummaryModel instance,
) => <String, dynamic>{
  'totalCollection': instance.totalCollection,
  'totalExpense': instance.totalExpense,
  'currentBalance': instance.currentBalance,
  'thisMonthCollection': instance.thisMonthCollection,
  'thisMonthExpense': instance.thisMonthExpense,
  'thisMonthBalance': instance.thisMonthBalance,
  'breakdown': instance.breakdown.toJson(),
};

_FinanceBreakdown _$FinanceBreakdownFromJson(Map<String, dynamic> json) =>
    _FinanceBreakdown(
      total: json['total'] == null
          ? const FinanceTotals()
          : FinanceTotals.fromJson(json['total'] as Map<String, dynamic>),
      period: json['period'] == null
          ? const FinanceTotals()
          : FinanceTotals.fromJson(json['period'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FinanceBreakdownToJson(_FinanceBreakdown instance) =>
    <String, dynamic>{
      'total': instance.total.toJson(),
      'period': instance.period.toJson(),
    };

_FinanceTotals _$FinanceTotalsFromJson(
  Map<String, dynamic> json,
) => _FinanceTotals(
  generalCollections: (json['generalCollections'] as num?)?.toDouble() ?? 0,
  projectContributions: (json['projectContributions'] as num?)?.toDouble() ?? 0,
  imamSalaryCollected: (json['imamSalaryCollected'] as num?)?.toDouble() ?? 0,
  income: (json['income'] as num?)?.toDouble() ?? 0,
  expenses: (json['expenses'] as num?)?.toDouble() ?? 0,
  balance: (json['balance'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$FinanceTotalsToJson(_FinanceTotals instance) =>
    <String, dynamic>{
      'generalCollections': instance.generalCollections,
      'projectContributions': instance.projectContributions,
      'imamSalaryCollected': instance.imamSalaryCollected,
      'income': instance.income,
      'expenses': instance.expenses,
      'balance': instance.balance,
    };
