import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:platform_core_frontend/core/permissions/permission_helper.dart';
import 'package:platform_core_frontend/core/storage/session_storage.dart';
import 'package:platform_core_frontend/core/storage/token_storage.dart';
import 'package:platform_core_frontend/features/auth/data/auth_repository.dart';
import 'package:platform_core_frontend/shared/widgets/loading_view.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    TokenStorage? tokenStorage,
    AuthRepository? authRepository,
    SessionStorage? sessionStorage,
  })  : _tokenStorage = tokenStorage,
        _authRepository = authRepository,
        _sessionStorage = sessionStorage;

  final TokenStorage? _tokenStorage;
  final AuthRepository? _authRepository;
  final SessionStorage? _sessionStorage;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final TokenStorage _tokenStorage = widget._tokenStorage ?? TokenStorage();
  late final AuthRepository _authRepository =
      widget._authRepository ?? AuthRepository();
  late final SessionStorage _sessionStorage =
      widget._sessionStorage ?? SessionStorage();

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    final hasAccessToken = await _tokenStorage.hasAccessToken();
    if (hasAccessToken) {
      final user = await _sessionStorage.getUser();
      if (mounted) context.go(PermissionHelper.isSuperAdmin(user) ? '/super-admin' : '/main');
      return;
    }

    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await _authRepository.refreshSession();
        final user = await _sessionStorage.getUser();
        if (mounted) context.go(PermissionHelper.isSuperAdmin(user) ? '/super-admin' : '/main');
        return;
      } catch (_) {
        await _authRepository.clearLocalSession();
      }
    }

    if (!mounted) return;
    context.go('/auth');
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Masjid Core',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              const LoadingView(),
            ],
          ),
        ),
      ),
    );
  }
}
