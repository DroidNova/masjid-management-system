// mocktail needs `when(() => mock.call())` closures, not tear-offs.
// ignore_for_file: unnecessary_lambdas

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/projects/data/models/create_project_request.dart';
import 'package:masjid_core_frontend/features/projects/data/models/projects_filter.dart';
import 'package:masjid_core_frontend/features/projects/data/projects_repository.dart';
import 'package:masjid_core_frontend/features/projects/presentation/add_project_screen.dart';
import 'package:masjid_core_frontend/features/projects/presentation/projects_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../shared/ui/ui_test_helpers.dart';
import 'projects_test_helpers.dart';

class _FakeCreate extends Fake implements CreateProjectRequest {}

Future<void> _pump(
  WidgetTester tester,
  ProjectsRepository repository, {
  List<String> permissions = const <String>[AppPermissions.projectsRead],
}) => pumpRouted(
  tester,
  const Scaffold(body: ProjectsScreen()),
  overrides: [
    projectsRepositoryProvider.overrideWithValue(repository),
    authControllerProvider.overrideWith(() => SignedInAs(permissions)),
  ],
  extraRoutes: <String, Widget>{
    '/projects/add': const Scaffold(body: Text('add page')),
    '/projects/p1': const Scaffold(body: Text('detail page')),
  },
);

void main() {
  late MockProjectsRepository repository;

  setUpAll(() {
    registerProjectFallbacks();
    registerFallbackValue(_FakeCreate());
  });

  setUp(() {
    repository = MockProjectsRepository();
    when(
      () => repository.getProjects(any(), page: any(named: 'page')),
    ).thenAnswer((_) async => projectsPage([project('p1')]));
  });

  testWidgets('cards show progress, collected of target, and percent', (
    tester,
  ) async {
    await _pump(tester, repository);

    expect(find.text('New Wuzu Area'), findsOneWidget);
    expect(find.text('Ongoing'), findsWidgets);
    expect(find.text('₹80,000 of ₹2,00,000'), findsOneWidget);
    expect(find.text('40%'), findsOneWidget);

    await tester.tap(find.text('New Wuzu Area'));
    await tester.pumpAndSettle();
    expect(find.text('detail page'), findsOneWidget);
  });

  testWidgets('Add project only for managers', (tester) async {
    await _pump(tester, repository);
    expect(find.text('Add project'), findsNothing);
  });

  testWidgets('managers can add a project', (tester) async {
    await _pump(
      tester,
      repository,
      permissions: const <String>[
        AppPermissions.projectsRead,
        AppPermissions.projectsManage,
      ],
    );
    await tester.tap(find.text('Add project'));
    await tester.pumpAndSettle();
    expect(find.text('add page'), findsOneWidget);
  });

  testWidgets('a status chip asks the server for that status', (tester) async {
    await _pump(tester, repository);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Planned'));
    await tester.pumpAndSettle();

    final filters = verify(
      () => repository.getProjects(captureAny(), page: any(named: 'page')),
    ).captured.cast<ProjectsFilter>();
    expect(filters.last.status, 'PLANNED');
  });

  testWidgets('a failed load shows why with Try again', (tester) async {
    when(
      () => repository.getProjects(any(), page: any(named: 'page')),
    ).thenThrow(
      const ApiException(
        message: 'Projects are unavailable',
        code: 'UNKNOWN_X',
        statusCode: 500,
      ),
    );
    await _pump(tester, repository);

    expect(find.text('Projects are unavailable'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('adding a project: name, money needed, then save', (
    tester,
  ) async {
    when(
      () => repository.createProject(any()),
    ).thenAnswer((_) async => project('p9'));
    await pumpRouted(
      tester,
      const AddProjectScreen(),
      size: const Size(420, 1600),
      overrides: [projectsRepositoryProvider.overrideWithValue(repository)],
    );

    final next = find.widgetWithText(FilledButton, 'Next');
    expect(tester.widget<FilledButton>(next).onPressed, isNull);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Project name'),
      'New roof',
    );
    await tester.pump();
    await tester.tap(next);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ActionChip, '₹50,000'));
    await tester.pump();
    await tester.tap(next);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Planned'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    final request =
        verify(() => repository.createProject(captureAny())).captured.single
            as CreateProjectRequest;
    expect(request.title, 'New roof');
    expect(request.targetAmount, 50000);
    expect(request.status, 'PLANNED');
    expect(find.text('Project added'), findsOneWidget);
  });
}
