import 'package:masjid_core_frontend/features/auth/data/models/app_user.dart';

/// Permission names sent by the server in `user.permissions` at login and
/// from `/auth/me`. Must match `masjid-core/src/access/permissions.ts`.
///
/// Who has which permission is decided only on the server. To change it,
/// edit that file; the app follows automatically after the next login.
class AppPermissions {
  const AppPermissions._();

  static const String dashboardRead = 'dashboard.read';
  static const String masjidRead = 'masjid.read';
  static const String masjidUpdate = 'masjid.update';
  static const String masjidLeave = 'masjid.leave';
  static const String namazTimesRead = 'namaz_times.read';
  static const String namazTimesUpdate = 'namaz_times.update';
  static const String announcementsRead = 'announcements.read';
  static const String announcementsManage = 'announcements.manage';
  static const String membersRead = 'members.read';
  static const String membersManage = 'members.manage';
  static const String membersContactRead = 'members.contact.read';
  static const String financeRead = 'finance.read';
  static const String collectionsManage = 'collections.manage';
  static const String expensesManage = 'expenses.manage';
  static const String projectsRead = 'projects.read';
  static const String projectsManage = 'projects.manage';
  static const String contributionsRead = 'contributions.read';
  static const String contributionsRecord = 'contributions.record';
  static const String ownContributionsRead = 'own_contributions.read';
  static const String imamSalaryRead = 'imam_salary.read';
  static const String imamSalaryManage = 'imam_salary.manage';
  static const String platformUsersRead = 'platform.users.read';
  static const String platformUsersManage = 'platform.users.manage';
  static const String platformRolesAssign = 'platform.roles.assign';
  static const String platformMasjidsManage = 'platform.masjids.manage';
  static const String platformMasjidRequestsManage =
      'platform.masjid_requests.manage';
}

/// UI decisions based on the signed-in user's permissions.
///
/// Every `can...` method takes the user's permission list
/// (`AppUser.permissions`), never role names. Role names are only used to
/// pick the super admin shell and to label other users.
class PermissionHelper {
  const PermissionHelper._();

  // Role names, for labels and for reading other users' roles.
  static const String superAdmin = 'SUPER_ADMIN';
  static const String masjidAdmin = 'MASJID_ADMIN';
  static const String imam = 'IMAM';
  static const String committeeMember = 'COMMITTEE_MEMBER';
  static const String member = 'MEMBER';

  static bool has(AppUser? user, String permission) =>
      user?.permissions.contains(permission) ?? false;

  static bool hasIn(List<String> permissions, String permission) =>
      permissions.contains(permission);

  static bool hasRole(AppUser? user, String role) =>
      hasRoleInList(user?.roles ?? const <String>[], role);

  static bool hasRoleInList(List<String> roles, String role) =>
      roles.map((value) => value.toUpperCase()).contains(role.toUpperCase());

  /// Imam, committee, and admin accounts log in with a password and can
  /// change it; members log in with a code only. Mirrors PRIVILEGED_ROLES
  /// in masjid-core auth.service.ts (an account type, not a permission).
  static bool hasPassword(AppUser? user) => <String>[
    superAdmin,
    masjidAdmin,
    imam,
    committeeMember,
  ].any((role) => hasRole(user, role));

  /// Super admins use a separate admin shell instead of the masjid app.
  static bool isSuperAdmin(AppUser? user) => hasRole(user, superAdmin);

  static bool canViewMainApp(List<String> permissions) =>
      hasIn(permissions, AppPermissions.dashboardRead);

  static bool canManageFinance(List<String> permissions) =>
      hasIn(permissions, AppPermissions.collectionsManage) ||
      hasIn(permissions, AppPermissions.expensesManage);

  static bool canManageCollections(List<String> permissions) =>
      hasIn(permissions, AppPermissions.collectionsManage);

  static bool canManageExpenses(List<String> permissions) =>
      hasIn(permissions, AppPermissions.expensesManage);

  static bool canManageProjects(List<String> permissions) =>
      hasIn(permissions, AppPermissions.projectsManage);

  static bool canRecordContributions(List<String> permissions) =>
      hasIn(permissions, AppPermissions.contributionsRecord);

  static bool canViewOwnContributions(List<String> permissions) =>
      hasIn(permissions, AppPermissions.ownContributionsRead);

  static bool canManageAnnouncements(List<String> permissions) =>
      hasIn(permissions, AppPermissions.announcementsManage);

  static bool canUpdateNamazTime(List<String> permissions) =>
      hasIn(permissions, AppPermissions.namazTimesUpdate);

  static bool canViewImamSalary(List<String> permissions) =>
      hasIn(permissions, AppPermissions.imamSalaryRead);

  static bool canManageImamSalary(List<String> permissions) =>
      hasIn(permissions, AppPermissions.imamSalaryManage);

  static bool canAddCommunityUser(List<String> permissions) =>
      allowedCommunityRolesToCreate(permissions).isNotEmpty;

  /// Super admin appoints imams and committee members; the committee adds
  /// villagers (MEMBER). Mirrors MasjidsService on the server.
  static List<String> allowedCommunityRolesToCreate(List<String> permissions) {
    if (hasIn(permissions, AppPermissions.platformRolesAssign)) {
      return const <String>[imam, committeeMember, member];
    }
    if (hasIn(permissions, AppPermissions.membersManage)) {
      return const <String>[member];
    }
    return const <String>[];
  }

  static bool canManageCommunityUser({
    required List<String> currentUserPermissions,
    required List<String> targetUserRoles,
  }) {
    if (hasIn(currentUserPermissions, AppPermissions.platformUsersManage)) {
      return true;
    }
    if (!hasIn(currentUserPermissions, AppPermissions.membersManage)) {
      return false;
    }
    final targetIsOnlyMember =
        targetUserRoles.isNotEmpty &&
        targetUserRoles.every((role) => role.toUpperCase() == member);
    return targetIsOnlyMember;
  }

  static bool canEditCommunityUser({
    required List<String> currentUserPermissions,
    required List<String> targetUserRoles,
  }) => canManageCommunityUser(
    currentUserPermissions: currentUserPermissions,
    targetUserRoles: targetUserRoles,
  );

  static bool canChangeCommunityUserStatus({
    required List<String> currentUserPermissions,
    required List<String> targetUserRoles,
  }) => canManageCommunityUser(
    currentUserPermissions: currentUserPermissions,
    targetUserRoles: targetUserRoles,
  );
}
