// mocktail needs `when(() => mock.call())` closures, not tear-offs.
// ignore_for_file: unnecessary_lambdas

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/projects/data/models/project_model.dart';
import 'package:masjid_core_frontend/features/projects/data/projects_repository.dart';
import 'package:masjid_core_frontend/features/projects/presentation/project_detail_screen.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../shared/ui/ui_test_helpers.dart';
import 'projects_test_helpers.dart';

const _manager = <String>[
  AppPermissions.projectsRead,
  AppPermissions.projectsManage,
  AppPermissions.contributionsRead,
  AppPermissions.contributionsRecord,
];

Future<void> _pump(
  WidgetTester tester,
  ProjectsRepository repository, {
  List<String> permissions = const <String>[AppPermissions.projectsRead],
  ProjectModel? initial,
}) => pumpRouted(
  tester,
  ProjectDetailScreen(projectId: 'p1', initialProject: initial),
  size: const Size(420, 1600),
  overrides: [
    projectsRepositoryProvider.overrideWithValue(repository),
    authControllerProvider.overrideWith(() => SignedInAs(permissions)),
  ],
);

void main() {
  late MockProjectsRepository repository;

  setUp(() => repository = MockProjectsRepository());

  testWidgets('loads the project and shows its progress', (tester) async {
    when(
      () => repository.getProjectById('p1'),
    ).thenAnswer((_) async => project('p1'));
    await _pump(tester, repository);

    expect(find.text('New Wuzu Area'), findsWidgets);
    expect(find.text('₹80,000'), findsOneWidget);
    expect(find.text('of ₹2,00,000'), findsOneWidget);
    expect(find.text('₹1,20,000 still needed'), findsOneWidget);
    expect(find.text('₹30,000 spent'), findsOneWidget);
    expect(find.text('1 Jun 2026'), findsOneWidget);
    expect(find.byType(ProgressRing), findsOneWidget);
    verify(() => repository.getProjectById('p1')).called(1);
  });

  testWidgets('the project from the list shows at once, then the fresh one', (
    tester,
  ) async {
    final reply = Completer<ProjectModel>();
    when(() => repository.getProjectById('p1')).thenAnswer((_) => reply.future);
    await _pump(tester, repository, initial: project('p1', title: 'Preview'));
    expect(find.text('Preview'), findsWidgets);

    reply.complete(project('p1', title: 'Fresh'));
    await tester.pumpAndSettle();
    expect(find.text('Fresh'), findsWidgets);
    expect(find.text('Preview'), findsNothing);
  });

  testWidgets('readers see givers only; no edit or cancel', (tester) async {
    when(
      () => repository.getProjectById('p1'),
    ).thenAnswer((_) async => project('p1'));
    await _pump(tester, repository);

    expect(find.text('Givers'), findsOneWidget);
    expect(find.text('Edit project'), findsNothing);
    expect(find.text('Cancel project'), findsNothing);
    expect(find.text('Add giver'), findsNothing);
  });

  testWidgets('managers can cancel the project with a hold', (tester) async {
    when(
      () => repository.getProjectById('p1'),
    ).thenAnswer((_) async => project('p1'));
    when(() => repository.deleteProject('p1')).thenAnswer((_) async {});
    await _pump(tester, repository, permissions: _manager);

    expect(find.text('Edit project'), findsOneWidget);
    expect(find.text('Add giver'), findsOneWidget);
    await tester.ensureVisible(find.text('Cancel project'));
    await tester.tap(find.text('Cancel project'));
    await tester.pumpAndSettle();
    expect(find.text('Cancel this project?'), findsOneWidget);

    final hold = find.descendant(
      of: find.byType(HoldToConfirmButton),
      matching: find.text('Cancel project'),
    );
    final gesture = await tester.startGesture(tester.getCenter(hold));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2100));
    await gesture.up();
    await tester.pumpAndSettle();

    verify(() => repository.deleteProject('p1')).called(1);
    expect(find.text('Project cancelled'), findsOneWidget);
  });

  testWidgets('a failed load shows why with Try again', (tester) async {
    when(() => repository.getProjectById('p1')).thenThrow(
      const ApiException(
        message: 'Project not found',
        code: 'PROJECT_NOT_FOUND',
        statusCode: 404,
      ),
    );
    await _pump(tester, repository);

    expect(find.text('Project not found'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });
}
