import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/pagination/page.dart';
import 'package:masjid_core_frontend/core/pagination/paged_controller.dart';
import 'package:masjid_core_frontend/core/pagination/paged_family_controller.dart';
import 'package:masjid_core_frontend/core/refresh/data_scopes.dart';
import 'package:masjid_core_frontend/features/contributions/data/contributions_repository.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/collection_contribution.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/contributor_option.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/new_contribution.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/project_contribution.dart';

// ---------------------------------------------------------------------------
// Project contributions (committee view of one project).
// ---------------------------------------------------------------------------

/// Which project, plus the list filters.
typedef ProjectContributionsQuery = ({
  String projectId,
  String search,
  String? paymentMode,
});

final projectContributionsProvider = AsyncNotifierProvider.autoDispose
    .family<
      ProjectContributionsController,
      PagedState<ProjectContribution>,
      ProjectContributionsQuery
    >(ProjectContributionsController.new);

class ProjectContributionsController
    extends
        PagedFamilyController<ProjectContribution, ProjectContributionsQuery> {
  @override
  Future<PagedState<ProjectContribution>> build(ProjectContributionsQuery arg) {
    ref.watch(dataVersionProvider(DataScope.contributions));
    ref.watch(dataVersionProvider(DataScope.projects));
    return super.build(arg);
  }

  @override
  Future<PageResult<ProjectContribution>> fetchPage(
    ProjectContributionsQuery arg,
    int page,
  ) => ref
      .read(contributionsRepositoryProvider)
      .getProjectContributions(
        arg.projectId,
        search: arg.search,
        paymentMode: arg.paymentMode,
        page: page,
      );
}

/// Title of the project, loaded by id so the screen works from a fresh URL.
final projectTitleProvider = FutureProvider.autoDispose.family<String?, String>(
  (ref, projectId) async {
    ref.watch(dataVersionProvider(DataScope.projects));
    return ref
        .watch(contributionsRepositoryProvider)
        .getProjectTitle(projectId);
  },
);

// ---------------------------------------------------------------------------
// General collection contributions.
// ---------------------------------------------------------------------------

typedef CollectionContributionsFilter = ({
  String search,
  String? paymentMode,
  String? collectionType,
});

final collectionContributionsFilterProvider =
    StateProvider.autoDispose<CollectionContributionsFilter>(
      (ref) => (search: '', paymentMode: null, collectionType: null),
    );

final collectionContributionsProvider =
    AsyncNotifierProvider.autoDispose<
      CollectionContributionsController,
      PagedState<CollectionContribution>
    >(CollectionContributionsController.new);

class CollectionContributionsController
    extends PagedController<CollectionContribution> {
  @override
  Future<PagedState<CollectionContribution>> build() {
    ref.watch(collectionContributionsFilterProvider);
    ref.watch(dataVersionProvider(DataScope.contributions));
    ref.watch(dataVersionProvider(DataScope.finance));
    return super.build();
  }

  @override
  Future<PageResult<CollectionContribution>> fetchPage(int page) {
    final filter = ref.read(collectionContributionsFilterProvider);
    return ref
        .read(contributionsRepositoryProvider)
        .getCollectionContributions(
          search: filter.search,
          paymentMode: filter.paymentMode,
          collectionType: filter.collectionType,
          page: page,
        );
  }
}

// ---------------------------------------------------------------------------
// Recording contributions.
// ---------------------------------------------------------------------------

/// Members to pick from when recording. Empty if they cannot be loaded: an
/// external contributor can still be entered by name.
final contributorOptionsProvider =
    FutureProvider.autoDispose<List<ContributorOption>>((ref) async {
      try {
        return await ref
            .watch(contributionsRepositoryProvider)
            .getContributorOptions();
      } catch (_) {
        return const <ContributorOption>[];
      }
    });

final contributionRecorderProvider = Provider<ContributionRecorder>(
  ContributionRecorder.new,
);

/// Records contributions and tells the rest of the app that money changed.
class ContributionRecorder {
  ContributionRecorder(this._ref);

  final Ref _ref;

  ContributionsRepository get _repository =>
      _ref.read(contributionsRepositoryProvider);

  Future<ProjectContribution> recordProjectContribution(
    String projectId,
    NewContribution contribution,
  ) async {
    final saved = await _repository.addProjectContribution(
      projectId,
      contribution,
    );
    _ref.markChanged(<DataScope>[...DataChanges.money, DataScope.projects]);
    return saved;
  }

  Future<CollectionContribution> recordCollectionContribution(
    NewContribution contribution,
  ) async {
    final saved = await _repository.addCollectionContribution(contribution);
    _ref.markChanged(DataChanges.money);
    return saved;
  }
}
