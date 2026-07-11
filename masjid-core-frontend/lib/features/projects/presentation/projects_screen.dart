import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:platform_core_frontend/core/permissions/permission_helper.dart';
import 'package:platform_core_frontend/core/refresh/app_data_refresh_bus.dart';
import 'package:platform_core_frontend/core/storage/session_storage.dart';
import 'package:platform_core_frontend/features/auth/data/auth_repository.dart';
import 'package:platform_core_frontend/features/auth/data/models/app_user.dart';
import 'package:platform_core_frontend/features/projects/data/models/project_model.dart';
import 'package:platform_core_frontend/features/projects/data/projects_repository.dart';
import 'package:platform_core_frontend/features/projects/presentation/widgets/project_card.dart';
import 'package:platform_core_frontend/features/projects/presentation/widgets/project_empty_view.dart';
import 'package:platform_core_frontend/shared/widgets/app_button.dart';
import 'package:platform_core_frontend/shared/widgets/loading_view.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({
    super.key,
    ProjectsRepository? projectsRepository,
    AuthRepository? authRepository,
    SessionStorage? sessionStorage,
  })  : _projectsRepository = projectsRepository,
        _authRepository = authRepository,
        _sessionStorage = sessionStorage;

  final ProjectsRepository? _projectsRepository;
  final AuthRepository? _authRepository;
  final SessionStorage? _sessionStorage;

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  late final ProjectsRepository _projectsRepository =
      widget._projectsRepository ?? ProjectsRepository();
  late final AuthRepository _authRepository =
      widget._authRepository ?? AuthRepository();
  late final SessionStorage _sessionStorage =
      widget._sessionStorage ?? SessionStorage();

  List<ProjectModel> _projects = <ProjectModel>[];
  String _selectedFilter = 'ALL';
  String? _errorMessage;
  bool _isLoading = true;
  bool _hasLoaded = false;
  Future<void>? _activeLoad;
  late final ValueNotifier<int> _refreshNotifier;
  AppUser? _currentUser;

  @override
  void initState() {
    super.initState();
    _refreshNotifier =
        AppDataRefreshBus.instance.notifierFor(AppDataScope.projects);
    _refreshNotifier.addListener(_onRefreshRequested);
    _loadCurrentUser();
    _loadProjects();
  }

  @override
  void dispose() {
    _refreshNotifier.removeListener(_onRefreshRequested);
    super.dispose();
  }

  void _onRefreshRequested() {
    _loadProjects(force: true);
  }

  Future<void> _loadCurrentUser() async {
    final user = await _sessionStorage.getUser();
    if (!mounted) return;
    setState(() => _currentUser = user);
  }

  Future<void> _loadProjects({bool force = false}) {
    final activeLoad = _activeLoad;
    if (activeLoad != null) return activeLoad;
    if (!force && _hasLoaded) return Future<void>.value();

    _activeLoad = _performLoadProjects().whenComplete(() {
      _activeLoad = null;
    });
    return _activeLoad!;
  }

  Future<void> _performLoadProjects() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final projects = await _projectsRepository.getProjects();
      if (!mounted) return;
      setState(() {
        _projects = projects;
        _hasLoaded = true;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = _cleanError(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openAddProject() async {
    await context.push('/projects/add');
  }

  Future<void> _openProject(ProjectModel project) async {
    await context.push('/projects/${project.id}', extra: project);
  }

  Future<void> _logout() async {
    await _authRepository.logout();
    if (!mounted) return;
    context.go('/auth');
  }

  List<ProjectModel> get _filteredProjects {
    if (_selectedFilter == 'ALL') return _projects;
    return _projects
        .where((project) => project.status == _selectedFilter)
        .toList();
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  bool get _isUnauthorizedError {
    final message = _errorMessage?.toLowerCase() ?? '';
    return message.contains('unauthorized') || message.contains('401');
  }

  bool get _isNoMasjidError {
    final message = _errorMessage?.toLowerCase() ?? '';
    return message.contains('not assigned') || message.contains('masjid');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const LoadingView();

    if (_errorMessage != null) {
      if (_isUnauthorizedError) {
        return _ProjectsErrorView(
          message: 'Session expired. Please login again.',
          buttonLabel: 'Back to Login',
          onPressed: _logout,
        );
      }
      return _ProjectsErrorView(
        message: _isNoMasjidError
            ? 'You are not assigned to any masjid yet.'
            : 'Unable to load projects.',
        detail: _isNoMasjidError ? null : _errorMessage,
        onPressed: () => _loadProjects(force: true),
      );
    }

    final visibleProjects = _filteredProjects;
    final canManageProjects = PermissionHelper.canManageProjects(
      _currentUser?.roles ?? const <String>[],
    );

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => _loadProjects(force: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'Projects',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 6),
                    const Text('Track masjid construction and repair work'),
                    const SizedBox(height: 16),
                    if (canManageProjects) ...<Widget>[
                      AppButton(label: 'Add Project', onPressed: _openAddProject),
                      const SizedBox(height: 16),
                    ],
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: <Widget>[
                          _filterChip('ALL', 'All'),
                          const SizedBox(width: 8),
                          _filterChip('PLANNED', 'Planned'),
                          const SizedBox(width: 8),
                          _filterChip('ONGOING', 'Ongoing'),
                          const SizedBox(width: 8),
                          _filterChip('COMPLETED', 'Completed'),
                          const SizedBox(width: 8),
                          _filterChip('CANCELLED', 'Cancelled'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (visibleProjects.isEmpty)
                      const ProjectEmptyView(message: 'No projects added yet.')
                    else
                      ...visibleProjects.map(
                        (project) => ProjectCard(
                          project: project,
                          onTap: () => _openProject(project),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String value, String label) {
    return FilterChip(
      label: Text(label),
      selected: _selectedFilter == value,
      onSelected: (_) => setState(() => _selectedFilter = value),
    );
  }
}

class _ProjectsErrorView extends StatelessWidget {
  const _ProjectsErrorView({
    required this.message,
    required this.onPressed,
    this.detail,
    this.buttonLabel = 'Retry',
  });

  final String message;
  final String? detail;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Icon(
                  Icons.task_alt_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (detail != null) ...<Widget>[
                  const SizedBox(height: 8),
                  Text(detail!, textAlign: TextAlign.center),
                ],
                const SizedBox(height: 20),
                AppButton(label: buttonLabel, onPressed: onPressed),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
