import 'package:platform_core_frontend/features/contributions/data/contributions_api.dart';
import 'package:platform_core_frontend/features/contributions/models/my_contribution_summary_model.dart';
import 'package:platform_core_frontend/features/contributions/models/my_imam_salary_contribution_model.dart';
import 'package:platform_core_frontend/features/contributions/models/my_imam_salary_payment_model.dart';
import 'package:platform_core_frontend/shared/models/paginated_response.dart';

class ContributionsRepository {
  ContributionsRepository({ContributionsApi? api})
      : _api = api ?? ContributionsApi();

  final ContributionsApi _api;

  Future<MyContributionSummaryModel> getMySummary() => _api.getMySummary();

  Future<PaginatedResponse<MyImamSalaryContributionModel>>
      getMyImamSalaryContributions({
    int monthsBack = 6,
    int page = 1,
    int limit = 20,
  }) {
    return _api.getMyImamSalaryContributions(
      monthsBack: monthsBack,
      page: page,
      limit: limit,
    );
  }

  Future<PaginatedResponse<MyImamSalaryPaymentModel>>
      getMyImamSalaryPayments({
    required int month,
    required int year,
    int page = 1,
    int limit = 20,
  }) {
    return _api.getMyImamSalaryPayments(
      month: month,
      year: year,
      page: page,
      limit: limit,
    );
  }
}
