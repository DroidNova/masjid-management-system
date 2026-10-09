// mocktail needs `when(() => mock.call())` closures, not tear-offs.
// ignore_for_file: unnecessary_lambdas

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/core/pagination/page.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/auth/data/models/app_user.dart';
import 'package:masjid_core_frontend/features/imam_salary/application/imam_salary_controllers.dart';
import 'package:masjid_core_frontend/features/imam_salary/data/imam_salary_repository.dart';
import 'package:masjid_core_frontend/features/imam_salary/data/models/imam_salary_models.dart';
import 'package:masjid_core_frontend/features/imam_salary/presentation/imam_salary_screen.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../shared/ui/ui_test_helpers.dart';

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

const _committee = <String>[
  AppPermissions.imamSalaryManage,
  AppPermissions.imamSalaryRead,
];

Future<void> _pump(
  WidgetTester tester,
  ImamSalaryRepository repository,
  List<String> permissions,
) => pumpRouted(
  tester,
  const ImamSalaryScreen(),
  size: const Size(420, 2000),
  overrides: [
    imamSalaryRepositoryProvider.overrideWithValue(repository),
    authControllerProvider.overrideWith(() => _SignedIn(permissions)),
    salaryPeriodProvider.overrideWith((ref) => (month: 6, year: 2026)),
  ],
);

/// Taps a quick amount chip in an open sheet.
Future<void> _chip(WidgetTester tester, String label) async {
  await tester.tap(find.widgetWithText(ActionChip, label));
  await tester.pump();
}

