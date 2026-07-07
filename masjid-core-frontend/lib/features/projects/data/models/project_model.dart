class ProjectModel {
  const ProjectModel({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.collectedAmount,
    required this.spentAmount,
    required this.status,
    this.description,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: _string(json['id']),
      title: _string(json['title'], fallback: 'Untitled Project'),
      description: _optionalString(json['description']),
      targetAmount: parseDouble(json['targetAmount']),
      collectedAmount: parseDouble(json['collectedAmount']),
      spentAmount: parseDouble(json['spentAmount']),
      status: _string(json['status'], fallback: 'ONGOING'),
      startDate: _optionalString(json['startDate']),
      endDate: _optionalString(json['endDate']),
      createdAt: _optionalString(json['createdAt']),
      updatedAt: _optionalString(json['updatedAt']),
    );
  }

  final String id;
  final String title;
  final String? description;
  final double targetAmount;
  final double collectedAmount;
  final double spentAmount;
  final String status;
  final String? startDate;
  final String? endDate;
  final String? createdAt;
  final String? updatedAt;

  double get progressPercentage {
    if (targetAmount <= 0) return 0;
    return ((collectedAmount / targetAmount) * 100).clamp(0, 100).toDouble();
  }
}

double parseDouble(Object? value) {
  if (value is int) return value.toDouble();
  if (value is double) return value;
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

String _string(Object? value, {String fallback = ''}) {
  final parsed = value?.toString();
  if (parsed == null || parsed.trim().isEmpty) return fallback;
  return parsed;
}

String? _optionalString(Object? value) {
  final parsed = value?.toString();
  if (parsed == null || parsed.trim().isEmpty) return null;
  return parsed;
}

void addStringIfNotEmpty(Map<String, dynamic> json, String key, String? value) {
  final trimmedValue = value?.trim();
  if (trimmedValue != null && trimmedValue.isNotEmpty) {
    json[key] = trimmedValue;
  }
}
