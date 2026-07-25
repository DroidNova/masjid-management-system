import 'package:platform_core_frontend/core/network/api_request_coordinator.dart';
import 'package:platform_core_frontend/core/refresh/app_data_refresh_bus.dart';
import 'package:platform_core_frontend/features/imam_salary/data/imam_salary_api.dart';
import 'package:platform_core_frontend/features/imam_salary/models/create_imam_salary_request.dart';
import 'package:platform_core_frontend/features/imam_salary/models/imam_salary_model.dart';
import 'package:platform_core_frontend/features/imam_salary/models/imam_salary_ledger_models.dart';
import 'package:platform_core_frontend/shared/models/paginated_response.dart';
import 'package:platform_core_frontend/features/imam_salary/models/update_imam_salary_request.dart';

class ImamSalaryRepository {
  ImamSalaryRepository({ImamSalaryApi? imamSalaryApi})
      : _imamSalaryApi = imamSalaryApi ?? ImamSalaryApi();

  final ImamSalaryApi _imamSalaryApi;

  Future<List<ImamSalaryModel>> getImamSalaries() {
    return ApiRequestCoordinator.instance.run<List<ImamSalaryModel>>(
      key: 'GET:/imam-salaries',
      request: _imamSalaryApi.getImamSalaries,
    );
  }

  Future<ImamSalaryModel> getImamSalaryById(String id) {
    return ApiRequestCoordinator.instance.run<ImamSalaryModel>(
      key: 'GET:/imam-salaries/$id',
      request: () => _imamSalaryApi.getImamSalaryById(id),
    );
  }

  Future<ImamSalaryModel> createImamSalary(
    CreateImamSalaryRequest request,
  ) async {
    final salary = await _imamSalaryApi.createImamSalary(request);
    _notifySalaryChanged();
    return salary;
  }

  Future<ImamSalaryModel> updateImamSalary(
    String id,
    UpdateImamSalaryRequest request,
  ) async {
    final salary = await _imamSalaryApi.updateImamSalary(id, request);
    _notifySalaryChanged();
    return salary;
  }

  Future<void> deleteImamSalary(String id) async {
    await _imamSalaryApi.deleteImamSalary(id);
    _notifySalaryChanged();
  }

  void _notifySalaryChanged() {
    AppDataRefreshBus.instance.notifyMany(<AppDataScope>[
      AppDataScope.imamSalary,
      AppDataScope.finance,
      AppDataScope.dashboard,
    ]);
  }
  Future<PaginatedResponse<ImamSalaryMonthModel>> getMonths({required int month, required int year, int page = 1, int limit = 20}) => _imamSalaryApi.getMonths(month: month, year: year, page: page, limit: limit);
  Future<ImamSalaryMonthModel> getMonth(String id) => _imamSalaryApi.getMonth(id);
  Future<PaginatedResponse<ImamSalaryAssignmentModel>> getAssignments(String id, {String? status, String? search, int page = 1, int limit = 20}) => _imamSalaryApi.getAssignments(id, status: status, search: search, page: page, limit: limit);
  Future<PaginatedResponse<ImamSalaryPaymentModel>> getPayments({required int month, required int year, String? paymentMode, String? search, int page = 1, int limit = 20}) => _imamSalaryApi.getPayments(month: month, year: year, paymentMode: paymentMode, search: search, page: page, limit: limit);
  Future<List<MyImamSalaryHistoryModel>> getMyHistory() => _imamSalaryApi.getMyHistory();
  Future<ImamSalaryMonthModel> createMonth(CreateImamSalaryMonthRequest request) async { final value = await _imamSalaryApi.createMonth(request); _notifySalaryChanged(); return value; }
  Future<ImamSalaryMonthModel> updateAmount(String id, UpdateImamSalaryAmountRequest request) async { final value = await _imamSalaryApi.updateAmount(id, request); _notifySalaryChanged(); return value; }
  Future<ImamSalaryPaymentModel> addPayment(CreateImamSalaryPaymentRequest request) async { final value = await _imamSalaryApi.addPayment(request); _notifySalaryChanged(); return value; }

}
