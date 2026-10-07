import 'package:masjid_core_frontend/core/network/api_client.dart';
import 'package:masjid_core_frontend/core/pagination/page.dart';
import 'package:masjid_core_frontend/features/imam_salary/data/models/imam_salary_models.dart';

/// Imam salary ledger endpoints. Errors surface as ApiException (with `code`,
/// e.g. IMAM_SALARY_NOT_FOUND, IMAM_SALARY_ALREADY_EXISTS).
class ImamSalaryApi {
  ImamSalaryApi(this._apiClient);

  final ApiClient _apiClient;

  static const int pageSize = 20;

  Future<PageResult<ImamSalaryMonth>> getMonths({
    required int month,
    required int year,
    int page = 1,
  }) async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/imam-salaries/months',
      query: <String, dynamic>{
        'month': month,
        'year': year,
        'page': page,
        'limit': pageSize,
      },
    );
    return PageResult<ImamSalaryMonth>.fromJson(data, ImamSalaryMonth.fromJson);
  }

  Future<ImamSalaryMonth> createMonth({
    required int month,
    required int year,
    required double amountPerHead,
    String? note,
  }) async {
    final trimmedNote = note?.trim();
    final data = await _apiClient.post<Map<String, dynamic>>(
      '/imam-salaries/months',
      body: <String, dynamic>{
        'month': month,
        'year': year,
        'amountPerHead': amountPerHead,
        if (trimmedNote != null && trimmedNote.isNotEmpty) 'note': trimmedNote,
      },
    );
    return ImamSalaryMonth.fromJson(data);
  }

  Future<ImamSalaryMonth> updateAmount(
    String monthId, {
    required double amountPerHead,
    String? reason,
  }) async {
    final trimmedReason = reason?.trim();
    final data = await _apiClient.patch<Map<String, dynamic>>(
      '/imam-salaries/months/$monthId/amount',
      body: <String, dynamic>{
        'amountPerHead': amountPerHead,
        if (trimmedReason != null && trimmedReason.isNotEmpty)
          'reason': trimmedReason,
      },
    );
    return ImamSalaryMonth.fromJson(data);
  }

  Future<PageResult<SalaryAssignment>> getAssignments(
    String monthId, {
    String? status,
    String? search,
    int page = 1,
  }) async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/imam-salaries/months/$monthId/assignments',
      query: <String, dynamic>{
        'page': page,
        'limit': pageSize,
        'status': ?status,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    return PageResult<SalaryAssignment>.fromJson(
      data,
      SalaryAssignment.fromJson,
    );
  }

  Future<SalaryPayment> addPayment({
    required String assignmentId,
    required double amount,
    required String paymentMode,
    required DateTime paidAt,
    String? note,
  }) async {
    final trimmedNote = note?.trim();
    final data = await _apiClient.post<Map<String, dynamic>>(
      '/imam-salaries/payments',
      body: <String, dynamic>{
        'assignmentId': assignmentId,
        'amount': amount,
        'paymentMode': paymentMode,
        'paidAt': paidAt.toUtc().toIso8601String(),
        if (trimmedNote != null && trimmedNote.isNotEmpty) 'note': trimmedNote,
      },
    );
    return SalaryPayment.fromJson(data);
  }

  Future<PageResult<SalaryPayment>> getPayments({
    required int month,
    required int year,
    String? paymentMode,
    String? search,
    int page = 1,
  }) async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/imam-salaries/payments',
      query: <String, dynamic>{
        'month': month,
        'year': year,
        'page': page,
        'limit': pageSize,
        'paymentMode': ?paymentMode,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    return PageResult<SalaryPayment>.fromJson(data, SalaryPayment.fromJson);
  }

  /// The signed-in member's last [monthsBack] months (not paged).
  Future<List<MySalaryHistoryMonth>> getMyHistory({int monthsBack = 6}) async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/imam-salaries/my-history',
      query: <String, dynamic>{'monthsBack': monthsBack},
    );
    final items = data['items'];
    if (items is! List) return const <MySalaryHistoryMonth>[];
    return items
        .whereType<Map<String, dynamic>>()
        .map(MySalaryHistoryMonth.fromJson)
        .toList();
  }
}
