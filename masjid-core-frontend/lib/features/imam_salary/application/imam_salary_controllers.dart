import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/pagination/page.dart';
import 'package:masjid_core_frontend/core/pagination/paged_controller.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/core/refresh/data_scopes.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/imam_salary/application/salary_validation.dart';
import 'package:masjid_core_frontend/features/imam_salary/data/imam_salary_repository.dart';
import 'package:masjid_core_frontend/features/imam_salary/data/models/imam_salary_models.dart';

/// What the signed-in user sees on the imam salary screen.
enum SalaryView {
  /// Committee (imam_salary.manage): full ledger with actions.
  committee,

  /// Imam (imam_salary.read): month summary, read only.
  imam,

  /// Member (own_contributions.read): own last 6 months.
  member,

  none,
}

SalaryView salaryViewFor(List<String> permissions) {
  if (PermissionHelper.canManageImamSalary(permissions)) {
    return SalaryView.committee;
  }
  if (PermissionHelper.canViewImamSalary(permissions)) return SalaryView.imam;
  if (PermissionHelper.canViewOwnContributions(permissions)) {
    return SalaryView.member;
  }
  return SalaryView.none;
}

/// Everything a salary change can affect.
const List<DataScope> salaryChanges = <DataScope>[
  ...DataChanges.money,
  DataScope.imamSalary,
];

// ---------------------------------------------------------------------------
// Selected month and list filters (screen state shared by the controllers).
// ---------------------------------------------------------------------------

typedef SalaryPeriod = ({int month, int year});

final salaryPeriodProvider = StateProvider.autoDispose<SalaryPeriod>((ref) {
  final now = DateTime.now();
  return (month: now.month, year: now.year);
});

typedef SalaryLedgerFilter = ({
  String search,
  String? status,
  String? paymentMode,
});

final salaryLedgerFilterProvider =
    StateProvider.autoDispose<SalaryLedgerFilter>(
      (ref) => (search: '', status: null, paymentMode: null),
    );

// ---------------------------------------------------------------------------
// The selected salary month, plus the committee's changes to it.
// ---------------------------------------------------------------------------

final salaryMonthProvider =
    AsyncNotifierProvider.autoDispose<SalaryMonthController, ImamSalaryMonth?>(
      SalaryMonthController.new,
    );

class SalaryMonthController extends AutoDisposeAsyncNotifier<ImamSalaryMonth?> {
  ImamSalaryRepository get _repository =>
      ref.read(imamSalaryRepositoryProvider);

  /// The month for the selected period, or null if it was not started yet.
  @override
  Future<ImamSalaryMonth?> build() {
    ref.watch(currentUserProvider.select((user) => user?.id));
    ref.watch(dataVersionProvider(DataScope.imamSalary));
    final period = ref.watch(salaryPeriodProvider);
    return ref
        .watch(imamSalaryRepositoryProvider)
        .findMonth(month: period.month, year: period.year);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// Starts the selected month with [amountPerHead] for every family head.
  Future<void> startMonth({required double amountPerHead, String? note}) async {
    final problem = amountError(amountPerHead);
    if (problem != null) throw invalidInput('amountPerHead', problem);

    final period = ref.read(salaryPeriodProvider);
    await _repository.createMonth(
      month: period.month,
      year: period.year,
      amountPerHead: amountPerHead,
      note: note,
    );
    ref.markChanged(salaryChanges);
  }

  /// Raises the amount per head of the current month.
  Future<void> increaseAmount({
    required double amountPerHead,
    String? reason,
  }) async {
    final month = state.valueOrNull;
    if (month == null) throw StateError('No salary month loaded');
    final problem = increasedAmountError(
      amountPerHead,
      current: month.amountPerHead,
    );
    if (problem != null) throw invalidInput('amountPerHead', problem);

    await _repository.updateAmount(
      month.id,
      amountPerHead: amountPerHead,
      reason: reason,
    );
    ref.markChanged(salaryChanges);
  }

  /// Records a payment against one family head's assignment.
  Future<void> addPayment({
    required SalaryAssignment assignment,
    required double amount,
    required String paymentMode,
    required DateTime paidAt,
    String? note,
  }) async {
    final problem = paymentAmountError(amount, due: assignment.dueAmount);
    if (problem != null) throw invalidInput('amount', problem);

    await _repository.addPayment(
      assignmentId: assignment.id,
      amount: amount,
      paymentMode: paymentMode,
      paidAt: paidAt,
      note: note,
    );
    ref.markChanged(salaryChanges);
  }
}

// ---------------------------------------------------------------------------
// Committee lists for the selected month.
// ---------------------------------------------------------------------------

final salaryAssignmentsProvider =
    AsyncNotifierProvider.autoDispose<
      SalaryAssignmentsController,
      PagedState<SalaryAssignment>
    >(SalaryAssignmentsController.new);

class SalaryAssignmentsController extends PagedController<SalaryAssignment> {
  String? _monthId;

