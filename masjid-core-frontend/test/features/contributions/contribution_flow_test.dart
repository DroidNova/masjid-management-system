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
import 'package:masjid_core_frontend/features/contributions/data/models/new_contribution.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/project_contribution.dart';
import 'package:masjid_core_frontend/features/contributions/presentation/collection_contributions_screen.dart';
import 'package:masjid_core_frontend/features/contributions/presentation/contribution_flow_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../shared/ui/ui_test_helpers.dart';

class _MockRepository extends Mock implements ContributionsRepository {}

class _SignedIn extends AuthController {
  @override
  AuthState build() => const AuthSignedIn(
    AppUser(
      id: 'u1',
      fullName: 'Treasurer',
      permissions: <String>[
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

void main() {
  late _MockRepository repository;
  final today = DateTime(2026, 10, 9);

  setUpAll(() {
    registerFallbackValue(
      NewContribution(
        contributorName: 'x',
        amount: 1,
        paymentMode: 'CASH',
        paidAt: DateTime(2026),
      ),
    );
  });

  setUp(() {
    repository = _MockRepository();
    when(() => repository.getContributorOptions()).thenAnswer(
      (_) async => const <ContributorOption>[
        ContributorOption(
          id: 'm1',
          fullName: 'Ahmed Khan',
          phone: '+919811111111',
        ),
        ContributorOption(id: 'm2', fullName: 'Bilal Shaikh'),
      ],
    );
  });

  Future<void> pumpFlow(WidgetTester tester, {String? projectId}) => pumpRouted(
    tester,
    ContributionFlowScreen(projectId: projectId, today: today),
    size: const Size(420, 1600),
    overrides: [
      contributionsRepositoryProvider.overrideWithValue(repository),
      authControllerProvider.overrideWith(_SignedIn.new),
    ],
  );

  testWidgets('a member gives zakat online', (tester) async {
    when(
      () => repository.addCollectionContribution(any()),
    ).thenAnswer((_) async => const CollectionContribution(id: 'k1'));
    await pumpFlow(tester);

    // Who: pick from the members list (moves on by itself).
    await tester.tap(find.text('Pick a member'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'ahmed');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ahmed Khan'));
    await tester.pumpAndSettle();

    // What for: zakat (moves on by itself).
    expect(find.text('What for?'), findsOneWidget);
    await tester.tap(find.text('Zakat'));
    await tester.pumpAndSettle();

    // How much, online.
    await tapKeypad(tester, '1100');
    await tester.tap(find.text('Online'));
    await tester.pump();
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Save'));
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    final saved =
        verify(
              () => repository.addCollectionContribution(captureAny()),
            ).captured.single
            as NewContribution;
    expect(saved.memberId, 'm1');
    expect(saved.contributorName, 'Ahmed Khan');
    expect(saved.contributorPhone, '+919811111111');
    expect(saved.collectionType, 'ZAKAT');
    expect(saved.amount, 1100);
    expect(saved.paymentMode, 'ONLINE');
    expect(saved.paidAt, today);
    expect(find.text('+₹1,100 · Ahmed Khan'), findsOneWidget);
  });

  testWidgets('someone who is not a member gives to a project', (tester) async {
    when(
      () => repository.addProjectContribution('p1', any()),
    ).thenAnswer((_) async => const ProjectContribution(id: 'c9'));
    await pumpFlow(tester, projectId: 'p1');

    await tester.tap(find.text('Not a member'));
    await tester.pump();
    final next = find.widgetWithText(FilledButton, 'Next');
    expect(tester.widget<FilledButton>(next).onPressed, isNull);
    await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'Guest');
    await tester.pump();
    await tester.tap(next);
    await tester.pumpAndSettle();

    // Projects have no "what for" step.
    expect(find.text('How much?'), findsOneWidget);
    await tester.tap(find.text('₹500'));
    await tester.pump();
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Save'));
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    final saved =
        verify(
              () => repository.addProjectContribution('p1', captureAny()),
            ).captured.single
            as NewContribution;
    expect(saved.memberId, isNull);
    expect(saved.contributorName, 'Guest');
    expect(saved.collectionType, isNull);
    expect(saved.paymentMode, 'CASH');
  });

  testWidgets('Givers lists who gave, what for, and how', (tester) async {
    when(
      () => repository.getCollectionContributions(
        search: any(named: 'search'),
        paymentMode: any(named: 'paymentMode'),
        collectionType: any(named: 'collectionType'),
        page: any(named: 'page'),
      ),
    ).thenAnswer(
      (_) async => _page(<CollectionContribution>[
        CollectionContribution(
          id: 'k1',
          collectionType: 'DONATION_BOX',
          contributorName: 'Yusuf',
          amount: 250.5,
          paymentMode: 'ONLINE',
          paidAt: DateTime(2026, 6, 4),
        ),
      ]),
    );
    await pumpRouted(
      tester,
      const CollectionContributionsScreen(),
      overrides: [
        contributionsRepositoryProvider.overrideWithValue(repository),
        authControllerProvider.overrideWith(_SignedIn.new),
      ],
      extraRoutes: const <String, Widget>{
        '/contributions/new': Scaffold(body: Text('flow page')),
      },
    );

    expect(find.text('Yusuf'), findsOneWidget);
    expect(find.text('Donation box'), findsWidgets);
    expect(find.text('Online'), findsOneWidget);
    expect(find.text('+₹250.50'), findsOneWidget);
    expect(find.text('4 Jun 2026'), findsOneWidget);

    await tester.tap(find.text('Add giver'));
    await tester.pumpAndSettle();
    expect(find.text('flow page'), findsOneWidget);
  });
}
