class ApiEndpoints {
  const ApiEndpoints._();

  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';
  static const String authMe = '/auth/me';

  static const String adminUsers = '/admin/users';

  static String adminUserById(String id) => '/admin/users/$id';
  static String adminUserStatus(String id) => '/admin/users/$id/status';
  static String adminUserRoles(String id) => '/admin/users/$id/roles';
}