  @override
  Future<PagedState<SalaryAssignment>> build() async {
    ref.watch(salaryLedgerFilterProvider.select((f) => (f.search, f.status)));
    // Reloads whenever the month reloads (period change or salary change).
    final month = await ref.watch(salaryMonthProvider.future);
    _monthId = month?.id;
    return super.build();
  }

  @override
  Future<PageResult<SalaryAssignment>> fetchPage(int page) async {
    final monthId = _monthId;
    if (monthId == null) return _emptyPage<SalaryAssignment>();
    final filter = ref.read(salaryLedgerFilterProvider);
    return ref
        .read(imamSalaryRepositoryProvider)
        .getAssignments(
          monthId,
          status: filter.status,
          search: filter.search,
          page: page,
        );
  }
}

final salaryPaymentsProvider =
    AsyncNotifierProvider.autoDispose<
      SalaryPaymentsController,
      PagedState<SalaryPayment>
    >(SalaryPaymentsController.new);

class SalaryPaymentsController extends PagedController<SalaryPayment> {
  @override
  Future<PagedState<SalaryPayment>> build() {
    ref.watch(currentUserProvider.select((user) => user?.id));
    ref.watch(dataVersionProvider(DataScope.imamSalary));
    ref.watch(salaryPeriodProvider);
    ref.watch(
      salaryLedgerFilterProvider.select((f) => (f.search, f.paymentMode)),
    );
    return super.build();
  }

  @override
  Future<PageResult<SalaryPayment>> fetchPage(int page) {
    final period = ref.read(salaryPeriodProvider);
    final filter = ref.read(salaryLedgerFilterProvider);
    return ref
        .read(imamSalaryRepositoryProvider)
        .getPayments(
          month: period.month,
          year: period.year,
          paymentMode: filter.paymentMode,
          search: filter.search,
          page: page,
        );
  }
}

PageResult<T> _emptyPage<T>() => PageResult<T>(
  items: <T>[],
  meta: const PageMeta(
    page: 1,
    limit: 20,
    total: 0,
    totalPages: 0,
    hasNextPage: false,
  ),
);

// ---------------------------------------------------------------------------
// A member's own history.
// ---------------------------------------------------------------------------

final mySalaryHistoryProvider =
    AsyncNotifierProvider.autoDispose<
      MySalaryHistoryController,
      List<MySalaryHistoryMonth>
    >(MySalaryHistoryController.new);

class MySalaryHistoryController
    extends AutoDisposeAsyncNotifier<List<MySalaryHistoryMonth>> {
  @override
  Future<List<MySalaryHistoryMonth>> build() {
    ref.watch(currentUserProvider.select((user) => user?.id));
    ref.watch(dataVersionProvider(DataScope.imamSalary));
    ref.watch(dataVersionProvider(DataScope.contributions));
    return ref.watch(imamSalaryRepositoryProvider).getMyHistory();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
