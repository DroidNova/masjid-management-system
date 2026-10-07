// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_contribution.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CollectionContribution _$CollectionContributionFromJson(
  Map<String, dynamic> json,
) => _CollectionContribution(
  id: json['id'] as String,
  collectionType: json['collectionType'] as String? ?? '',
  contributorName: json['contributorName'] as String? ?? '',
  contributorPhone: json['contributorPhone'] as String?,
  amount: (json['amount'] as num?)?.toDouble() ?? 0,
  paymentMode: json['paymentMode'] as String? ?? '',
  paidAt: json['paidAt'] == null
      ? null
      : DateTime.parse(json['paidAt'] as String),
  collectedByName: json['collectedByName'] as String? ?? '',
  note: json['note'] as String?,
);

Map<String, dynamic> _$CollectionContributionToJson(
  _CollectionContribution instance,
) => <String, dynamic>{
  'id': instance.id,
  'collectionType': instance.collectionType,
  'contributorName': instance.contributorName,
  'contributorPhone': instance.contributorPhone,
  'amount': instance.amount,
  'paymentMode': instance.paymentMode,
  'paidAt': instance.paidAt?.toIso8601String(),
  'collectedByName': instance.collectedByName,
  'note': instance.note,
};
