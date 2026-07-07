import 'package:platform_core_frontend/features/dashboard/data/models/model_parsing.dart';

class ProjectsSummary {
  const ProjectsSummary({
    required this.activeProjectsCount,
    required this.latestProjects,
  });

  factory ProjectsSummary.fromJson(Map<String, dynamic> json) {
    final projects = json['latestProjects'];
    return ProjectsSummary(
      activeProjectsCount: parseInt(json['activeProjectsCount']),
      latestProjects: projects is List<dynamic>
          ? projects
              .whereType<Map<String, dynamic>>()
              .map(ProjectPreview.fromJson)
              .toList()
          : <ProjectPreview>[],
    );
  }

  final int activeProjectsCount;
  final List<ProjectPreview> latestProjects;
}

class ProjectPreview {
  const ProjectPreview({
    this.id,
    this.title,
    required this.targetAmount,
    required this.collectedAmount,
    required this.progressPercentage,
    this.status,
  });

  factory ProjectPreview.fromJson(Map<String, dynamic> json) {
    return ProjectPreview(
      id: parseString(json['id']),
      title: parseString(json['title']),
      targetAmount: parseDouble(json['targetAmount']),
      collectedAmount: parseDouble(json['collectedAmount']),
      progressPercentage: parseDouble(json['progressPercentage']),
      status: parseString(json['status']),
    );
  }

  final String? id;
  final String? title;
  final double targetAmount;
  final double collectedAmount;
  final double progressPercentage;
  final String? status;
}
