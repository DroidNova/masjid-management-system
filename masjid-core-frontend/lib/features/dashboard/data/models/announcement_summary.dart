import 'package:platform_core_frontend/features/dashboard/data/models/model_parsing.dart';

class AnnouncementSummary {
  const AnnouncementSummary({this.id, this.title, this.message, this.createdAt});

  factory AnnouncementSummary.fromJson(Map<String, dynamic> json) {
    return AnnouncementSummary(
      id: parseString(json['id']),
      title: parseString(json['title']),
      message: parseString(json['message']),
      createdAt: parseString(json['createdAt']),
    );
  }

  final String? id;
  final String? title;
  final String? message;
  final String? createdAt;
}
