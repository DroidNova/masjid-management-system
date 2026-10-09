// mocktail needs `when(() => mock.call())` closures, not tear-offs.
// ignore_for_file: unnecessary_lambdas

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/core/pagination/page.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_list_filter.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_masjid_model.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_masjid_request_model.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_user_model.dart';
import 'package:masjid_core_frontend/features/super_admin/data/super_admin_repository.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/masjid_requests/admin_masjid_request_detail_screen.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/masjid_requests/admin_masjid_requests_screen.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/masjids/admin_masjids_screen.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/users/admin_user_detail_screen.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/users/admin_users_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../shared/ui/ui_test_helpers.dart';

class _MockRepository extends Mock implements SuperAdminRepository {}

/// Builds a page exactly as the API sends it: `{ items, meta }`.
PageResult<T> _page<T>(
  List<Map<String, dynamic>> items,
  T Function(Map<String, dynamic>) parse, {
  int total = -1,
  bool hasNextPage = false,
}) => PageResult<T>.fromJson(<String, dynamic>{
  'items': items,
  'meta': <String, dynamic>{
    'page': 1,
    'limit': 20,
    'total': total < 0 ? items.length : total,
    'totalPages': 1,
    'hasNextPage': hasNextPage,
  },
}, parse);

const _userJson = <String, dynamic>{
  'id': 'u1',
  'fullName': 'Abdul Rahman',
  'email': null,
  'phone': '+919876543210',
  'status': 'ACTIVE',
  'masjidId': 'm1',
  'masjidName': 'Jama Masjid',
  'masjid': <String, dynamic>{'id': 'm1', 'name': 'Jama Masjid'},
  'roles': <String>['IMAM'],
  'createdAt': '2026-06-19T00:00:00.000Z',
};

const _masjidJson = <String, dynamic>{
  'id': 'm1',
  'name': 'Jama Masjid',
  'country': 'India',
  'state': 'Uttar Pradesh',
  'locality': 'Nighasan',
  'address': 'Main Road',
  'status': 'APPROVED',
  'requestedByName': 'Rahim',
  'requestedByPhone': '+919876543210',
  'imamName': 'Abdul Rahman',
  'usersCount': 12,
  '_count': <String, dynamic>{'users': 12},
};

const _requestJson = <String, dynamic>{
  'id': 'r1',
  'requesterName': 'Rahim',
  'requesterPhone': '+919876543210',
  'status': 'PENDING',
  'masjidName': 'Noor Masjid',
  'country': 'India',
  'state': 'Uttar Pradesh',
  'locality': 'Nighasan',
  'address': 'Station Road',
  'imamName': 'Abdul Rahman',
  'imamPhone': '+919876543211',
  'imamAddress': 'Nighasan',
  'committeeMembers': <Map<String, dynamic>>[
    <String, dynamic>{
      'name': 'Yusuf',
      'phone': '+919876543212',
      'fatherName': 'Ibrahim',
      'age': 40,
      'gender': 'MALE',
    },
  ],
  'createdAt': '2026-06-19T00:00:00.000Z',
};

Future<void> _pump(
  WidgetTester tester,
  SuperAdminRepository repository,
  Widget child, {
  Size size = const Size(420, 1400),
}) => pumpRouted(
  tester,
  child,
  size: size,
  overrides: [superAdminRepositoryProvider.overrideWithValue(repository)],
);

