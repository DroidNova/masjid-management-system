// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_dashboard_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AdminDashboardSummary _$AdminDashboardSummaryFromJson(
  Map<String, dynamic> json,
) => _AdminDashboardSummary(
  totalUsers: (json['totalUsers'] as num?)?.toInt() ?? 0,
  activeUsers: (json['activeUsers'] as num?)?.toInt() ?? 0,
  inactiveUsers: (json['inactiveUsers'] as num?)?.toInt() ?? 0,
  suspendedUsers: (json['suspendedUsers'] as num?)?.toInt() ?? 0,
  totalMasjids: (json['totalMasjids'] as num?)?.toInt() ?? 0,
  approvedMasjids: (json['approvedMasjids'] as num?)?.toInt() ?? 0,
  pendingMasjids: (json['pendingMasjids'] as num?)?.toInt() ?? 0,
  suspendedMasjids: (json['suspendedMasjids'] as num?)?.toInt() ?? 0,
  pendingRequests: (json['pendingRequests'] as num?)?.toInt() ?? 0,
  approvedRequests: (json['approvedRequests'] as num?)?.toInt() ?? 0,
  rejectedRequests: (json['rejectedRequests'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$AdminDashboardSummaryToJson(
  _AdminDashboardSummary instance,
) => <String, dynamic>{
  'totalUsers': instance.totalUsers,
  'activeUsers': instance.activeUsers,
  'inactiveUsers': instance.inactiveUsers,
  'suspendedUsers': instance.suspendedUsers,
  'totalMasjids': instance.totalMasjids,
  'approvedMasjids': instance.approvedMasjids,
  'pendingMasjids': instance.pendingMasjids,
  'suspendedMasjids': instance.suspendedMasjids,
  'pendingRequests': instance.pendingRequests,
  'approvedRequests': instance.approvedRequests,
  'rejectedRequests': instance.rejectedRequests,
};
