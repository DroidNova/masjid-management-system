// mocktail needs `when(() => mock.call())` closures, not tear-offs.
// ignore_for_file: unnecessary_lambdas

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/pagination/page.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/community/data/community_repository.dart';
import 'package:masjid_core_frontend/features/community/data/models/community_user_model.dart';
import 'package:masjid_core_frontend/features/community/data/models/masjid_detail_model.dart';
import 'package:masjid_core_frontend/features/community/presentation/add_community_user_screen.dart';
import 'package:masjid_core_frontend/features/community/presentation/community_screen.dart';
import 'package:masjid_core_frontend/features/community/presentation/edit_community_user_screen.dart';
import 'package:masjid_core_frontend/features/contributions/data/contributions_repository.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/collection_contribution.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/my_contribution_summary.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/my_imam_salary_month.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/my_imam_salary_payment.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/project_contribution.dart';
import 'package:masjid_core_frontend/features/contributions/presentation/imam_salary_payment_history_screen.dart';
import 'package:masjid_core_frontend/features/contributions/presentation/my_contributions_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../shared/ui/ui_test_helpers.dart';
import 'community/community_test_helpers.dart';

class _MockContributions extends Mock implements ContributionsRepository {}

const _manager = <String>[
  AppPermissions.membersRead,
  AppPermissions.membersManage,
  AppPermissions.ownContributionsRead,
];

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

const _villager = CommunityUserModel(
  id: 'u-member',
  fullName: 'Mohammed Abdul Rafiq Khan Sahab',
  roles: ['MEMBER'],
  phone: '+919876543210',
  email: 'mohammed.abdul.rafiq.khan@example.com',
  fatherName: 'Abdul Karim Khan Sahab',
  age: 54,
  isFamilyHead: true,
  familyMemberCount: 12,
  status: 'ACTIVE',
);

Future<void> _openFirstPerson(WidgetTester tester) async {
  await tester.tap(find.text(_villager.fullName).first);
  await tester.pumpAndSettle();
}

Future<void> _openSection(WidgetTester tester, int index) async {
  await tester.scrollUntilVisible(
    find.byWidgetPredicate((widget) => widget is SegmentedButton),
    300,
    scrollable: find.byType(Scrollable).first,
  );
  final segments = find.descendant(
    of: find.byWidgetPredicate((widget) => widget is SegmentedButton),
    matching: find.byType(Icon),
  );
  await tester.tap(segments.at(index));
  await tester.pumpAndSettle();
}

/// People and My payments screens lay out without overflow in each
/// language, on a phone and on desktop, and with a large device font.
/// Long names and big numbers on purpose.
void main() {
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
    'people': (const Scaffold(body: CommunityScreen()), null),
    'person details': (
      const Scaffold(body: CommunityScreen()),
      _openFirstPerson,
    ),
    'add person': (const AddCommunityUserScreen(), null),
    'edit person last step': (
      const EditCommunityUserScreen(userId: 'u-member', initial: _villager),
      (tester) async {
        for (var i = 0; i < 2; i++) {
          final next = find.widgetWithText(FilledButton, 'Next');
          if (next.evaluate().isEmpty) break;
          await tester.ensureVisible(next);
          await tester.tap(next);
          await tester.pumpAndSettle();
        }
      },
    ),
    'my payments salary': (const MyContributionsScreen(showAppBar: true), null),
    'my payments projects': (
      const MyContributionsScreen(),
      (tester) => _openSection(tester, 1),
    ),
    'my payments donations': (
      const MyContributionsScreen(),
      (tester) => _openSection(tester, 2),
    ),
    'salary payments': (
      const ImamSalaryPaymentHistoryScreen(month: 6, year: 2026),
      null,
    ),
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
    final community = MockCommunityRepository();
    when(() => community.getMyMasjid()).thenAnswer(
      (_) async => const MasjidDetailModel(
        id: 'm1',
        name: 'Jama Masjid Barota Sharif and Madrasa',
        locality: 'Barota',
        welcomeMsg: 'Welcome to our masjid. Please pray with us every day.',
        district: 'Muzaffarpur',
        state: 'Bihar',
      ),
    );
    when(() => community.getMyMasjidUsers()).thenAnswer(
      (_) async => const <CommunityUserModel>[
        _villager,
        CommunityUserModel(
          id: 'u-imam',
          fullName: 'Maulana Imam Sahab Qari Abdul Hakeem',
          roles: ['IMAM'],
        ),
        CommunityUserModel(
          id: 'u-old',
          fullName: 'Old Member Who Left The Village',
          roles: ['MEMBER'],
          status: 'INACTIVE',
        ),
      ],
    );

    final contributions = _MockContributions();
    when(() => contributions.getMySummary()).thenAnswer(
      (_) async => const MyContributionSummary(
        user: MyContributionUser(id: 'u1', fullName: 'Rafiq'),
        imamSalary: ImamSalaryContributionSummary(
          totalExpected: 1234567,
          totalPaid: 234567,
          totalDue: 1000000,
        ),
        projectContributionTotal: 9876543,
        collectionContributionTotal: 1234567.5,
        totalContributionAmount: 12345678.5,
      ),
    );
    when(
      () => contributions.getMyImamSalaryMonths(page: any(named: 'page')),
    ).thenAnswer(
      (_) async => _page(const <MyImamSalaryMonth>[
        MyImamSalaryMonth(
          month: 9,
          year: 2026,
          expectedAmount: 123456,
          paidAmount: 23456,
          dueAmount: 100000,
          status: 'PARTIAL',
          paymentsCount: 2,
        ),
      ]),
    );
    when(
      () => contributions.getMyProjectContributions(page: any(named: 'page')),
    ).thenAnswer(
      (_) async => _page(<ProjectContribution>[
        ProjectContribution(
          id: 'p1',
          amount: 1234567,
          paymentMode: 'ONLINE',
          paidAt: DateTime(2026, 6, 3),
          project: const ContributionProject(
            title: 'New wudu area, roof repair, and painting of the masjid',
          ),
        ),
      ]),
    );
    when(
      () =>
          contributions.getMyCollectionContributions(page: any(named: 'page')),
    ).thenAnswer(
      (_) async => _page(<CollectionContribution>[
        CollectionContribution(
          id: 'c1',
          collectionType: 'ZAKAT',
          amount: 1234567,
          paymentMode: 'CASH',
          paidAt: DateTime(2026, 6, 3),
        ),
      ]),
    );
    when(
      () => contributions.getMyImamSalaryPayments(
        month: 6,
        year: 2026,
        page: any(named: 'page'),
      ),
    ).thenAnswer(
      (_) async => _page(<MyImamSalaryPayment>[
        MyImamSalaryPayment(
          id: 'x1',
          amount: 1234567,
          paymentMode: 'CASH',
          paidAt: DateTime(2026, 6, 10),
          collectedByName: 'Committee Treasurer Haji Abdul Sattar',
          note: 'Paid after Jumma namaz, for the whole family',
        ),
      ]),
    );

    await pumpRouted(
      tester,
      screen.$1,
      locale: locale,
      size: size,
      overrides: [
        communityRepositoryProvider.overrideWithValue(community),
        contributionsRepositoryProvider.overrideWithValue(contributions),
        authControllerProvider.overrideWith(
          () => FixedAuth(testUser(permissions: _manager)),
        ),
      ],
    );
    await screen.$2?.call(tester);
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
