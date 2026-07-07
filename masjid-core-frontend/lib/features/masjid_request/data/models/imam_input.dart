class ImamInput {
  const ImamInput({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
  });

  final String name;
  final String email;
  final String phone;
  final String address;

  bool get isEmpty =>
      name.trim().isEmpty &&
      email.trim().isEmpty &&
      phone.trim().isEmpty &&
      address.trim().isEmpty;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    _addIfNotEmpty(json, 'name', name);
    _addIfNotEmpty(json, 'email', email);
    _addIfNotEmpty(json, 'phone', phone);
    _addIfNotEmpty(json, 'address', address);
    return json;
  }

  void _addIfNotEmpty(Map<String, dynamic> json, String key, String value) {
    final trimmedValue = value.trim();
    if (trimmedValue.isNotEmpty) {
      json[key] = trimmedValue;
    }
  }
}
