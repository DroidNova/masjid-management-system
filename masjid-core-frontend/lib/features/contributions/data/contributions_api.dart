import 'package:platform_core_frontend/core/network/api_client.dart';
import 'package:platform_core_frontend/core/network/response_parser.dart';
import 'package:platform_core_frontend/features/contributions/models/my_contribution_summary_model.dart';
import 'package:platform_core_frontend/features/contributions/models/my_imam_salary_contribution_model.dart';
import 'package:platform_core_frontend/features/contributions/models/my_imam_salary_payment_model.dart';
import 'package:platform_core_frontend/shared/models/paginated_response.dart';

class ContributionsApi {
  ContributionsApi({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<MyContributionSummaryModel> getMySummary() async {
    final response = await _apiClient.dio.get<Object?>(
      '/contributions/my/summary',
    );
    return MyContributionSummaryModel.fromJson(unwrapMap(response.data));
  }

  Future<PaginatedResponse<MyImamSalaryContributionModel>>
      getMyImamSalaryContributions({
    int monthsBack = 6,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _apiClient.dio.get<Object?>(
      '/contributions/my/imam-salary',
      queryParameters: <String, dynamic>{
        'monthsBack': monthsBack,
        'page': page,
        'limit': limit,
      },
    );
    return PaginatedResponse<MyImamSalaryContributionModel>.fromJson(
      unwrapMap(response.data),
      MyImamSalaryContributionModel.fromJson,
    );
  }

  Future<PaginatedResponse<MyImamSalaryPaymentModel>>
      getMyImamSalaryPayments({
    required int month,
    required int year,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _apiClient.dio.get<Object?>(
      '/contributions/my/imam-salary/$month/$year/payments',
      queryParameters: <String, dynamic>{'page': page, 'limit': limit},
    );
    return PaginatedResponse<MyImamSalaryPaymentModel>.fromJson(
      unwrapMap(response.data),
      MyImamSalaryPaymentModel.fromJson,
    );
  }
}
