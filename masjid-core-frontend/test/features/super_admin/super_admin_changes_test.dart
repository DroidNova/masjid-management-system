// mocktail needs `when(() => mock.call())` closures, not tear-offs.
// ignore_for_file: unnecessary_lambdas

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:masjid_core_frontend/core/network/api_client.dart';
import 'package:masjid_core_frontend/core/pagination/page.dart';
import 'package:masjid_core_frontend/core/refresh/data_scopes.dart';
import 'package:masjid_core_frontend/features/super_admin/application/super_admin_actions.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_list_filter.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_masjid_model.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_masjid_request_model.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_user_model.dart';
import 'package:masjid_core_frontend/features/super_admin/data/super_admin_api.dart';
import 'package:masjid_core_frontend/features/super_admin/data/super_admin_repository.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/masjid_requests/admin_masjid_requests_screen.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/masjids/admin_masjids_screen.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/users/admin_user_detail_screen.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepository extends Mock implements SuperAdminRepository {}

class _MockApiClient extends Mock implements ApiClient {}

PageResult<T> _page<T>(
  List<Map<String, dynamic>> items,
  T Function(Map<String, dynamic>) parse,
) => PageResult<T>.fromJson(<String, dynamic>{
  'items': items,
  'meta': <String, dynamic>{
    'page': 1,
    'limit': 20,
    'total': items.length,
    'totalPages': 1,
    'hasNextPage': false,
  },
}, parse);

const _userJson = <String, dynamic>{
  'id': 'u1',
  'fullName': 'Abdul Rahman',
  'status': 'ACTIVE',
  'roles': <String>['IMAM'],
};

const _masjidJson = <String, dynamic>{
  'id': 'm1',
  'name': 'Jama Masjid',
  'status': 'APPROVED',
  'usersCount': 12,
};

const _requestJson = <String, dynamic>{
  'id': 'r1',
  'requesterName': 'Rahim',
  'requesterPhone': '+919876543210',
  'status': 'PENDING',
  'masjidName': 'Noor Masjid',
  'committeeMembers': <Map<String, dynamic>>[],
};

