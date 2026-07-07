import 'package:platform_core_frontend/features/dashboard/data/models/announcement_summary.dart';
import 'package:platform_core_frontend/features/dashboard/data/models/finance_summary.dart';
import 'package:platform_core_frontend/features/dashboard/data/models/imam_salary_summary.dart';
import 'package:platform_core_frontend/features/dashboard/data/models/imam_summary.dart';
import 'package:platform_core_frontend/features/dashboard/data/models/masjid_summary.dart';
import 'package:platform_core_frontend/features/dashboard/data/models/model_parsing.dart';
import 'package:platform_core_frontend/features/dashboard/data/models/namaz_time_summary.dart';
import 'package:platform_core_frontend/features/dashboard/data/models/project_summary.dart';

class DashboardResponse {
  const DashboardResponse({
    this.masjid,
    this.namazTime,
    this.imam,
    required this.membersCount,
    required this.latestAnnouncements,
    this.projectsSummary,
    this.financeSummary,
    this.imamSalarySummary,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    final masjidJson = parseMap(json['masjid']);
    final namazTimeJson = parseMap(json['namazTime']);
    final imamJson = parseMap(json['imam']);
    final announcements = json['latestAnnouncements'];
    final projectsSummaryJson = parseMap(json['projectsSummary']);
    final financeSummaryJson = parseMap(json['financeSummary']);
    final imamSalarySummaryJson = parseMap(json['imamSalarySummary']);

    return DashboardResponse(
      masjid: masjidJson == null ? null : MasjidSummary.fromJson(masjidJson),
      namazTime: namazTimeJson == null
          ? null
          : NamazTimeSummary.fromJson(namazTimeJson),
      imam: imamJson == null ? null : ImamSummary.fromJson(imamJson),
      membersCount: parseInt(json['membersCount']),
      latestAnnouncements: announcements is List<dynamic>
          ? announcements
              .whereType<Map<String, dynamic>>()
              .map(AnnouncementSummary.fromJson)
              .toList()
          : <AnnouncementSummary>[],
      projectsSummary: projectsSummaryJson == null
          ? null
          : ProjectsSummary.fromJson(projectsSummaryJson),
      financeSummary: financeSummaryJson == null
          ? null
          : FinanceSummary.fromJson(financeSummaryJson),
      imamSalarySummary: imamSalarySummaryJson == null
          ? null
          : ImamSalarySummary.fromJson(imamSalarySummaryJson),
    );
  }

  final MasjidSummary? masjid;
  final NamazTimeSummary? namazTime;
  final ImamSummary? imam;
  final int membersCount;
  final List<AnnouncementSummary> latestAnnouncements;
  final ProjectsSummary? projectsSummary;
  final FinanceSummary? financeSummary;
  final ImamSalarySummary? imamSalarySummary;
}
