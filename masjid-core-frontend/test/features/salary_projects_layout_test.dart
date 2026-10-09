// mocktail needs `when(() => mock.call())` closures, not tear-offs.
// ignore_for_file: unnecessary_lambdas

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/pagination/page.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/auth/data/models/app_user.dart';
import 'package:masjid_core_frontend/features/contributions/data/contributions_repository.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/project_contribution.dart';
import 'package:masjid_core_frontend/features/contributions/presentation/project_contributions_screen.dart';
import 'package:masjid_core_frontend/features/imam_salary/application/imam_salary_controllers.dart';
import 'package:masjid_core_frontend/features/imam_salary/data/imam_salary_repository.dart';
import 'package:masjid_core_frontend/features/imam_salary/data/models/imam_salary_models.dart';
import 'package:masjid_core_frontend/features/imam_salary/presentation/imam_salary_screen.dart';
import 'package:masjid_core_frontend/features/projects/data/models/project_model.dart';
import 'package:masjid_core_frontend/features/projects/data/models/projects_filter.dart';
import 'package:masjid_core_frontend/features/projects/data/projects_repository.dart';
import 'package:masjid_core_frontend/features/projects/presentation/project_detail_screen.dart';
import 'package:masjid_core_frontend/features/projects/presentation/project_form_screen.dart';
import 'package:masjid_core_frontend/features/projects/presentation/projects_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../shared/ui/ui_test_helpers.dart';

class _MockSalary extends Mock implements ImamSalaryRepository {}

class _MockProjects extends Mock implements ProjectsRepository {}

class _MockContributions extends Mock implements ContributionsRepository {}

class _As extends AuthController {
  _As(this.permissions);

  final List<String> permissions;

  @override
  AuthState build() => AuthSignedIn(
    AppUser(
      id: 'u1',
      fullName: 'Treasurer',
      masjidId: 'm1',
      permissions: permissions,
    ),
  );
}

const _committee = <String>[
  AppPermissions.imamSalaryManage,
  AppPermissions.imamSalaryRead,
  AppPermissions.projectsRead,
  AppPermissions.projectsManage,
  AppPermissions.contributionsRead,
  AppPermissions.contributionsRecord,
];

PageResult<T> _page<T>(List<T> items) => PageResult<T>(
  items: items,
  meta: PageMeta(
    page: 1,
    limit: 20,
    total: items.length,
    totalPages: 1,
    hasNextPage: false,
  ),
);

final _project = ProjectModel(
  id: 'p1',
  title: 'New wudu area, roof repair, and painting of the whole masjid',
  description: 'Long work that the whole village supports with donations.',
  targetAmount: 12345678,
  collectedAmount: 2345678.5,
  spentAmount: 1234567,
  remainingAmount: 9999999.5,
  progressPercentage: 19,
  startDate: DateTime(2026, 6),
  endDate: DateTime(2027, 6),
);

