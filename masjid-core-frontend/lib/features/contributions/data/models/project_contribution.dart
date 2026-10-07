import 'package:freezed_annotation/freezed_annotation.dart';

part 'project_contribution.freezed.dart';
part 'project_contribution.g.dart';

/// One contribution to a project (`/projects/:id/contributions` and
/// `/contributions/my/projects`; the latter also sends `project.title`).
@freezed
abstract class ProjectContribution with _$ProjectContribution {
  const factory ProjectContribution({
    required String id,
    @Default('') String projectId,
    @Default('') String contributorName,
    String? contributorPhone,
    @Default(0) double amount,
    @Default('') String paymentMode,
    DateTime? paidAt,
    @Default('') String collectedByName,
    String? note,
    ContributionProject? project,
  }) = _ProjectContribution;

  const ProjectContribution._();

  factory ProjectContribution.fromJson(Map<String, dynamic> json) =>
      _$ProjectContributionFromJson(json);

  String? get projectTitle => project?.title;
}

@freezed
abstract class ContributionProject with _$ContributionProject {
  const factory ContributionProject({String? title}) = _ContributionProject;

  factory ContributionProject.fromJson(Map<String, dynamic> json) =>
      _$ContributionProjectFromJson(json);
}
