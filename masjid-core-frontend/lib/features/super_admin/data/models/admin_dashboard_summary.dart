import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_dashboard_summary.freezed.dart';
part 'admin_dashboard_summary.g.dart';

/// Counts from `GET /admin/dashboard/summary`.
@freezed
abstract class AdminDashboardSummary with _$AdminDashboardSummary {
  const factory AdminDashboardSummary({
    @Default(0) int totalUsers,
    @Default(0) int activeUsers,
    @Default(0) int inactiveUsers,
    @Default(0) int suspendedUsers,
    @Default(0) int totalMasjids,
    @Default(0) int approvedMasjids,
    @Default(0) int pendingMasjids,
    @Default(0) int suspendedMasjids,
    @Default(0) int pendingRequests,
    @Default(0) int approvedRequests,
    @Default(0) int rejectedRequests,
  }) = _AdminDashboardSummary;

  factory AdminDashboardSummary.fromJson(Map<String, dynamic> json) =>
      _$AdminDashboardSummaryFromJson(json);
}
