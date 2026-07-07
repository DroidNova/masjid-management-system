class CommunityUserModel {
  const CommunityUserModel({
    required this.id,
    required this.fullName,
    required this.roles,
    this.email,
    this.phone,
    this.status,
    this.masjidId,
    this.message,
    this.temporaryPassword,
    this.createdAt,
    this.updatedAt,
  });

  factory CommunityUserModel.fromJson(Map<String, dynamic> json) {
    return CommunityUserModel(
      id: _string(json['id']),
      fullName: _string(json['fullName'], fallback: 'Community Member'),
      email: _optionalString(json['email']),
      phone: _optionalString(json['phone']),
      status: _optionalString(json['status']),
      masjidId: _optionalString(json['masjidId']),
      message: _optionalString(json['message']),
      temporaryPassword: _optionalString(json['temporaryPassword']),
      roles: (json['roles'] as List<dynamic>? ?? const <dynamic>[])
          .map((role) => role.toString())
          .toList(),
      createdAt: _optionalString(json['createdAt']),
      updatedAt: _optionalString(json['updatedAt']),
    );
  }

  final String id;
  final String fullName;
  final String? email;
  final String? phone;
  final String? status;
  final String? masjidId;
  final String? message;
  final String? temporaryPassword;
  final List<String> roles;
  final String? createdAt;
  final String? updatedAt;

  bool get isImam => roles.contains('IMAM');
  bool get isCommitteeMember => roles.contains('COMMITTEE_MEMBER');
  bool get isMember => roles.contains('MEMBER');
  bool get isMasjidAdmin => roles.contains('MASJID_ADMIN');

  String get primaryRoleLabel {
    if (isMasjidAdmin) return 'Masjid Admin';
    if (isImam) return 'Imam';
    if (isCommitteeMember) return 'Committee Member';
    if (isMember) return 'Member';
    if (roles.contains('SUPER_ADMIN')) return 'Super Admin';
    return 'Member';
  }
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
