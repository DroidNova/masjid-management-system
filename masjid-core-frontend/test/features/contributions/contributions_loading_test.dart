// mocktail needs `when(() => mock.call())` closures, not tear-offs.
// ignore_for_file: unnecessary_lambdas

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/core/pagination/page.dart';
import 'package:masjid_core_frontend/core/refresh/data_scopes.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/auth/data/models/app_user.dart';
import 'package:masjid_core_frontend/features/contributions/application/contribution_list_controllers.dart';
import 'package:masjid_core_frontend/features/contributions/data/contributions_repository.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/collection_contribution.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/contributor_option.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/my_contribution_summary.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/my_imam_salary_month.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/project_contribution.dart';
import 'package:masjid_core_frontend/features/contributions/presentation/my_contributions_screen.dart';
import 'package:masjid_core_frontend/features/contributions/presentation/project_contributions_screen.dart';
import 'package:masjid_core_frontend/features/projects/application/project_detail_controller.dart';
import 'package:masjid_core_frontend/features/projects/data/models/project_model.dart';
import 'package:masjid_core_frontend/features/projects/data/projects_repository.dart';
import 'package:mocktail/mocktail.dart';

import '../../shared/ui/ui_test_helpers.dart';

class _MockRepository extends Mock implements ContributionsRepository {}

class _MockProjectsRepository extends Mock implements ProjectsRepository {}

class _SignedIn extends AuthController {
  @override
  AuthState build() => const AuthSignedIn(AppUser(id: 'u1', fullName: 'Me'));
}

PageResult<T> _page<T>(List<T> items, {int page = 1, bool more = false}) =>
    PageResult<T>(
      items: items,
      meta: PageMeta(
        page: page,
        limit: 20,
        total: 100,
        totalPages: more ? page + 1 : page,
        hasNextPage: more,
      ),
    );

