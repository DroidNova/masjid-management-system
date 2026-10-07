// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_entry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CollectionEntryModel _$CollectionEntryModelFromJson(
  Map<String, dynamic> json,
) => _CollectionEntryModel(
  id: json['id'] as String,
  type: json['type'] as String,
  amount: (json['amount'] as num).toDouble(),
  title: json['title'] as String?,
  description: json['description'] as String?,
  collectedAt: json['collectedAt'] == null
      ? null
      : DateTime.parse(json['collectedAt'] as String),
  status: json['status'] as String? ?? 'ACTIVE',
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$CollectionEntryModelToJson(
  _CollectionEntryModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'amount': instance.amount,
  'title': instance.title,
  'description': instance.description,
  'collectedAt': instance.collectedAt?.toIso8601String(),
  'status': instance.status,
  'createdAt': instance.createdAt?.toIso8601String(),
};
