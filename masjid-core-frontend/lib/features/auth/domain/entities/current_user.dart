class CurrentUser {
  const CurrentUser({
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
    this.displayName,
  });

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
  final String? displayName;
  final List<String> roles;
  final List<String> permissions;
}
