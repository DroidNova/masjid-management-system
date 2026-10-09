// mocktail needs `when(() => mock.call())` closures, not tear-offs.
// ignore_for_file: unnecessary_lambdas

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/core/pagination/page.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/auth/data/models/app_user.dart';
import 'package:masjid_core_frontend/features/finance/data/finance_repository.dart';
import 'package:masjid_core_frontend/features/finance/data/models/collection_entry_model.dart';
import 'package:masjid_core_frontend/features/finance/data/models/create_collection_request.dart';
import 'package:masjid_core_frontend/features/finance/data/models/create_expense_request.dart';
import 'package:masjid_core_frontend/features/finance/data/models/expense_entry_model.dart';
import 'package:masjid_core_frontend/features/finance/data/models/finance_entry_filter.dart';
import 'package:masjid_core_frontend/features/finance/data/models/finance_summary_model.dart';
import 'package:masjid_core_frontend/features/finance/presentation/finance_screen.dart';
import 'package:masjid_core_frontend/features/finance/presentation/money_entry_screen.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../shared/ui/ui_test_helpers.dart';

class _MockFinanceRepository extends Mock implements FinanceRepository {}

class _FakeCollection extends Fake implements CreateCollectionRequest {}

class _FakeExpense extends Fake implements CreateExpenseRequest {}

class _SignedIn extends AuthController {
  _SignedIn(this.permissions);

  final List<String> permissions;

  @override
  AuthState build() => AuthSignedIn(
    AppUser(id: 'u1', fullName: 'Test User', permissions: permissions),
  );
}

final _summary = FinanceSummaryModel.fromJson(const <String, dynamic>{
  'totalCollection': 1500,
  'totalExpense': 400,
  'currentBalance': 1100,
  'thisMonthCollection': 300,
  'thisMonthExpense': 100,
  'thisMonthBalance': 200,
});

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

final _friday = CollectionEntryModel(
  id: 'c1',
  type: 'JUMMA_COLLECTION',
  amount: 700.5,
  collectedAt: DateTime.utc(2026, 10, 2),
);

final _bill = ExpenseEntryModel(
  id: 'e1',
  type: 'ELECTRICITY_BILL',
  amount: 900,
  spentAt: DateTime.utc(2026, 10, 3),
);

const _manager = <String>[
  AppPermissions.financeRead,
  AppPermissions.collectionsManage,
  AppPermissions.expensesManage,
];

Future<void> _pump(
  WidgetTester tester,
  FinanceRepository repository, {
  List<String> permissions = const <String>[AppPermissions.financeRead],
}) => pumpRouted(
  tester,
  const Scaffold(body: FinanceScreen()),
  size: const Size(420, 1800),
  overrides: [
    financeRepositoryProvider.overrideWithValue(repository),
    authControllerProvider.overrideWith(() => _SignedIn(permissions)),
  ],
  extraRoutes: const <String, Widget>{
    '/finance/add-collection': Scaffold(body: Text('money in page')),
    '/finance/collection-contributions': Scaffold(body: Text('givers page')),
  },
);

/// One half of the money in / money out switch.
Finder _segment(String label) => find.descendant(
  of: find.byType(SegmentedButton<bool>),
  matching: find.text(label),
);

