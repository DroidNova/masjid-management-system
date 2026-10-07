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
import 'package:masjid_core_frontend/features/finance/data/finance_repository.dart';
import 'package:masjid_core_frontend/features/finance/data/models/collection_entry_model.dart';
import 'package:masjid_core_frontend/features/finance/data/models/finance_entry_filter.dart';
import 'package:masjid_core_frontend/features/finance/data/models/finance_summary_model.dart';
import 'package:masjid_core_frontend/features/finance/presentation/finance_screen.dart';
import 'package:mocktail/mocktail.dart';

class _MockFinanceRepository extends Mock implements FinanceRepository {}

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
  'breakdown': <String, dynamic>{
    'total': <String, dynamic>{
      'generalCollections': 1000,
      'projectContributions': 350,
      'imamSalaryCollected': 150,
      'income': 1500,
      'expenses': 400,
      'balance': 1100,
    },
    'period': <String, dynamic>{
      'generalCollections': 200,
      'projectContributions': 60,
      'imamSalaryCollected': 40,
      'income': 300,
      'expenses': 100,
      'balance': 200,
    },
  },
});

PageResult<CollectionEntryModel> _collectionsPage() =>
    PageResult<CollectionEntryModel>.fromJson(const <String, dynamic>{
      'items': <Object>[
        <String, dynamic>{
          'id': 'c1',
          'type': 'JUMMA_COLLECTION',
          'amount': 700.5,
          'title': 'Friday collection',
          'collectedAt': '2026-10-02T00:00:00.000Z',
          'status': 'ACTIVE',
        },
      ],
      'meta': <String, dynamic>{
        'page': 1,
        'limit': 20,
        'total': 1,
        'totalPages': 1,
        'hasNextPage': false,
      },
    }, CollectionEntryModel.fromJson);

Future<void> _pump(
  WidgetTester tester,
  FinanceRepository repository, {
  List<String> permissions = const <String>[],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        financeRepositoryProvider.overrideWithValue(repository),
        authControllerProvider.overrideWith(() => _SignedIn(permissions)),
      ],
      child: const MaterialApp(home: Scaffold(body: FinanceScreen())),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en_IN');
    registerFallbackValue(const FinanceEntryFilter());
  });

  late _MockFinanceRepository repository;

  setUp(() {
    repository = _MockFinanceRepository();
    when(
      () => repository.getFinanceSummary(),
    ).thenAnswer((_) async => _summary);
    when(
      () => repository.getCollections(any(), page: any(named: 'page')),
    ).thenAnswer((_) async => _collectionsPage());
  });

  testWidgets('shows totals, the breakdown rows and collections', (
    tester,
  ) async {
    await _pump(tester, repository);

    expect(find.text('Finance Summary'), findsOneWidget);
    expect(find.text('₹1,100'), findsOneWidget); // current balance
    expect(find.text('₹1,500'), findsOneWidget); // total collection
    // Breakdown lines appear for all-time and for this month.
    expect(find.text('General Collections'), findsNWidgets(2));
    expect(find.text('Project Contributions'), findsNWidgets(2));
    expect(find.text('Imam Salary Collected'), findsNWidgets(2));
    expect(find.text('₹350'), findsOneWidget);
    expect(find.text('₹150'), findsOneWidget);

    expect(find.text('Friday collection'), findsOneWidget);
    expect(find.text('₹700.50'), findsOneWidget);
  });

  testWidgets('hides add buttons without manage permissions', (tester) async {
    await _pump(
      tester,
      repository,
      permissions: const <String>[AppPermissions.financeRead],
    );

    expect(find.text('Friday collection'), findsOneWidget);
    expect(find.text('Add Collection'), findsNothing);
  });

  testWidgets('shows add buttons with manage permissions', (tester) async {
    await _pump(
      tester,
      repository,
      permissions: const <String>[
        AppPermissions.financeRead,
        AppPermissions.collectionsManage,
      ],
    );

    expect(find.text('Add Collection'), findsOneWidget);
  });

  testWidgets('summary error shows the message and retry', (tester) async {
    when(() => repository.getFinanceSummary()).thenThrow(
      const ApiException(
        message: 'Server unavailable',
        code: ApiErrorCodes.unknown,
        statusCode: 500,
      ),
    );

    await _pump(tester, repository);

    expect(find.text('Unable to load finance data.'), findsOneWidget);
    expect(find.text('Server unavailable'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('no-masjid error is detected by code', (tester) async {
    when(() => repository.getFinanceSummary()).thenThrow(
      const ApiException(
        message: 'Current user is not assigned to a masjid',
        code: ApiErrorCodes.userMasjidNotAssigned,
        statusCode: 403,
      ),
    );

    await _pump(tester, repository);

    expect(
      find.text('You are not assigned to any masjid yet.'),
      findsOneWidget,
    );
  });

  testWidgets('list error shows inside the section', (tester) async {
    when(
      () => repository.getCollections(any(), page: any(named: 'page')),
    ).thenThrow(
      const ApiException(
        message: 'Could not load collections',
        code: ApiErrorCodes.unknown,
      ),
    );

    await _pump(tester, repository);

    expect(find.text('Finance Summary'), findsOneWidget);
    expect(find.text('Could not load collections'), findsOneWidget);
  });
}