void main() {
  late _MockRepository repository;
  late _MockProjectsRepository projects;
  late ProviderContainer container;

  setUpAll(() => initializeDateFormatting('en_IN'));

  setUp(() {
    repository = _MockRepository();
    projects = _MockProjectsRepository();
    container = ProviderContainer(
      overrides: [
        contributionsRepositoryProvider.overrideWithValue(repository),
        projectsRepositoryProvider.overrideWithValue(projects),
        authControllerProvider.overrideWith(_SignedIn.new),
      ],
    );
    addTearDown(container.dispose);
  });

  test(
    'project contributions do not reload when a project is edited',
    () async {
      when(
        () => repository.getProjectContributions(
          any(),
          search: any(named: 'search'),
          paymentMode: any(named: 'paymentMode'),
          page: any(named: 'page'),
        ),
      ).thenAnswer((_) async => _page(<ProjectContribution>[]));
      final provider = projectContributionsProvider((
        projectId: 'p1',
        search: '',
        paymentMode: null,
      ));
      container.listen(provider, (_, _) {});
      await container.read(provider.future);

      container.read(dataVersionProvider(DataScope.projects).notifier).state++;
      await container.read(provider.future);

      verify(
        () => repository.getProjectContributions(
          'p1',
          search: '',
          paymentMode: any(named: 'paymentMode'),
        ),
      ).called(1);
    },
  );

  group('projectTitleProvider', () {
    test('reuses the loaded project detail', () async {
      when(
        () => projects.getProjectById('p1'),
      ).thenAnswer((_) async => const ProjectModel(id: 'p1', title: 'Roof'));
      container.listen(projectDetailProvider('p1'), (_, _) {});
      await container.read(projectDetailProvider('p1').future);

      container.listen(projectTitleProvider('p1'), (_, _) {});
      final title = await container.read(projectTitleProvider('p1').future);

      expect(title, 'Roof');
      verifyNever(() => repository.getProjectTitle(any()));
    });

    test('loads the title when the detail is not loaded', () async {
      when(
        () => repository.getProjectTitle('p1'),
      ).thenAnswer((_) async => 'Roof');

      container.listen(projectTitleProvider('p1'), (_, _) {});
      final title = await container.read(projectTitleProvider('p1').future);

      expect(title, 'Roof');
      verifyNever(() => projects.getProjectById(any()));
    });

    test('does not reload when projects change', () async {
      when(
        () => repository.getProjectTitle('p1'),
      ).thenAnswer((_) async => 'Roof');
      container.listen(projectTitleProvider('p1'), (_, _) {});
      await container.read(projectTitleProvider('p1').future);

      container.read(dataVersionProvider(DataScope.projects).notifier).state++;
      await container.read(projectTitleProvider('p1').future);

      verify(() => repository.getProjectTitle('p1')).called(1);
    });
  });

  group('contributorOptionsProvider', () {
    test('is kept for the session and reloads when members change', () async {
      when(() => repository.getContributorOptions()).thenAnswer(
        (_) async => const <ContributorOption>[
          ContributorOption(id: 'm1', fullName: 'Ahmed'),
        ],
      );

      // Two dialogs opened one after the other: one request.
      final sub = container.listen(contributorOptionsProvider, (_, _) {});
      await container.read(contributorOptionsProvider.future);
      sub.close();
      await Future<void>.delayed(Duration.zero);
      await container.read(contributorOptionsProvider.future);
      verify(() => repository.getContributorOptions()).called(1);

      container.read(dataVersionProvider(DataScope.members).notifier).state++;
      await container.read(contributorOptionsProvider.future);
      verify(() => repository.getContributorOptions()).called(1);
    });

    test('surfaces a load error instead of an empty list', () async {
      when(() => repository.getContributorOptions()).thenThrow(
        const ApiException(message: 'Forbidden', code: ApiErrorCodes.forbidden),
      );

      container.listen(contributorOptionsProvider, (_, _) {});
      await expectLater(
        container.read(contributorOptionsProvider.future),
        throwsA(isA<ApiException>()),
      );
      expect(container.read(contributorOptionsProvider).hasError, isTrue);
    });
  });

  testWidgets('a title passed from the project screen is not fetched', (
    tester,
  ) async {
    when(
      () => repository.getProjectContributions(
        any(),
        search: any(named: 'search'),
        paymentMode: any(named: 'paymentMode'),
        page: any(named: 'page'),
      ),
    ).thenAnswer((_) async => _page(<ProjectContribution>[]));

    await pumpUi(
      tester,
      const ProjectContributionsScreen(projectId: 'p1', projectTitle: 'Roof'),
      overrides: [
        contributionsRepositoryProvider.overrideWithValue(repository),
        authControllerProvider.overrideWith(_SignedIn.new),
      ],
    );

    expect(find.text('Givers · Roof'), findsOneWidget);
    verifyNever(() => repository.getProjectTitle(any()));
  });

  testWidgets('My Contributions loads more only for the section scrolled to', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    when(() => repository.getMySummary()).thenAnswer(
      (_) async => const MyContributionSummary(
        user: MyContributionUser(id: 'u1', fullName: 'Ahmed Khan'),
        imamSalary: ImamSalaryContributionSummary(),
      ),
    );
    when(
      () => repository.getMyImamSalaryMonths(page: any(named: 'page')),
    ).thenAnswer(
      (invocation) async => _page(
        <MyImamSalaryMonth>[
          for (var i = 1; i <= 12; i++) MyImamSalaryMonth(month: i, year: 2025),
        ],
        page: invocation.namedArguments[#page] as int? ?? 1,
        // Two pages of months.
        more: (invocation.namedArguments[#page] as int? ?? 1) == 1,
      ),
    );
    when(
      () => repository.getMyProjectContributions(page: any(named: 'page')),
    ).thenAnswer(
      (_) async => _page(<ProjectContribution>[
        for (var i = 0; i < 12; i++)
          ProjectContribution(id: 'p$i', contributorName: 'Me', amount: 10),
      ], more: true),
    );
    when(
      () => repository.getMyCollectionContributions(page: any(named: 'page')),
    ).thenAnswer((_) async => _page(<CollectionContribution>[], more: true));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          contributionsRepositoryProvider.overrideWithValue(repository),
          authControllerProvider.overrideWith(_SignedIn.new),
        ],
        child: const MaterialApp(home: MyContributionsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Nothing near a section end yet: no second pages.
    verifyNever(() => repository.getMyImamSalaryMonths(page: 2));
    verifyNever(() => repository.getMyProjectContributions(page: 2));
    verifyNever(() => repository.getMyCollectionContributions(page: 2));

    // Scroll to the end of the salary months only.
    for (
      var i = 0;
      i < 30 && find.text('Project Contributions').evaluate().isEmpty;
      i++
    ) {
      await tester.drag(find.byType(ListView), const Offset(0, -200));
      await tester.pumpAndSettle();
    }
    expect(find.text('Project Contributions'), findsOneWidget);

    verify(() => repository.getMyImamSalaryMonths(page: 2)).called(1);
    verifyNever(() => repository.getMyProjectContributions(page: 2));
    verifyNever(() => repository.getMyCollectionContributions(page: 2));
  });
}