void main() {
  late _MockFinanceRepository repository;

  setUpAll(() {
    registerFallbackValue(const FinanceEntryFilter());
    registerFallbackValue(_FakeCollection());
    registerFallbackValue(_FakeExpense());
  });

  setUp(() {
    repository = _MockFinanceRepository();
    when(
      () => repository.getFinanceSummary(),
    ).thenAnswer((_) async => _summary);
    when(
      () => repository.getCollections(any(), page: any(named: 'page')),
    ).thenAnswer((_) async => _page([_friday]));
    when(
      () => repository.getExpenses(any(), page: any(named: 'page')),
    ).thenAnswer((_) async => _page([_bill]));
  });

  testWidgets('shows the balance, this month, and money in by day', (
    tester,
  ) async {
    await _pump(tester, repository);

    expect(find.text('₹1,100'), findsOneWidget);
    expect(find.text('+₹300'), findsOneWidget);
    expect(find.text('−₹100'), findsOneWidget);
    expect(find.text('Jumma'), findsWidgets);
    expect(find.text('+₹700.50'), findsOneWidget);
    expect(find.text('2 Oct 2026'), findsOneWidget);
  });

  testWidgets('no money buttons for those who may only look', (tester) async {
    await _pump(tester, repository);
    expect(find.widgetWithText(FilledButton, 'Money in'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Money out'), findsNothing);
  });

  testWidgets('money buttons for those who may add', (tester) async {
    await _pump(tester, repository, permissions: _manager);
    expect(find.widgetWithText(FilledButton, 'Money in'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Money out'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Money in'));
    await tester.pumpAndSettle();
    expect(find.text('money in page'), findsOneWidget);
  });

  testWidgets('Money out shows expenses; switching back does not reload', (
    tester,
  ) async {
    await _pump(tester, repository);

    await tester.tap(_segment('Money out'));
    await tester.pumpAndSettle();
    expect(find.text('Electricity'), findsWidgets);
    expect(find.text('−₹900'), findsOneWidget);

    await tester.tap(_segment('Money in'));
    await tester.pumpAndSettle();
    expect(find.text('+₹700.50'), findsOneWidget);
    verify(
      () => repository.getCollections(any(), page: any(named: 'page')),
    ).called(1);
  });

  testWidgets('a kind chip filters the list', (tester) async {
    await _pump(tester, repository);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Donation box'));
    await tester.pumpAndSettle();

    final filters = verify(
      () => repository.getCollections(captureAny(), page: any(named: 'page')),
    ).captured.cast<FinanceEntryFilter>();
    expect(filters.last.type, 'DONATION_BOX');
  });

  testWidgets('cancelling an entry needs a hold', (tester) async {
    when(
      () => repository.cancelCollection('c1'),
    ).thenAnswer((_) async => _friday.copyWith(status: 'CANCELLED'));
    await _pump(tester, repository, permissions: _manager);

    await tester.tap(find.text('+₹700.50'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Cancel entry'));
    await tester.pumpAndSettle();
    expect(find.text('Cancel this entry?'), findsOneWidget);

    final hold = find.descendant(
      of: find.byType(HoldToConfirmButton),
      matching: find.text('Cancel entry'),
    );
    final gesture = await tester.startGesture(tester.getCenter(hold));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2100));
    await gesture.up();
    await tester.pumpAndSettle();

    verify(() => repository.cancelCollection('c1')).called(1);
  });

  testWidgets('no masjid: says so and offers to log out', (tester) async {
    when(() => repository.getFinanceSummary()).thenThrow(
      const ApiException(
        message: 'not assigned',
        code: ApiErrorCodes.userMasjidNotAssigned,
        statusCode: 403,
      ),
    );
    await _pump(tester, repository);

    expect(
      find.text('You are not assigned to any masjid yet.'),
      findsOneWidget,
    );
    expect(find.text('Logout'), findsOneWidget);
  });

  testWidgets('a failed summary still shows the list', (tester) async {
    when(() => repository.getFinanceSummary()).thenThrow(
      const ApiException(message: 'boom', code: 'UNKNOWN', statusCode: 500),
    );
    await _pump(tester, repository);

    expect(find.text('Unable to load the money totals.'), findsOneWidget);
    expect(find.text('+₹700.50'), findsOneWidget);
  });

  testWidgets('a failed list shows why with Try again', (tester) async {
    when(
      () => repository.getCollections(any(), page: any(named: 'page')),
    ).thenThrow(
      const ApiException(
        message: 'Collections are unavailable',
        code: 'UNKNOWN_X',
        statusCode: 500,
      ),
    );
    await _pump(tester, repository);

    expect(find.text('Collections are unavailable'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  group('money in / out entry', () {
    final today = DateTime(2026, 10, 9);

    Future<void> pumpEntry(WidgetTester tester, {required bool isExpense}) =>
        pumpRouted(
          tester,
          MoneyEntryScreen(isExpense: isExpense, today: today),
          size: const Size(420, 1600),
          overrides: [financeRepositoryProvider.overrideWithValue(repository)],
        );

    testWidgets('₹500 Jumma collection: Jumma, ₹500, Save', (tester) async {
      when(
        () => repository.createCollection(any()),
      ).thenAnswer((_) async => _friday);
      await pumpEntry(tester, isExpense: false);

      // 1. The kind: choosing it moves on by itself.
      await tester.tap(find.text('Jumma'));
      await tester.pumpAndSettle();
      // 2. A quick amount.
      await tester.tap(find.widgetWithText(ActionChip, '₹500'));
      await tester.pump();
      // 3. Save (today is already chosen).
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      final request =
          verify(
                () => repository.createCollection(captureAny()),
              ).captured.single
              as CreateCollectionRequest;
      expect(request.type, 'JUMMA_COLLECTION');
      expect(request.amount, 500);
      expect(request.collectedAt, '2026-10-09');
      expect(find.text('Money in saved'), findsOneWidget);
      expect(find.text('+₹500 · Jumma'), findsOneWidget);
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('money out with yesterday and a note', (tester) async {
      when(
        () => repository.createExpense(any()),
      ).thenAnswer((_) async => _bill);
      await pumpEntry(tester, isExpense: true);

      await tester.tap(find.text('Electricity'));
      await tester.pumpAndSettle();
      await tapKeypad(tester, '1250');
      await tester.tap(find.text('Yesterday'));
      await tester.tap(find.text('Add a note'));
      await tester.pump();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Note (optional)'),
        'October bill',
      );
      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Save'));
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      final request =
          verify(() => repository.createExpense(captureAny())).captured.single
              as CreateExpenseRequest;
      expect(request.type, 'ELECTRICITY_BILL');
      expect(request.amount, 1250);
      expect(request.spentAt, '2026-10-08');
      expect(request.description, 'October bill');
    });

    testWidgets('a refused save shows the reason and stays', (tester) async {
      when(() => repository.createCollection(any())).thenThrow(
        const ApiException(
          message: 'Amount must be at most 10000000',
          code: 'VALIDATION_ERROR',
          statusCode: 400,
        ),
      );
      await pumpEntry(tester, isExpense: false);

      await tester.tap(find.text('Zakat'));
      await tester.pumpAndSettle();
      await tapKeypad(tester, '5');
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      expect(find.text('Amount must be at most 10000000'), findsOneWidget);
      expect(find.text('Home'), findsNothing);
    });
  });
}
