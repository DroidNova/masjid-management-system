class CreateImamSalaryRequest {
  const CreateImamSalaryRequest({
    required this.month,
    required this.year,
    required this.salaryAmount,
    this.paidAmount = 0,
    this.status = 'UNPAID',
    this.paidDate,
    this.note,
  });

  final int month;
  final int year;
  final double salaryAmount;
  final double paidAmount;
  final String status;
  final String? paidDate;
  final String? note;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'month': month,
      'year': year,
      'salaryAmount': salaryAmount,
      'paidAmount': paidAmount,
      'status': status,
    };
    final trimmedPaidDate = paidDate?.trim();
    if (trimmedPaidDate != null && trimmedPaidDate.isNotEmpty) {
      json['paidDate'] = trimmedPaidDate;
    }
    final trimmedNote = note?.trim();
    if (trimmedNote != null && trimmedNote.isNotEmpty) {
      json['note'] = trimmedNote;
    }
    return json;
  }
}
