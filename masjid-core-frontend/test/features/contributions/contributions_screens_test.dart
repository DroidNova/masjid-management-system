// mocktail needs `when(() => mock.call())` closures, not tear-offs.
// ignore_for_file: unnecessary_lambdas

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/core/pagination/page.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/auth/data/models/app_user.dart';
import 'package:masjid_core_frontend/features/contributions/data/contributions_repository.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/collection_contribution.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/contributor_option.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/my_contribution_summary.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/my_imam_salary_month.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/my_imam_salary_payment.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/new_contribution.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/project_contribution.dart';
import 'package:masjid_core_frontend/features/contributions/presentation/imam_salary_payment_history_screen.dart';
import 'package:masjid_core_frontend/features/contributions/presentation/my_contributions_screen.dart';
import 'package:masjid_core_frontend/features/contributions/presentation/project_contributions_screen.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepository extends Mock implements ContributionsRepository {}

class _SignedIn extends AuthController {
  _SignedIn(this.permissions);

  final List<String> permissions;

  @override
  AuthState build() => AuthSignedIn(
    AppUser(id: 'u1', fullName: 'Test User', permissions: permissions),
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

Future<void> _pump(
  WidgetTester tester,
  ContributionsRepository repository,
  Widget screen, {
  List<String> permissions = const <String>[],
}) async {
  tester.view.physicalSize = const Size(1000, 2000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        contributionsRepositoryProvider.overrideWithValue(repository),
        authControllerProvider.overrideWith(() => _SignedIn(permissions)),
      ],
      child: MaterialApp(home: screen),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  late _MockRepository repository;

  setUpAll(() {
    initializeDateFormatting('en_IN');
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
        ContributorOption(id: 'm1', fullName: 'Ahmed Khan'),
      ],
    );
  });

