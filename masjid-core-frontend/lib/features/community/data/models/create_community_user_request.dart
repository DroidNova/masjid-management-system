class CreateCommunityUserRequest {
  CreateCommunityUserRequest({
    required this.fullName,
    required this.phone,
    this.email,
    required this.role,
    required this.fatherName,
    required this.age,
    required this.gender,
    this.isFamilyHead,
    this.familyMemberCount,
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
  final String fatherName;
  final int age;
  final String gender;
  final bool? isFamilyHead;
  final int? familyMemberCount;
  final String? masjidId;

  Map<String, dynamic> toJson() {
    final trimmedEmail = email?.trim();
    final trimmedMasjidId = masjidId?.trim();

    return <String, dynamic>{
      'fullName': fullName.trim(),
      'phone': phone.trim(),
      'role': role.trim(),
      'fatherName': fatherName.trim(),
      'age': age,
      'gender': gender.trim(),
      if (isFamilyHead != null) 'isFamilyHead': isFamilyHead,
      if (familyMemberCount != null) 'familyMemberCount': familyMemberCount,
      if (trimmedEmail != null && trimmedEmail.isNotEmpty)
        'email': trimmedEmail,
      if (trimmedMasjidId != null && trimmedMasjidId.isNotEmpty)
        'masjidId': trimmedMasjidId,
    };
  }
}
