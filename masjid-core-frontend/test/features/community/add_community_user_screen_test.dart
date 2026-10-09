// mocktail needs `when(() => mock.call())` closures, not tear-offs.
// ignore_for_file: unnecessary_lambdas

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/auth/data/models/app_user.dart';
import 'package:masjid_core_frontend/features/community/data/community_repository.dart';
import 'package:masjid_core_frontend/features/community/data/models/community_user_model.dart';
import 'package:masjid_core_frontend/features/community/data/models/create_community_user_request.dart';
import 'package:masjid_core_frontend/features/community/presentation/add_community_user_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../shared/ui/ui_test_helpers.dart';
import 'community_test_helpers.dart';

const _manager = [AppPermissions.membersRead, AppPermissions.membersManage];

Future<void> _pump(
  WidgetTester tester,
  CommunityRepository repository,
  AppUser user,
) => pumpRouted(
  tester,
  const AddCommunityUserScreen(),
  size: const Size(420, 1000),
  overrides: [
    communityRepositoryProvider.overrideWithValue(repository),
    authControllerProvider.overrideWith(() => FixedAuth(user)),
  ],
);

Future<void> _type(WidgetTester tester, String label, String text) async {
  final field = find.widgetWithText(TextFormField, label);
  await tester.ensureVisible(field);
  await tester.enterText(field, text);
  await tester.pump();
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Fills the first two steps; stops on the last one, before Save.
Future<void> _fillForm(WidgetTester tester) async {
  await _type(tester, 'Phone number', '9876543210');
  await _type(tester, 'Name', ' Abdul ');
  await _tap(tester, find.widgetWithText(FilledButton, 'Next'));
  await _type(tester, "Father's name", 'Karim');
  await _type(tester, 'Age', '30');
  await _tap(tester, find.text('Man'));
  await _tap(tester, find.widgetWithText(FilledButton, 'Next'));
}

Future<void> _save(WidgetTester tester) =>
    _tap(tester, find.widgetWithText(FilledButton, 'Save'));

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
  setUp(() {
    TestWidgetsFlutterBinding
        .instance
        .platformDispatcher
        .accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(
      disableAnimations: true,
    );
  });
  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher
        .clearAccessibilityFeaturesTestValue();
  });

  testWidgets('an empty first step does not move on', (tester) async {
    await _pump(
      tester,
      MockCommunityRepository(),
      testUser(permissions: _manager),
    );

    await _tap(tester, find.widgetWithText(FilledButton, 'Next'));
    expect(find.widgetWithText(TextFormField, 'Name'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, "Father's name"), findsNothing);
  });

  testWidgets('the committee adds a family head as a MEMBER', (tester) async {
    final repository = MockCommunityRepository();
    when(() => repository.createMasjidUser(any())).thenAnswer(
      (_) async => const CommunityUserModel(
        id: 'new',
        fullName: 'Abdul',
        roles: ['MEMBER'],
      ),
    );

    await _pump(tester, repository, testUser(permissions: _manager));
    await _fillForm(tester);
    // Only one role is allowed, so no role choice is shown.
    expect(find.byType(ChoiceChip), findsNothing);
    await _tap(tester, find.text('Family head'));
    await _type(tester, 'Family members (optional)', '5');
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
      'isFamilyHead': true,
      'familyMemberCount': 5,
    });
    expect(find.text('Person added'), findsOneWidget);
  });

  testWidgets('a temporary password is shown to copy', (tester) async {
    final repository = MockCommunityRepository();
    when(() => repository.createMasjidUser(any())).thenAnswer(
      (_) async => const CommunityUserModel(
        id: 'new',
        fullName: 'Abdul',
        roles: ['MEMBER'],
        temporaryPassword: 'Xy7-pass',
      ),
    );

    await _pump(tester, repository, testUser(permissions: _manager));
    await _fillForm(tester);
    // Save keeps spinning under the sheet until OK, so it never settles.
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Xy7-pass'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'OK'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
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
    expect(find.text('Person added'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Save'), findsOneWidget);
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
}
