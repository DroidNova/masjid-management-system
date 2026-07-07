import 'package:platform_core_frontend/features/projects/data/models/project_model.dart';

class UpdateProjectRequest {
  const UpdateProjectRequest({
    this.title,
    this.description,
    this.targetAmount,
    this.collectedAmount,
    this.spentAmount,
    this.status,
    this.startDate,
    this.endDate,
  });

  final String? title;
  final String? description;
  final double? targetAmount;
  final double? collectedAmount;
  final double? spentAmount;
  final String? status;
  final String? startDate;
  final String? endDate;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    addStringIfNotEmpty(json, 'title', title);
    addStringIfNotEmpty(json, 'description', description);
    if (targetAmount != null) json['targetAmount'] = targetAmount;
    if (collectedAmount != null) json['collectedAmount'] = collectedAmount;
    if (spentAmount != null) json['spentAmount'] = spentAmount;
    addStringIfNotEmpty(json, 'status', status);
    addStringIfNotEmpty(json, 'startDate', startDate);
    addStringIfNotEmpty(json, 'endDate', endDate);
    return json;
  }
}
