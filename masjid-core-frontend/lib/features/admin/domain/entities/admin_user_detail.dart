class AdminUserDetail {
  const AdminUserDetail({
    required this.id,
    required this.email,
    required this.status,
    required this.roles,
    required this.permissions,
    this.name,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String email;
  final String status;
  final List<String> roles;
  final List<String> permissions;
  final String? name;
  final String? createdAt;
  final String? updatedAt;
}
