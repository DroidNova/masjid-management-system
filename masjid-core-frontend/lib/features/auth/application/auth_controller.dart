import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/core/providers.dart';
import 'package:masjid_core_frontend/features/auth/data/models/app_user.dart';
import 'package:masjid_core_frontend/features/auth/data/models/auth_session.dart';

/// Who is using the app right now. The router redirects from this state.
sealed class AuthState {
  const AuthState();
}

/// Startup: stored tokens have not been checked yet (splash screen).
class AuthUnknown extends AuthState {
  const AuthUnknown();
}

class AuthSignedOut extends AuthState {
  const AuthSignedOut({this.message});

  /// Shown once after logout, e.g. "Your session has expired".
  final String? message;
}

class AuthSignedIn extends AuthState {
  const AuthSignedIn(this.user);

  final AppUser user;
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

/// The signed-in user, or null. Widgets should watch this instead of reading
/// secure storage themselves.
final currentUserProvider = Provider<AppUser?>((ref) {
  final state = ref.watch(authControllerProvider);
  return state is AuthSignedIn ? state.user : null;
});

/// The signed-in user's permission names (empty when signed out).
final currentPermissionsProvider = Provider<List<String>>(
  (ref) => ref.watch(currentUserProvider)?.permissions ?? const <String>[],
);

/// Single owner of the session: hydrates it at startup, signs in and out,
/// and reacts when the server ends the session.
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Check stored tokens once, after the first frame.
    Future<void>.microtask(_hydrate);
    return const AuthUnknown();
  }

  Future<void> _hydrate() async {
    final tokens = ref.read(tokenStorageProvider);
    final sessions = ref.read(sessionStorageProvider);

    final storedUser = await sessions.getUser();
    final hasAccess = await tokens.hasAccessToken();
    final refreshToken = await tokens.getRefreshToken();

    if (storedUser != null && hasAccess) {
      // Open the app immediately; refresh roles/permissions in the background.
      state = AuthSignedIn(storedUser);
      unawaited(refreshUser());
      return;
    }

    if (refreshToken != null && refreshToken.isNotEmpty) {
      // No access token: /auth/me triggers a token refresh in the interceptor.
      await refreshUser(signOutOnFailure: true);
      return;
    }

    state = const AuthSignedOut();
  }

  /// Call after OTP verification succeeded (tokens are already stored).
  void signIn(AuthSession session) {
    state = AuthSignedIn(session.user);
  }

  /// Reloads the user (roles, permissions, masjid) from `/auth/me`.
  Future<void> refreshUser({bool signOutOnFailure = false}) async {
    try {
      final user = await ref.read(authRepositoryProvider).fetchCurrentUser();
      // Same user (AppUser has ==): keep the state so nothing that watches
      // the user rebuilds or reloads.
      final current = state;
      if (current is AuthSignedIn && current.user == user) return;
      state = AuthSignedIn(user);
    } on ApiException catch (error) {
      // Network trouble: keep whatever we have. Session errors arrive via
      // [handleSessionExpired] from the interceptor.
      // A deactivated or deleted account is signed out as well.
      final accountGone =
          error.code == ApiErrorCodes.userInactive ||
          error.code == ApiErrorCodes.userNotFound;
      if (signOutOnFailure || error.isUnauthorized || accountGone) {
        await ref.read(authRepositoryProvider).clearLocalSession();
        if (state is! AuthSignedOut) state = const AuthSignedOut();
      }
    }
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AuthSignedOut();
  }

  /// The refresh token was rejected: tokens are already cleared.
  Future<void> handleSessionExpired() async {
    await ref.read(sessionStorageProvider).clearUser();
    if (state is AuthSignedIn) {
      state = const AuthSignedOut(
        message: 'Your session has expired. Please login again.',
      );
    } else if (state is AuthUnknown) {
      state = const AuthSignedOut();
    }
  }
}

/// Where a signed-in user lands.
String homeLocationFor(AppUser user) =>
    PermissionHelper.isSuperAdmin(user) ? '/super-admin' : '/main/home';
