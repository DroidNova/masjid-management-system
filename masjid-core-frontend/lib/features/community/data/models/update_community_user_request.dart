class UpdateCommunityUserRequest {
  const UpdateCommunityUserRequest({
    required this.fullName,
    required this.phone,
    this.email,
    required this.fatherName,
    required this.age,
    required this.gender,
    this.isFamilyHead,
    this.familyMemberCount,
  });

  final String fullName;
  final String phone;
  final String? email;
  final String fatherName;
  final int age;
  final String gender;
  final bool? isFamilyHead;
  final int? familyMemberCount;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'fullName': fullName.trim(),
      'phone': phone.trim(),
      'fatherName': fatherName.trim(),
      'age': age,
      'gender': gender.trim(),
      if (isFamilyHead != null) 'isFamilyHead': isFamilyHead,
      if (familyMemberCount != null) 'familyMemberCount': familyMemberCount,
    };
    final trimmedEmail = email?.trim();
    if (trimmedEmail != null && trimmedEmail.isNotEmpty) json['email'] = trimmedEmail;
    return json;
  }
}