  group('ProjectContributionsScreen', () {
    setUp(() {
      when(
        () => repository.getProjectContributions(
          any(),
          search: any(named: 'search'),
          paymentMode: any(named: 'paymentMode'),
          page: any(named: 'page'),
        ),
      ).thenAnswer(
        (_) async => _page(<ProjectContribution>[
          ProjectContribution(
            id: 'c1',
            projectId: 'p1',
            contributorName: 'Ahmed Khan',
            amount: 1500,
            paymentMode: 'CASH',
            paidAt: DateTime(2026, 6, 3),
            collectedByName: 'Committee One',
          ),
        ]),
      );
      when(
        () => repository.getProjectTitle('p1'),
      ).thenAnswer((_) async => 'New Roof');
    });

    testWidgets('loads the title by id and lists contributions', (
      tester,
    ) async {
      await _pump(
        tester,
        repository,
        const ProjectContributionsScreen(projectId: 'p1'),
        permissions: const <String>[AppPermissions.contributionsRead],
      );

      expect(find.text('New Roof Contributions'), findsOneWidget);
      expect(find.text('Ahmed Khan'), findsOneWidget);
      expect(find.text('₹1,500'), findsOneWidget);
      expect(find.text('Collected by Committee One'), findsOneWidget);
      // contributions.read only: no add button.
      expect(find.text('Add Contribution'), findsNothing);
    });

    testWidgets('shows the server message when the list fails', (tester) async {
      when(
        () => repository.getProjectContributions(
          any(),
          search: any(named: 'search'),
          paymentMode: any(named: 'paymentMode'),
          page: any(named: 'page'),
        ),
      ).thenThrow(
        const ApiException(
          message: 'Project not found',
          code: 'PROJECT_NOT_FOUND',
          statusCode: 404,
        ),
      );

      await _pump(
        tester,
        repository,
        const ProjectContributionsScreen(projectId: 'p1'),
      );

      expect(find.text('Project not found'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });

  testWidgets('MyContributionsScreen shows summary and each section', (
    tester,
  ) async {
    when(() => repository.getMySummary()).thenAnswer(
      (_) async => const MyContributionSummary(
        user: MyContributionUser(
          id: 'u1',
          fullName: 'Ahmed Khan',
          phone: '+919876500000',
          isFamilyHead: true,
        ),
        imamSalary: ImamSalaryContributionSummary(
          monthsShown: 6,
          totalExpected: 3600,
          totalPaid: 3000,
          totalDue: 600,
          paidMonths: 5,
          unpaidMonths: 1,
        ),
        projectContributionTotal: 1500,
        collectionContributionTotal: 250,
        totalContributionAmount: 4750,
      ),
    );
    when(
      () => repository.getMyImamSalaryMonths(page: any(named: 'page')),
    ).thenAnswer(
      (_) async => _page(<MyImamSalaryMonth>[
        const MyImamSalaryMonth(
          month: 6,
          year: 2026,
          expectedAmount: 600,
          dueAmount: 600,
        ),
      ]),
    );
    when(
      () => repository.getMyProjectContributions(page: any(named: 'page')),
    ).thenAnswer(
      (_) async => _page(<ProjectContribution>[
        const ProjectContribution(
          id: 'c1',
          amount: 1500,
          project: ContributionProject(title: 'New Roof'),
        ),
      ]),
    );
    when(
      () => repository.getMyCollectionContributions(page: any(named: 'page')),
    ).thenAnswer((_) async => _page(<CollectionContribution>[]));

    await _pump(
      tester,
      repository,
      const MyContributionsScreen(),
      permissions: const <String>[AppPermissions.ownContributionsRead],
    );

    expect(find.text('Ahmed Khan'), findsOneWidget);
    expect(find.text('Family Head'), findsOneWidget);
    expect(find.text('All paid contributions ₹4,750'), findsOneWidget);
    expect(find.text('June 2026'), findsOneWidget);
    expect(find.text('View Payments'), findsOneWidget);
    expect(find.text('New Roof'), findsOneWidget);
    expect(find.text('No collection contributions yet.'), findsOneWidget);
  });

  testWidgets('MyContributionsScreen shows a retry when the summary fails', (
    tester,
  ) async {
    when(() => repository.getMySummary()).thenThrow(
      const ApiException(
        message: 'You are not assigned to a masjid',
        code: ApiErrorCodes.userMasjidNotAssigned,
        statusCode: 403,
      ),
    );
    when(
      () => repository.getMyImamSalaryMonths(page: any(named: 'page')),
    ).thenAnswer((_) async => _page(<MyImamSalaryMonth>[]));
    when(
      () => repository.getMyProjectContributions(page: any(named: 'page')),
    ).thenAnswer((_) async => _page(<ProjectContribution>[]));
    when(
      () => repository.getMyCollectionContributions(page: any(named: 'page')),
    ).thenAnswer((_) async => _page(<CollectionContribution>[]));

    await _pump(tester, repository, const MyContributionsScreen());

    expect(find.text('You are not assigned to a masjid'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('ImamSalaryPaymentHistoryScreen lists the month payments', (
    tester,
  ) async {
    when(
      () => repository.getMyImamSalaryPayments(
        month: 5,
        year: 2026,
        page: any(named: 'page'),
      ),
    ).thenAnswer(
      (_) async => _page(<MyImamSalaryPayment>[
        MyImamSalaryPayment(
          id: 'x1',
          amount: 300,
          paymentMode: 'CASH',
          paidAt: DateTime(2026, 5, 10),
          collectedByName: 'Committee One',
          note: 'After Jumma',
        ),
      ]),
    );

    await _pump(
      tester,
      repository,
      const ImamSalaryPaymentHistoryScreen(month: 5, year: 2026),
    );

    expect(find.text('May 2026'), findsOneWidget);
    expect(find.text('₹300'), findsOneWidget);
    expect(find.text('Paid on 10 May 2026'), findsOneWidget);
    expect(find.text('After Jumma'), findsOneWidget);
  });
}
