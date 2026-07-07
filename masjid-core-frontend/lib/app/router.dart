import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:platform_core_frontend/core/permissions/permission_helper.dart';
import 'package:platform_core_frontend/core/storage/session_storage.dart';
import 'package:platform_core_frontend/features/super_admin/models/admin_masjid_model.dart';
import 'package:platform_core_frontend/features/super_admin/models/admin_masjid_request_model.dart';
import 'package:platform_core_frontend/features/super_admin/models/admin_user_model.dart';
import 'package:platform_core_frontend/features/super_admin/presentation/masjid_requests/admin_masjid_request_detail_screen.dart';
import 'package:platform_core_frontend/features/super_admin/presentation/masjids/admin_masjid_detail_screen.dart';
import 'package:platform_core_frontend/features/super_admin/presentation/super_admin_shell_screen.dart';
import 'package:platform_core_frontend/features/super_admin/presentation/users/admin_user_detail_screen.dart';
import 'package:platform_core_frontend/shared/widgets/not_allowed_view.dart';
import 'package:platform_core_frontend/features/announcements/data/models/announcement_model.dart';
import 'package:platform_core_frontend/features/announcements/presentation/add_announcement_screen.dart';
import 'package:platform_core_frontend/features/announcements/presentation/announcements_screen.dart';
import 'package:platform_core_frontend/features/announcements/presentation/edit_announcement_screen.dart';
import 'package:platform_core_frontend/features/auth/presentation/auth_landing_screen.dart';
import 'package:platform_core_frontend/features/auth/presentation/login_password_screen.dart';
import 'package:platform_core_frontend/features/auth/presentation/login_phone_screen.dart';
import 'package:platform_core_frontend/features/auth/presentation/otp_screen.dart';
import 'package:platform_core_frontend/features/community/presentation/add_community_user_screen.dart';
import 'package:platform_core_frontend/features/projects/presentation/projects_screen.dart';
import 'package:platform_core_frontend/features/finance/presentation/finance_screen.dart';
import 'package:platform_core_frontend/features/dashboard/presentation/home_dashboard_screen.dart';
import 'package:platform_core_frontend/features/community/presentation/community_screen.dart';
import 'package:platform_core_frontend/features/finance/presentation/add_collection_screen.dart';
import 'package:platform_core_frontend/features/finance/presentation/add_expense_screen.dart';
import 'package:platform_core_frontend/features/imam_salary/models/imam_salary_model.dart';
import 'package:platform_core_frontend/features/imam_salary/presentation/add_imam_salary_screen.dart';
import 'package:platform_core_frontend/features/imam_salary/presentation/edit_imam_salary_screen.dart';
import 'package:platform_core_frontend/features/imam_salary/presentation/imam_salary_detail_screen.dart';
import 'package:platform_core_frontend/features/imam_salary/presentation/imam_salary_screen.dart';
import 'package:platform_core_frontend/features/main_shell/presentation/main_shell_screen.dart';
import 'package:platform_core_frontend/features/masjid_request/presentation/masjid_request_form_screen.dart';
import 'package:platform_core_frontend/features/namaz_time/presentation/update_namaz_time_screen.dart';
import 'package:platform_core_frontend/features/projects/data/models/project_model.dart';
import 'package:platform_core_frontend/features/projects/presentation/add_project_screen.dart';
import 'package:platform_core_frontend/features/projects/presentation/edit_project_screen.dart';
import 'package:platform_core_frontend/features/projects/presentation/project_detail_screen.dart';
import 'package:platform_core_frontend/features/splash/presentation/splash_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: <RouteBase>[
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
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

        return OtpScreen(phone: phone, challengeId: challengeId);
      },
    ),
    GoRoute(
      path: '/masjid-request',
      builder: (context, state) => const MasjidRequestFormScreen(),
    ),
    GoRoute(
      path: '/community/add-user',
      builder: (context, state) => _RoleGuard(
        isAllowed: PermissionHelper.canAddCommunityUser,
        child: const AddCommunityUserScreen(),
      ),
    ),
    GoRoute(
      path: '/finance/add-collection',
      builder: (context, state) => _RoleGuard(
        isAllowed: PermissionHelper.canManageFinance,
        child: const AddCollectionScreen(),
      ),
    ),
    GoRoute(
      path: '/finance/add-expense',
      builder: (context, state) => _RoleGuard(
        isAllowed: PermissionHelper.canManageFinance,
        child: const AddExpenseScreen(),
      ),
    ),

    GoRoute(
      path: '/imam-salaries',
      builder: (context, state) => const ImamSalaryScreen(),
    ),
    GoRoute(
      path: '/imam-salaries/add',
      builder: (context, state) => _RoleGuard(
        isAllowed: PermissionHelper.canManageImamSalary,
        child: const AddImamSalaryScreen(),
      ),
    ),
    GoRoute(
      path: '/imam-salaries/:id/edit',
      builder: (context, state) {
        final salaryId = state.pathParameters['id'] ?? '';
        final extra = state.extra;
        final salary = extra is ImamSalaryModel ? extra : null;
        return _RoleGuard(
          isAllowed: PermissionHelper.canManageImamSalary,
          child: EditImamSalaryScreen(
            salaryId: salaryId,
            initialSalary: salary,
          ),
        );
      },
    ),
    GoRoute(
      path: '/imam-salaries/:id',
      builder: (context, state) {
        final salaryId = state.pathParameters['id'] ?? '';
        final extra = state.extra;
        final salary = extra is ImamSalaryModel ? extra : null;
        return ImamSalaryDetailScreen(
          salaryId: salaryId,
          initialSalary: salary,
        );
      },
    ),

    GoRoute(
      path: '/announcements',
      builder: (context, state) => const AnnouncementsScreen(),
    ),
    GoRoute(
      path: '/announcements/add',
      builder: (context, state) => _RoleGuard(
        isAllowed: PermissionHelper.canManageAnnouncements,
        child: const AddAnnouncementScreen(),
      ),
    ),
    GoRoute(
      path: '/announcements/:id/edit',
      builder: (context, state) {
        final announcementId = state.pathParameters['id'] ?? '';
        final extra = state.extra;
        final announcement = extra is AnnouncementModel ? extra : null;
        return _RoleGuard(
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
        final extra = state.extra;
        String? masjidId;
        if (extra is Map<String, dynamic>) {
          masjidId = extra['masjidId']?.toString();
        }
        return _RoleGuard(
          isAllowed: PermissionHelper.canUpdateNamazTime,
          child: UpdateNamazTimeScreen(masjidId: masjidId),
        );
      },
    ),
    GoRoute(
      path: '/projects/add',
      builder: (context, state) => _RoleGuard(
        isAllowed: PermissionHelper.canManageProjects,
        child: const AddProjectScreen(),
      ),
    ),
    GoRoute(
      path: '/projects/:id/edit',
      builder: (context, state) {
        final projectId = state.pathParameters['id'] ?? '';
        final extra = state.extra;
        final project = extra is ProjectModel ? extra : null;
        return _RoleGuard(
          isAllowed: PermissionHelper.canManageProjects,
          child: EditProjectScreen(
            projectId: projectId,
            initialProject: project,
          ),
        );
      },
    ),
    GoRoute(
      path: '/projects/:id',
      builder: (context, state) {
        final projectId = state.pathParameters['id'] ?? '';
        final extra = state.extra;
        final project = extra is ProjectModel ? extra : null;
        return ProjectDetailScreen(
          projectId: projectId,
          initialProject: project,
        );
      },
    ),

    GoRoute(
      path: '/super-admin',
      builder: (context, state) => const _SuperAdminGuard(child: SuperAdminShellScreen()),
    ),
    GoRoute(
      path: '/super-admin/requests',
      builder: (context, state) => const _SuperAdminGuard(child: SuperAdminShellScreen(initialIndex: 1)),
    ),
    GoRoute(
      path: '/super-admin/requests/:id',
      builder: (context, state) => _SuperAdminGuard(child: AdminMasjidRequestDetailScreen(id: state.pathParameters['id'] ?? '', initial: state.extra is AdminMasjidRequestModel ? state.extra as AdminMasjidRequestModel : null)),
    ),
    GoRoute(
      path: '/super-admin/masjids',
      builder: (context, state) => const _SuperAdminGuard(child: SuperAdminShellScreen(initialIndex: 2)),
    ),
    GoRoute(
      path: '/super-admin/masjids/:id',
      builder: (context, state) => _SuperAdminGuard(child: AdminMasjidDetailScreen(id: state.pathParameters['id'] ?? '', initial: state.extra is AdminMasjidModel ? state.extra as AdminMasjidModel : null)),
    ),
    GoRoute(
      path: '/super-admin/users',
      builder: (context, state) => const _SuperAdminGuard(child: SuperAdminShellScreen(initialIndex: 3)),
    ),
    GoRoute(
      path: '/super-admin/users/:id',
      builder: (context, state) => _SuperAdminGuard(child: AdminUserDetailScreen(id: state.pathParameters['id'] ?? '', initial: state.extra is AdminUserModel ? state.extra as AdminUserModel : null)),
    ),
    GoRoute(
      path: '/main',
      redirect: (context, state) async {
        final user = await SessionStorage().getUser();
        if (PermissionHelper.isSuperAdmin(user)) return '/super-admin';
        return '/main/home';
      },
    ),
    ShellRoute(
      builder: (context, state, child) => MainShellScreen(child: child),
      routes: <RouteBase>[
        GoRoute(
          path: '/main/home',
          builder: (context, state) => const HomeDashboardScreen(),
        ),
        GoRoute(
          path: '/main/finance',
          builder: (context, state) => const FinanceScreen(),
        ),
        GoRoute(
          path: '/main/projects',
          builder: (context, state) => const ProjectsScreen(),
        ),
        GoRoute(
          path: '/main/community',
          builder: (context, state) => const CommunityScreen(),
        ),
      ],
    ),
  ],
);

Map<String, String>? _readExtraMap(Object? extra) {
  if (extra is Map<String, String>) return extra;
  if (extra is Map<String, dynamic>) {
    return extra.map(
      (key, value) => MapEntry(key, value?.toString() ?? ''),
    );
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


class _SuperAdminGuard extends StatelessWidget {
  const _SuperAdminGuard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SessionStorage().getUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final user = snapshot.data;
        if (user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/auth'));
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (!PermissionHelper.isSuperAdmin(user)) {
          return const Scaffold(body: NotAllowedView(message: 'Only SUPER_ADMIN users can access this page.'));
        }
        return child;
      },
    );
  }
}


class _RoleGuard extends StatelessWidget {
  const _RoleGuard({required this.isAllowed, required this.child});

  final bool Function(List<String> roles) isAllowed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SessionStorage().getUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final roles = snapshot.data?.roles ?? const <String>[];
        if (!isAllowed(roles)) {
          return const Scaffold(body: NotAllowedView());
        }
        return child;
      },
    );
  }
}
