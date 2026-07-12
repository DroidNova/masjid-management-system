class UpdateCommunityUserRequest {
  const UpdateCommunityUserRequest({
    required this.fullName,
    required this.phone,
    this.email,
  });

  final String fullName;
  final String phone;
  final String? email;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'fullName': fullName.trim(),
      'phone': phone.trim(),
    };
    final trimmedEmail = email?.trim();
    if (trimmedEmail != null && trimmedEmail.isNotEmpty) json['email'] = trimmedEmail;
    return json;
  }
}
