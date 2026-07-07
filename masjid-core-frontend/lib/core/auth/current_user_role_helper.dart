import 'package:platform_core_frontend/core/permissions/permission_helper.dart';
import 'package:platform_core_frontend/features/auth/data/models/app_user.dart';

class CurrentUserRoleHelper {
  const CurrentUserRoleHelper._();

  static const String superAdmin = 'SUPER_ADMIN';
  static const String masjidAdmin = 'MASJID_ADMIN';
  static const String committeeMember = 'COMMITTEE_MEMBER';
  static const String imam = 'IMAM';
  static const String member = 'MEMBER';

  static bool hasRole(AppUser user, String role) {
    return PermissionHelper.hasRole(user, role);
  }

  static bool canAddUsers(AppUser user) {
    return PermissionHelper.canAddCommunityUser(user.roles);
  }

  static List<String> allowedRolesToCreate(AppUser user) {
    return PermissionHelper.allowedCommunityRolesToCreate(user.roles);
  }

  static String roleLabel(String role) {
    switch (role) {
      case member:
        return 'Member';
      case imam:
        return 'Imam';
      case committeeMember:
        return 'Committee Member';
      default:
        return role;
    }
  }
}
