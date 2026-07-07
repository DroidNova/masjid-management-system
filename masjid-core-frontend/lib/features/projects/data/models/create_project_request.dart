import 'package:platform_core_frontend/features/projects/data/models/project_model.dart';

class CreateProjectRequest {
  const CreateProjectRequest({
    required this.title,
    required this.targetAmount,
    required this.collectedAmount,
    required this.spentAmount,
    required this.status,
    this.description,
    this.startDate,
    this.endDate,
  });

  final String title;
  final String? description;
  final double targetAmount;
  final double collectedAmount;
  final double spentAmount;
  final String status;
  final String? startDate;
  final String? endDate;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'title': title.trim(),
      'targetAmount': targetAmount,
      'collectedAmount': collectedAmount,
      'spentAmount': spentAmount,
      'status': status,
    };
    addStringIfNotEmpty(json, 'description', description);
    addStringIfNotEmpty(json, 'startDate', startDate);
    addStringIfNotEmpty(json, 'endDate', endDate);
    return json;
  }
}
