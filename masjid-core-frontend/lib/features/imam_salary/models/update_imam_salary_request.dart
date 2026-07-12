class UpdateImamSalaryRequest {
  const UpdateImamSalaryRequest({
    this.month,
    this.year,
    this.salaryAmount,
    this.paidAmount,
    this.paidDate,
    this.note,
  });

  final int? month;
  final int? year;
  final double? salaryAmount;
  final double? paidAmount;
  final String? paidDate;
  final String? note;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (month != null) json['month'] = month;
    if (year != null) json['year'] = year;
    if (salaryAmount != null) json['salaryAmount'] = salaryAmount;
    if (paidAmount != null) json['paidAmount'] = paidAmount;
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
