class CommitteeMemberInput {
  const CommitteeMemberInput({
    required this.name,
    required this.phone,
  });

  final String name;
  final String phone;

  bool get isEmpty => name.trim().isEmpty && phone.trim().isEmpty;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    _addIfNotEmpty(json, 'name', name);
    _addIfNotEmpty(json, 'phone', phone);
    return json;
  }

  CommitteeMemberInput copyWith({String? name, String? phone}) {
    return CommitteeMemberInput(
      name: name ?? this.name,
      phone: phone ?? this.phone,
    );
  }

  void _addIfNotEmpty(Map<String, dynamic> json, String key, String value) {
    final trimmedValue = value.trim();
    if (trimmedValue.isNotEmpty) {
      json[key] = trimmedValue;
    }
  }
}
