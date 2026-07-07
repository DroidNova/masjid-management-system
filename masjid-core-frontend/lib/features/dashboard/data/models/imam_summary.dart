import 'package:platform_core_frontend/features/dashboard/data/models/model_parsing.dart';

class ImamSummary {
  const ImamSummary({this.id, this.fullName, this.email, this.phone});

  factory ImamSummary.fromJson(Map<String, dynamic> json) {
    return ImamSummary(
      id: parseString(json['id']),
      fullName: parseString(json['fullName']),
      email: parseString(json['email']),
      phone: parseString(json['phone']),
    );
  }

  final String? id;
  final String? fullName;
  final String? email;
  final String? phone;
}
