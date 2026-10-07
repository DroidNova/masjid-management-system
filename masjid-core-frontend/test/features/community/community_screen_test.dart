// mocktail needs `when(() => mock.call())` closures, not tear-offs.
// ignore_for_file: unnecessary_lambdas

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

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
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        communityRepositoryProvider.overrideWithValue(repository),
        authControllerProvider.overrideWith(() => FixedAuth(user)),
      ],
      child: const MaterialApp(
        localizationsDelegates: localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: CommunityScreen()),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

MockCommunityRepository _repositoryWithData() {
  final repository = MockCommunityRepository();
  when(() => repository.getMyMasjid()).thenAnswer((_) async => _masjid);
  when(() => repository.getMyMasjidUsers()).thenAnswer((_) async => _users);
  return repository;
}

void main() {
  testWidgets('shows the masjid and its users grouped by role', (tester) async {
    await _pump(tester, _repositoryWithData(), testUser());

    expect(find.text('Barota Masjid'), findsOneWidget);
    expect(find.text('Imam Sahab'), findsOneWidget);
    expect(find.text('Committee Person'), findsOneWidget);
    expect(find.text('Villager'), findsOneWidget);
    expect(find.text('Phone: +919800000001'), findsOneWidget);
  });

  testWidgets('hidden contact details show nothing, never "null"', (
    tester,
  ) async {
    await _pump(tester, _repositoryWithData(), testUser());

    expect(find.textContaining('null'), findsNothing);
    // Only the one user whose phone was sent shows a phone line.
    expect(find.textContaining('Phone:'), findsOneWidget);
    expect(find.textContaining('Email:'), findsNothing);
  });

  testWidgets('without members.manage there is no Add User, Edit or Status', (
    tester,
  ) async {
    await _pump(
      tester,
      _repositoryWithData(),
      testUser(permissions: const [AppPermissions.membersRead]),
    );

    expect(find.text('Add User'), findsNothing);
    expect(find.text('Edit'), findsNothing);
    expect(find.text('Status'), findsNothing);
  });

  testWidgets('members.manage may add users and edit plain members only', (
    tester,
  ) async {
    await _pump(
      tester,
      _repositoryWithData(),
      testUser(
        permissions: const [
          AppPermissions.membersRead,
          AppPermissions.membersManage,
        ],
      ),
    );

    expect(find.text('Add User'), findsOneWidget);
    // Villager (MEMBER) only; not the imam or committee member.
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);
  });

  testWidgets('a load error shows the server message and Retry', (
    tester,
  ) async {
    final repository = MockCommunityRepository();
    when(() => repository.getMyMasjid()).thenAnswer((_) async => _masjid);
    when(() => repository.getMyMasjidUsers()).thenThrow(
      const ApiException(
        message: 'Requires permission: members.read',
        code: ApiErrorCodes.forbidden,
        statusCode: 403,
      ),
    );

    await _pump(tester, repository, testUser());

    expect(find.text('Unable to load community details.'), findsOneWidget);
    expect(find.text('Requires permission: members.read'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
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
