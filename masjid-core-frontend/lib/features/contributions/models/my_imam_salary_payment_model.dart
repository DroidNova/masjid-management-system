class MyImamSalaryPaymentModel {
  const MyImamSalaryPaymentModel({
    required this.id,
    required this.amount,
    required this.paymentMode,
    required this.paidAt,
    required this.collectedByName,
    this.note,
  });

  factory MyImamSalaryPaymentModel.fromJson(Map<String, dynamic> json) {
    final amount = json['amount'];
    return MyImamSalaryPaymentModel(
      id: json['id']?.toString() ?? '',
      amount: amount is num
          ? amount.toDouble()
          : double.tryParse('$amount') ?? 0,
      paymentMode: json['paymentMode']?.toString() ?? '',
      paidAt: DateTime.tryParse(json['paidAt']?.toString() ?? ''),
      collectedByName: json['collectedByName']?.toString() ?? 'Not available',
      note: _optionalText(json['note']),
    );
  }

  final String id;
  final double amount;
  final String paymentMode;
  final DateTime? paidAt;
  final String collectedByName;
  final String? note;

  static String? _optionalText(dynamic value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}
