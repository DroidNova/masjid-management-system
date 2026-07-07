class MasjidDetailModel {
  const MasjidDetailModel({
    required this.id,
    required this.name,
    this.village,
    this.city,
    this.district,
    this.state,
    this.address,
    this.contactNo,
    this.description,
    this.welcomeMsg,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory MasjidDetailModel.fromJson(Map<String, dynamic> json) {
    return MasjidDetailModel(
      id: _string(json['id']),
      name: _string(json['name'], fallback: 'Masjid'),
      village: _optionalString(json['village']),
      city: _optionalString(json['city']),
      district: _optionalString(json['district']),
      state: _optionalString(json['state']),
      address: _optionalString(json['address']),
      contactNo: _optionalString(json['contactNo']),
      description: _optionalString(json['description']),
      welcomeMsg: _optionalString(json['welcomeMsg']),
      status: _optionalString(json['status']),
      createdAt: _optionalString(json['createdAt']),
      updatedAt: _optionalString(json['updatedAt']),
    );
  }

  final String id;
  final String name;
  final String? village;
  final String? city;
  final String? district;
  final String? state;
  final String? address;
  final String? contactNo;
  final String? description;
  final String? welcomeMsg;
  final String? status;
  final String? createdAt;
  final String? updatedAt;
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
