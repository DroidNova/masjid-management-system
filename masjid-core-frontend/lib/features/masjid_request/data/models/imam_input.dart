class ImamInput {
  const ImamInput({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.fatherName,
    required this.age,
    required this.gender,
  });

  final String name;
  final String email;
  final String phone;
  final String address;
  final String fatherName;
  final int age;
  final String gender;

  bool get isEmpty =>
      name.trim().isEmpty &&
      email.trim().isEmpty &&
      phone.trim().isEmpty &&
      address.trim().isEmpty &&
      fatherName.trim().isEmpty &&
      gender.trim().isEmpty;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    _addIfNotEmpty(json, 'name', name);
    _addIfNotEmpty(json, 'email', email);
    _addIfNotEmpty(json, 'phone', phone);
    _addIfNotEmpty(json, 'address', address);
    _addIfNotEmpty(json, 'fatherName', fatherName);
    json['age'] = age;
    _addIfNotEmpty(json, 'gender', gender);
    return json;
  }

  void _addIfNotEmpty(Map<String, dynamic> json, String key, String value) {
    final trimmedValue = value.trim();
    if (trimmedValue.isNotEmpty) {
      json[key] = trimmedValue;
    }
  }
}
