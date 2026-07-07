class AnnouncementModel {
  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.message,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      isActive: json['isActive'] is bool ? json['isActive'] as bool : true,
      createdAt: _optionalString(json['createdAt']),
      updatedAt: _optionalString(json['updatedAt']),
    );
  }

  final String id;
  final String title;
  final String message;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;
}

String? _optionalString(Object? value) {
  final parsed = value?.toString();
  if (parsed == null || parsed.trim().isEmpty) return null;
  return parsed;
}