/// Taps the page's Approve, then confirms in the sheet.
Future<void> _approveAndConfirm(WidgetTester tester) async {
  await tester.tap(find.text('Approve').first);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Approve').last);
  await tester.pumpAndSettle();
}

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

  group('models parse the real contract', () {
    test('user list item, request with committee members', () {
      final user = AdminUserModel.fromJson(_userJson);
      expect(user.roles, <String>['IMAM']);
      expect(user.masjidName, 'Jama Masjid');
      expect(user.createdAt, DateTime.utc(2026, 6, 19));

      final request = AdminMasjidRequestModel.fromJson(_requestJson);
      expect(request.isPending, isTrue);
      expect(request.committeeMembers.single.name, 'Yusuf');

      final page = _page(
        <Map<String, dynamic>>[_masjidJson],
        AdminMasjidModel.fromJson,
        total: 41,
        hasNextPage: true,
      );
      expect(page.meta.total, 41);
      expect(page.meta.hasNextPage, isTrue);
      expect(page.items.single.usersCount, 12);
    });
  });

  group('AdminUsersScreen', () {
    testWidgets('shows users from the API', (tester) async {
      when(
        () => repository.getUsers(any(), page: any(named: 'page')),
      ).thenAnswer(
        (_) async =>
            _page(<Map<String, dynamic>>[_userJson], AdminUserModel.fromJson),
      );

      await _pump(tester, repository, const Scaffold(body: AdminUsersScreen()));

      expect(find.text('Abdul Rahman'), findsOneWidget);
      expect(find.text('Imam, Jama Masjid'), findsOneWidget);
      expect(find.text('Active'), findsWidgets);
    });

    testWidgets('shows the server error with Try again', (tester) async {
      when(
        () => repository.getUsers(any(), page: any(named: 'page')),
      ).thenThrow(
        const ApiException(
          message: 'Requires permission: platform.users.read',
          code: ApiErrorCodes.forbidden,
          statusCode: 403,
        ),
      );

      await _pump(tester, repository, const Scaffold(body: AdminUsersScreen()));

      expect(
        find.text('Requires permission: platform.users.read'),
        findsOneWidget,
      );
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('status filter reloads with that status', (tester) async {
      when(
        () => repository.getUsers(any(), page: any(named: 'page')),
      ).thenAnswer(
        (_) async =>
            _page(<Map<String, dynamic>>[_userJson], AdminUserModel.fromJson),
      );

      await _pump(tester, repository, const Scaffold(body: AdminUsersScreen()));
      await tester.tap(find.widgetWithText(ChoiceChip, 'Inactive'));
      await tester.pump();
      await tester.pump();

      final filters = verify(
        () => repository.getUsers(captureAny(), page: any(named: 'page')),
      ).captured.cast<AdminListFilter>();
      expect(filters.last.status, 'INACTIVE');
    });
  });

  testWidgets('AdminMasjidsScreen shows masjids from the API', (tester) async {
    when(
      () => repository.getMasjids(any(), page: any(named: 'page')),
    ).thenAnswer(
      (_) async =>
          _page(<Map<String, dynamic>>[_masjidJson], AdminMasjidModel.fromJson),
    );

    await _pump(tester, repository, const Scaffold(body: AdminMasjidsScreen()));

    expect(find.text('Jama Masjid'), findsOneWidget);
    expect(find.text('Imam: Abdul Rahman, 12 people'), findsOneWidget);
  });

  testWidgets('on desktop a picked request opens beside the list', (
    tester,
  ) async {
    when(
      () => repository.getMasjidRequests(any(), page: any(named: 'page')),
    ).thenAnswer(
      (_) async => _page(<Map<String, dynamic>>[
        _requestJson,
      ], AdminMasjidRequestModel.fromJson),
    );
    when(
      () => repository.getMasjidRequest('r1'),
    ).thenAnswer((_) async => AdminMasjidRequestModel.fromJson(_requestJson));

    await _pump(
      tester,
      repository,
      const Scaffold(body: AdminMasjidRequestsScreen()),
      size: const Size(1400, 900),
    );
    expect(find.text('Pick one from the list to see it here.'), findsOneWidget);

    await tester.tap(find.text('Noor Masjid'));
    await tester.pumpAndSettle();

    expect(find.text('Noor Masjid'), findsNWidgets(2));
    expect(find.text('Approve'), findsOneWidget);
    expect(find.text('Reject'), findsOneWidget);
  });

  group('request details', () {
    setUp(() {
      when(
        () => repository.getMasjidRequest('r1'),
      ).thenAnswer((_) async => AdminMasjidRequestModel.fromJson(_requestJson));
    });

    testWidgets('show the masjid, imam, and committee members', (tester) async {
      await _pump(
        tester,
        repository,
        const AdminMasjidRequestDetailScreen(id: 'r1'),
      );

      expect(find.text('Noor Masjid'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Yusuf'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('+919876543212, Ibrahim'), findsOneWidget);
    });

    testWidgets('approve that hits USER_IN_ANOTHER_MASJID shows the message', (
      tester,
    ) async {
      const message =
          'Committee member +919876543212 is already a member of another '
          'masjid. Ask them to leave that masjid from the app first, or '
          'change the request.';
      when(() => repository.approveMasjidRequest('r1')).thenThrow(
        const ApiException(
          message: message,
          code: ApiErrorCodes.userInAnotherMasjid,
          statusCode: 409,
        ),
      );

      await _pump(
        tester,
        repository,
        const AdminMasjidRequestDetailScreen(id: 'r1'),
      );
      await _approveAndConfirm(tester);

      expect(find.text('Cannot approve'), findsOneWidget);
      expect(find.text(message), findsOneWidget);
      // Nothing changed, so the request is not reloaded.
      verify(() => repository.getMasjidRequest('r1')).called(1);
    });

    testWidgets('a successful approve reloads the request', (tester) async {
      when(
        () => repository.approveMasjidRequest('r1'),
      ).thenAnswer((_) async {});

      await _pump(
        tester,
        repository,
        const AdminMasjidRequestDetailScreen(id: 'r1'),
      );
      await _approveAndConfirm(tester);

      expect(find.text('Request approved'), findsOneWidget);
      verify(() => repository.approveMasjidRequest('r1')).called(1);
      verify(() => repository.getMasjidRequest('r1')).called(2);
    });
  });

  group('user details load by id', () {
    testWidgets('from a fresh URL (no extra)', (tester) async {
      when(
        () => repository.getUser('u1'),
      ).thenAnswer((_) async => AdminUserModel.fromJson(_userJson));

      await _pump(tester, repository, const AdminUserDetailScreen(id: 'u1'));

      verify(() => repository.getUser('u1')).called(1);
      expect(find.text('Abdul Rahman'), findsOneWidget);
      expect(find.text('Imam'), findsOneWidget);
    });

    testWidgets('shows the server error', (tester) async {
      when(() => repository.getUser('nope')).thenThrow(
        const ApiException(
          message: 'User not found',
          code: 'NOT_FOUND',
          statusCode: 404,
        ),
      );

      await _pump(tester, repository, const AdminUserDetailScreen(id: 'nope'));

      expect(find.text('User not found'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });
  });
}
