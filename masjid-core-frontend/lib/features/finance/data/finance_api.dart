import 'package:masjid_core_frontend/core/network/api_client.dart';
import 'package:masjid_core_frontend/core/pagination/page.dart';
import 'package:masjid_core_frontend/features/finance/data/models/collection_entry_model.dart';
import 'package:masjid_core_frontend/features/finance/data/models/create_collection_request.dart';
import 'package:masjid_core_frontend/features/finance/data/models/create_expense_request.dart';
import 'package:masjid_core_frontend/features/finance/data/models/expense_entry_model.dart';
import 'package:masjid_core_frontend/features/finance/data/models/finance_entry_filter.dart';
import 'package:masjid_core_frontend/features/finance/data/models/finance_summary_model.dart';

/// Finance, collection and expense endpoints. Errors surface as ApiException.
class FinanceApi {
  FinanceApi(this._apiClient);

  final ApiClient _apiClient;

  Future<FinanceSummaryModel> getFinanceSummary() async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/finance/my-masjid/summary',
    );
    return FinanceSummaryModel.fromJson(data);
  }

  Future<PageResult<CollectionEntryModel>> getCollections(
    FinanceEntryFilter filter, {
    required int page,
    required int limit,
  }) async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/collections/my-masjid',
      query: <String, dynamic>{
        ...filter.toQuery(),
        'page': page,
        'limit': limit,
      },
    );
    return PageResult.fromJson(data, CollectionEntryModel.fromJson);
  }

  Future<CollectionEntryModel> createCollection(
    CreateCollectionRequest request,
  ) async {
    final data = await _apiClient.post<Map<String, dynamic>>(
      '/collections/my-masjid',
      body: request.toJson(),
    );
    return CollectionEntryModel.fromJson(data);
  }

  /// The server keeps the record and sets its status to CANCELLED.
  Future<CollectionEntryModel> cancelCollection(String id) async {
    final data = await _apiClient.delete<Map<String, dynamic>>(
      '/collections/$id',
    );
    return CollectionEntryModel.fromJson(data);
  }

  Future<PageResult<ExpenseEntryModel>> getExpenses(
    FinanceEntryFilter filter, {
    required int page,
    required int limit,
  }) async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/expenses/my-masjid',
      query: <String, dynamic>{
        ...filter.toQuery(),
        'page': page,
        'limit': limit,
      },
    );
    return PageResult.fromJson(data, ExpenseEntryModel.fromJson);
  }

  Future<ExpenseEntryModel> createExpense(CreateExpenseRequest request) async {
    final data = await _apiClient.post<Map<String, dynamic>>(
      '/expenses/my-masjid',
      body: request.toJson(),
    );
    return ExpenseEntryModel.fromJson(data);
  }

  /// The server keeps the record and sets its status to CANCELLED.
  Future<ExpenseEntryModel> cancelExpense(String id) async {
    final data = await _apiClient.delete<Map<String, dynamic>>('/expenses/$id');
    return ExpenseEntryModel.fromJson(data);
  }
}
