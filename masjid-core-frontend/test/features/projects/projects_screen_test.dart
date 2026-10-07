// mocktail needs `when(() => mock.call())` closures, not tear-offs.
// ignore_for_file: unnecessary_lambdas

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/projects/data/models/projects_filter.dart';
import 'package:masjid_core_frontend/features/projects/data/projects_repository.dart';
import 'package:masjid_core_frontend/features/projects/presentation/projects_screen.dart';
import 'package:mocktail/mocktail.dart';

import 'projects_test_helpers.dart';

Future<void> _pump(
  WidgetTester tester,
  ProjectsRepository repository, {
  List<String> permissions = const <String>[AppPermissions.projectsRead],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        projectsRepositoryProvider.overrideWithValue(repository),
        authControllerProvider.overrideWith(() => SignedInAs(permissions)),
      ],
      child: const MaterialApp(home: Scaffold(body: ProjectsScreen())),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en_IN');
    registerProjectFallbacks();
  });

  late MockProjectsRepository repository;

  setUp(() {
    repository = MockProjectsRepository();
    when(
      () => repository.getProjects(any(), page: any(named: 'page')),
    ).thenAnswer((_) async => projectsPage([project('p1')]));
  });

  testWidgets('lists projects with formatted amounts', (tester) async {
    await _pump(tester, repository);

    expect(find.text('New Wuzu Area'), findsOneWidget);
    expect(find.text('Target: ₹2,00,000'), findsOneWidget);
    expect(find.text('Progress: 40%'), findsOneWidget);
  });

  testWidgets('hides Add Project without projects.manage', (tester) async {
    await _pump(tester, repository);
    expect(find.text('Add Project'), findsNothing);
  });

  testWidgets('shows Add Project with projects.manage', (tester) async {
    await _pump(
      tester,
      repository,
      permissions: const <String>[
        AppPermissions.projectsRead,
        AppPermissions.projectsManage,
      ],
    );
    expect(find.text('Add Project'), findsOneWidget);
  });

  testWidgets('a status chip asks the server for that status', (tester) async {
    await _pump(tester, repository);

    await tester.tap(find.text('Completed'));
    await tester.pump();
    await tester.pump();

    verify(
      () => repository.getProjects(const ProjectsFilter(status: 'COMPLETED')),
    ).called(1);
  });

  testWidgets('error shows the message and retry', (tester) async {
    when(
      () => repository.getProjects(any(), page: any(named: 'page')),
    ).thenThrow(
      const ApiException(
        message: 'Server unavailable',
        code: ApiErrorCodes.unknown,
        statusCode: 500,
      ),
    );

    await _pump(tester, repository);

    expect(find.text('Unable to load projects.'), findsOneWidget);
    expect(find.text('Server unavailable'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
