import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/core/permissions/permission_gate.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/auth/data/models/app_user.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

import 'ui_test_helpers.dart';

class _Member extends AuthController {
  @override
  AuthState build() => const AuthSignedIn(AppUser(id: 'u1', fullName: 'Rafiq'));
}

void main() {
  testWidgets('a page not allowed says so and Go back leaves it', (
    tester,
  ) async {
    await pumpRouted(
      tester,
      PermissionGate(
        isAllowed: (permissions) => permissions.contains('secret'),
        child: const Text('Secret page'),
      ),
      overrides: [authControllerProvider.overrideWith(_Member.new)],
    );

    expect(find.text('Secret page'), findsNothing);
    expect(find.text('Not allowed'), findsOneWidget);

    await tester.tap(find.text('Go back'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('a wrong link says so and Go home leaves it', (tester) async {
    await pumpRouted(tester, const NotFoundView());

    expect(find.text('Page not found'), findsOneWidget);
    await tester.tap(find.text('Go home'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('no internet gets its own picture and Try again', (tester) async {
    var retries = 0;
    await pumpUi(
      tester,
      Scaffold(
        body: ErrorState(
          error: const ApiException(
            message: 'Cannot reach the server.',
            code: ApiErrorCodes.network,
          ),
          onRetry: () => retries++,
        ),
      ),
    );

    expect(find.byIcon(AppIcons.noInternet), findsOneWidget);
    expect(
      find.text('No internet. Check your connection and try again.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Try again'));
    expect(retries, 1);
  });

  testWidgets('a bug never shows raw error text', (tester) async {
    await pumpUi(
      tester,
      const Scaffold(body: ErrorState(error: FormatException('bad json'))),
    );

    expect(find.textContaining('FormatException'), findsNothing);
    expect(find.text('Try again'), findsNothing);
  });
}
