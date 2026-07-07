import 'package:platform_core_frontend/features/dashboard/data/models/model_parsing.dart';

class MasjidSummary {
  const MasjidSummary({
    this.id,
    this.name,
    this.village,
    this.city,
    this.district,
    this.state,
    this.address,
    this.contactNo,
    this.description,
    this.welcomeMsg,
    this.status,
  });

  factory MasjidSummary.fromJson(Map<String, dynamic> json) {
    return MasjidSummary(
      id: parseString(json['id']),
      name: parseString(json['name']),
      village: parseString(json['village']),
      city: parseString(json['city']),
      district: parseString(json['district']),
      state: parseString(json['state']),
      address: parseString(json['address']),
      contactNo: parseString(json['contactNo']),
      description: parseString(json['description']),
      welcomeMsg: parseString(json['welcomeMsg']),
      status: parseString(json['status']),
    );
  }

  final String? id;
  final String? name;
  final String? village;
  final String? city;
  final String? district;
  final String? state;
  final String? address;
  final String? contactNo;
  final String? description;
  final String? welcomeMsg;
  final String? status;
}
