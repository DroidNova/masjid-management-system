import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:platform_core_frontend/core/routing/app_router.dart';
import 'package:platform_core_frontend/core/widgets/app_scaffold.dart';
import 'package:platform_core_frontend/features/auth/presentation/auth_scope.dart';
import 'package:platform_core_frontend/features/auth/presentation/controllers/auth_controller.dart';
import 'package:platform_core_frontend/features/auth/presentation/state/auth_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  AuthController? _authController;
  late final VoidCallback _listener;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_authController != null) {
      return;
    }

    _authController = AuthScope.of(context);
    _listener = () => _handleState(_authController!.state);
    _authController!.addListener(_listener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authController!.restoreSession();
    });
  }

  @override
  void dispose() {
    _authController?.removeListener(_listener);
    super.dispose();
  }

  void _handleState(AuthState state) {
    if (!mounted) {
      return;
    }

    if (state.status == AuthStatus.authenticated) {
      context.go(AppRoutes.home);
      return;
    }

    if (state.status == AuthStatus.unauthenticated) {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Platform Core Frontend',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 12),
          Text(
            'Checking session...',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
