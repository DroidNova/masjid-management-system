class AdminUserSummary {
  const AdminUserSummary({
    required this.id,
    required this.email,
    required this.status,
    required this.roles,
    this.name,
  });

  final String id;
  final String email;
  final String status;
  final List<String> roles;
  final String? name;
}
