import 'package:platform_core_frontend/core/network/api_request_coordinator.dart';
import 'package:platform_core_frontend/core/refresh/app_data_refresh_bus.dart';
import 'package:platform_core_frontend/features/finance/data/finance_api.dart';
import 'package:platform_core_frontend/features/finance/data/models/collection_entry_model.dart';
import 'package:platform_core_frontend/features/finance/data/models/create_collection_request.dart';
import 'package:platform_core_frontend/features/finance/data/models/create_expense_request.dart';
import 'package:platform_core_frontend/features/finance/data/models/expense_entry_model.dart';
import 'package:platform_core_frontend/features/finance/data/models/finance_summary_model.dart';

class FinanceRepository {
  FinanceRepository({FinanceApi? financeApi})
      : _financeApi = financeApi ?? FinanceApi();

  final FinanceApi _financeApi;

  Future<FinanceSummaryModel> getFinanceSummary() {
    return ApiRequestCoordinator.instance.run<FinanceSummaryModel>(
      key: 'GET:/finance/my-masjid/summary',
      request: _financeApi.getFinanceSummary,
    );
  }

  Future<List<CollectionEntryModel>> getCollections() {
    return ApiRequestCoordinator.instance.run<List<CollectionEntryModel>>(
      key: 'GET:/collections/my-masjid',
      request: _financeApi.getCollections,
    );
  }

  Future<void> createCollection(CreateCollectionRequest request) async {
    await _financeApi.createCollection(request);
    AppDataRefreshBus.instance.notifyMany(<AppDataScope>[
      AppDataScope.finance,
      AppDataScope.dashboard,
    ]);
  }

  Future<List<ExpenseEntryModel>> getExpenses() {
    return ApiRequestCoordinator.instance.run<List<ExpenseEntryModel>>(
      key: 'GET:/expenses/my-masjid',
      request: _financeApi.getExpenses,
    );
  }

  Future<void> createExpense(CreateExpenseRequest request) async {
    await _financeApi.createExpense(request);
    AppDataRefreshBus.instance.notifyMany(<AppDataScope>[
      AppDataScope.finance,
      AppDataScope.dashboard,
    ]);
  }
}
