import 'package:platform_core_frontend/shared/models/audit_info.dart';

class ImamSalaryModel {
  const ImamSalaryModel({
    required this.id,
    this.masjidId,
    this.imamId,
    required this.month,
    required this.year,
    required this.salaryAmount,
    required this.paidAmount,
    required this.dueAmount,
    required this.status,
    this.paidDate,
    this.note,
    this.auditInfo = const AuditInfo(),
    this.createdAt,
    this.updatedAt,
    this.imamName,
    this.imamPhone,
    this.imamEmail,
  });

  final String id;
  final String? masjidId;
  final String? imamId;
  final int month;
  final int year;
  final double salaryAmount;
  final double paidAmount;
  final double dueAmount;
  final String status;
  final String? paidDate;
  final String? note;
  final AuditInfo auditInfo;
  final String? createdAt;
  final String? updatedAt;
  final String? imamName;
  final String? imamPhone;
  final String? imamEmail;

  factory ImamSalaryModel.fromJson(Map<String, dynamic> json) {
    final imam = json['imam'];
    final imamMap = imam is Map<String, dynamic> ? imam : null;

    final salaryAmount = parseDouble(json['salaryAmount']);
    final paidAmount = parseDouble(json['paidAmount']);
    final dueAmount = json.containsKey('dueAmount')
        ? parseDouble(json['dueAmount'])
        : salaryAmount - paidAmount;

    return ImamSalaryModel(
      id: _readString(json['id']) ?? '',
      masjidId: _readString(json['masjidId']),
      imamId: _readString(json['imamId']),
      month: parseInt(json['month']),
      year: parseInt(json['year']),
      salaryAmount: salaryAmount,
      paidAmount: paidAmount,
      dueAmount: dueAmount,
      status: _readString(json['status']) ?? 'UNPAID',
      paidDate: _readString(json['paidDate']),
      note: _readString(json['note']),
      auditInfo: AuditInfo.fromJson(json),
      createdAt: _readString(json['createdAt']),
      updatedAt: _readString(json['updatedAt']),
      imamName: _readString(imamMap?['fullName']) ?? _readString(imamMap?['name']),
      imamPhone: _readString(imamMap?['phone']),
      imamEmail: _readString(imamMap?['email']),
    );
  }

  String get monthName {
    const monthNames = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    if (month < 1 || month > 12) return 'Month $month';
    return monthNames[month - 1];
  }

  double get calculatedDueAmount => salaryAmount - paidAmount;
  bool get isPaid => status == 'PAID';
  bool get isPartial => status == 'PARTIAL';
  bool get isUnpaid => status == 'UNPAID';
}

double parseDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim()) ?? 0;
  return 0;
}

int parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim()) ?? 0;
  return 0;
}

String? _readString(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}
