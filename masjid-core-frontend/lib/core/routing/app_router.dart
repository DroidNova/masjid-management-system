import 'package:go_router/go_router.dart';
import 'package:platform_core_frontend/features/admin/domain/repositories/admin_repository.dart';
import 'package:platform_core_frontend/features/admin/presentation/pages/admin_user_detail_page.dart';
import 'package:platform_core_frontend/features/admin/presentation/pages/admin_users_page.dart';
import 'package:platform_core_frontend/features/auth/presentation/controllers/auth_controller.dart';
import 'package:platform_core_frontend/features/auth/presentation/pages/login_page.dart';
import 'package:platform_core_frontend/features/auth/presentation/pages/register_page.dart';
import 'package:platform_core_frontend/features/auth/presentation/pages/splash_page.dart';
import 'package:platform_core_frontend/features/profile/presentation/pages/home_page.dart';
import 'package:platform_core_frontend/features/profile/presentation/pages/profile_page.dart';

class AppRouteGroup {
  const AppRouteGroup._();

  static const String admin = '/admin';
}

class AppRoutes {
  const AppRoutes._();

  static const String root = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';

  static const String adminUsers = '${AppRouteGroup.admin}/users';

  static String adminUserDetail(String id) => '$adminUsers/$id';
}

class AppRouter {
  AppRouter({
    required AuthController authController,
    required AdminRepository adminRepository,
  }) : _router = GoRouter(
          routes: [
            GoRoute(
              path: AppRoutes.root,
              builder: (_, __) => const SplashPage(),
            ),
            GoRoute(
              path: AppRoutes.login,
              builder: (_, __) => const LoginPage(),
            ),
            GoRoute(
              path: AppRoutes.register,
              builder: (_, __) => const RegisterPage(),
            ),
            GoRoute(
              path: AppRoutes.home,
              builder: (_, __) => const HomePage(),
            ),
            GoRoute(
              path: AppRoutes.profile,
              builder: (_, __) => const ProfilePage(),
            ),
            GoRoute(
              path: AppRoutes.adminUsers,
              builder: (_, __) => AdminUsersPage(repository: adminRepository),
            ),
            GoRoute(
              path: '${AppRoutes.adminUsers}/:id',
              builder: (_, state) => AdminUserDetailPage(
                userId: state.pathParameters['id'] ?? '',
                repository: adminRepository,
              ),
            ),
          ],
          redirect: (context, state) {
            final isAuthenticated = authController.state.isAuthenticated;
            final routeName = state.fullPath ?? state.uri.path;

            if (_isProtectedRoute(routeName) && !isAuthenticated) {
              return AppRoutes.login;
            }
            if (_isPublicAuthRoute(routeName) && isAuthenticated) {
              return AppRoutes.home;
            }
            if (_isAdminRoute(routeName) && !authController.canAccessAdmin) {
              return AppRoutes.home;
            }
            return null;
          },
          refreshListenable: authController,
        );
  final GoRouter _router;
  GoRouter get router => _router;

  bool _isProtectedRoute(String routeName) {
    return routeName == AppRoutes.home ||
        routeName == AppRoutes.profile ||
        _isAdminRoute(routeName);
  }

  bool _isPublicAuthRoute(String routeName) {
    return routeName == AppRoutes.login || routeName == AppRoutes.register;
  }

  bool _isAdminRoute(String routeName) {
    return routeName == AppRoutes.adminUsers ||
        routeName.startsWith('${AppRoutes.adminUsers}/');
  }
}
