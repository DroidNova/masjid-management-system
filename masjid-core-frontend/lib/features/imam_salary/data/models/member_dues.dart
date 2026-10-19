import 'package:flutter/foundation.dart';

/// One unpaid (or part paid) salary month of a family head.
@immutable
class DueMonth {
  const DueMonth({
    required this.assignmentId,
    required this.month,
    required this.year,
    required this.dueAmount,
  });

  factory DueMonth.fromJson(Map<String, dynamic> json) => DueMonth(
    assignmentId: json['assignmentId'] as String,
    month: (json['month'] as num).toInt(),
    year: (json['year'] as num).toInt(),
    dueAmount: (json['dueAmount'] as num).toDouble(),
  );

  final String assignmentId;
  final int month;
  final int year;
  final double dueAmount;
}

/// Everything a family head still owes, oldest month first
/// (`GET /imam-salaries/members/:id/dues`).
@immutable
class MemberDues {
  const MemberDues({required this.totalDue, required this.months});

  factory MemberDues.fromJson(Map<String, dynamic> json) => MemberDues(
    totalDue: (json['totalDue'] as num? ?? 0).toDouble(),
    months: (json['months'] as List<dynamic>? ?? const <dynamic>[])
        .map((item) => DueMonth.fromJson(item as Map<String, dynamic>))
        .toList(),
  );

  final double totalDue;
  final List<DueMonth> months;

  /// How [amount] would be shared out, oldest month first: each month with
  /// the part of it this amount pays.
  List<(DueMonth, double)> cover(double amount) {
    final result = <(DueMonth, double)>[];
    var left = (amount * 100).round();
    for (final month in months) {
      if (left <= 0) break;
      final due = (month.dueAmount * 100).round();
      final part = left < due ? left : due;
      result.add((month, part / 100));
      left -= part;
    }
    return result;
  }
}
