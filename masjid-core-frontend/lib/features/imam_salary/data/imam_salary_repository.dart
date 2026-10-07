import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/pagination/page.dart';
import 'package:masjid_core_frontend/core/providers.dart';
import 'package:masjid_core_frontend/features/imam_salary/data/imam_salary_api.dart';
import 'package:masjid_core_frontend/features/imam_salary/data/models/imam_salary_models.dart';

final imamSalaryRepositoryProvider = Provider<ImamSalaryRepository>(
  (ref) => ImamSalaryRepository(ImamSalaryApi(ref.watch(apiClientProvider))),
);

class ImamSalaryRepository {
  ImamSalaryRepository(this._api);

  final ImamSalaryApi _api;

  /// The salary month for [month]/[year], or null if it was not started.
  Future<ImamSalaryMonth?> findMonth({
    required int month,
    required int year,
  }) async {
    final page = await _api.getMonths(month: month, year: year);
    return page.items.isEmpty ? null : page.items.first;
  }

  Future<ImamSalaryMonth> createMonth({
    required int month,
    required int year,
    required double amountPerHead,
    String? note,
  }) => _api.createMonth(
    month: month,
    year: year,
    amountPerHead: amountPerHead,
    note: note,
  );

  Future<ImamSalaryMonth> updateAmount(
    String monthId, {
    required double amountPerHead,
    String? reason,
  }) =>
      _api.updateAmount(monthId, amountPerHead: amountPerHead, reason: reason);

  Future<PageResult<SalaryAssignment>> getAssignments(
    String monthId, {
    String? status,
    String? search,
    int page = 1,
  }) =>
      _api.getAssignments(monthId, status: status, search: search, page: page);

  Future<SalaryPayment> addPayment({
    required String assignmentId,
    required double amount,
    required String paymentMode,
    required DateTime paidAt,
    String? note,
  }) => _api.addPayment(
    assignmentId: assignmentId,
    amount: amount,
    paymentMode: paymentMode,
    paidAt: paidAt,
    note: note,
  );

  Future<PageResult<SalaryPayment>> getPayments({
    required int month,
    required int year,
    String? paymentMode,
    String? search,
    int page = 1,
  }) => _api.getPayments(
    month: month,
    year: year,
    paymentMode: paymentMode,
    search: search,
    page: page,
  );

  Future<List<MySalaryHistoryMonth>> getMyHistory() => _api.getMyHistory();
}
