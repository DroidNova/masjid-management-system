import 'package:flutter/widgets.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// Every page that can be a tab of the masjid app. The order is the order
/// of the router's shell branches (app/router.dart); which ones show as
/// tabs depends on the person (see [mainTabsFor]).
enum MainTab {
  home('/main/home', AppIcons.home),
  money('/main/finance', AppIcons.money),
  projects('/main/projects', AppIcons.projects),
  people('/main/community', AppIcons.people),
  news('/main/news', AppIcons.announcements),
  times('/main/times', AppIcons.fajr),
  myPayments('/main/my-payments', AppIcons.myPayments),
  profile('/main/profile', AppIcons.profile);

  const MainTab(this.path, this.icon);

  final String path;
  final IconData icon;

  /// Its branch in the router's StatefulShellRoute.
  int get branch => index;

  /// One word (rule 2).
  String label(AppLocalizations l10n) => switch (this) {
    home => l10n.tabHome,
    money => l10n.tabMoney,
    projects => l10n.tabProjects,
    people => l10n.tabPeople,
    news => l10n.tabNews,
    times => l10n.tabTimes,
    myPayments => l10n.tabMyPayments,
    profile => l10n.tabProfile,
  };
}

/// The tabs a person sees, decided by permissions (never role names), with
/// Profile always last (UI_REDESIGN_PLAN.md, section 4):
/// - money managers (committee): Home, Money, Projects, People, Profile
/// - namaz time editors (imam): Home, Times, News, Profile
/// - everyone else (members): Home, News, My payments, Profile
List<MainTab> mainTabsFor(List<String> permissions) {
  if (PermissionHelper.canManageFinance(permissions)) {
    return const <MainTab>[
      MainTab.home,
      MainTab.money,
      MainTab.projects,
      MainTab.people,
      MainTab.profile,
    ];
  }
  if (PermissionHelper.canUpdateNamazTime(permissions)) {
    return const <MainTab>[
      MainTab.home,
      MainTab.times,
      MainTab.news,
      MainTab.profile,
    ];
  }
  return <MainTab>[
    MainTab.home,
    MainTab.news,
    if (PermissionHelper.canViewOwnContributions(permissions))
      MainTab.myPayments
    else
      MainTab.projects,
    MainTab.profile,
  ];
}
