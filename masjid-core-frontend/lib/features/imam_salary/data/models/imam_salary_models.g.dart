// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'imam_salary_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ImamSalaryMonth _$ImamSalaryMonthFromJson(Map<String, dynamic> json) =>
    _ImamSalaryMonth(
      id: json['id'] as String,
      month: (json['month'] as num).toInt(),
      year: (json['year'] as num).toInt(),
      amountPerHead: (json['amountPerHead'] as num?)?.toDouble() ?? 0,
      totalExpected: (json['totalExpected'] as num?)?.toDouble() ?? 0,
      totalCollected: (json['totalCollected'] as num?)?.toDouble() ?? 0,
      totalDue: (json['totalDue'] as num?)?.toDouble() ?? 0,
      paidCount: (json['paidCount'] as num?)?.toInt() ?? 0,
      partialCount: (json['partialCount'] as num?)?.toInt() ?? 0,
      unpaidCount: (json['unpaidCount'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? SalaryStatus.unpaid,
      note: json['note'] as String?,
    );

Map<String, dynamic> _$ImamSalaryMonthToJson(_ImamSalaryMonth instance) =>
    <String, dynamic>{
      'id': instance.id,
      'month': instance.month,
      'year': instance.year,
      'amountPerHead': instance.amountPerHead,
      'totalExpected': instance.totalExpected,
      'totalCollected': instance.totalCollected,
      'totalDue': instance.totalDue,
      'paidCount': instance.paidCount,
      'partialCount': instance.partialCount,
      'unpaidCount': instance.unpaidCount,
      'status': instance.status,
      'note': instance.note,
    };

_SalaryAssignment _$SalaryAssignmentFromJson(Map<String, dynamic> json) =>
    _SalaryAssignment(
      id: json['id'] as String,
      memberId: json['memberId'] as String? ?? '',
      memberName: json['memberName'] as String? ?? '',
      memberPhone: json['memberPhone'] as String? ?? '',
      expectedAmount: (json['expectedAmount'] as num?)?.toDouble() ?? 0,
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0,
      dueAmount: (json['dueAmount'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? SalaryStatus.unpaid,
    );

Map<String, dynamic> _$SalaryAssignmentToJson(_SalaryAssignment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'memberId': instance.memberId,
      'memberName': instance.memberName,
      'memberPhone': instance.memberPhone,
      'expectedAmount': instance.expectedAmount,
      'paidAmount': instance.paidAmount,
      'dueAmount': instance.dueAmount,
      'status': instance.status,
    };

_SalaryPayment _$SalaryPaymentFromJson(Map<String, dynamic> json) =>
    _SalaryPayment(
      id: json['id'] as String,
      memberId: json['memberId'] as String? ?? '',
      memberName: json['memberName'] as String? ?? '',
      memberPhone: json['memberPhone'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      paymentMode: json['paymentMode'] as String? ?? '',
      paidAt: json['paidAt'] == null
          ? null
          : DateTime.parse(json['paidAt'] as String),
      collectedByName: json['collectedByName'] as String? ?? '',
      note: json['note'] as String?,
      paymentForMonth: (json['paymentForMonth'] as num?)?.toInt() ?? 0,
      paymentForYear: (json['paymentForYear'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$SalaryPaymentToJson(_SalaryPayment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'memberId': instance.memberId,
      'memberName': instance.memberName,
      'memberPhone': instance.memberPhone,
      'amount': instance.amount,
      'paymentMode': instance.paymentMode,
      'paidAt': instance.paidAt?.toIso8601String(),
      'collectedByName': instance.collectedByName,
      'note': instance.note,
      'paymentForMonth': instance.paymentForMonth,
      'paymentForYear': instance.paymentForYear,
    };

_MySalaryHistoryMonth _$MySalaryHistoryMonthFromJson(
  Map<String, dynamic> json,
) => _MySalaryHistoryMonth(
  month: (json['month'] as num).toInt(),
  year: (json['year'] as num).toInt(),
  expectedAmount: (json['expectedAmount'] as num?)?.toDouble() ?? 0,
  paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0,
  dueAmount: (json['dueAmount'] as num?)?.toDouble() ?? 0,
  status: json['status'] as String? ?? SalaryStatus.unpaid,
  payments:
      (json['payments'] as List<dynamic>?)
          ?.map(
            (e) => MySalaryHistoryPayment.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <MySalaryHistoryPayment>[],
);

Map<String, dynamic> _$MySalaryHistoryMonthToJson(
  _MySalaryHistoryMonth instance,
) => <String, dynamic>{
  'month': instance.month,
  'year': instance.year,
  'expectedAmount': instance.expectedAmount,
  'paidAmount': instance.paidAmount,
  'dueAmount': instance.dueAmount,
  'status': instance.status,
  'payments': instance.payments.map((e) => e.toJson()).toList(),
};

_MySalaryHistoryPayment _$MySalaryHistoryPaymentFromJson(
  Map<String, dynamic> json,
) => _MySalaryHistoryPayment(
  id: json['id'] as String,
  amount: (json['amount'] as num?)?.toDouble() ?? 0,
  paymentMode: json['paymentMode'] as String? ?? '',
  paidAt: json['paidAt'] == null
      ? null
      : DateTime.parse(json['paidAt'] as String),
  note: json['note'] as String?,
);

Map<String, dynamic> _$MySalaryHistoryPaymentToJson(
  _MySalaryHistoryPayment instance,
) => <String, dynamic>{
  'id': instance.id,
  'amount': instance.amount,
  'paymentMode': instance.paymentMode,
  'paidAt': instance.paidAt?.toIso8601String(),
  'note': instance.note,
};
