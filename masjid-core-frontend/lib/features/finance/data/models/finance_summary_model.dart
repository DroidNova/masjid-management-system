import 'package:platform_core_frontend/features/finance/data/models/finance_model_parsing.dart';

class FinanceSummaryModel {
  const FinanceSummaryModel({
    required this.totalCollection,
    required this.totalExpense,
    required this.currentBalance,
    required this.thisMonthCollection,
    required this.thisMonthExpense,
  });

  factory FinanceSummaryModel.fromJson(Map<String, dynamic> json) {
    return FinanceSummaryModel(
      totalCollection: parseDouble(json['totalCollection']),
      totalExpense: parseDouble(json['totalExpense']),
      currentBalance: parseDouble(json['currentBalance']),
      thisMonthCollection: parseDouble(json['thisMonthCollection']),
      thisMonthExpense: parseDouble(json['thisMonthExpense']),
    );
  }

  factory FinanceSummaryModel.empty() {
    return const FinanceSummaryModel(
      totalCollection: 0,
      totalExpense: 0,
      currentBalance: 0,
      thisMonthCollection: 0,
      thisMonthExpense: 0,
    );
  }

  final double totalCollection;
  final double totalExpense;
  final double currentBalance;
  final double thisMonthCollection;
  final double thisMonthExpense;
}
