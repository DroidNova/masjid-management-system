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
import 'package:masjid_core_frontend/features/imam_salary/application/imam_salary_controllers.dart';
import 'package:masjid_core_frontend/features/imam_salary/data/imam_salary_repository.dart';
import 'package:masjid_core_frontend/features/imam_salary/data/models/imam_salary_models.dart';
import 'package:masjid_core_frontend/features/imam_salary/presentation/imam_salary_screen.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepository extends Mock implements ImamSalaryRepository {}

class _SignedIn extends AuthController {
  _SignedIn(this.permissions);

  final List<String> permissions;

  @override
  AuthState build() => AuthSignedIn(
    AppUser(id: 'u1', fullName: 'Test User', permissions: permissions),
  );
}

const _month = ImamSalaryMonth(
  id: 'm1',
  month: 6,
  year: 2026,
  amountPerHead: 600,
  totalExpected: 1200,
  totalCollected: 200,
  totalDue: 1000,
  partialCount: 1,
  unpaidCount: 1,
);

const _assignment = SalaryAssignment(
  id: 'a1',
  memberName: 'Ahmed Khan',
  memberPhone: '9876500000',
  expectedAmount: 600,
  paidAmount: 200,
  dueAmount: 400,
  status: SalaryStatus.partial,
);

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
  ImamSalaryRepository repository,
  List<String> permissions,
) async {
  tester.view.physicalSize = const Size(1000, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        imamSalaryRepositoryProvider.overrideWithValue(repository),
        authControllerProvider.overrideWith(() => _SignedIn(permissions)),
        salaryPeriodProvider.overrideWith((ref) => (month: 6, year: 2026)),
      ],
      child: const MaterialApp(home: ImamSalaryScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  late _MockRepository repository;

  setUpAll(() {
    initializeDateFormatting('en_IN');
    registerFallbackValue(DateTime(2026));
  });

  setUp(() {
    repository = _MockRepository();
    when(
      () => repository.findMonth(
        month: any(named: 'month'),
        year: any(named: 'year'),
      ),
    ).thenAnswer((_) async => _month);
    when(
      () => repository.getAssignments(
        any(),
        status: any(named: 'status'),
        search: any(named: 'search'),
        page: any(named: 'page'),
      ),
    ).thenAnswer((_) async => _page(<SalaryAssignment>[_assignment]));
    when(
      () => repository.getPayments(
        month: any(named: 'month'),
        year: any(named: 'year'),
        paymentMode: any(named: 'paymentMode'),
        search: any(named: 'search'),
        page: any(named: 'page'),
      ),
    ).thenAnswer(
      (_) async => _page(<SalaryPayment>[
        SalaryPayment(
          id: 'p1',
          memberName: 'Ahmed Khan',
          amount: 200,
          paymentMode: 'CASH',
          paidAt: DateTime(2026, 6, 2),
          collectedByName: 'Committee One',
        ),
      ]),
    );
  });

  group('committee (imam_salary.manage)', () {
    const permissions = <String>[
      AppPermissions.imamSalaryManage,
      AppPermissions.imamSalaryRead,
    ];

    testWidgets('shows the ledger with actions', (tester) async {
      await _pump(tester, repository, permissions);

      expect(find.text('Imam Salary'), findsOneWidget);
      expect(find.text('June 2026'), findsOneWidget);
      expect(find.text('Due ₹1,000'), findsOneWidget);
      expect(find.text('Increase Salary'), findsOneWidget);
      expect(find.text('Assignments'), findsOneWidget);
      expect(find.text('Transactions'), findsOneWidget);
      expect(find.text('Ahmed Khan'), findsOneWidget);
      expect(find.text('Add Payment'), findsOneWidget);
    });

    testWidgets('offers "Start Salary Month" when the month is missing', (
      tester,
    ) async {
      when(
        () => repository.findMonth(
          month: any(named: 'month'),
          year: any(named: 'year'),
        ),
      ).thenAnswer((_) async => null);

      await _pump(tester, repository, permissions);

      expect(find.text('Start Salary Month'), findsOneWidget);
      expect(find.text('Increase Salary'), findsNothing);
    });

    testWidgets('payment above the due amount is refused in the form', (
      tester,
    ) async {
      await _pump(tester, repository, permissions);

      await tester.tap(find.text('Add Payment'));
      await tester.pumpAndSettle();
      expect(find.text('Payment from Ahmed Khan'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Amount'),
        '500',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Add Payment'));
      await tester.pumpAndSettle();

      expect(
        find.text('Payment cannot exceed the due amount (₹400)'),
        findsOneWidget,
      );
      verifyNever(
        () => repository.addPayment(
          assignmentId: any(named: 'assignmentId'),
          amount: any(named: 'amount'),
          paymentMode: any(named: 'paymentMode'),
          paidAt: any(named: 'paidAt'),
          note: any(named: 'note'),
        ),
      );
    });

    testWidgets('a server error on the month load shows message and retry', (
      tester,
    ) async {
      when(
        () => repository.findMonth(
          month: any(named: 'month'),
          year: any(named: 'year'),
        ),
      ).thenThrow(
        const ApiException(
          message: 'Salary month not found',
          code: 'IMAM_SALARY_NOT_FOUND',
          statusCode: 404,
        ),
      );

      await _pump(tester, repository, permissions);

      expect(find.text('Salary month not found'), findsWidgets);
      expect(find.text('Retry'), findsWidgets);
    });
  });

  testWidgets('imam (imam_salary.read) sees the summary read-only', (
    tester,
  ) async {
    await _pump(tester, repository, const <String>[
      AppPermissions.imamSalaryRead,
    ]);

    expect(find.text('June 2026'), findsOneWidget);
    expect(find.text('Collected ₹200'), findsOneWidget);
    expect(find.text('Increase Salary'), findsNothing);
    expect(find.text('Assignments'), findsNothing);
    expect(find.text('Add Payment'), findsNothing);
    verifyNever(
      () => repository.getAssignments(
        any(),
        status: any(named: 'status'),
        search: any(named: 'search'),
        page: any(named: 'page'),
      ),
    );
  });

  testWidgets('member (own_contributions.read) sees own history', (
    tester,
  ) async {
    when(() => repository.getMyHistory()).thenAnswer(
      (_) async => const <MySalaryHistoryMonth>[
        MySalaryHistoryMonth(
          month: 5,
          year: 2026,
          expectedAmount: 600,
          paidAmount: 600,
          status: SalaryStatus.paid,
          payments: <MySalaryHistoryPayment>[
            MySalaryHistoryPayment(id: 'p1', amount: 600),
          ],
        ),
      ],
    );

    await _pump(tester, repository, const <String>[
      AppPermissions.ownContributionsRead,
    ]);

    expect(find.text('My Imam Salary History'), findsOneWidget);
    expect(find.text('May 2026'), findsOneWidget);
    expect(find.text(SalaryStatus.paid), findsOneWidget);
    expect(find.textContaining('1 payment(s)'), findsOneWidget);
    verifyNever(
      () => repository.findMonth(
        month: any(named: 'month'),
        year: any(named: 'year'),
      ),
    );
  });

  testWidgets('member history load error shows a retry', (tester) async {
    when(() => repository.getMyHistory()).thenThrow(
      const ApiException(
        message: 'Cannot reach the server. Check your internet connection.',
        code: ApiErrorCodes.network,
      ),
    );

    await _pump(tester, repository, const <String>[
      AppPermissions.ownContributionsRead,
    ]);

    expect(
      find.text('Cannot reach the server. Check your internet connection.'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
  });
}
