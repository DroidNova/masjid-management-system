// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_expense_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateExpenseRequest _$CreateExpenseRequestFromJson(
  Map<String, dynamic> json,
) => _CreateExpenseRequest(
  type: json['type'] as String,
  amount: (json['amount'] as num).toDouble(),
  title: json['title'] as String?,
  description: json['description'] as String?,
  spentAt: json['spentAt'] as String?,
);

Map<String, dynamic> _$CreateExpenseRequestToJson(
  _CreateExpenseRequest instance,
) => <String, dynamic>{
  'type': instance.type,
  'amount': instance.amount,
  'title': ?instance.title,
  'description': ?instance.description,
  'spentAt': ?instance.spentAt,
};
