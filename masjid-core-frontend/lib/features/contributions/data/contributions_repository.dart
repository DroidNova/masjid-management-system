import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/pagination/page.dart';
import 'package:masjid_core_frontend/core/providers.dart';
import 'package:masjid_core_frontend/features/contributions/data/contributions_api.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/collection_contribution.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/contributor_option.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/my_contribution_summary.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/my_imam_salary_month.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/my_imam_salary_payment.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/new_contribution.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/project_contribution.dart';

final contributionsRepositoryProvider = Provider<ContributionsRepository>(
  (ref) =>
      ContributionsRepository(ContributionsApi(ref.watch(apiClientProvider))),
);

class ContributionsRepository {
  ContributionsRepository(this._api);

  final ContributionsApi _api;

  Future<MyContributionSummary> getMySummary() => _api.getMySummary();

  Future<PageResult<MyImamSalaryMonth>> getMyImamSalaryMonths({int page = 1}) =>
      _api.getMyImamSalaryMonths(page: page);

  Future<PageResult<MyImamSalaryPayment>> getMyImamSalaryPayments({
    required int month,
    required int year,
    int page = 1,
  }) => _api.getMyImamSalaryPayments(month: month, year: year, page: page);

  Future<PageResult<ProjectContribution>> getMyProjectContributions({
    int page = 1,
  }) => _api.getMyProjectContributions(page: page);

  Future<PageResult<CollectionContribution>> getMyCollectionContributions({
    int page = 1,
  }) => _api.getMyCollectionContributions(page: page);

  Future<PageResult<ProjectContribution>> getProjectContributions(
    String projectId, {
    String? search,
    String? paymentMode,
    int page = 1,
  }) => _api.getProjectContributions(
    projectId,
    search: search,
    paymentMode: paymentMode,
    page: page,
  );

  Future<PageResult<CollectionContribution>> getCollectionContributions({
    String? search,
    String? paymentMode,
    String? collectionType,
    int page = 1,
  }) => _api.getCollectionContributions(
    search: search,
    paymentMode: paymentMode,
    collectionType: collectionType,
    page: page,
  );

  Future<ProjectContribution> addProjectContribution(
    String projectId,
    NewContribution contribution,
  ) => _api.addProjectContribution(projectId, contribution);

  Future<CollectionContribution> addCollectionContribution(
    NewContribution contribution,
  ) => _api.addCollectionContribution(contribution);

  Future<List<ContributorOption>> getContributorOptions() =>
      _api.getContributorOptions();

  Future<String?> getProjectTitle(String projectId) =>
      _api.getProjectTitle(projectId);
}
