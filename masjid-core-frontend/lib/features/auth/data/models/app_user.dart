class AppUser {
  const AppUser({
    required this.id,
    required this.fullName,
    required this.roles,
    required this.permissions,
    this.email,
    this.phone,
    this.status,
    this.masjidId,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.createdAt,
    this.updatedAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      status: json['status']?.toString(),
      masjidId: json['masjidId']?.toString(),
      isEmailVerified: _readBool(json['isEmailVerified']),
      isPhoneVerified: _readBool(json['isPhoneVerified']),
      createdAt: _readDateTime(json['createdAt']),
      updatedAt: _readDateTime(json['updatedAt']),
      roles: (json['roles'] as List<dynamic>? ?? const <dynamic>[])
          .map((role) => role.toString())
          .toList(),
      permissions:
          (json['permissions'] as List<dynamic>? ?? const <dynamic>[])
              .map((permission) => permission.toString())
              .toList(),
    );
  }

  final String id;
  final String fullName;
  final String? email;
  final String? phone;
  final String? status;
  final String? masjidId;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<String> roles;
  final List<String> permissions;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'status': status,
      'masjidId': masjidId,
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'roles': roles,
      'permissions': permissions,
    };
  }

  static bool _readBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().toLowerCase();
    return text == 'true' || text == '1';
  }

  static DateTime? _readDateTime(dynamic value) {
    if (value is DateTime) return value;
    final text = value?.toString();
    if (text == null || text.isEmpty) return null;
    return DateTime.tryParse(text);
  }
}
