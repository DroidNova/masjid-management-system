import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/config/api_config.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/core/settings/app_settings.dart';
import 'package:masjid_core_frontend/features/announcements/data/models/announcement_model.dart';
import 'package:masjid_core_frontend/features/announcements/presentation/add_announcement_screen.dart';
import 'package:masjid_core_frontend/features/announcements/presentation/announcements_screen.dart';
import 'package:masjid_core_frontend/features/announcements/presentation/edit_announcement_screen.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/auth/data/models/login_start_response.dart';
import 'package:masjid_core_frontend/features/auth/presentation/auth_landing_screen.dart';
import 'package:masjid_core_frontend/features/auth/presentation/login_password_screen.dart';
import 'package:masjid_core_frontend/features/auth/presentation/login_phone_screen.dart';
import 'package:masjid_core_frontend/features/auth/presentation/otp_screen.dart';
import 'package:masjid_core_frontend/features/community/presentation/add_community_user_screen.dart';
import 'package:masjid_core_frontend/features/community/presentation/community_screen.dart';
import 'package:masjid_core_frontend/features/contributions/presentation/collection_contributions_screen.dart';
import 'package:masjid_core_frontend/features/contributions/presentation/imam_salary_payment_history_screen.dart';
import 'package:masjid_core_frontend/features/contributions/presentation/my_contributions_screen.dart';
import 'package:masjid_core_frontend/features/contributions/presentation/project_contributions_screen.dart';
import 'package:masjid_core_frontend/features/dashboard/data/models/namaz_time_summary.dart';
import 'package:masjid_core_frontend/features/dashboard/presentation/home_dashboard_screen.dart';
import 'package:masjid_core_frontend/features/dev_gallery/presentation/design_gallery_screen.dart';
import 'package:masjid_core_frontend/features/finance/presentation/add_collection_screen.dart';
import 'package:masjid_core_frontend/features/finance/presentation/add_expense_screen.dart';
import 'package:masjid_core_frontend/features/finance/presentation/finance_screen.dart';
import 'package:masjid_core_frontend/features/imam_salary/presentation/imam_salary_screen.dart';
import 'package:masjid_core_frontend/features/language/presentation/language_screen.dart';
import 'package:masjid_core_frontend/features/main_shell/presentation/main_shell_screen.dart';
import 'package:masjid_core_frontend/features/masjid_request/presentation/masjid_request_form_screen.dart';
import 'package:masjid_core_frontend/features/masjid_request/presentation/masjid_request_submitted_screen.dart';
import 'package:masjid_core_frontend/features/masjid_request/presentation/track_masjid_application_screen.dart';
import 'package:masjid_core_frontend/features/namaz_time/data/models/namaz_time_model.dart';
import 'package:masjid_core_frontend/features/namaz_time/presentation/namaz_times_screen.dart';
import 'package:masjid_core_frontend/features/namaz_time/presentation/update_namaz_time_screen.dart';
import 'package:masjid_core_frontend/features/profile/presentation/change_password_screen.dart';
import 'package:masjid_core_frontend/features/profile/presentation/profile_screen.dart';
import 'package:masjid_core_frontend/features/projects/data/models/project_model.dart';
import 'package:masjid_core_frontend/features/projects/presentation/add_project_screen.dart';
import 'package:masjid_core_frontend/features/projects/presentation/edit_project_screen.dart';
import 'package:masjid_core_frontend/features/projects/presentation/project_detail_screen.dart';
import 'package:masjid_core_frontend/features/projects/presentation/projects_screen.dart';
import 'package:masjid_core_frontend/features/splash/presentation/splash_screen.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_masjid_model.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_masjid_request_model.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_user_model.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/masjid_requests/admin_masjid_request_detail_screen.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/masjid_requests/admin_masjid_requests_screen.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/masjids/admin_masjid_detail_screen.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/masjids/admin_masjids_screen.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/super_admin_dashboard_screen.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/super_admin_shell_screen.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/users/admin_user_detail_screen.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/users/admin_users_screen.dart';
import 'package:masjid_core_frontend/shared/widgets/permission_gate.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Pages anyone can open without logging in.
const Set<String> publicLocations = <String>{
  '/auth',
  '/login-phone',
  '/login-password',
  '/login-otp',
  '/masjid-request',
  '/masjid-request/submitted',
  '/masjid-request/track',
  designGalleryLocation,
  languageLocation,
};

/// The language picker; shown first until a language is chosen.
const String languageLocation = '/language';

/// Design-system gallery; registered only outside production builds.
const String designGalleryLocation = '/dev/gallery';

