// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_imam_salary_payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MyImamSalaryPayment _$MyImamSalaryPaymentFromJson(Map<String, dynamic> json) =>
    _MyImamSalaryPayment(
      id: json['id'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      paymentMode: json['paymentMode'] as String? ?? '',
      paidAt: json['paidAt'] == null
          ? null
          : DateTime.parse(json['paidAt'] as String),
      collectedByName: json['collectedByName'] as String? ?? 'Not available',
      note: json['note'] as String?,
    );

Map<String, dynamic> _$MyImamSalaryPaymentToJson(
  _MyImamSalaryPayment instance,
) => <String, dynamic>{
  'id': instance.id,
  'amount': instance.amount,
  'paymentMode': instance.paymentMode,
  'paidAt': instance.paidAt?.toIso8601String(),
  'collectedByName': instance.collectedByName,
  'note': instance.note,
};
