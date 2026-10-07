import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class SessionExpiredHandler {
  SessionExpiredHandler._();

  static bool _isShowingDialog = false;

  static Future<void> showDialogAndRedirect() async {
    final context = rootNavigatorKey.currentContext;
    if (context == null || _isShowingDialog) return;

    final location = GoRouter.of(
      context,
    ).routeInformationProvider.value.uri.path;
    if (_isAuthRoute(location)) return;

    _isShowingDialog = true;
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Session expired'),
          content: const Text('Your session has expired. Please login again.'),
          actions: <Widget>[
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Login'),
            ),
          ],
        ),
      );
    } finally {
      _isShowingDialog = false;
      // The context is read fresh from the root navigator after the dialog
      // closes, so it is not a stale context captured before the await.
      final redirectContext = rootNavigatorKey.currentContext;
      if (redirectContext != null) {
        // ignore: use_build_context_synchronously
        redirectContext.go('/login-phone');
      }
    }
  }

  static bool _isAuthRoute(String location) {
    return location == '/auth' ||
        location == '/login-phone' ||
        location == '/login-password' ||
        location == '/login-otp' ||
        location == '/splash';
  }
}
