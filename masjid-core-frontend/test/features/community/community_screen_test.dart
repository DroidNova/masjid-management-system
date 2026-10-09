// mocktail needs `when(() => mock.call())` closures, not tear-offs.
// ignore_for_file: unnecessary_lambdas

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/auth/data/models/app_user.dart';
import 'package:masjid_core_frontend/features/community/application/community_controller.dart';
import 'package:masjid_core_frontend/features/community/data/community_repository.dart';
import 'package:masjid_core_frontend/features/community/data/models/community_user_model.dart';
import 'package:masjid_core_frontend/features/community/data/models/masjid_detail_model.dart';
import 'package:masjid_core_frontend/features/community/presentation/community_screen.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../shared/ui/ui_test_helpers.dart';
import 'community_test_helpers.dart';

const _masjid = MasjidDetailModel(id: 'm1', name: 'Barota Masjid');

final _users = <CommunityUserModel>[
  CommunityUserModel.fromJson(const {
    'id': 'u-imam',
    'fullName': 'Imam Sahab',
    'roles': ['IMAM'],
    'phone': null,
    'email': null,
  }),
  CommunityUserModel.fromJson(const {
    'id': 'u-committee',
    'fullName': 'Committee Person',
    'roles': ['COMMITTEE_MEMBER'],
    'phone': '+919800000001',
  }),
  CommunityUserModel.fromJson(const {
    'id': 'u-member',
    'fullName': 'Villager',
    'roles': ['MEMBER'],
    'phone': null,
    'email': null,
    'status': 'ACTIVE',
  }),
];

Future<void> _pump(
  WidgetTester tester,
  CommunityRepository repository,
  AppUser user,
) => pumpRouted(
  tester,
  const Scaffold(body: CommunityScreen()),
  size: const Size(420, 1200),
  overrides: [
    communityRepositoryProvider.overrideWithValue(repository),
    authControllerProvider.overrideWith(() => FixedAuth(user)),
  ],
);

const _manager = [AppPermissions.membersRead, AppPermissions.membersManage];

MockCommunityRepository _repositoryWithData() {
  final repository = MockCommunityRepository();
  when(() => repository.getMyMasjid()).thenAnswer((_) async => _masjid);
  when(() => repository.getMyMasjidUsers()).thenAnswer((_) async => _users);
  return repository;
}

void main() {
  testWidgets('shows the masjid, how many people, and each person', (
    tester,
  ) async {
    await _pump(tester, _repositoryWithData(), testUser());

    expect(find.text('Barota Masjid'), findsOneWidget);
    expect(find.text('3 people'), findsOneWidget);
    expect(find.text('Imam Sahab'), findsOneWidget);
    expect(find.text('Committee Person'), findsOneWidget);
    expect(find.text('Villager'), findsOneWidget);
    expect(find.textContaining('null'), findsNothing);
  });

  testWidgets('group chips and search narrow the list', (tester) async {
    await _pump(tester, _repositoryWithData(), testUser());

    await tester.tap(find.widgetWithText(ChoiceChip, 'Imam'));
    await tester.pumpAndSettle();
    expect(find.text('Imam Sahab'), findsOneWidget);
    expect(find.text('Villager'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, 'All'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'villa');
    await tester.pumpAndSettle();
    expect(find.text('Villager'), findsOneWidget);
    expect(find.text('Committee Person'), findsNothing);
  });

  testWidgets('readers see details only: no Add person, Edit or Turn off', (
    tester,
  ) async {
    await _pump(
      tester,
      _repositoryWithData(),
      testUser(permissions: const [AppPermissions.membersRead]),
    );

    expect(find.text('Add person'), findsNothing);
    await tester.tap(find.text('Committee Person'));
    await tester.pumpAndSettle();
    expect(find.text('+919800000001'), findsWidgets);
    expect(find.text('Edit'), findsNothing);
    expect(find.text('Turn off'), findsNothing);
  });

  testWidgets('members.manage may edit and turn off plain members only', (
    tester,
  ) async {
    await _pump(tester, _repositoryWithData(), testUser(permissions: _manager));

    expect(find.text('Add person'), findsOneWidget);

    await tester.tap(find.text('Imam Sahab'));
    await tester.pumpAndSettle();
    expect(find.text('Edit'), findsNothing);
    expect(find.text('Turn off'), findsNothing);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Villager'));
    await tester.pumpAndSettle();
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Turn off'), findsOneWidget);
  });

  testWidgets('turning a member off asks first, with a hold', (tester) async {
    final repository = _repositoryWithData();
    when(
      () => repository.updateMasjidUserStatus('u-member', 'INACTIVE'),
    ).thenAnswer(
      (_) async => const CommunityUserModel(
        id: 'u-member',
        fullName: 'Villager',
        roles: ['MEMBER'],
        status: 'INACTIVE',
      ),
    );
    await _pump(tester, repository, testUser(permissions: _manager));

    await tester.tap(find.text('Villager'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Turn off'));
    await tester.pumpAndSettle();
    expect(find.text('Turn off this person?'), findsOneWidget);
    expect(find.text('They cannot log in to the app.'), findsOneWidget);

    final hold = find.descendant(
      of: find.byType(HoldToConfirmButton),
      matching: find.text('Turn off'),
    );
    final gesture = await tester.startGesture(tester.getCenter(hold));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2100));
    await gesture.up();
    await tester.pumpAndSettle();

    verify(
      () => repository.updateMasjidUserStatus('u-member', 'INACTIVE'),
    ).called(1);
  });

  testWidgets('a load error shows the server message and Try again', (
    tester,
  ) async {
    final repository = MockCommunityRepository();
    when(() => repository.getMyMasjid()).thenAnswer((_) async => _masjid);
    when(() => repository.getMyMasjidUsers()).thenThrow(
      const ApiException(
        message: 'Server is busy',
        code: 'SOMETHING',
        statusCode: 500,
      ),
    );

    await _pump(tester, repository, testUser());

    expect(find.text('Server is busy'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('USER_MASJID_NOT_ASSIGNED says so, by code', (tester) async {
    final repository = MockCommunityRepository();
    when(() => repository.getMyMasjid()).thenThrow(
      const ApiException(
        message: 'Current user is not assigned to a masjid',
        code: ApiErrorCodes.userMasjidNotAssigned,
        statusCode: 403,
      ),
    );
    when(() => repository.getMyMasjidUsers()).thenAnswer((_) async => _users);

    await _pump(tester, repository, testUser());

    expect(
      find.text('You are not assigned to any masjid yet.'),
      findsOneWidget,
    );
    expect(find.text('Try again'), findsNothing);
  });

  test('CommunityData groups admins with the committee, others as members', () {
    final data = CommunityData(
      masjid: _masjid,
      users: <CommunityUserModel>[
        ..._users,
        const CommunityUserModel(
          id: 'u-admin-imam',
          fullName: 'Admin Imam',
          roles: ['MASJID_ADMIN', 'IMAM'],
        ),
      ],
    );

    expect(data.imamUsers.map((u) => u.id), ['u-imam']);
    expect(data.committeeUsers.map((u) => u.id), [
      'u-committee',
      'u-admin-imam',
    ]);
    expect(data.memberUsers.map((u) => u.id), ['u-member']);
  });
}
