import 'package:dio/dio.dart';
import 'package:platform_core_frontend/core/network/api_client.dart';
import 'package:platform_core_frontend/features/finance/data/models/collection_entry_model.dart';
import 'package:platform_core_frontend/features/finance/data/models/create_collection_request.dart';
import 'package:platform_core_frontend/features/finance/data/models/create_expense_request.dart';
import 'package:platform_core_frontend/features/finance/data/models/expense_entry_model.dart';
import 'package:platform_core_frontend/features/finance/data/models/finance_summary_model.dart';

class FinanceApi {
  FinanceApi({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<FinanceSummaryModel> getFinanceSummary() async {
    try {
      final response = await _apiClient.dio.get<Object?>(
        '/finance/my-masjid/summary',
      );
      return FinanceSummaryModel.fromJson(_extractMapData(response.data));
    } on DioException catch (error) {
      throw Exception(_readDioErrorMessage(error));
    }
  }

  Future<List<CollectionEntryModel>> getCollections() async {
    try {
      final response = await _apiClient.dio.get<Object?>(
        '/collections/my-masjid',
      );
      return _extractListData(response.data)
          .whereType<Map<String, dynamic>>()
          .map(CollectionEntryModel.fromJson)
          .toList();
    } on DioException catch (error) {
      throw Exception(_readDioErrorMessage(error));
    }
  }

  Future<void> createCollection(CreateCollectionRequest request) async {
    try {
      await _apiClient.dio.post<Object?>(
        '/collections/my-masjid',
        data: request.toJson(),
      );
    } on DioException catch (error) {
      throw Exception(_readDioErrorMessage(error));
    }
  }

  Future<List<ExpenseEntryModel>> getExpenses() async {
    try {
      final response = await _apiClient.dio.get<Object?>(
        '/expenses/my-masjid',
      );
      return _extractListData(response.data)
          .whereType<Map<String, dynamic>>()
          .map(ExpenseEntryModel.fromJson)
          .toList();
    } on DioException catch (error) {
      throw Exception(_readDioErrorMessage(error));
    }
  }

  Future<void> createExpense(CreateExpenseRequest request) async {
    try {
      await _apiClient.dio.post<Object?>(
        '/expenses/my-masjid',
        data: request.toJson(),
      );
    } on DioException catch (error) {
      throw Exception(_readDioErrorMessage(error));
    }
  }

  Map<String, dynamic> _extractMapData(Object? responseData) {
    final data = _unwrapData(responseData);
    if (data is Map<String, dynamic>) return data;
    return <String, dynamic>{};
  }

  List<dynamic> _extractListData(Object? responseData) {
    final data = _unwrapData(responseData);
    if (data is List<dynamic>) return data;
    if (data is Map<String, dynamic>) {
      final items = data['items'];
      if (items is List<dynamic>) return items;
    }
    return <dynamic>[];
  }

  Object? _unwrapData(Object? responseData) {
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      return responseData['data'];
    }
    return responseData;
  }

  String _readDioErrorMessage(DioException error) {
    final responseData = error.response?.data;
    if (responseData is Map<String, dynamic>) {
      final message = responseData['message'];
      if (message is String && message.isNotEmpty) return message;

      final responseError = responseData['error'];
      if (responseError is Map<String, dynamic>) {
        final errorMessage = responseError['message'];
        if (errorMessage is String && errorMessage.isNotEmpty) {
          return errorMessage;
        }
      }
    }

    return error.message ?? 'Unable to load finance data.';
  }
}
