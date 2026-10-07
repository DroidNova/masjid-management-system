// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_entry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExpenseEntryModel _$ExpenseEntryModelFromJson(Map<String, dynamic> json) =>
    _ExpenseEntryModel(
      id: json['id'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      title: json['title'] as String?,
      description: json['description'] as String?,
      spentAt: json['spentAt'] == null
          ? null
          : DateTime.parse(json['spentAt'] as String),
      status: json['status'] as String? ?? 'ACTIVE',
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ExpenseEntryModelToJson(_ExpenseEntryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'amount': instance.amount,
      'title': instance.title,
      'description': instance.description,
      'spentAt': instance.spentAt?.toIso8601String(),
      'status': instance.status,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