/// Login pages: a signed-in user is sent home from these.
const Set<String> _loginLocations = <String>{
  '/auth',
  '/login-phone',
  '/login-password',
  '/login-otp',
};

/// Decides where to send the user for [uri] given the auth [state].
/// Returns null to stay. Kept free of Flutter so it is easy to test.
String? authRedirect(AuthState state, Uri uri) {
  final path = uri.path;

  switch (state) {
    case AuthUnknown():
      // Wait on the splash screen; remember where the user wanted to go.
      if (path == '/splash') return null;
      return Uri(
        path: '/splash',
        queryParameters: <String, String>{'from': uri.toString()},
      ).toString();

    case AuthSignedOut():
      if (publicLocations.contains(path)) return null;
      // Back to the public page they opened or refreshed (website), except
      // the mid-login steps, whose data a refresh loses.
      final from = path == '/splash' ? uri.queryParameters['from'] : null;
      final fromPath = from == null ? null : Uri.parse(from).path;
      if (fromPath != null &&
          publicLocations.contains(fromPath) &&
          fromPath != '/login-otp' &&
          fromPath != '/login-password') {
        return from;
      }
      return '/auth';

    case AuthSignedIn(:final user):
      final home = homeLocationFor(user);
      if (path == '/splash') {
        final from = uri.queryParameters['from'];
        final canResume =
            from != null &&
            from.startsWith('/') &&
            !from.startsWith('/splash') &&
            !_loginLocations.contains(Uri.parse(from).path);
        return canResume ? from : home;
      }
      if (_loginLocations.contains(path) || path == '/' || path == '/main') {
        return home;
      }
      final isSuperAdmin = PermissionHelper.isSuperAdmin(user);
      if (path.startsWith('/super-admin') && !isSuperAdmin) return home;
      // Super admins have no masjid, so the masjid app does not apply.
      if (path.startsWith('/main') && isSuperAdmin) return home;
      return null;
  }
}

/// Re-runs the router's redirect whenever the auth state changes.
class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(Ref ref) {
    ref.listen<AuthState>(
      authControllerProvider,
      (previous, next) => notifyListeners(),
    );
  }
}

/// Sends people who have not chosen a language yet to the language picker
/// first (UI_REDESIGN_PLAN.md, rule 12), then on to [target]: where the
/// auth redirect wanted to go, or the requested page. The splash screen and
/// the gallery are left alone. Returns null to stay.
String? languageRedirect({
  required bool hasChosenLanguage,
  required Uri uri,
  String? target,
}) {
  if (hasChosenLanguage) return target;
  final next = Uri.parse(target ?? uri.toString());
  if (next.path == languageLocation ||
      next.path == '/splash' ||
      next.path == designGalleryLocation) {
    return target;
  }
  return Uri(
    path: languageLocation,
    queryParameters: <String, String>{'from': next.toString()},
  ).toString();
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRefresh(ref);
  ref.onDispose(refresh.dispose);
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) => languageRedirect(
      hasChosenLanguage: ref.read(appSettingsProvider).hasChosenLanguage,
      uri: state.uri,
      target: authRedirect(ref.read(authControllerProvider), state.uri),
    ),
    routes: _routes,
  );
});

