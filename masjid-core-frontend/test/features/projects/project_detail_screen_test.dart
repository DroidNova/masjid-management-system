// mocktail needs `when(() => mock.call())` closures, not tear-offs.
// ignore_for_file: unnecessary_lambdas

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/projects/data/models/project_model.dart';
import 'package:masjid_core_frontend/features/projects/data/projects_repository.dart';
import 'package:masjid_core_frontend/features/projects/presentation/project_detail_screen.dart';
import 'package:mocktail/mocktail.dart';

import 'projects_test_helpers.dart';

Future<void> _pump(
  WidgetTester tester,
  ProjectsRepository repository, {
  ProjectModel? initialProject,
  List<String> permissions = const <String>[AppPermissions.projectsRead],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        projectsRepositoryProvider.overrideWithValue(repository),
        authControllerProvider.overrideWith(() => SignedInAs(permissions)),
      ],
      child: MaterialApp(
        home: ProjectDetailScreen(
          projectId: 'p1',
          initialProject: initialProject,
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  setUpAll(() => initializeDateFormatting('en_IN'));

  late MockProjectsRepository repository;

  setUp(() => repository = MockProjectsRepository());

  testWidgets('loads the project by id (fresh URL, no extra)', (tester) async {
    when(
      () => repository.getProjectById('p1'),
    ).thenAnswer((_) async => project('p1'));

    await _pump(tester, repository);

    expect(find.text('New Wuzu Area'), findsOneWidget);
    expect(find.text('Collected: ₹80,000'), findsOneWidget);
    expect(find.text('Start Date: 1 Jun 2026'), findsOneWidget);
    verify(() => repository.getProjectById('p1')).called(1);
  });

  testWidgets('shows the extra instantly, then the loaded project', (
    tester,
  ) async {
    final completer = Completer<ProjectModel>();
    when(
      () => repository.getProjectById('p1'),
    ).thenAnswer((_) => completer.future);

    await _pump(
      tester,
      repository,
      initialProject: project('p1', title: 'Preview title'),
    );
    expect(find.text('Preview title'), findsOneWidget);

    completer.complete(project('p1', title: 'Fresh title'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Fresh title'), findsOneWidget);
    expect(find.text('Preview title'), findsNothing);
  });

  testWidgets('hides edit and delete without projects.manage', (tester) async {
    when(
      () => repository.getProjectById('p1'),
    ).thenAnswer((_) async => project('p1'));

    await _pump(tester, repository);

    expect(find.text('Edit Project'), findsNothing);
    expect(find.text('Delete / Cancel Project'), findsNothing);
    expect(find.text('View Contributions'), findsOneWidget);
  });

  testWidgets('shows edit and delete with projects.manage', (tester) async {
    when(
      () => repository.getProjectById('p1'),
    ).thenAnswer((_) async => project('p1'));

    await _pump(
      tester,
      repository,
      permissions: const <String>[
        AppPermissions.projectsRead,
        AppPermissions.projectsManage,
      ],
    );

    expect(find.text('Edit Project'), findsOneWidget);
    expect(find.text('Delete / Cancel Project'), findsOneWidget);
  });

  testWidgets('error shows the message and retry', (tester) async {
    when(() => repository.getProjectById('p1')).thenThrow(
      const ApiException(
        message: 'Project not found',
        code: 'PROJECT_NOT_FOUND',
        statusCode: 404,
      ),
    );

    await _pump(tester, repository);

    expect(find.text('Project not found'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
