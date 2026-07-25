class MyImamSalaryContributionModel {
  const MyImamSalaryContributionModel({
    required this.month,
    required this.year,
    required this.expectedAmount,
    required this.paidAmount,
    required this.dueAmount,
    required this.status,
    required this.paymentsCount,
    this.lastPaidAt,
  });

  factory MyImamSalaryContributionModel.fromJson(Map<String, dynamic> json) {
    double money(String key) {
      final value = json[key];
      return value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
    }

    int number(String key) {
      final value = json[key];
      return value is num ? value.toInt() : int.tryParse('$value') ?? 0;
    }

    return MyImamSalaryContributionModel(
      month: number('month'),
      year: number('year'),
      expectedAmount: money('expectedAmount'),
      paidAmount: money('paidAmount'),
      dueAmount: money('dueAmount'),
      status: json['status']?.toString() ?? 'UNPAID',
      paymentsCount: number('paymentsCount'),
      lastPaidAt: DateTime.tryParse(json['lastPaidAt']?.toString() ?? ''),
    );
  }

  final int month;
  final int year;
  final double expectedAmount;
  final double paidAmount;
  final double dueAmount;
  final String status;
  final int paymentsCount;
  final DateTime? lastPaidAt;
}
