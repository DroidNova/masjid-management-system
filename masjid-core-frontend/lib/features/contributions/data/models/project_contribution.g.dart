// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_contribution.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProjectContribution _$ProjectContributionFromJson(Map<String, dynamic> json) =>
    _ProjectContribution(
      id: json['id'] as String,
      projectId: json['projectId'] as String? ?? '',
      contributorName: json['contributorName'] as String? ?? '',
      contributorPhone: json['contributorPhone'] as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      paymentMode: json['paymentMode'] as String? ?? '',
      paidAt: json['paidAt'] == null
          ? null
          : DateTime.parse(json['paidAt'] as String),
      collectedByName: json['collectedByName'] as String? ?? '',
      note: json['note'] as String?,
      project: json['project'] == null
          ? null
          : ContributionProject.fromJson(
              json['project'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$ProjectContributionToJson(
  _ProjectContribution instance,
) => <String, dynamic>{
  'id': instance.id,
  'projectId': instance.projectId,
  'contributorName': instance.contributorName,
  'contributorPhone': instance.contributorPhone,
  'amount': instance.amount,
  'paymentMode': instance.paymentMode,
  'paidAt': instance.paidAt?.toIso8601String(),
  'collectedByName': instance.collectedByName,
  'note': instance.note,
  'project': instance.project?.toJson(),
};

_ContributionProject _$ContributionProjectFromJson(Map<String, dynamic> json) =>
    _ContributionProject(title: json['title'] as String?);

Map<String, dynamic> _$ContributionProjectToJson(
  _ContributionProject instance,
) => <String, dynamic>{'title': instance.title};
