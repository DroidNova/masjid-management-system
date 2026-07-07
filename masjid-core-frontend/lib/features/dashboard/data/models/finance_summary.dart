import 'package:platform_core_frontend/features/dashboard/data/models/model_parsing.dart';

class FinanceSummary {
  const FinanceSummary({
    required this.totalCollection,
    required this.totalExpense,
    required this.currentBalance,
    required this.thisMonthCollection,
    required this.thisMonthExpense,
  });

  factory FinanceSummary.fromJson(Map<String, dynamic> json) {
    return FinanceSummary(
      totalCollection: parseDouble(json['totalCollection']),
      totalExpense: parseDouble(json['totalExpense']),
      currentBalance: parseDouble(json['currentBalance']),
      thisMonthCollection: parseDouble(json['thisMonthCollection']),
      thisMonthExpense: parseDouble(json['thisMonthExpense']),
    );
  }

  factory FinanceSummary.empty() {
    return const FinanceSummary(
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
