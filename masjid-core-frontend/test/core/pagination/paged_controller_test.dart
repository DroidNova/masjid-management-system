import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/pagination/page.dart';
import 'package:masjid_core_frontend/core/pagination/paged_controller.dart';
import 'package:masjid_core_frontend/core/pagination/paged_family_controller.dart';

/// A fake backend: each call is answered by the test through [pending].
class _Server {
  final List<({String filter, int page, Completer<PageResult<String>> reply})>
  pending = [];

  Future<PageResult<String>> fetch(String filter, int page) {
    final reply = Completer<PageResult<String>>();
    pending.add((filter: filter, page: page, reply: reply));
    return reply.future;
  }

  /// Answers the oldest open call with `<filter>-<page>` and more pages.
  void answerNext() {
    final call = pending.removeAt(0);
    call.reply.complete(
      PageResult<String>(
        items: <String>['${call.filter}-${call.page}'],
        meta: PageMeta(
          page: call.page,
          limit: 1,
          total: 10,
          totalPages: 10,
          hasNextPage: true,
        ),
      ),
    );
  }
}

final _serverProvider = Provider<_Server>((ref) => _Server());
final _filterProvider = StateProvider.autoDispose<String>((ref) => 'a');

final _listProvider =
    AsyncNotifierProvider.autoDispose<_ListController, PagedState<String>>(
      _ListController.new,
    );

class _ListController extends PagedController<String> {
  @override
  Future<PagedState<String>> build() {
    ref.watch(_filterProvider);
    return super.build();
  }

  @override
  Future<PageResult<String>> fetchPage(int page) =>
      ref.read(_serverProvider).fetch(ref.read(_filterProvider), page);

  /// Like an in-place edit from a mutation (e.g. a replaced row).
  void rename(String from, String to) {
    final current = state.requireValue;
    state = AsyncData(
      current.copyWith(
        items: [for (final item in current.items) item == from ? to : item],
        loadingMore: current.loadingMore,
      ),
    );
  }
}

final _familyProvider = AsyncNotifierProvider.autoDispose
    .family<_FamilyController, PagedState<String>, String>(
      _FamilyController.new,
    );

class _FamilyController extends PagedFamilyController<String, String> {
  @override
  Future<PageResult<String>> fetchPage(String arg, int page) =>
      ref.read(_serverProvider).fetch(arg, page);
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  late ProviderContainer container;
  late _Server server;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
    server = container.read(_serverProvider);
  });

  Future<void> loadFirstPage() async {
    container.listen(_listProvider, (_, _) {});
    await _settle();
    server.answerNext();
    await container.read(_listProvider.future);
  }

  List<String> items() => container.read(_listProvider).requireValue.items;

  test('a filter change during load-more drops the old page', () async {
    await loadFirstPage();

    final loadMore = container.read(_listProvider.notifier).loadMore();
    container.read(_filterProvider.notifier).state = 'b';
    await _settle();

    // Old page 2 arrives after the filter changed, then the new page 1.
    server.answerNext();
    await loadMore;
    server.answerNext();
    final reloaded = await container.read(_listProvider.future);

    expect(reloaded.items, <String>['b-1']);
    expect(reloaded.page, 1);
    expect(reloaded.loadingMore, isFalse);
    await _settle();
    expect(items(), <String>['b-1']);
  });

  test('a refresh during load-more does not resurrect old items', () async {
    await loadFirstPage();

    final loadMore = container.read(_listProvider.notifier).loadMore();
    final refresh = container.read(_listProvider.notifier).refresh();
    await _settle();

    // The refresh's page 1 answers first, then the stale page 2.
    expect(server.pending.map((call) => call.page), <int>[2, 1]);
    final stalePage = server.pending.removeAt(0);
    server.answerNext();
    await refresh;
    stalePage.reply.complete(
      const PageResult<String>(
        items: <String>['a-2'],
        meta: PageMeta(
          page: 2,
          limit: 1,
          total: 10,
          totalPages: 10,
          hasNextPage: true,
        ),
      ),
    );
    await loadMore;

    expect(items(), <String>['a-1']);
    expect(container.read(_listProvider).requireValue.loadingMore, isFalse);
  });

  test('load-more is ignored while page 1 is reloading', () async {
    await loadFirstPage();

    container.read(_filterProvider.notifier).state = 'b';
    await _settle();
    await container.read(_listProvider.notifier).loadMore();

    expect(server.pending.map((call) => call.page), <int>[1]);
  });

  test('load-more keeps an item replaced while it was in flight', () async {
    await loadFirstPage();

    final loadMore = container.read(_listProvider.notifier).loadMore();
    container.read(_listProvider.notifier).rename('a-1', 'a-1 (edited)');
    server.answerNext();
    await loadMore;

    expect(items(), <String>['a-1 (edited)', 'a-2']);
  });

  test('family: a refresh during load-more drops the old page', () async {
    final provider = _familyProvider('x');
    container.listen(provider, (_, _) {});
    await _settle();
    server.answerNext();
    await container.read(provider.future);

    final loadMore = container.read(provider.notifier).loadMore();
    final refresh = container.read(provider.notifier).refresh();
    await _settle();
    final stalePage = server.pending.removeAt(0);
    server.answerNext();
    await refresh;
    stalePage.reply.complete(
      const PageResult<String>(
        items: <String>['x-2'],
        meta: PageMeta(
          page: 2,
          limit: 1,
          total: 10,
          totalPages: 10,
          hasNextPage: true,
        ),
      ),
    );
    await loadMore;

    expect(container.read(provider).requireValue.items, <String>['x-1']);
  });
}
