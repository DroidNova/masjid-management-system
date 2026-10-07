import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/core/refresh/data_scopes.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/auth/data/models/app_user.dart';
import 'package:masjid_core_frontend/features/community/application/add_community_user_controller.dart';
import 'package:masjid_core_frontend/features/community/data/community_repository.dart';
import 'package:masjid_core_frontend/features/community/data/models/community_user_model.dart';
import 'package:masjid_core_frontend/features/community/data/models/create_community_user_request.dart';
import 'package:masjid_core_frontend/features/community/presentation/add_community_user_screen.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

import 'community_test_helpers.dart';

const _manager = [AppPermissions.membersRead, AppPermissions.membersManage];

Future<ProviderContainer> _pump(
  WidgetTester tester,
  CommunityRepository repository,
  AppUser user,
) async {
  final router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(body: Text('Community')),
      ),
      GoRoute(
        path: '/add',
        builder: (context, state) => const AddCommunityUserScreen(),
      ),
    ],
  );
  final container = ProviderContainer(
    overrides: [
      communityRepositoryProvider.overrideWithValue(repository),
      authControllerProvider.overrideWith(() => FixedAuth(user)),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  unawaited(router.push('/add'));
  await tester.pumpAndSettle();
  return container;
}

Future<void> _fillForm(WidgetTester tester) async {
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Full Name *'),
    'Abdul',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Phone *'),
    '9876543210',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Father Name *'),
    'Karim',
  );
  await tester.enterText(find.widgetWithText(TextFormField, 'Age *'), '30');
  await tester.ensureVisible(find.text('Gender *'));
  await tester.tap(find.text('Gender *'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Male').last);
  await tester.pumpAndSettle();
}

Future<void> _save(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Save User'));
  await tester.tap(find.text('Save User'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const CreateCommunityUserRequest(
        fullName: '',
        phone: '',
        role: 'MEMBER',
        fatherName: '',
        age: 1,
        gender: 'MALE',
      ),
    );
  });

  testWidgets('USER_IN_ANOTHER_MASJID shows the server message clearly', (
    tester,
  ) async {
    const serverMessage =
        'This phone number belongs to another masjid. '
        'Ask them to leave that masjid first.';
    final repository = MockCommunityRepository();
    when(() => repository.createMasjidUser(any())).thenThrow(
      const ApiException(
        message: serverMessage,
        code: ApiErrorCodes.userInAnotherMasjid,
        statusCode: 409,
      ),
    );

    await _pump(tester, repository, testUser(permissions: _manager));
    await _fillForm(tester);
    await _save(tester);

    expect(find.text(serverMessage), findsOneWidget);
    // Still on the form: nothing was added.
    expect(find.text('User Added'), findsNothing);
    expect(find.text('Save User'), findsOneWidget);
  });

  testWidgets('MASJID_USER_ALREADY_LINKED shows the server message', (
    tester,
  ) async {
    final repository = MockCommunityRepository();
    when(() => repository.createMasjidUser(any())).thenThrow(
      const ApiException(
        message: 'User is already linked to this masjid',
        code: ApiErrorCodes.masjidUserAlreadyLinked,
        statusCode: 409,
      ),
    );

    await _pump(tester, repository, testUser(permissions: _manager));
    await _fillForm(tester);
    await _save(tester);

    expect(find.text('User is already linked to this masjid'), findsOneWidget);
  });

  testWidgets('sends a trimmed MEMBER request and confirms', (tester) async {
    final repository = MockCommunityRepository();
    when(() => repository.createMasjidUser(any())).thenAnswer(
      (_) async => const CommunityUserModel(
        id: 'new',
        fullName: 'Abdul',
        roles: ['MEMBER'],
      ),
    );

    final container = await _pump(
      tester,
      repository,
      testUser(permissions: _manager),
    );
    await _fillForm(tester);
    await _save(tester);

    final request =
        verify(() => repository.createMasjidUser(captureAny())).captured.single
            as CreateCommunityUserRequest;
    expect(request.toJson(), <String, Object?>{
      'fullName': 'Abdul',
      'phone': '+919876543210',
      'role': 'MEMBER',
      'fatherName': 'Karim',
      'age': 30,
      'gender': 'MALE',
      'isFamilyHead': false,
    });
    expect(
      find.text(
        'Member added successfully. This user can login using phone OTP.',
      ),
      findsOneWidget,
    );
    expect(container.read(dataVersionProvider(DataScope.members)), 1);
  });

  testWidgets('users who may not add anyone see Not allowed', (tester) async {
    await _pump(
      tester,
      MockCommunityRepository(),
      testUser(permissions: const [AppPermissions.membersRead]),
    );

    expect(find.text('Not allowed'), findsOneWidget);
    expect(find.text('Save User'), findsNothing);
  });

  test('success message prefers the server message, then the password', () {
    const user = CommunityUserModel(id: 'x', fullName: 'X');
    expect(
      addUserSuccessMessage(user.copyWith(message: 'From server'), 'IMAM'),
      'From server',
    );
    expect(
      addUserSuccessMessage(user.copyWith(temporaryPassword: 'abc'), 'IMAM'),
      'User added successfully. Temporary password is abc.',
    );
    expect(addUserSuccessMessage(user, 'IMAM'), 'User added successfully.');
  });
}
