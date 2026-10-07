// mocktail needs `when(() => mock.call())` closures, not tear-offs.
// ignore_for_file: unnecessary_lambdas

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/auth/data/models/app_user.dart';
import 'package:masjid_core_frontend/features/community/data/community_repository.dart';
import 'package:masjid_core_frontend/shared/widgets/account_menu_button.dart';
import 'package:mocktail/mocktail.dart';

class _MockCommunityRepository extends Mock implements CommunityRepository {}

class _FixedAuth extends AuthController {
  _FixedAuth(this.user);

  final AppUser? user;
  int signOutCalls = 0;

  @override
  AuthState build() =>
      user == null ? const AuthSignedOut() : AuthSignedIn(user!);

  @override
  Future<void> signOut() async {
    signOutCalls++;
    state = const AuthSignedOut();
  }
}

AppUser _user({required List<String> permissions, String? masjidId}) => AppUser(
  id: 'u1',
  fullName: 'Rafiq',
  roles: const ['MEMBER'],
  permissions: permissions,
  masjidId: masjidId,
);

Future<_FixedAuth> _pump(
  WidgetTester tester,
  AppUser? user, {
  CommunityRepository? repository,
}) async {
  final auth = _FixedAuth(user);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authControllerProvider.overrideWith(() => auth),
        communityRepositoryProvider.overrideWithValue(
          repository ?? _MockCommunityRepository(),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(appBar: AppBar(actions: const [AccountMenuButton()])),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return auth;
}

Future<void> _leave(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Account'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Leave masjid'));
  await tester.pumpAndSettle();
  // Confirm in the dialog.
  await tester.tap(find.widgetWithText(FilledButton, 'Leave masjid'));
  await tester.pumpAndSettle();
}

void main() {
  final member = _user(
    permissions: const [AppPermissions.masjidLeave],
    masjidId: 'm1',
  );

  testWidgets('offers "Leave masjid" to a member of a masjid', (tester) async {
    await _pump(tester, member);

    await tester.tap(find.byTooltip('Account'));
    await tester.pumpAndSettle();
    expect(find.text('Leave masjid'), findsOneWidget);
  });

  testWidgets('is hidden when the user has no masjid', (tester) async {
    await _pump(tester, _user(permissions: const [AppPermissions.masjidLeave]));
    expect(find.byTooltip('Account'), findsNothing);
  });

  testWidgets('is hidden without the masjid.leave permission', (tester) async {
    await _pump(tester, _user(permissions: const [], masjidId: 'm1'));
    expect(find.byTooltip('Account'), findsNothing);
  });

  testWidgets('leaving calls the API, shows a message and signs out', (
    tester,
  ) async {
    final repository = _MockCommunityRepository();
    when(() => repository.leaveMyMasjid()).thenAnswer((_) async {});

    final auth = await _pump(tester, member, repository: repository);
    await _leave(tester);

    verify(() => repository.leaveMyMasjid()).called(1);
    expect(find.text('You have left the masjid.'), findsOneWidget);
    expect(auth.signOutCalls, 1);
  });

  testWidgets('a failed leave shows the server message and stays signed in', (
    tester,
  ) async {
    final repository = _MockCommunityRepository();
    when(() => repository.leaveMyMasjid()).thenThrow(
      const ApiException(
        message: 'Current user is not assigned to a masjid',
        code: ApiErrorCodes.userMasjidNotAssigned,
        statusCode: 400,
      ),
    );

    final auth = await _pump(tester, member, repository: repository);
    await _leave(tester);

    expect(
      find.text('Current user is not assigned to a masjid'),
      findsOneWidget,
    );
    expect(auth.signOutCalls, 0);
    expect(find.byTooltip('Account'), findsOneWidget);
  });
}
