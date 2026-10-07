// mocktail needs `when(() => mock.call())` closures, not tear-offs.
// ignore_for_file: unnecessary_lambdas

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/pagination/page.dart';
import 'package:masjid_core_frontend/core/refresh/data_scopes.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/finance/application/finance_entries_controller.dart';
import 'package:masjid_core_frontend/features/finance/application/finance_entry_controller.dart';
import 'package:masjid_core_frontend/features/finance/data/finance_repository.dart';
import 'package:masjid_core_frontend/features/finance/data/models/collection_entry_model.dart';
import 'package:masjid_core_frontend/features/finance/data/models/create_collection_request.dart';
import 'package:masjid_core_frontend/features/finance/data/models/finance_entry_filter.dart';
import 'package:mocktail/mocktail.dart';

class _MockFinanceRepository extends Mock implements FinanceRepository {}

class _SignedOut extends AuthController {
  @override
  AuthState build() => const AuthSignedOut();
}

PageResult<CollectionEntryModel> _page(int page, {required bool hasNext}) =>
    PageResult<CollectionEntryModel>(
      items: <CollectionEntryModel>[
        CollectionEntryModel(id: 'c$page', type: 'OTHER', amount: 10.0 * page),
      ],
      meta: PageMeta(
        page: page,
        limit: 1,
        total: 2,
        totalPages: 2,
        hasNextPage: hasNext,
      ),
    );

void main() {
  setUpAll(() {
    registerFallbackValue(const FinanceEntryFilter());
    registerFallbackValue(
      const CreateCollectionRequest(type: 'OTHER', amount: 1),
    );
  });

  late _MockFinanceRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _MockFinanceRepository();
    container = ProviderContainer(
      overrides: [
        financeRepositoryProvider.overrideWithValue(repository),
        authControllerProvider.overrideWith(_SignedOut.new),
      ],
    );
    addTearDown(container.dispose);
  });

  test('loadMore appends the next page', () async {
    when(
      () => repository.getCollections(any()),
    ).thenAnswer((_) async => _page(1, hasNext: true));
    when(
      () => repository.getCollections(any(), page: 2),
    ).thenAnswer((_) async => _page(2, hasNext: false));

    container.listen(collectionsControllerProvider, (_, _) {});
    final first = await container.read(collectionsControllerProvider.future);
    expect(first.items.map((e) => e.id), <String>['c1']);
    expect(first.hasMore, isTrue);

    await container.read(collectionsControllerProvider.notifier).loadMore();

    final state = container.read(collectionsControllerProvider).requireValue;
    expect(state.items.map((e) => e.id), <String>['c1', 'c2']);
    expect(state.page, 2);
    expect(state.hasMore, isFalse);
  });

  test('changing the filter reloads from page 1 with the filter', () async {
    when(
      () => repository.getCollections(any(), page: any(named: 'page')),
    ).thenAnswer((invocation) async {
      final page = invocation.namedArguments[#page] as int;
      return _page(page, hasNext: true);
    });

    container.listen(collectionsControllerProvider, (_, _) {});
    await container.read(collectionsControllerProvider.future);
    await container.read(collectionsControllerProvider.notifier).loadMore();
    expect(
      container.read(collectionsControllerProvider).requireValue.items,
      hasLength(2),
    );

    container
        .read(collectionsFilterProvider.notifier)
        .update((filter) => filter.copyWith(type: 'ZAKAT'));
    final reloaded = await container.read(collectionsControllerProvider.future);

    expect(reloaded.page, 1);
    expect(reloaded.items.map((e) => e.id), <String>['c1']);
    verify(
      () => repository.getCollections(const FinanceEntryFilter(type: 'ZAKAT')),
    ).called(1);
  });

  test('adding a collection marks money scopes changed', () async {
    when(() => repository.createCollection(any())).thenAnswer(
      (_) async =>
          const CollectionEntryModel(id: 'new', type: 'OTHER', amount: 5),
    );
    container.listen(financeEntryControllerProvider, (_, _) {});

    final ok = await container
        .read(financeEntryControllerProvider.notifier)
        .addCollection(const CreateCollectionRequest(type: 'OTHER', amount: 5));

    expect(ok, isTrue);
    for (final scope in DataChanges.money) {
      expect(container.read(dataVersionProvider(scope)), 1);
    }
  });
}
