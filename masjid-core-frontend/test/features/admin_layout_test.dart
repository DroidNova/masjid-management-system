// mocktail needs `when(() => mock.call())` closures, not tear-offs.
// ignore_for_file: unnecessary_lambdas

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/pagination/page.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_dashboard_summary.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_list_filter.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_masjid_model.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_masjid_request_model.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_user_model.dart';
import 'package:masjid_core_frontend/features/super_admin/data/super_admin_repository.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/admin_parts.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/masjid_requests/admin_masjid_request_detail_screen.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/masjid_requests/admin_masjid_requests_screen.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/masjids/admin_masjid_detail_screen.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/masjids/admin_masjids_screen.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/super_admin_dashboard_screen.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/users/admin_user_detail_screen.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/users/admin_users_screen.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';
import 'package:mocktail/mocktail.dart';

import '../shared/ui/ui_test_helpers.dart';

class _MockRepository extends Mock implements SuperAdminRepository {}

PageResult<T> _page<T>(List<T> items) => PageResult<T>(
  items: items,
  meta: PageMeta(
    page: 1,
    limit: 20,
    total: items.length,
    totalPages: 1,
    hasNextPage: false,
  ),
);

const _request = AdminMasjidRequestModel(
  id: 'r1',
  masjidName: 'Jama Masjid Barota Sharif and Madrasa Islamia',
  status: 'REJECTED',
  rejectionReason: 'The phone number of the imam did not answer for a week',
  requesterName: 'Mohammed Abdul Rafiq Khan Sahab',
  requesterPhone: '+919876543210',
  requesterEmail: 'mohammed.abdul.rafiq.khan@example.com',
  locality: 'Barota Kheri',
  district: 'Lakhimpur Kheri',
  state: 'Uttar Pradesh',
  country: 'India',
  address: 'Near the old station road, behind the big school',
  imamName: 'Maulana Qari Abdul Hakeem Sahab',
  imamPhone: '+919876543211',
  committeeMembers: <CommitteeMember>[
    CommitteeMember(
      name: 'Haji Abdul Sattar',
      phone: '+919876543212',
      fatherName: 'Abdul Ghaffar',
    ),
  ],
);

const _masjid = AdminMasjidModel(
  id: 'm1',
  name: 'Jama Masjid Barota Sharif and Madrasa Islamia',
  status: 'SUSPENDED',
  rejectionReason: 'Fake details were sent in the request form',
  locality: 'Barota Kheri',
  district: 'Lakhimpur Kheri',
  state: 'Uttar Pradesh',
  imamName: 'Maulana Qari Abdul Hakeem Sahab',
  usersCount: 12345,
);

const _user = AdminUserModel(
  id: 'u1',
  fullName: 'Mohammed Abdul Rafiq Khan Sahab',
  status: 'ACTIVE',
  phone: '+919876543210',
  email: 'mohammed.abdul.rafiq.khan@example.com',
  masjidName: 'Jama Masjid Barota Sharif and Madrasa Islamia',
  roles: <String>['IMAM', 'COMMITTEE_MEMBER', 'MEMBER'],
);

Future<void> _pickFirst(WidgetTester tester) async {
  await tester.tap(find.byType(AdminListCard).first);
  await tester.pumpAndSettle();
}

/// Admin screens lay out without overflow in each language, on a phone and
/// on desktop (list and details side by side), and with a large font.
void main() {
  setUpAll(() => registerFallbackValue(const AdminListFilter()));
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

  /// name → (screen, after it opens)
  final screens = <String, (Widget, Future<void> Function(WidgetTester)?)>{
    'dashboard': (const Scaffold(body: SuperAdminDashboardScreen()), null),
    'requests': (const Scaffold(body: AdminMasjidRequestsScreen()), _pickFirst),
    'request': (const AdminMasjidRequestDetailScreen(id: 'r1'), null),
    'masjids': (const Scaffold(body: AdminMasjidsScreen()), _pickFirst),
    'masjid': (const AdminMasjidDetailScreen(id: 'm1'), null),
    'users': (const Scaffold(body: AdminUsersScreen()), _pickFirst),
    'user': (const AdminUserDetailScreen(id: 'u1'), null),
    'not found': (const NotFoundView(), null),
  };
  const sizes = <String, Size>{
    'phone': Size(360, 780),
    'desktop': Size(1280, 900),
  };

  Future<void> pump(
    WidgetTester tester,
    (Widget, Future<void> Function(WidgetTester)?) screen,
    Locale locale,
    Size size,
  ) async {
    final repository = _MockRepository();
    when(() => repository.getDashboardSummary()).thenAnswer(
      (_) async => const AdminDashboardSummary(
        totalUsers: 1234567,
        activeUsers: 1234000,
        inactiveUsers: 500,
        suspendedUsers: 67,
        totalMasjids: 12345,
        approvedMasjids: 12000,
        pendingMasjids: 300,
        suspendedMasjids: 45,
        pendingRequests: 1234,
        approvedRequests: 12000,
        rejectedRequests: 456,
      ),
    );
    when(
      () => repository.getMasjidRequests(any(), page: any(named: 'page')),
    ).thenAnswer((_) async => _page(<AdminMasjidRequestModel>[_request]));
    when(
      () => repository.getMasjidRequest('r1'),
    ).thenAnswer((_) async => _request);
    when(
      () => repository.getMasjids(any(), page: any(named: 'page')),
    ).thenAnswer((_) async => _page(<AdminMasjidModel>[_masjid]));
    when(() => repository.getMasjid('m1')).thenAnswer((_) async => _masjid);
    when(
      () => repository.getUsers(any(), page: any(named: 'page')),
    ).thenAnswer((_) async => _page(<AdminUserModel>[_user]));
    when(() => repository.getUser('u1')).thenAnswer((_) async => _user);

    await pumpRouted(
      tester,
      screen.$1,
      locale: locale,
      size: size,
      overrides: [superAdminRepositoryProvider.overrideWithValue(repository)],
    );
    // On phones a picked item opens as a page; only desktop shows it here.
    if (size.width >= 1024) await screen.$2?.call(tester);
  }

  for (final screen in screens.entries) {
    for (final language in <String>['en', 'hi', 'ur']) {
      for (final size in sizes.entries) {
        testWidgets('${screen.key} in $language on a ${size.key}', (
          tester,
        ) async {
          await pump(tester, screen.value, Locale(language), size.value);
          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('${screen.key} on a phone with a large device font', (
      tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.6;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pump(
        tester,
        screen.value,
        const Locale('ur'),
        const Size(360, 780),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
