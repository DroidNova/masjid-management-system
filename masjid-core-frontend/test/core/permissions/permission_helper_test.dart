import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';

void main() {
  group('PermissionHelper', () {
    test('role matching is case-insensitive', () {
      expect(PermissionHelper.hasRoleInList(['imam'], 'IMAM'), isTrue);
      expect(PermissionHelper.hasRoleInList(['MEMBER'], 'IMAM'), isFalse);
    });

    test('imam can update namaz time and announcements but not finance', () {
      const roles = ['IMAM'];
      expect(PermissionHelper.canUpdateNamazTime(roles), isTrue);
      expect(PermissionHelper.canManageAnnouncements(roles), isTrue);
      expect(PermissionHelper.canManageFinance(roles), isFalse);
      expect(PermissionHelper.canManageImamSalary(roles), isFalse);
    });

    test('committee member manages finance, projects and members', () {
      const roles = ['COMMITTEE_MEMBER'];
      expect(PermissionHelper.canManageFinance(roles), isTrue);
      expect(PermissionHelper.canManageProjects(roles), isTrue);
      expect(PermissionHelper.allowedCommunityRolesToCreate(roles), ['MEMBER']);
    });

    test('member has no management rights', () {
      const roles = ['MEMBER'];
      expect(PermissionHelper.canViewMainApp(roles), isTrue);
      expect(PermissionHelper.canManageFinance(roles), isFalse);
      expect(PermissionHelper.canManageAnnouncements(roles), isFalse);
      expect(PermissionHelper.canAddCommunityUser(roles), isFalse);
    });

    test('committee member may manage members only', () {
      expect(
        PermissionHelper.canManageCommunityUser(
          currentUserRoles: const ['COMMITTEE_MEMBER'],
          targetUserRoles: const ['MEMBER'],
        ),
        isTrue,
      );
      expect(
        PermissionHelper.canManageCommunityUser(
          currentUserRoles: const ['COMMITTEE_MEMBER'],
          targetUserRoles: const ['IMAM'],
        ),
        isFalse,
      );
    });
  });
}