/// Salary and project screens lay out without overflow in each language, on
/// a phone and on desktop, and with a large device font. Big numbers on
/// purpose.
void main() {
  setUpAll(() => registerFallbackValue(const ProjectsFilter()));
  setUp(() {
    TestWidgetsFlutterBinding
        .instance
        .platformDispatcher
        .accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(
      disableAnimations: true,
    );
  });
  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher
        .clearAccessibilityFeaturesTestValue();
  });

  /// name → (screen, permissions, after it opens)
  final screens =
      <String, (Widget, List<String>, Future<void> Function(WidgetTester)?)>{
        'salary committee': (const ImamSalaryScreen(), _committee, null),
        'salary payment sheet': (
          const ImamSalaryScreen(),
          _committee,
          (tester) async {
            await tester.scrollUntilVisible(
              find.byType(FamilyDueTile),
              300,
              scrollable: find.byType(Scrollable).first,
            );
            await tester.tap(find.byType(FamilyDueTile).first);
            await tester.pumpAndSettle();
          },
        ),
        'salary member': (
          const ImamSalaryScreen(),
          const <String>[AppPermissions.ownContributionsRead],
          null,
        ),
        'projects': (const Scaffold(body: ProjectsScreen()), _committee, null),
        'project': (
          ProjectDetailScreen(projectId: 'p1', initialProject: _project),
          _committee,
          null,
        ),
        'project form': (
          ProjectFormScreen(initial: _project),
          _committee,
          null,
        ),
        'project givers': (
          const ProjectContributionsScreen(
            projectId: 'p1',
            projectTitle: 'Roof',
          ),
          _committee,
          null,
        ),
      };
  const sizes = <String, Size>{
    'phone': Size(360, 780),
    'desktop': Size(1280, 900),
  };

  Future<void> pump(
    WidgetTester tester,
    (Widget, List<String>, Future<void> Function(WidgetTester)?) screen,
    Locale locale,
    Size size,
  ) async {
    final salary = _MockSalary();
    when(
      () => salary.findMonth(
        month: any(named: 'month'),
        year: any(named: 'year'),
      ),
    ).thenAnswer(
      (_) async => const ImamSalaryMonth(
        id: 'm1',
        month: 6,
        year: 2026,
        amountPerHead: 1500,
        totalExpected: 1234567,
        totalCollected: 234567,
        totalDue: 1000000,
        paidCount: 120,
        partialCount: 45,
        unpaidCount: 300,
      ),
    );
    when(
      () => salary.getAssignments(
        any(),
        status: any(named: 'status'),
        search: any(named: 'search'),
        page: any(named: 'page'),
      ),
    ).thenAnswer(
      (_) async => _page(const <SalaryAssignment>[
        SalaryAssignment(
          id: 'a1',
          memberName: 'Mohammed Abdul Rafiq Khan Sahab',
          expectedAmount: 1500,
          paidAmount: 500,
          dueAmount: 1000,
          status: SalaryStatus.partial,
        ),
      ]),
    );
    when(() => salary.getMyHistory()).thenAnswer(
      (_) async => const <MySalaryHistoryMonth>[
        MySalaryHistoryMonth(
          month: 6,
          year: 2026,
          expectedAmount: 1500,
          paidAmount: 500,
          dueAmount: 1000,
          status: SalaryStatus.partial,
          payments: <MySalaryHistoryPayment>[
            MySalaryHistoryPayment(id: 'x', amount: 500),
          ],
        ),
      ],
    );
    final projects = _MockProjects();
    when(
      () => projects.getProjects(any(), page: any(named: 'page')),
    ).thenAnswer((_) async => _page([_project]));
    when(() => projects.getProjectById('p1')).thenAnswer((_) async => _project);
    final contributions = _MockContributions();
    when(
      () => contributions.getProjectContributions(
        any(),
        search: any(named: 'search'),
        paymentMode: any(named: 'paymentMode'),
        page: any(named: 'page'),
      ),
    ).thenAnswer(
      (_) async => _page(<ProjectContribution>[
        ProjectContribution(
          id: 'c1',
          contributorName: 'Mohammed Abdul Rafiq Khan Sahab',
          amount: 1234567,
          paymentMode: 'ONLINE',
          paidAt: DateTime(2026, 6, 3),
        ),
      ]),
    );

    await pumpUi(
      tester,
      screen.$1,
      locale: locale,
      size: size,
      overrides: [
        imamSalaryRepositoryProvider.overrideWithValue(salary),
        projectsRepositoryProvider.overrideWithValue(projects),
        contributionsRepositoryProvider.overrideWithValue(contributions),
        authControllerProvider.overrideWith(() => _As(screen.$2)),
        salaryPeriodProvider.overrideWith((ref) => (month: 6, year: 2026)),
      ],
    );
    await screen.$3?.call(tester);
  }

  for (final screen in screens.entries) {
    for (final language in <String>['en', 'hi', 'ur']) {
      for (final size in sizes.entries) {
        testWidgets('${screen.key} in $language on a ${size.key}', (
          tester,
        ) async {
          await pump(tester, screen.value, Locale(language), size.value);
          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('${screen.key} on a phone with a large device font', (
      tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.6;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pump(
        tester,
        screen.value,
        const Locale('ur'),
        const Size(360, 780),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
