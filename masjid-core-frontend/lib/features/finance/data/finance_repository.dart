import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/pagination/page.dart';
import 'package:masjid_core_frontend/core/providers.dart';
import 'package:masjid_core_frontend/features/finance/data/finance_api.dart';
import 'package:masjid_core_frontend/features/finance/data/models/collection_entry_model.dart';
import 'package:masjid_core_frontend/features/finance/data/models/create_collection_request.dart';
import 'package:masjid_core_frontend/features/finance/data/models/create_expense_request.dart';
import 'package:masjid_core_frontend/features/finance/data/models/expense_entry_model.dart';
import 'package:masjid_core_frontend/features/finance/data/models/finance_entry_filter.dart';
import 'package:masjid_core_frontend/features/finance/data/models/finance_summary_model.dart';

final financeRepositoryProvider = Provider<FinanceRepository>(
  (ref) => FinanceRepository(FinanceApi(ref.watch(apiClientProvider))),
);

class FinanceRepository {
  FinanceRepository(this._api);

  final FinanceApi _api;

  static const int pageSize = 20;

  Future<FinanceSummaryModel> getFinanceSummary() => _api.getFinanceSummary();

  Future<PageResult<CollectionEntryModel>> getCollections(
    FinanceEntryFilter filter, {
    int page = 1,
  }) => _api.getCollections(filter, page: page, limit: pageSize);

  Future<CollectionEntryModel> createCollection(
    CreateCollectionRequest request,
  ) => _api.createCollection(request);

  Future<CollectionEntryModel> cancelCollection(String id) =>
      _api.cancelCollection(id);

  Future<PageResult<ExpenseEntryModel>> getExpenses(
    FinanceEntryFilter filter, {
    int page = 1,
  }) => _api.getExpenses(filter, page: page, limit: pageSize);

  Future<ExpenseEntryModel> createExpense(CreateExpenseRequest request) =>
      _api.createExpense(request);

  Future<ExpenseEntryModel> cancelExpense(String id) => _api.cancelExpense(id);
}
