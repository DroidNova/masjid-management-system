import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/pagination/page.dart';
import 'package:masjid_core_frontend/core/pagination/paged_controller.dart';
import 'package:masjid_core_frontend/core/refresh/data_scopes.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/finance/data/finance_repository.dart';
import 'package:masjid_core_frontend/features/finance/data/models/collection_entry_model.dart';
import 'package:masjid_core_frontend/features/finance/data/models/expense_entry_model.dart';
import 'package:masjid_core_frontend/features/finance/data/models/finance_entry_filter.dart';

/// Filter for the collections list. Changing it reloads from page 1.
final collectionsFilterProvider = StateProvider.autoDispose<FinanceEntryFilter>(
  (ref) => const FinanceEntryFilter(),
);

/// Filter for the expenses list. Changing it reloads from page 1.
final expensesFilterProvider = StateProvider.autoDispose<FinanceEntryFilter>(
  (ref) => const FinanceEntryFilter(),
);

final collectionsControllerProvider =
    AsyncNotifierProvider.autoDispose<
      CollectionsController,
      PagedState<CollectionEntryModel>
    >(CollectionsController.new);

final expensesControllerProvider =
    AsyncNotifierProvider.autoDispose<
      ExpensesController,
      PagedState<ExpenseEntryModel>
    >(ExpensesController.new);

class CollectionsController extends PagedController<CollectionEntryModel> {
  @override
  Future<PagedState<CollectionEntryModel>> build() {
    ref.watch(currentUserProvider.select((user) => user?.id));
    ref.watch(collectionsFilterProvider);
    ref.watch(dataVersionProvider(DataScope.finance));
    return super.build();
  }

  @override
  Future<PageResult<CollectionEntryModel>> fetchPage(int page) => ref
      .read(financeRepositoryProvider)
      .getCollections(ref.read(collectionsFilterProvider), page: page);
}

class ExpensesController extends PagedController<ExpenseEntryModel> {
  @override
  Future<PagedState<ExpenseEntryModel>> build() {
    ref.watch(currentUserProvider.select((user) => user?.id));
    ref.watch(expensesFilterProvider);
    ref.watch(dataVersionProvider(DataScope.finance));
    return super.build();
  }

  @override
  Future<PageResult<ExpenseEntryModel>> fetchPage(int page) => ref
      .read(financeRepositoryProvider)
      .getExpenses(ref.read(expensesFilterProvider), page: page);
}