void main() {
  late _MockRepository repository;

  setUpAll(() => registerFallbackValue(DateTime(2026)));

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
        ),
      ]),
    );
  });

  group('committee', () {
    testWidgets('the month at a glance and each family', (tester) async {
      await _pump(tester, repository, _committee);

      expect(find.byType(SalaryHero), findsOneWidget);
      expect(find.text('₹200'), findsOneWidget);
      expect(find.text('of ₹1,200'), findsOneWidget);
      expect(find.text('1 part paid'), findsOneWidget);
      expect(find.text('1 not paid'), findsOneWidget);
      expect(find.text('Ahmed Khan'), findsOneWidget);
      expect(find.widgetWithText(StatusBadge, 'Part paid'), findsOneWidget);
      expect(find.text('₹400'), findsOneWidget);
    });

    testWidgets("a family's payment: tap the family, then Save", (
      tester,
    ) async {
      when(
        () => repository.addPayment(
          assignmentId: any(named: 'assignmentId'),
          amount: any(named: 'amount'),
          paymentMode: any(named: 'paymentMode'),
          paidAt: any(named: 'paidAt'),
          note: any(named: 'note'),
        ),
      ).thenAnswer((_) async => const SalaryPayment(id: 'p2'));
      await _pump(tester, repository, _committee);

      await tester.tap(find.byType(FamilyDueTile));
      await tester.pumpAndSettle();
      // The amount is already what they owe.
      expect(find.text('₹400'), findsWidgets);
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      verify(
        () => repository.addPayment(
          assignmentId: 'a1',
          amount: 400,
          paymentMode: 'CASH',
          paidAt: any(named: 'paidAt'),
          note: any(named: 'note'),
        ),
      ).called(1);
      expect(find.text('Payment saved'), findsOneWidget);
    });

    testWidgets('more than is due is refused before sending', (tester) async {
      await _pump(tester, repository, _committee);

      await tester.tap(find.byType(FamilyDueTile));
      await tester.pumpAndSettle();
      await tapKeypad(tester, '0');

      expect(
        find.text('This is more than what is due (₹400).'),
        findsOneWidget,
      );
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Save'))
            .onPressed,
        isNull,
      );
    });

    testWidgets('Payments lists who paid', (tester) async {
      await _pump(tester, repository, _committee);

      await tester.tap(
        find.descendant(
          of: find.byType(SegmentedButton<bool>),
          matching: find.text('Payments'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('+₹200'), findsOneWidget);
      expect(find.text('2 Jun 2026'), findsOneWidget);
    });

    testWidgets('a month not started can be started', (tester) async {
      when(
        () => repository.findMonth(
          month: any(named: 'month'),
          year: any(named: 'year'),
        ),
      ).thenAnswer((_) async => null);
      when(
        () => repository.createMonth(
          month: any(named: 'month'),
          year: any(named: 'year'),
          amountPerHead: any(named: 'amountPerHead'),
          note: any(named: 'note'),
        ),
      ).thenAnswer((_) async => _month);
      await _pump(tester, repository, _committee);

      expect(find.text("This month's salary is not started"), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Start month'));
      await tester.pumpAndSettle();
      await _chip(tester, '₹500');
      await tester.tap(find.widgetWithText(FilledButton, 'Start month').last);
      await tester.pumpAndSettle();

      verify(
        () => repository.createMonth(
          month: 6,
          year: 2026,
          amountPerHead: 500,
          note: any(named: 'note'),
        ),
      ).called(1);
    });

    testWidgets('the amount can be raised, never lowered', (tester) async {
      when(
        () => repository.updateAmount(
          any(),
          amountPerHead: any(named: 'amountPerHead'),
          reason: any(named: 'reason'),
        ),
      ).thenAnswer((_) async => _month);
      await _pump(tester, repository, _committee);

      await tester.tap(find.text('Raise amount'));
      await tester.pumpAndSettle();
      await _chip(tester, '₹500');
      expect(
        find.text('The amount can only go up (now ₹600).'),
        findsOneWidget,
      );

      await _chip(tester, '₹1,000');
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();
      verify(
        () => repository.updateAmount(
          'm1',
          amountPerHead: 1000,
          reason: any(named: 'reason'),
        ),
      ).called(1);
    });

    testWidgets('a failed month load shows why with Try again', (tester) async {
      when(
        () => repository.findMonth(
          month: any(named: 'month'),
          year: any(named: 'year'),
        ),
      ).thenThrow(
        const ApiException(
          message: 'Salary is unavailable',
          code: 'UNKNOWN_X',
          statusCode: 500,
        ),
      );
      await _pump(tester, repository, _committee);

      expect(find.text('Salary is unavailable'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });
  });

  testWidgets('the imam sees the month, nothing to change', (tester) async {
    await _pump(tester, repository, const <String>[
      AppPermissions.imamSalaryRead,
    ]);

    expect(find.byType(SalaryHero), findsOneWidget);
    expect(find.text('Raise amount'), findsNothing);
    expect(find.byType(FamilyDueTile), findsNothing);
  });

  group('member', () {
    const member = <String>[AppPermissions.ownContributionsRead];

    testWidgets('sees their own months with what is still to pay', (
      tester,
    ) async {
      when(() => repository.getMyHistory()).thenAnswer(
        (_) async => const <MySalaryHistoryMonth>[
          MySalaryHistoryMonth(
            month: 6,
            year: 2026,
            expectedAmount: 600,
            paidAmount: 200,
            dueAmount: 400,
            status: SalaryStatus.partial,
          ),
        ],
      );
      await _pump(tester, repository, member);

      expect(find.text('June 2026'), findsOneWidget);
      expect(find.widgetWithText(StatusBadge, 'Part paid'), findsOneWidget);
      expect(find.text('Paid ₹200 of ₹600'), findsOneWidget);
      expect(find.text('₹400 still to pay'), findsOneWidget);
    });

    testWidgets('a failed load offers Try again', (tester) async {
      when(() => repository.getMyHistory()).thenThrow(
        const ApiException(message: 'nope', code: 'UNKNOWN_X', statusCode: 500),
      );
      await _pump(tester, repository, member);

      expect(find.text('Try again'), findsOneWidget);
    });
  });
}
