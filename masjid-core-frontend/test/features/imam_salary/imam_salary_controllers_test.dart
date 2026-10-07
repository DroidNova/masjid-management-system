// mocktail needs `when(() => mock.call())` closures, not tear-offs.
// ignore_for_file: unnecessary_lambdas

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/core/pagination/page.dart';
import 'package:masjid_core_frontend/core/refresh/data_scopes.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/imam_salary/application/imam_salary_controllers.dart';
import 'package:masjid_core_frontend/features/imam_salary/data/imam_salary_repository.dart';
import 'package:masjid_core_frontend/features/imam_salary/data/models/imam_salary_models.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepository extends Mock implements ImamSalaryRepository {}

class _SignedOut extends AuthController {
  @override
  AuthState build() => const AuthSignedOut();
}

const _month = ImamSalaryMonth(
  id: 'm1',
  month: 6,
  year: 2026,
  amountPerHead: 600,
  totalExpected: 1200,
  totalDue: 1200,
  unpaidCount: 2,
);

const _assignment = SalaryAssignment(
  id: 'a1',
  memberName: 'Ahmed',
  expectedAmount: 600,
  dueAmount: 400,
  paidAmount: 200,
  status: SalaryStatus.partial,
);

PageResult<T> _page<T>(
  List<T> items, {
  required int page,
  required bool more,
}) => PageResult<T>(
  items: items,
  meta: PageMeta(
    page: page,
    limit: 20,
    total: 40,
    totalPages: 2,
    hasNextPage: more,
  ),
);

void main() {
  late _MockRepository repository;
  late ProviderContainer container;

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
    container = ProviderContainer(
      overrides: [
        imamSalaryRepositoryProvider.overrideWithValue(repository),
        authControllerProvider.overrideWith(_SignedOut.new),
        salaryPeriodProvider.overrideWith((ref) => (month: 6, year: 2026)),
      ],
    );
    addTearDown(container.dispose);
  });

  group('SalaryMonthController.addPayment', () {
    test(
      'rejects a payment above the due amount without calling the API',
      () async {
        container.listen(salaryMonthProvider, (_, _) {});
        await container.read(salaryMonthProvider.future);

        await expectLater(
          container
              .read(salaryMonthProvider.notifier)
              .addPayment(
                assignment: _assignment,
                amount: 400.01,
                paymentMode: 'CASH',
                paidAt: DateTime(2026, 6, 5),
              ),
          throwsA(
            isA<ApiException>()
                .having((e) => e.code, 'code', ApiErrorCodes.validation)
                .having(
                  (e) => e.fieldErrors['amount'],
                  'amount error',
                  isNotEmpty,
                ),
          ),
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
      },
    );

    test(
      'records a valid payment and marks money + salary as changed',
      () async {
        when(
          () => repository.addPayment(
            assignmentId: any(named: 'assignmentId'),
            amount: any(named: 'amount'),
            paymentMode: any(named: 'paymentMode'),
            paidAt: any(named: 'paidAt'),
            note: any(named: 'note'),
          ),
        ).thenAnswer((_) async => const SalaryPayment(id: 'p1', amount: 400));
        container.listen(salaryMonthProvider, (_, _) {});
        await container.read(salaryMonthProvider.future);

        await container
            .read(salaryMonthProvider.notifier)
            .addPayment(
              assignment: _assignment,
              amount: 400,
              paymentMode: 'CASH',
              paidAt: DateTime(2026, 6, 5),
            );

        verify(
          () => repository.addPayment(
            assignmentId: 'a1',
            amount: 400,
            paymentMode: 'CASH',
            paidAt: DateTime(2026, 6, 5),
            note: any(named: 'note'),
          ),
        ).called(1);
        for (final scope in <DataScope>[
          DataScope.imamSalary,
          DataScope.finance,
          DataScope.dashboard,
          DataScope.contributions,
        ]) {
          expect(
            container.read(dataVersionProvider(scope)),
            1,
            reason: '$scope',
          );
        }
      },
    );
  });

  test('increaseAmount refuses a lower amount per head', () async {
    container.listen(salaryMonthProvider, (_, _) {});
    await container.read(salaryMonthProvider.future);

    await expectLater(
      container
          .read(salaryMonthProvider.notifier)
          .increaseAmount(amountPerHead: 500),
      throwsA(isA<ApiException>()),
    );
    verifyNever(
      () => repository.updateAmount(
        any(),
        amountPerHead: any(named: 'amountPerHead'),
        reason: any(named: 'reason'),
      ),
    );
  });

  group('SalaryAssignmentsController', () {
    test('loads the first page for the month, then appends the next', () async {
      when(
        () => repository.getAssignments(
          'm1',
          status: any(named: 'status'),
          search: any(named: 'search'),
        ),
      ).thenAnswer(
        (_) async =>
            _page(<SalaryAssignment>[_assignment], page: 1, more: true),
      );
      when(
        () => repository.getAssignments(
          'm1',
          status: any(named: 'status'),
          search: any(named: 'search'),
          page: 2,
        ),
      ).thenAnswer(
        (_) async => _page(
          <SalaryAssignment>[_assignment.copyWith(id: 'a2')],
          page: 2,
          more: false,
        ),
      );
      container.listen(salaryAssignmentsProvider, (_, _) {});

      final first = await container.read(salaryAssignmentsProvider.future);
      expect(first.items.map((a) => a.id), <String>['a1']);
      expect(first.hasMore, isTrue);

      await container.read(salaryAssignmentsProvider.notifier).loadMore();
      final state = container.read(salaryAssignmentsProvider).requireValue;
      expect(state.items.map((a) => a.id), <String>['a1', 'a2']);
      expect(state.hasMore, isFalse);
    });

    test('is empty (no request) when the month was not started', () async {
      when(
        () => repository.findMonth(
          month: any(named: 'month'),
          year: any(named: 'year'),
        ),
      ).thenAnswer((_) async => null);
      container.listen(salaryAssignmentsProvider, (_, _) {});

      final state = await container.read(salaryAssignmentsProvider.future);
      expect(state.items, isEmpty);
      expect(state.hasMore, isFalse);
      verifyNever(
        () => repository.getAssignments(
          any(),
          status: any(named: 'status'),
          search: any(named: 'search'),
          page: any(named: 'page'),
        ),
      );
    });

    test('a status filter reloads with that status', () async {
      when(
        () => repository.getAssignments(
          any(),
          status: any(named: 'status'),
          search: any(named: 'search'),
          page: any(named: 'page'),
        ),
      ).thenAnswer(
        (_) async => _page(<SalaryAssignment>[], page: 1, more: false),
      );
      container.listen(salaryAssignmentsProvider, (_, _) {});
      await container.read(salaryAssignmentsProvider.future);

      container.read(salaryLedgerFilterProvider.notifier).state = (
        search: '',
        status: SalaryStatus.unpaid,
        paymentMode: null,
      );
      await container.read(salaryAssignmentsProvider.future);

      verify(
        () => repository.getAssignments(
          'm1',
          status: SalaryStatus.unpaid,
          search: '',
        ),
      ).called(1);
    });
  });
}
