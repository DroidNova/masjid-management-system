// mocktail needs `when(() => mock.call())` closures, not tear-offs.
// ignore_for_file: unnecessary_lambdas

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:masjid_core_frontend/core/network/api_client.dart';
import 'package:masjid_core_frontend/core/refresh/data_scopes.dart';
import 'package:masjid_core_frontend/features/super_admin/application/super_admin_actions.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_list_filter.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_masjid_model.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_masjid_request_model.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_user_model.dart';
import 'package:masjid_core_frontend/features/super_admin/data/super_admin_api.dart';
import 'package:masjid_core_frontend/features/super_admin/data/super_admin_repository.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/masjid_requests/admin_masjid_request_detail_screen.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/masjids/admin_masjid_detail_screen.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/users/admin_user_detail_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../shared/ui/ui_test_helpers.dart';

class _MockRepository extends Mock implements SuperAdminRepository {}

class _MockApiClient extends Mock implements ApiClient {}

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
) => pumpRouted(
  tester,
  child,
  overrides: [superAdminRepositoryProvider.overrideWithValue(repository)],
);

/// The page's own button, not the one in an open sheet.
Finder _pageButton(String label) => find
    .ancestor(
      of: find.text(label),
      matching: find.byWidgetPredicate((widget) => widget is ButtonStyleButton),
    )
    .first;

ButtonStyleButton _button(WidgetTester tester, String label) =>
    tester.widget<ButtonStyleButton>(_pageButton(label));

void main() {
  late _MockRepository repository;

  setUpAll(() async {
    registerFallbackValue(const AdminListFilter());
    await initializeDateFormatting('en_IN');
  });
  setUp(() {
    repository = _MockRepository();
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

  group('masjid request', () {
    setUp(() {
      when(
        () => repository.getMasjidRequest('r1'),
      ).thenAnswer((_) async => AdminMasjidRequestModel.fromJson(_requestJson));
    });

    testWidgets('approve asks for confirmation; cancel sends nothing', (
      tester,
    ) async {
      await _pump(
        tester,
        repository,
        const AdminMasjidRequestDetailScreen(id: 'r1'),
      );
      await tester.tap(_pageButton('Approve'));
      await tester.pumpAndSettle();
      expect(find.text('Approve this masjid?'), findsOneWidget);

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

      await _pump(
        tester,
        repository,
        const AdminMasjidRequestDetailScreen(id: 'r1'),
      );
      await tester.tap(_pageButton('Approve'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Approve').last);
      await tester.pump();

      expect(_button(tester, 'Approve').onPressed, isNull);
      expect(_button(tester, 'Reject').onPressed, isNull);

      approval.complete();
      await tester.pumpAndSettle();
      expect(find.text('Request approved'), findsOneWidget);
      verify(() => repository.approveMasjidRequest('r1')).called(1);
    });

    testWidgets('reject sends the reason typed', (tester) async {
      when(
        () => repository.rejectMasjidRequest('r1', reason: 'Not real'),
      ).thenAnswer((_) async {});

      await _pump(
        tester,
        repository,
        const AdminMasjidRequestDetailScreen(id: 'r1'),
      );
      await tester.tap(_pageButton('Reject'));
      await tester.pumpAndSettle();
      expect(find.text('Reject this request?'), findsOneWidget);
      await tester.enterText(find.byType(TextField).last, ' Not real ');
      await tester.tap(find.text('Reject').last);
      await tester.pumpAndSettle();

      verify(
        () => repository.rejectMasjidRequest('r1', reason: 'Not real'),
      ).called(1);
    });
  });

  testWidgets('suspending a masjid asks for the required reason', (
    tester,
  ) async {
    when(
      () => repository.getMasjid('m1'),
    ).thenAnswer((_) async => AdminMasjidModel.fromJson(_masjidJson));
    when(
      () => repository.updateMasjidStatus(
        any(),
        any(),
        reason: any(named: 'reason'),
      ),
    ).thenAnswer((_) async {});

    await _pump(tester, repository, const AdminMasjidDetailScreen(id: 'm1'));
    await tester.tap(find.text('Change status'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Suspended'));
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
    await tester.tap(find.text('Change roles'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CheckboxListTile, 'Member'));
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    // The success screen closes by itself.
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(find.text('Imam, Member'), findsOneWidget);
    verify(
      () => repository.assignUserRoles('u1', <String>['IMAM', 'MEMBER']),
    ).called(1);
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
