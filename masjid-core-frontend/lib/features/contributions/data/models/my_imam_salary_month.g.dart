// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_imam_salary_month.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MyImamSalaryMonth _$MyImamSalaryMonthFromJson(Map<String, dynamic> json) =>
    _MyImamSalaryMonth(
      month: (json['month'] as num).toInt(),
      year: (json['year'] as num).toInt(),
      expectedAmount: (json['expectedAmount'] as num?)?.toDouble() ?? 0,
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0,
      dueAmount: (json['dueAmount'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? 'UNPAID',
      paymentsCount: (json['paymentsCount'] as num?)?.toInt() ?? 0,
      lastPaidAt: json['lastPaidAt'] == null
          ? null
          : DateTime.parse(json['lastPaidAt'] as String),
    );

Map<String, dynamic> _$MyImamSalaryMonthToJson(_MyImamSalaryMonth instance) =>
    <String, dynamic>{
      'month': instance.month,
      'year': instance.year,
      'expectedAmount': instance.expectedAmount,
      'paidAmount': instance.paidAmount,
      'dueAmount': instance.dueAmount,
      'status': instance.status,
      'paymentsCount': instance.paymentsCount,
      'lastPaidAt': instance.lastPaidAt?.toIso8601String(),
    };
