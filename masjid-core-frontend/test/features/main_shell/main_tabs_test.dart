import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/features/main_shell/main_tabs.dart';

const _member = <String>[
  AppPermissions.dashboardRead,
  AppPermissions.announcementsRead,
  AppPermissions.financeRead,
  AppPermissions.projectsRead,
  AppPermissions.ownContributionsRead,
  AppPermissions.masjidLeave,
];

const _imam = <String>[
  AppPermissions.dashboardRead,
  AppPermissions.namazTimesUpdate,
  AppPermissions.announcementsManage,
  AppPermissions.imamSalaryRead,
];

const _committee = <String>[
  AppPermissions.dashboardRead,
  AppPermissions.namazTimesUpdate,
  AppPermissions.announcementsManage,
  AppPermissions.collectionsManage,
  AppPermissions.expensesManage,
  AppPermissions.projectsManage,
  AppPermissions.membersManage,
];

void main() {
  test('committee: Home, Money, Projects, People, Profile', () {
    expect(mainTabsFor(_committee), <MainTab>[
      MainTab.home,
      MainTab.money,
      MainTab.projects,
      MainTab.people,
      MainTab.profile,
    ]);
  });

  test('imam: Home, Times, News, Profile', () {
    expect(mainTabsFor(_imam), <MainTab>[
      MainTab.home,
      MainTab.times,
      MainTab.news,
      MainTab.profile,
    ]);
  });

  test('member: Home, News, My payments, Profile', () {
    expect(mainTabsFor(_member), <MainTab>[
      MainTab.home,
      MainTab.news,
      MainTab.myPayments,
      MainTab.profile,
    ]);
  });

  test('Profile is always last and there are never more than five', () {
    for (final permissions in <List<String>>[
      _member,
      _imam,
      _committee,
      const <String>[],
    ]) {
      final tabs = mainTabsFor(permissions);
      expect(tabs.last, MainTab.profile);
      expect(tabs.length, lessThanOrEqualTo(5));
    }
  });

  test('each tab knows its router branch (the enum order)', () {
    expect(MainTab.home.branch, 0);
    expect(MainTab.profile.branch, MainTab.values.length - 1);
    expect(MainTab.values.map((tab) => tab.path).toSet(), hasLength(8));
  });
}
