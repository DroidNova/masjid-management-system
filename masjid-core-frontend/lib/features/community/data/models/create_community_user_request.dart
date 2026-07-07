class CreateCommunityUserRequest {
  CreateCommunityUserRequest({
    required this.fullName,
    required this.phone,
    this.email,
    required this.role,
    this.masjidId,
  }) {
    if (!_allowedRoles.contains(role.trim())) {
      throw ArgumentError('This role cannot be created from this screen.');
    }
  }

  static const Set<String> _allowedRoles = <String>{
    'MEMBER',
    'IMAM',
    'COMMITTEE_MEMBER',
  };

  final String fullName;
  final String phone;
  final String? email;
  final String role;
  final String? masjidId;

  Map<String, dynamic> toJson() {
    final trimmedEmail = email?.trim();
    final trimmedMasjidId = masjidId?.trim();

    return <String, dynamic>{
      'fullName': fullName.trim(),
      'phone': phone.trim(),
      'role': role.trim(),
      if (trimmedEmail != null && trimmedEmail.isNotEmpty)
        'email': trimmedEmail,
      if (trimmedMasjidId != null && trimmedMasjidId.isNotEmpty)
        'masjidId': trimmedMasjidId,
    };
  }
}
