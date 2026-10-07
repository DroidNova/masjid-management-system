import 'package:masjid_core_frontend/core/network/api_client.dart';
import 'package:masjid_core_frontend/core/pagination/page.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/collection_contribution.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/contributor_option.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/my_contribution_summary.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/my_imam_salary_month.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/my_imam_salary_payment.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/new_contribution.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/project_contribution.dart';

/// Contribution endpoints. Errors surface as ApiException (with `code`).
class ContributionsApi {
  ContributionsApi(this._apiClient);

  final ApiClient _apiClient;

  static const int pageSize = 20;

  Future<MyContributionSummary> getMySummary() async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/contributions/my/summary',
    );
    return MyContributionSummary.fromJson(data);
  }

  Future<PageResult<MyImamSalaryMonth>> getMyImamSalaryMonths({
    int monthsBack = 6,
    int page = 1,
  }) => _page(
    '/contributions/my/imam-salary',
    MyImamSalaryMonth.fromJson,
    page: page,
    query: <String, dynamic>{'monthsBack': monthsBack},
  );

  Future<PageResult<MyImamSalaryPayment>> getMyImamSalaryPayments({
    required int month,
    required int year,
    int page = 1,
  }) => _page(
    '/contributions/my/imam-salary/$month/$year/payments',
    MyImamSalaryPayment.fromJson,
    page: page,
  );

  Future<PageResult<ProjectContribution>> getMyProjectContributions({
    int page = 1,
  }) => _page(
    '/contributions/my/projects',
    ProjectContribution.fromJson,
    page: page,
  );

  Future<PageResult<CollectionContribution>> getMyCollectionContributions({
    int page = 1,
  }) => _page(
    '/contributions/my/collections',
    CollectionContribution.fromJson,
    page: page,
  );

  Future<PageResult<ProjectContribution>> getProjectContributions(
    String projectId, {
    String? search,
    String? paymentMode,
    int page = 1,
  }) => _page(
    '/projects/$projectId/contributions',
    ProjectContribution.fromJson,
    page: page,
    query: <String, dynamic>{
      if (search != null && search.isNotEmpty) 'search': search,
      'paymentMode': ?paymentMode,
    },
  );

  Future<PageResult<CollectionContribution>> getCollectionContributions({
    String? search,
    String? paymentMode,
    String? collectionType,
    int page = 1,
  }) => _page(
    '/collections/contributions',
    CollectionContribution.fromJson,
    page: page,
    query: <String, dynamic>{
      if (search != null && search.isNotEmpty) 'search': search,
      'paymentMode': ?paymentMode,
      'collectionType': ?collectionType,
    },
  );

  Future<ProjectContribution> addProjectContribution(
    String projectId,
    NewContribution contribution,
  ) async {
    final data = await _apiClient.post<Map<String, dynamic>>(
      '/projects/$projectId/contributions',
      body: contribution.toJson(),
    );
    return ProjectContribution.fromJson(data);
  }

  Future<CollectionContribution> addCollectionContribution(
    NewContribution contribution,
  ) async {
    final data = await _apiClient.post<Map<String, dynamic>>(
      '/collections/contributions',
      body: contribution.toJson(),
    );
    return CollectionContribution.fromJson(data);
  }

  /// Members of the current masjid, to pick as the contributor.
  Future<List<ContributorOption>> getContributorOptions() async {
    final data = await _apiClient.get<List<dynamic>>('/masjids/my/users');
    return data
        .whereType<Map<String, dynamic>>()
        .map(ContributorOption.fromJson)
        .toList();
  }

  /// Project title for the contributions screen header (`GET /projects/:id`).
  Future<String?> getProjectTitle(String projectId) async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/projects/$projectId',
    );
    final title = data['title'];
    return title is String && title.isNotEmpty ? title : null;
  }

  Future<PageResult<T>> _page<T>(
    String path,
    T Function(Map<String, dynamic>) parse, {
    required int page,
    Map<String, dynamic> query = const <String, dynamic>{},
  }) async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      path,
      query: <String, dynamic>{...query, 'page': page, 'limit': pageSize},
    );
    return PageResult<T>.fromJson(data, parse);
  }
}
