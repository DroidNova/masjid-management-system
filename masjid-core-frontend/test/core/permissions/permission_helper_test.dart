import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';

// Permission lists as the server sends them for each role
// (masjid-core/src/access/permissions.ts).
const _everyone = <String>[
  AppPermissions.dashboardRead,
  AppPermissions.masjidRead,
  AppPermissions.namazTimesRead,
  AppPermissions.announcementsRead,
  AppPermissions.membersRead,
  AppPermissions.financeRead,
  AppPermissions.projectsRead,
  AppPermissions.ownContributionsRead,
];
const _member = _everyone;
const _imam = <String>[
  ..._everyone,
  AppPermissions.namazTimesUpdate,
  AppPermissions.announcementsManage,
  AppPermissions.imamSalaryRead,
  AppPermissions.contributionsRead,
];
const _committee = <String>[
  ..._everyone,
  AppPermissions.namazTimesUpdate,
  AppPermissions.announcementsManage,
  AppPermissions.masjidUpdate,
  AppPermissions.membersManage,
  AppPermissions.collectionsManage,
  AppPermissions.expensesManage,
  AppPermissions.projectsManage,
  AppPermissions.contributionsRead,
  AppPermissions.contributionsRecord,
  AppPermissions.imamSalaryRead,
  AppPermissions.imamSalaryManage,
];
const _superAdmin = <String>[
  ..._committee,
  AppPermissions.platformUsersRead,
  AppPermissions.platformUsersManage,
  AppPermissions.platformRolesAssign,
  AppPermissions.platformMasjidsManage,
  AppPermissions.platformMasjidRequestsManage,
];

void main() {
  group('PermissionHelper', () {
    test('imam: namaz times and announcements, read-only salary', () {
      expect(PermissionHelper.canUpdateNamazTime(_imam), isTrue);
      expect(PermissionHelper.canManageAnnouncements(_imam), isTrue);
      expect(PermissionHelper.canViewImamSalary(_imam), isTrue);
      expect(PermissionHelper.canManageImamSalary(_imam), isFalse);
      expect(PermissionHelper.canManageFinance(_imam), isFalse);
      expect(PermissionHelper.canManageProjects(_imam), isFalse);
      expect(PermissionHelper.canRecordContributions(_imam), isFalse);
      expect(PermissionHelper.canAddCommunityUser(_imam), isFalse);
    });

    test('committee member manages money, projects and members', () {
      expect(PermissionHelper.canManageFinance(_committee), isTrue);
      expect(PermissionHelper.canManageProjects(_committee), isTrue);
      expect(PermissionHelper.canRecordContributions(_committee), isTrue);
      expect(PermissionHelper.canManageImamSalary(_committee), isTrue);
      expect(PermissionHelper.allowedCommunityRolesToCreate(_committee), [
        PermissionHelper.member,
      ]);
    });

    test('member has no management rights', () {
      expect(PermissionHelper.canViewMainApp(_member), isTrue);
      expect(PermissionHelper.canViewOwnContributions(_member), isTrue);
      expect(PermissionHelper.canManageFinance(_member), isFalse);
      expect(PermissionHelper.canManageAnnouncements(_member), isFalse);
      expect(PermissionHelper.canViewImamSalary(_member), isFalse);
      expect(PermissionHelper.canAddCommunityUser(_member), isFalse);
    });

    test('super admin appoints imams and committee members', () {
      expect(PermissionHelper.allowedCommunityRolesToCreate(_superAdmin), [
        PermissionHelper.imam,
        PermissionHelper.committeeMember,
        PermissionHelper.member,
      ]);
    });

    test('committee member may manage villagers only', () {
      expect(
        PermissionHelper.canManageCommunityUser(
          currentUserPermissions: _committee,
          targetUserRoles: const ['MEMBER'],
        ),
        isTrue,
      );
      expect(
        PermissionHelper.canManageCommunityUser(
          currentUserPermissions: _committee,
          targetUserRoles: const ['IMAM'],
        ),
        isFalse,
      );
      expect(
        PermissionHelper.canManageCommunityUser(
          currentUserPermissions: _imam,
          targetUserRoles: const ['MEMBER'],
        ),
        isFalse,
      );
    });

    test('an empty permission list allows nothing', () {
      expect(PermissionHelper.canViewMainApp(const []), isFalse);
      expect(PermissionHelper.allowedCommunityRolesToCreate(const []), isEmpty);
    });
  });
}
