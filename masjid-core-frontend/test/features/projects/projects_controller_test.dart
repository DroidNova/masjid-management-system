// mocktail needs `when(() => mock.call())` closures, not tear-offs.
// ignore_for_file: unnecessary_lambdas

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/refresh/data_scopes.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/projects/application/project_editor_controller.dart';
import 'package:masjid_core_frontend/features/projects/application/projects_controller.dart';
import 'package:masjid_core_frontend/features/projects/data/models/projects_filter.dart';
import 'package:masjid_core_frontend/features/projects/data/projects_repository.dart';
import 'package:mocktail/mocktail.dart';

import 'projects_test_helpers.dart';

void main() {
  setUpAll(registerProjectFallbacks);

  late MockProjectsRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockProjectsRepository();
    when(
      () => repository.getProjects(any(), page: any(named: 'page')),
    ).thenAnswer((invocation) async {
      final page = invocation.namedArguments[#page] as int;
      return projectsPage([project('p$page')], page: page, hasNext: page < 2);
    });
    container = ProviderContainer(
      overrides: [
        projectsRepositoryProvider.overrideWithValue(repository),
        authControllerProvider.overrideWith(() => SignedInAs(const [])),
      ],
    );
    addTearDown(container.dispose);
    container.listen(projectsControllerProvider, (_, _) {});
  });

  test('loadMore appends pages until there are no more', () async {
    await container.read(projectsControllerProvider.future);
    final controller = container.read(projectsControllerProvider.notifier);

    await controller.loadMore();
    await controller.loadMore(); // no next page: does nothing

    final state = container.read(projectsControllerProvider).requireValue;
    expect(state.items.map((p) => p.id), <String>['p1', 'p2']);
    expect(state.hasMore, isFalse);
    verify(() => repository.getProjects(any(), page: 2)).called(1);
    verifyNever(() => repository.getProjects(any(), page: 3));
  });

  test('a filter change resets to page 1 with the new status', () async {
    await container.read(projectsControllerProvider.future);
    await container.read(projectsControllerProvider.notifier).loadMore();

    container
        .read(projectsFilterProvider.notifier)
        .update((filter) => filter.copyWith(status: 'PLANNED'));
    final state = await container.read(projectsControllerProvider.future);

    expect(state.page, 1);
    expect(state.items.map((p) => p.id), <String>['p1']);
    verify(
      () => repository.getProjects(const ProjectsFilter(status: 'PLANNED')),
    ).called(1);
  });

  test('deleting a project reloads lists and the dashboard', () async {
    when(() => repository.deleteProject('p1')).thenAnswer((_) async {});
    container.listen(projectEditorControllerProvider, (_, _) {});
    await container.read(projectsControllerProvider.future);

    final ok = await container
        .read(projectEditorControllerProvider.notifier)
        .deleteProject('p1');

    expect(ok, isTrue);
    expect(container.read(dataVersionProvider(DataScope.projects)), 1);
    expect(container.read(dataVersionProvider(DataScope.dashboard)), 1);
    await container.read(projectsControllerProvider.future);
    verify(() => repository.getProjects(any())).called(2);
  });
}
