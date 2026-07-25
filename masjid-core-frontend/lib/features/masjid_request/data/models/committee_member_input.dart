class CommitteeMemberInput {
  const CommitteeMemberInput({
    required this.name,
    required this.phone,
    required this.fatherName,
    required this.age,
    required this.gender,
  });

  final String name;
  final String phone;
  final String fatherName;
  final int age;
  final String gender;

  bool get isEmpty => name.trim().isEmpty && phone.trim().isEmpty && fatherName.trim().isEmpty && gender.trim().isEmpty;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    _addIfNotEmpty(json, 'name', name);
    _addIfNotEmpty(json, 'phone', phone);
    _addIfNotEmpty(json, 'fatherName', fatherName);
    json['age'] = age;
    _addIfNotEmpty(json, 'gender', gender);
    return json;
  }

  CommitteeMemberInput copyWith({String? name, String? phone, String? fatherName, int? age, String? gender}) {
    return CommitteeMemberInput(name: name ?? this.name, phone: phone ?? this.phone, fatherName: fatherName ?? this.fatherName, age: age ?? this.age, gender: gender ?? this.gender);
  }

  void _addIfNotEmpty(Map<String, dynamic> json, String key, String value) {
    final trimmedValue = value.trim();
    if (trimmedValue.isNotEmpty) {
      json[key] = trimmedValue;
    }
  }
}
