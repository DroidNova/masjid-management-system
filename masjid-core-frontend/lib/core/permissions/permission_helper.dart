import 'package:platform_core_frontend/features/auth/data/models/app_user.dart';

class PermissionHelper {
  const PermissionHelper._();

  static const String superAdmin = 'SUPER_ADMIN';
  static const String masjidAdmin = 'MASJID_ADMIN';
  static const String imam = 'IMAM';
  static const String committeeMember = 'COMMITTEE_MEMBER';
  static const String member = 'MEMBER';

  static bool hasRole(AppUser? user, String role) {
    return hasRoleInList(user?.roles ?? const <String>[], role);
  }

  static bool hasRoleInList(List<String> roles, String role) {
    return roles.map((value) => value.toUpperCase()).contains(role.toUpperCase());
  }

  static bool isSuperAdmin(AppUser? user) => hasRole(user, superAdmin);

  static bool canViewMainApp(List<String> roles) {
    return hasRoleInList(roles, masjidAdmin) ||
        hasRoleInList(roles, imam) ||
        hasRoleInList(roles, committeeMember) ||
        hasRoleInList(roles, member) ||
        hasRoleInList(roles, superAdmin);
  }

  static bool canManageFinance(List<String> roles) {
    return hasRoleInList(roles, masjidAdmin) || hasRoleInList(roles, committeeMember) || hasRoleInList(roles, superAdmin);
  }

  static bool canManageProjects(List<String> roles) => canManageFinance(roles);

  static bool canManageAnnouncements(List<String> roles) {
    return hasRoleInList(roles, masjidAdmin) ||
        hasRoleInList(roles, committeeMember) ||
        hasRoleInList(roles, imam) ||
        hasRoleInList(roles, superAdmin);
  }

  static bool canUpdateNamazTime(List<String> roles) => canManageAnnouncements(roles);

  static bool canManageImamSalary(List<String> roles) => canManageFinance(roles);

  static bool canAddCommunityUser(List<String> roles) => allowedCommunityRolesToCreate(roles).isNotEmpty;

  static List<String> allowedCommunityRolesToCreate(List<String> roles) {
    if (hasRoleInList(roles, superAdmin) || hasRoleInList(roles, masjidAdmin)) {
      return const <String>[imam, committeeMember];
    }
    if (hasRoleInList(roles, committeeMember)) return const <String>[member];
    return const <String>[];
  }

  static bool canManageCommunityUser({
    required List<String> currentUserRoles,
    required List<String> targetUserRoles,
  }) {
    if (hasRoleInList(targetUserRoles, superAdmin) || hasRoleInList(targetUserRoles, masjidAdmin)) {
      return false;
    }
    if (hasRoleInList(currentUserRoles, superAdmin) || hasRoleInList(currentUserRoles, masjidAdmin)) {
      return hasRoleInList(targetUserRoles, imam) || hasRoleInList(targetUserRoles, committeeMember);
    }
    if (hasRoleInList(currentUserRoles, committeeMember)) {
      return hasRoleInList(targetUserRoles, member);
    }
    return false;
  }

  static bool canEditCommunityUser({required List<String> currentUserRoles, required List<String> targetUserRoles}) {
    return canManageCommunityUser(currentUserRoles: currentUserRoles, targetUserRoles: targetUserRoles);
  }

  static bool canChangeCommunityUserStatus({required List<String> currentUserRoles, required List<String> targetUserRoles}) {
    return canManageCommunityUser(currentUserRoles: currentUserRoles, targetUserRoles: targetUserRoles);
  }
}