final List<RouteBase> _routes = <RouteBase>[
  GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
  if (!ApiConfig.isProduction)
    GoRoute(
      path: designGalleryLocation,
      builder: (context, state) => const DesignGalleryScreen(),
    ),
  GoRoute(
    path: '/profile/password',
    builder: (context, state) => const ChangePasswordScreen(),
  ),
  GoRoute(
    path: languageLocation,
    builder: (context, state) =>
        LanguageScreen(from: state.uri.queryParameters['from']),
  ),
  GoRoute(
    path: '/auth',
    builder: (context, state) => const AuthLandingScreen(),
  ),
  GoRoute(
    path: '/login-phone',
    builder: (context, state) => const LoginPhoneScreen(),
  ),
  GoRoute(
    path: '/login-password',
    builder: (context, state) {
      final extra = _readExtraMap(state.extra);
      final phone = extra?['phone'];

      if (phone == null || phone.isEmpty) {
        return const _MissingLoginDataScreen();
      }

      return LoginPasswordScreen(phone: phone);
    },
  ),
  GoRoute(
    path: '/login-otp',
    builder: (context, state) {
      final extra = _readExtraMap(state.extra);
      final phone = extra?['phone'];
      final challengeId = extra?['challengeId'];

      if (phone == null ||
          phone.isEmpty ||
          challengeId == null ||
          challengeId.isEmpty) {
        return const _MissingLoginDataScreen();
      }

      return OtpScreen(
        phone: phone,
        challengeId: challengeId,
        otpLength:
            int.tryParse(extra?['otpLength'] ?? '') ??
            LoginStartResponse.defaultOtpLength,
      );
    },
  ),
  GoRoute(
    path: '/masjid-request',
    builder: (context, state) => const MasjidRequestFormScreen(),
  ),
  GoRoute(
    path: '/masjid-request/submitted',
    builder: (context, state) => const MasjidRequestSubmittedScreen(),
  ),
  GoRoute(
    path: '/masjid-request/track',
    builder: (context, state) => const TrackMasjidApplicationScreen(),
  ),
  GoRoute(
    path: '/community/add-user',
    builder: (context, state) => const PermissionGate(
      isAllowed: PermissionHelper.canAddCommunityUser,
      child: AddCommunityUserScreen(),
    ),
  ),
  GoRoute(
    path: '/finance/add-collection',
    builder: (context, state) => const PermissionGate(
      isAllowed: PermissionHelper.canManageFinance,
      child: AddCollectionScreen(),
    ),
  ),
  GoRoute(
    path: '/finance/add-expense',
    builder: (context, state) => const PermissionGate(
      isAllowed: PermissionHelper.canManageFinance,
      child: AddExpenseScreen(),
    ),
  ),

  GoRoute(
    path: '/projects/:id/contributions',
    builder: (context, state) => ProjectContributionsScreen(
      projectId: state.pathParameters['id'] ?? '',
      // The project screen passes the title; a fresh URL loads it by id.
      projectTitle: state.extra is String ? state.extra! as String : null,
    ),
  ),
  GoRoute(
    path: '/finance/collection-contributions',
    builder: (context, state) => const CollectionContributionsScreen(),
  ),
  GoRoute(
    path: '/contributions',
    builder: (context, state) => const MyContributionsScreen(),
  ),
  GoRoute(
    path: '/contributions/imam-salary/:month/:year/payments',
    builder: (context, state) {
      final month = int.tryParse(state.pathParameters['month'] ?? '');
      final year = int.tryParse(state.pathParameters['year'] ?? '');
      if (month == null || year == null || month < 1 || month > 12) {
        return const _InvalidRouteParametersScreen();
      }
      return ImamSalaryPaymentHistoryScreen(month: month, year: year);
    },
  ),

  GoRoute(
    path: '/imam-salaries',
    builder: (context, state) => const ImamSalaryScreen(),
  ),

  GoRoute(
    path: '/announcements',
    builder: (context, state) => const AnnouncementsScreen(),
  ),
  GoRoute(
    path: '/announcements/add',
    builder: (context, state) => const PermissionGate(
      isAllowed: PermissionHelper.canManageAnnouncements,
      child: AddAnnouncementScreen(),
    ),
  ),
  GoRoute(
    path: '/announcements/:id/edit',
    builder: (context, state) {
      final announcementId = state.pathParameters['id'] ?? '';
      final extra = state.extra;
      final announcement = extra is AnnouncementModel ? extra : null;
      return PermissionGate(
        isAllowed: PermissionHelper.canManageAnnouncements,
        child: EditAnnouncementScreen(
          announcementId: announcementId,
          announcement: announcement,
        ),
      );
    },
  ),
  GoRoute(
    path: '/namaz-time/update',
    builder: (context, state) {
      // The dashboard passes the times it shows; a fresh URL loads them.
      final extra = state.extra;
      final initial = extra is NamazTimeSummary
          ? NamazTimeModel(
              fajr: extra.fajr,
              zuhr: extra.zuhr,
              asr: extra.asr,
              maghrib: extra.maghrib,
              isha: extra.isha,
              jumma: extra.jumma,
              note: extra.note,
            )
          : null;
      return PermissionGate(
        isAllowed: PermissionHelper.canUpdateNamazTime,
        child: UpdateNamazTimeScreen(initial: initial),
      );
    },
  ),
  GoRoute(
    path: '/projects/add',
    builder: (context, state) => const PermissionGate(
      isAllowed: PermissionHelper.canManageProjects,
      child: AddProjectScreen(),
    ),
  ),
  GoRoute(
    path: '/projects/:id/edit',
    builder: (context, state) {
      final projectId = state.pathParameters['id'] ?? '';
      final extra = state.extra;
      final project = extra is ProjectModel ? extra : null;
      return PermissionGate(
        isAllowed: PermissionHelper.canManageProjects,
        child: EditProjectScreen(projectId: projectId, initialProject: project),
      );
    },
  ),
  GoRoute(
    path: '/projects/:id',
    builder: (context, state) {
      final projectId = state.pathParameters['id'] ?? '';
      final extra = state.extra;
      final project = extra is ProjectModel ? extra : null;
      return ProjectDetailScreen(projectId: projectId, initialProject: project);
    },
  ),

  // ---------------------------------------------------------------- super admin
  StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) => _superAdminOnly(
      SuperAdminShellScreen(navigationShell: navigationShell),
    ),
    branches: <StatefulShellBranch>[
      StatefulShellBranch(
        routes: <RouteBase>[
          GoRoute(
            path: '/super-admin',
            builder: (context, state) => const SuperAdminDashboardScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: <RouteBase>[
          GoRoute(
            path: '/super-admin/requests',
            builder: (context, state) => const AdminMasjidRequestsScreen(),
            routes: <RouteBase>[
              GoRoute(
                path: ':id',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => _superAdminOnly(
                  AdminMasjidRequestDetailScreen(
                    id: state.pathParameters['id'] ?? '',
                    initial: state.extra is AdminMasjidRequestModel
                        ? state.extra as AdminMasjidRequestModel
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      StatefulShellBranch(
        routes: <RouteBase>[
          GoRoute(
            path: '/super-admin/masjids',
            builder: (context, state) => const AdminMasjidsScreen(),
            routes: <RouteBase>[
              GoRoute(
                path: ':id',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => _superAdminOnly(
                  AdminMasjidDetailScreen(
                    id: state.pathParameters['id'] ?? '',
                    initial: state.extra is AdminMasjidModel
                        ? state.extra as AdminMasjidModel
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      StatefulShellBranch(
        routes: <RouteBase>[
          GoRoute(
            path: '/super-admin/users',
            builder: (context, state) => const AdminUsersScreen(),
            routes: <RouteBase>[
              GoRoute(
                path: ':id',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => _superAdminOnly(
                  AdminUserDetailScreen(
                    id: state.pathParameters['id'] ?? '',
                    initial: state.extra is AdminUserModel
                        ? state.extra as AdminUserModel
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      StatefulShellBranch(
        routes: <RouteBase>[
          GoRoute(
            path: '/super-admin/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  ),

  // ---------------------------------------------------------------- masjid app
  StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) =>
        MainShellScreen(navigationShell: navigationShell),
    branches: <StatefulShellBranch>[
      StatefulShellBranch(
        routes: <RouteBase>[
          GoRoute(
            path: '/main/home',
            builder: (context, state) => const HomeDashboardScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: <RouteBase>[
          GoRoute(
            path: '/main/finance',
            builder: (context, state) => const FinanceScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: <RouteBase>[
          GoRoute(
            path: '/main/projects',
            builder: (context, state) => const ProjectsScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: <RouteBase>[
          GoRoute(
            path: '/main/community',
            builder: (context, state) => const CommunityScreen(),
          ),
        ],
      ),
      // The branches above and below follow MainTab's order
      // (features/main_shell/main_tabs.dart); which show as tabs depends
      // on the person.
      StatefulShellBranch(
        routes: <RouteBase>[
          GoRoute(
            path: '/main/news',
            builder: (context, state) => const AnnouncementsScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: <RouteBase>[
          GoRoute(
            path: '/main/times',
            builder: (context, state) => const NamazTimesScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: <RouteBase>[
          GoRoute(
            path: '/main/my-payments',
            builder: (context, state) => const MyContributionsScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: <RouteBase>[
          GoRoute(
            path: '/main/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  ),
];

/// Super admin screens need platform permissions (the redirect already keeps
/// other users out; this also covers a stale stored user).
Widget _superAdminOnly(Widget child) => PermissionGate(
  isAllowed: (permissions) =>
      permissions.contains(AppPermissions.platformUsersRead),
  child: child,
);

class _InvalidRouteParametersScreen extends StatelessWidget {
  const _InvalidRouteParametersScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Invalid contribution period.')),
    );
  }
}

Map<String, String>? _readExtraMap(Object? extra) {
  if (extra is Map<String, String>) return extra;
  if (extra is Map<String, dynamic>) {
    return extra.map((key, value) => MapEntry(key, value?.toString() ?? ''));
  }

  return null;
}

class _MissingLoginDataScreen extends StatelessWidget {
  const _MissingLoginDataScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Login information is missing. Please start again.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go('/login-phone'),
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
