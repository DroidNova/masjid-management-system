import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/refresh/data_scopes.dart';
import 'package:masjid_core_frontend/features/projects/data/models/create_project_request.dart';
import 'package:masjid_core_frontend/features/projects/data/models/update_project_request.dart';
import 'package:masjid_core_frontend/features/projects/data/projects_repository.dart';

/// Creates, updates and cancels projects.
///
/// State is the last mutation: loading while saving, error if it failed.
/// Screens watch it for the busy state and read `.error` for messages
/// (`userMessage` / `fieldError`). Every success marks the projects list,
/// project details and the dashboard as changed.
final projectEditorControllerProvider =
    AsyncNotifierProvider.autoDispose<ProjectEditorController, void>(
      ProjectEditorController.new,
    );

class ProjectEditorController extends AutoDisposeAsyncNotifier<void> {
  static const List<DataScope> changedScopes = <DataScope>[
    DataScope.projects,
    DataScope.dashboard,
  ];

  @override
  FutureOr<void> build() {}

  ProjectsRepository get _repository => ref.read(projectsRepositoryProvider);

  Future<bool> createProject(CreateProjectRequest request) =>
      _run(() => _repository.createProject(request));

  Future<bool> updateProject(String id, UpdateProjectRequest request) =>
      _run(() => _repository.updateProject(id, request));

  /// The server marks the project CANCELLED.
  Future<bool> deleteProject(String id) =>
      _run(() => _repository.deleteProject(id));

  Future<bool> _run(Future<Object?> Function() action) async {
    if (state.isLoading) return false;
    // Finish (and mark changes) even if the screen closes meanwhile.
    final keepAlive = ref.keepAlive();
    try {
      state = const AsyncLoading<void>();
      state = await AsyncValue.guard<void>(action);
      if (state.hasError) return false;
      ref.markChanged(changedScopes);
      return true;
    } finally {
      keepAlive.close();
    }
  }
}
