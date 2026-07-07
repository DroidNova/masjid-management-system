import 'package:platform_core_frontend/features/dashboard/data/models/model_parsing.dart';

class ImamSalarySummary {
  const ImamSalarySummary({
    required this.latestMonth,
    required this.latestYear,
    required this.salaryAmount,
    required this.paidAmount,
    required this.dueAmount,
    this.status,
  });

  factory ImamSalarySummary.fromJson(Map<String, dynamic> json) {
    return ImamSalarySummary(
      latestMonth: parseInt(json['latestMonth']),
      latestYear: parseInt(json['latestYear']),
      salaryAmount: parseDouble(json['salaryAmount']),
      paidAmount: parseDouble(json['paidAmount']),
      dueAmount: parseDouble(json['dueAmount']),
      status: parseString(json['status']),
    );
  }

  final int latestMonth;
  final int latestYear;
  final double salaryAmount;
  final double paidAmount;
  final double dueAmount;
  final String? status;
}
