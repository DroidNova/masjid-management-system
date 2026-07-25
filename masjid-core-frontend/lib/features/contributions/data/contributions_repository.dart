import 'package:platform_core_frontend/features/contributions/data/contributions_api.dart';
import 'package:platform_core_frontend/core/refresh/app_data_refresh_bus.dart';
import 'package:platform_core_frontend/features/contributions/models/collection_contribution_model.dart';
import 'package:platform_core_frontend/features/contributions/models/project_contribution_model.dart';
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
  Future<PaginatedResponse<ProjectContributionModel>> getProjectContributions(String projectId,{String? search,String? paymentMode,int page=1,int limit=20})=>_api.getProjectContributions(projectId,search:search,paymentMode:paymentMode,page:page,limit:limit);
  Future<PaginatedResponse<CollectionContributionModel>> getCollectionContributions({String? search,String? paymentMode,String? collectionType,int page=1,int limit=20})=>_api.getCollectionContributions(search:search,paymentMode:paymentMode,collectionType:collectionType,page:page,limit:limit);
  Future<PaginatedResponse<ProjectContributionModel>> getMyProjectContributions({int page=1,int limit=20})=>_api.getMyProjectContributions(page:page,limit:limit);
  Future<PaginatedResponse<CollectionContributionModel>> getMyCollectionContributions({int page=1,int limit=20})=>_api.getMyCollectionContributions(page:page,limit:limit);
  Future<ProjectContributionModel> addProjectContribution(String projectId,CreateProjectContributionRequest request) async {final result=await _api.addProjectContribution(projectId,request);_notify();return result;}
  Future<CollectionContributionModel> addCollectionContribution(CreateCollectionContributionRequest request) async {final result=await _api.addCollectionContribution(request);_notify();return result;}
  void _notify()=>AppDataRefreshBus.instance.notifyMany(<AppDataScope>[AppDataScope.projects,AppDataScope.finance,AppDataScope.dashboard]);

}
