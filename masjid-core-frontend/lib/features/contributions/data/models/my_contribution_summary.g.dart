// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_contribution_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MyContributionSummary _$MyContributionSummaryFromJson(
  Map<String, dynamic> json,
) => _MyContributionSummary(
  user: MyContributionUser.fromJson(json['user'] as Map<String, dynamic>),
  imamSalary: ImamSalaryContributionSummary.fromJson(
    json['imamSalary'] as Map<String, dynamic>,
  ),
  projectContributionTotal:
      (json['projectContributionTotal'] as num?)?.toDouble() ?? 0,
  collectionContributionTotal:
      (json['collectionContributionTotal'] as num?)?.toDouble() ?? 0,
  totalContributionAmount:
      (json['totalContributionAmount'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$MyContributionSummaryToJson(
  _MyContributionSummary instance,
) => <String, dynamic>{
  'user': instance.user.toJson(),
  'imamSalary': instance.imamSalary.toJson(),
  'projectContributionTotal': instance.projectContributionTotal,
  'collectionContributionTotal': instance.collectionContributionTotal,
  'totalContributionAmount': instance.totalContributionAmount,
};

_MyContributionUser _$MyContributionUserFromJson(Map<String, dynamic> json) =>
    _MyContributionUser(
      id: json['id'] as String,
      fullName: json['fullName'] as String? ?? '',
      phone: json['phone'] as String?,
      isFamilyHead: json['isFamilyHead'] as bool? ?? false,
    );

Map<String, dynamic> _$MyContributionUserToJson(_MyContributionUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'phone': instance.phone,
      'isFamilyHead': instance.isFamilyHead,
    };

_ImamSalaryContributionSummary _$ImamSalaryContributionSummaryFromJson(
  Map<String, dynamic> json,
) => _ImamSalaryContributionSummary(
  monthsShown: (json['monthsShown'] as num?)?.toInt() ?? 0,
  totalExpected: (json['totalExpected'] as num?)?.toDouble() ?? 0,
  totalPaid: (json['totalPaid'] as num?)?.toDouble() ?? 0,
  totalDue: (json['totalDue'] as num?)?.toDouble() ?? 0,
  paidMonths: (json['paidMonths'] as num?)?.toInt() ?? 0,
  partialMonths: (json['partialMonths'] as num?)?.toInt() ?? 0,
  unpaidMonths: (json['unpaidMonths'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ImamSalaryContributionSummaryToJson(
  _ImamSalaryContributionSummary instance,
) => <String, dynamic>{
  'monthsShown': instance.monthsShown,
  'totalExpected': instance.totalExpected,
  'totalPaid': instance.totalPaid,
  'totalDue': instance.totalDue,
  'paidMonths': instance.paidMonths,
  'partialMonths': instance.partialMonths,
  'unpaidMonths': instance.unpaidMonths,
};
