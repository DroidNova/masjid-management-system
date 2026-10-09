// mocktail needs `when(() => mock.call())` closures, not tear-offs.
// ignore_for_file: unnecessary_lambdas

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/pagination/page.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/auth/data/models/app_user.dart';
import 'package:masjid_core_frontend/features/contributions/data/contributions_repository.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/collection_contribution.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/contributor_option.dart';
import 'package:masjid_core_frontend/features/contributions/presentation/collection_contributions_screen.dart';
import 'package:masjid_core_frontend/features/contributions/presentation/contribution_flow_screen.dart';
import 'package:masjid_core_frontend/features/finance/data/finance_repository.dart';
import 'package:masjid_core_frontend/features/finance/data/models/collection_entry_model.dart';
import 'package:masjid_core_frontend/features/finance/data/models/finance_entry_filter.dart';
import 'package:masjid_core_frontend/features/finance/data/models/finance_summary_model.dart';
import 'package:masjid_core_frontend/features/finance/presentation/finance_screen.dart';
import 'package:masjid_core_frontend/features/finance/presentation/money_entry_screen.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';
import 'package:mocktail/mocktail.dart';

import '../shared/ui/ui_test_helpers.dart';

class _MockFinance extends Mock implements FinanceRepository {}

class _MockContributions extends Mock implements ContributionsRepository {}

class _Treasurer extends AuthController {
  @override
  AuthState build() => const AuthSignedIn(
    AppUser(
      id: 'u1',
      fullName: 'Treasurer',
      masjidId: 'm1',
      permissions: <String>[
        AppPermissions.financeRead,
        AppPermissions.collectionsManage,
        AppPermissions.expensesManage,
        AppPermissions.imamSalaryRead,
        AppPermissions.contributionsRead,
        AppPermissions.contributionsRecord,
      ],
    ),
  );
}

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

/// The Money screens lay out without overflow in each language, on a phone
/// and on desktop, and with a large device font. Big amounts on purpose.
void main() {
  setUpAll(() => registerFallbackValue(const FinanceEntryFilter()));
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

  /// name → (screen, what to do after it opens)
  final screens = <String, (Widget, Future<void> Function(WidgetTester)?)>{
    'money': (const Scaffold(body: FinanceScreen()), null),
    'money in, amount page': (
      MoneyEntryScreen(isExpense: false, today: DateTime(2026, 10, 9)),
      (tester) async {
        await tester.tap(find.byType(ActionTile).first);
        await tester.pumpAndSettle();
      },
    ),
    'givers': (const CollectionContributionsScreen(), null),
    'add giver': (const ContributionFlowScreen(), null),
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
    final finance = _MockFinance();
    when(() => finance.getFinanceSummary()).thenAnswer(
      (_) async => const FinanceSummaryModel(
        currentBalance: 12345678.5,
        thisMonthCollection: 9876543,
        thisMonthExpense: 1234567,
      ),
    );
    when(
      () => finance.getCollections(any(), page: any(named: 'page')),
    ).thenAnswer(
      (_) async => _page([
        CollectionEntryModel(
          id: 'c1',
          type: 'CONSTRUCTION_FUND',
          amount: 1234567.75,
          title: 'Collection for the new wudu area and the roof',
          description: 'Given after Jumma by the whole village',
          collectedAt: DateTime.utc(2026, 10, 2),
        ),
        CollectionEntryModel(
          id: 'c2',
          type: 'JUMMA_COLLECTION',
          amount: 500,
          status: 'CANCELLED',
          collectedAt: DateTime.utc(2026, 10, 2),
        ),
      ]),
    );
    final contributions = _MockContributions();
    when(() => contributions.getContributorOptions()).thenAnswer(
      (_) async => const <ContributorOption>[
        ContributorOption(id: 'm1', fullName: 'Ahmed'),
      ],
    );
    when(
      () => contributions.getCollectionContributions(
        search: any(named: 'search'),
        paymentMode: any(named: 'paymentMode'),
        collectionType: any(named: 'collectionType'),
        page: any(named: 'page'),
      ),
    ).thenAnswer(
      (_) async => _page(<CollectionContribution>[
        CollectionContribution(
          id: 'k1',
          collectionType: 'CONSTRUCTION_FUND',
          contributorName: 'Mohammed Abdul Rafiq Khan Sahab',
          amount: 1234567,
          paymentMode: 'ONLINE',
          paidAt: DateTime(2026, 6, 4),
          note: 'For the roof of the masjid and the new wudu area',
        ),
      ]),
    );

    await pumpUi(
      tester,
      screen.$1,
      locale: locale,
      size: size,
      overrides: [
        financeRepositoryProvider.overrideWithValue(finance),
        contributionsRepositoryProvider.overrideWithValue(contributions),
        authControllerProvider.overrideWith(_Treasurer.new),
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