Future<void> _pump(
  WidgetTester tester,
  SuperAdminRepository repository,
  Widget child,
) async {
  tester.view.physicalSize = const Size(1600, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [superAdminRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(home: Scaffold(body: child)),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  late _MockRepository repository;

  setUpAll(() async {
    registerFallbackValue(const AdminListFilter());
    await initializeDateFormatting('en_IN');
  });
  setUp(() => repository = _MockRepository());

  group('masjid requests', () {
    setUp(() {
      when(
        () => repository.getMasjidRequests(any(), page: any(named: 'page')),
      ).thenAnswer(
        (_) async => _page(<Map<String, dynamic>>[
          _requestJson,
        ], AdminMasjidRequestModel.fromJson),
      );
    });

    testWidgets('approve asks for confirmation; cancel sends nothing', (
      tester,
    ) async {
      await _pump(tester, repository, const AdminMasjidRequestsScreen());
      await tester.tap(find.widgetWithText(TextButton, 'Approve'));
      await tester.pumpAndSettle();
      expect(find.text('Approve request'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      verifyNever(() => repository.approveMasjidRequest(any()));
    });

    testWidgets('buttons are off while an approve is in flight', (
      tester,
    ) async {
      final approval = Completer<void>();
      when(
        () => repository.approveMasjidRequest('r1'),
      ).thenAnswer((_) => approval.future);

      await _pump(tester, repository, const AdminMasjidRequestsScreen());
      await tester.tap(find.widgetWithText(TextButton, 'Approve'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Approve'));
      await tester.pump();

      TextButton button(String label) =>
          tester.widget<TextButton>(find.widgetWithText(TextButton, label));
      expect(button('Approve').onPressed, isNull);
      expect(button('Reject').onPressed, isNull);

      approval.complete();
      await tester.pumpAndSettle();
      expect(button('Approve').onPressed, isNotNull);
      verify(() => repository.approveMasjidRequest('r1')).called(1);
    });
  });

  testWidgets('suspending a masjid asks for the required reason', (
    tester,
  ) async {
    when(
      () => repository.getMasjids(any(), page: any(named: 'page')),
    ).thenAnswer(
      (_) async =>
          _page(<Map<String, dynamic>>[_masjidJson], AdminMasjidModel.fromJson),
    );
    when(
      () => repository.updateMasjidStatus(
        any(),
        any(),
        reason: any(named: 'reason'),
      ),
    ).thenAnswer((_) async {});

    await _pump(tester, repository, const AdminMasjidsScreen());
    await tester.tap(find.text('Change Status'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SUSPENDED'));
    await tester.pumpAndSettle();

    FilledButton save() =>
        tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Save'));
    expect(save().onPressed, isNull);
    await tester.enterText(find.byType(TextField).last, 'Fake masjid');
    await tester.pump();
    expect(save().onPressed, isNotNull);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    verify(
      () => repository.updateMasjidStatus(
        'm1',
        'SUSPENDED',
        reason: 'Fake masjid',
      ),
    ).called(1);
  });

  testWidgets('assigning roles shows the returned user without a reload', (
    tester,
  ) async {
    when(
      () => repository.getUser('u1'),
    ).thenAnswer((_) async => AdminUserModel.fromJson(_userJson));
    when(() => repository.assignUserRoles('u1', any())).thenAnswer(
      (_) async => AdminUserModel.fromJson(<String, dynamic>{
        ..._userJson,
        'roles': <String>['IMAM', 'MEMBER'],
      }),
    );

    await _pump(tester, repository, const AdminUserDetailScreen(id: 'u1'));
    await tester.tap(find.text('Assign Roles'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('MEMBER'));
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('IMAM, MEMBER'), findsOneWidget);
    verify(() => repository.getUser('u1')).called(1);
  });

  test('each change marks only the admin data it affects', () async {
    final container = ProviderContainer(
      overrides: [superAdminRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    when(
      () => repository.updateUserStatus('u1', 'SUSPENDED'),
    ).thenAnswer((_) async {});
    when(() => repository.approveMasjidRequest('r1')).thenAnswer((_) async {});
    int version(DataScope scope) => container.read(dataVersionProvider(scope));

    final actions = container.read(superAdminActionsProvider);
    await actions.updateUserStatus('u1', 'SUSPENDED');
    expect(version(DataScope.adminUsers), 1);
    expect(version(DataScope.adminSummary), 1);
    expect(version(DataScope.adminMasjids), 0);
    expect(version(DataScope.adminRequests), 0);

    await actions.approveMasjidRequest('r1');
    expect(version(DataScope.adminRequests), 1);
    expect(version(DataScope.adminMasjids), 1);
    expect(version(DataScope.adminUsers), 2);
    expect(version(DataScope.adminSummary), 2);
    expect(container.read(adminBusyIdsProvider), isEmpty);
  });

  group('SuperAdminApi', () {
    late _MockApiClient client;

    setUp(() {
      client = _MockApiClient();
      when(
        () =>
            client.get<Map<String, dynamic>>(any(), query: any(named: 'query')),
      ).thenAnswer(
        (_) async => <String, dynamic>{
          'items': <Object>[],
          'meta': <String, dynamic>{},
        },
      );
    });

    Map<String, dynamic> queryFor(String path) =>
        verify(
              () => client.get<Map<String, dynamic>>(
                path,
                query: captureAny(named: 'query'),
              ),
            ).captured.single
            as Map<String, dynamic>;

    test('sends the role filter to /admin/users only', () async {
      final api = SuperAdminApi(client);
      const filter = AdminListFilter(role: 'IMAM', status: 'ACTIVE');

      await api.getUsers(filter, 1);
      await api.getMasjids(filter, 1);
      await api.getMasjidRequests(filter, 1);

      expect(queryFor('/admin/users')['role'], 'IMAM');
      expect(queryFor('/admin/masjids').containsKey('role'), isFalse);
      expect(queryFor('/masjid-requests').containsKey('role'), isFalse);
    });

    test('loads one masjid request by id', () async {
      when(
        () => client.get<Map<String, dynamic>>('/masjid-requests/r1'),
      ).thenAnswer((_) async => _requestJson);

      final request = await SuperAdminApi(client).getMasjidRequest('r1');

      expect(request.masjidName, 'Noor Masjid');
    });
  });
}
