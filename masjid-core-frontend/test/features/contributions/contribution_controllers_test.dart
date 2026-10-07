// mocktail needs `when(() => mock.call())` closures, not tear-offs.
// ignore_for_file: unnecessary_lambdas

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/core/pagination/page.dart';
import 'package:masjid_core_frontend/core/refresh/data_scopes.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/contributions/application/contribution_list_controllers.dart';
import 'package:masjid_core_frontend/features/contributions/application/my_contributions_controllers.dart';
import 'package:masjid_core_frontend/features/contributions/data/contributions_repository.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/collection_contribution.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/my_imam_salary_payment.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/new_contribution.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/project_contribution.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepository extends Mock implements ContributionsRepository {}

class _SignedOut extends AuthController {
  @override
  AuthState build() => const AuthSignedOut();
}

PageResult<T> _page<T>(List<T> items, {int page = 1, bool more = false}) =>
    PageResult<T>(
      items: items,
      meta: PageMeta(
        page: page,
        limit: 20,
        total: 40,
        totalPages: more ? page + 1 : page,
        hasNextPage: more,
      ),
    );

ProjectContribution _project(String id) =>
    ProjectContribution(id: id, contributorName: 'Donor $id', amount: 100);

void main() {
  late _MockRepository repository;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(
      NewContribution(
        contributorName: 'x',
        amount: 1,
        paymentMode: 'CASH',
        paidAt: DateTime(2026),
      ),
    );
  });

  setUp(() {
    repository = _MockRepository();
    container = ProviderContainer(
      overrides: [
        contributionsRepositoryProvider.overrideWithValue(repository),
        authControllerProvider.overrideWith(_SignedOut.new),
      ],
    );
    addTearDown(container.dispose);
  });

  group('project contributions (paged family controller)', () {
    const query = (projectId: 'p1', search: '', paymentMode: null);

    test('loads page 1, appends page 2, stops when no more pages', () async {
      when(
        () => repository.getProjectContributions(
          'p1',
          search: '',
          paymentMode: any(named: 'paymentMode'),
        ),
      ).thenAnswer(
        (_) async => _page(<ProjectContribution>[_project('c1')], more: true),
      );
      when(
        () => repository.getProjectContributions(
          'p1',
          search: '',
          paymentMode: any(named: 'paymentMode'),
          page: 2,
        ),
      ).thenAnswer(
        (_) async => _page(<ProjectContribution>[_project('c2')], page: 2),
      );
      final provider = projectContributionsProvider(query);
      container.listen(provider, (_, _) {});

      final first = await container.read(provider.future);
      expect(first.items.map((c) => c.id), <String>['c1']);

      await container.read(provider.notifier).loadMore();
      await container.read(provider.notifier).loadMore(); // no-op: no more
      final state = container.read(provider).requireValue;
      expect(state.items.map((c) => c.id), <String>['c1', 'c2']);
      expect(state.hasMore, isFalse);
      verify(
        () => repository.getProjectContributions(
          'p1',
          search: '',
          paymentMode: any(named: 'paymentMode'),
          page: 2,
        ),
      ).called(1);
    });

    test('a failed "load more" keeps the loaded items and the error', () async {
      const error = ApiException(message: 'Offline', code: 'NETWORK_ERROR');
      when(
        () => repository.getProjectContributions(
          'p1',
          search: '',
          paymentMode: any(named: 'paymentMode'),
        ),
      ).thenAnswer(
        (_) async => _page(<ProjectContribution>[_project('c1')], more: true),
      );
      when(
        () => repository.getProjectContributions(
          'p1',
          search: '',
          paymentMode: any(named: 'paymentMode'),
          page: 2,
        ),
      ).thenThrow(error);
      final provider = projectContributionsProvider(query);
      container.listen(provider, (_, _) {});
      await container.read(provider.future);

      await container.read(provider.notifier).loadMore();

      final state = container.read(provider).requireValue;
      expect(state.items.map((c) => c.id), <String>['c1']);
      expect(state.loadMoreError, error);
      expect(state.loadingMore, isFalse);
    });

    test('reloads when contributions change elsewhere', () async {
      when(
        () => repository.getProjectContributions(
          any(),
          search: any(named: 'search'),
          paymentMode: any(named: 'paymentMode'),
          page: any(named: 'page'),
        ),
      ).thenAnswer((_) async => _page(<ProjectContribution>[]));
      final provider = projectContributionsProvider(query);
      container.listen(provider, (_, _) {});
      await container.read(provider.future);

      container
          .read(dataVersionProvider(DataScope.contributions).notifier)
          .state++;
      await container.read(provider.future);

      verify(
        () => repository.getProjectContributions(
          'p1',
          search: '',
          paymentMode: any(named: 'paymentMode'),
        ),
      ).called(2);
    });
  });

  test(
    'collection contributions reload from page 1 on a filter change',
    () async {
      when(
        () => repository.getCollectionContributions(
          search: any(named: 'search'),
          paymentMode: any(named: 'paymentMode'),
          collectionType: any(named: 'collectionType'),
          page: any(named: 'page'),
        ),
      ).thenAnswer((_) async => _page(<CollectionContribution>[]));
      container.listen(collectionContributionsProvider, (_, _) {});
      await container.read(collectionContributionsProvider.future);

      container.read(collectionContributionsFilterProvider.notifier).state = (
        search: 'Ali',
        paymentMode: 'CASH',
        collectionType: 'ZAKAT',
      );
      await container.read(collectionContributionsProvider.future);

      verify(
        () => repository.getCollectionContributions(
          search: 'Ali',
          paymentMode: 'CASH',
          collectionType: 'ZAKAT',
        ),
      ).called(1);
    },
  );

  test('my salary payments are loaded for the given month', () async {
    when(
      () => repository.getMyImamSalaryPayments(month: 5, year: 2026),
    ).thenAnswer(
      (_) async => _page(<MyImamSalaryPayment>[
        const MyImamSalaryPayment(id: 'x1', amount: 300),
      ]),
    );
    final provider = myImamSalaryPaymentsProvider((month: 5, year: 2026));
    container.listen(provider, (_, _) {});

    final state = await container.read(provider.future);
    expect(state.items.single.amount, 300);
  });

  group('ContributionRecorder', () {
    final contribution = NewContribution(
      contributorName: 'Ali',
      amount: 500,
      paymentMode: 'CASH',
      paidAt: DateTime(2026, 6, 2),
    );

    test(
      'a project contribution marks money and projects as changed',
      () async {
        when(
          () => repository.addProjectContribution('p1', any()),
        ).thenAnswer((_) async => _project('new'));

        await container
            .read(contributionRecorderProvider)
            .recordProjectContribution('p1', contribution);

        for (final scope in <DataScope>[
          ...DataChanges.money,
          DataScope.projects,
        ]) {
          expect(
            container.read(dataVersionProvider(scope)),
            1,
            reason: '$scope',
          );
        }
      },
    );

    test('a collection contribution marks money as changed', () async {
      when(
        () => repository.addCollectionContribution(any()),
      ).thenAnswer((_) async => const CollectionContribution(id: 'new'));

      await container
          .read(contributionRecorderProvider)
          .recordCollectionContribution(contribution);

      expect(container.read(dataVersionProvider(DataScope.finance)), 1);
      expect(container.read(dataVersionProvider(DataScope.projects)), 0);
    });
  });

  test('NewContribution.toJson trims and drops empty optional fields', () {
    final json = NewContribution(
      memberId: '',
      contributorName: '  Ali  ',
      contributorPhone: ' ',
      amount: 250.5,
      paymentMode: 'ONLINE',
      paidAt: DateTime.utc(2026, 6, 2),
      note: '  ',
      collectionType: 'ZAKAT',
    ).toJson();

    expect(json, <String, dynamic>{
      'contributorName': 'Ali',
      'collectionType': 'ZAKAT',
      'amount': 250.5,
      'paymentMode': 'ONLINE',
      'paidAt': '2026-06-02T00:00:00.000Z',
    });
  });
}
