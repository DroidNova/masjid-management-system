// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_collection_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateCollectionRequest _$CreateCollectionRequestFromJson(
  Map<String, dynamic> json,
) => _CreateCollectionRequest(
  type: json['type'] as String,
  amount: (json['amount'] as num).toDouble(),
  title: json['title'] as String?,
  description: json['description'] as String?,
  collectedAt: json['collectedAt'] as String?,
);

Map<String, dynamic> _$CreateCollectionRequestToJson(
  _CreateCollectionRequest instance,
) => <String, dynamic>{
  'type': instance.type,
  'amount': instance.amount,
  'title': ?instance.title,
  'description': ?instance.description,
  'collectedAt': ?instance.collectedAt,
};
