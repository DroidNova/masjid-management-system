import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/pagination/page.dart';
import 'package:masjid_core_frontend/core/pagination/paged_controller.dart';
import 'package:masjid_core_frontend/core/pagination/paged_family_controller.dart';
import 'package:masjid_core_frontend/core/refresh/data_scopes.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/contributions/data/contributions_repository.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/collection_contribution.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/my_contribution_summary.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/my_imam_salary_month.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/my_imam_salary_payment.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/project_contribution.dart';

/// Reload "my" data when the user or any contribution / salary data changes.
void _watchMyData(Ref ref) {
  ref.watch(currentUserProvider.select((user) => user?.id));
  ref.watch(dataVersionProvider(DataScope.contributions));
  ref.watch(dataVersionProvider(DataScope.imamSalary));
}

final myContributionSummaryProvider =
    AsyncNotifierProvider.autoDispose<
      MyContributionSummaryController,
      MyContributionSummary
    >(MyContributionSummaryController.new);

class MyContributionSummaryController
    extends AutoDisposeAsyncNotifier<MyContributionSummary> {
  @override
  Future<MyContributionSummary> build() {
    _watchMyData(ref);
    return ref.watch(contributionsRepositoryProvider).getMySummary();
  }
}

final myImamSalaryMonthsProvider =
    AsyncNotifierProvider.autoDispose<
      MyImamSalaryMonthsController,
      PagedState<MyImamSalaryMonth>
    >(MyImamSalaryMonthsController.new);

class MyImamSalaryMonthsController extends PagedController<MyImamSalaryMonth> {
  @override
  Future<PagedState<MyImamSalaryMonth>> build() {
    _watchMyData(ref);
    return super.build();
  }

  @override
  Future<PageResult<MyImamSalaryMonth>> fetchPage(int page) => ref
      .read(contributionsRepositoryProvider)
      .getMyImamSalaryMonths(page: page);
}

final myProjectContributionsProvider =
    AsyncNotifierProvider.autoDispose<
      MyProjectContributionsController,
      PagedState<ProjectContribution>
    >(MyProjectContributionsController.new);

class MyProjectContributionsController
    extends PagedController<ProjectContribution> {
  @override
  Future<PagedState<ProjectContribution>> build() {
    _watchMyData(ref);
    return super.build();
  }

  @override
  Future<PageResult<ProjectContribution>> fetchPage(int page) => ref
      .read(contributionsRepositoryProvider)
      .getMyProjectContributions(page: page);
}

final myCollectionContributionsProvider =
    AsyncNotifierProvider.autoDispose<
      MyCollectionContributionsController,
      PagedState<CollectionContribution>
    >(MyCollectionContributionsController.new);

class MyCollectionContributionsController
    extends PagedController<CollectionContribution> {
  @override
  Future<PagedState<CollectionContribution>> build() {
    _watchMyData(ref);
    return super.build();
  }

  @override
  Future<PageResult<CollectionContribution>> fetchPage(int page) => ref
      .read(contributionsRepositoryProvider)
      .getMyCollectionContributions(page: page);
}

/// Which salary month's payments to show.
typedef SalaryMonthRef = ({int month, int year});

final myImamSalaryPaymentsProvider = AsyncNotifierProvider.autoDispose
    .family<
      MyImamSalaryPaymentsController,
      PagedState<MyImamSalaryPayment>,
      SalaryMonthRef
    >(MyImamSalaryPaymentsController.new);

class MyImamSalaryPaymentsController
    extends PagedFamilyController<MyImamSalaryPayment, SalaryMonthRef> {
  @override
  Future<PagedState<MyImamSalaryPayment>> build(SalaryMonthRef arg) {
    _watchMyData(ref);
    return super.build(arg);
  }

  @override
  Future<PageResult<MyImamSalaryPayment>> fetchPage(
    SalaryMonthRef arg,
    int page,
  ) => ref
      .read(contributionsRepositoryProvider)
      .getMyImamSalaryPayments(month: arg.month, year: arg.year, page: page);
}
