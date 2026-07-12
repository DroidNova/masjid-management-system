import 'package:flutter/material.dart';
import 'package:platform_core_frontend/shared/utils/date_format_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:platform_core_frontend/core/permissions/permission_helper.dart';
import 'package:platform_core_frontend/core/storage/session_storage.dart';
import 'package:platform_core_frontend/features/finance/presentation/widgets/finance_labels.dart';
import 'package:platform_core_frontend/features/projects/data/models/project_model.dart';
import 'package:platform_core_frontend/features/projects/data/projects_repository.dart';
import 'package:platform_core_frontend/features/projects/presentation/widgets/project_progress_bar.dart';
import 'package:platform_core_frontend/features/projects/presentation/widgets/project_status_chip.dart';
import 'package:platform_core_frontend/shared/widgets/app_button.dart';
import 'package:platform_core_frontend/shared/widgets/loading_view.dart';

class ProjectDetailScreen extends StatefulWidget {
  const ProjectDetailScreen({
    super.key,
    required this.projectId,
    this.initialProject,
    ProjectsRepository? projectsRepository,
    SessionStorage? sessionStorage,
  })  : _projectsRepository = projectsRepository,
        _sessionStorage = sessionStorage;

  final String projectId;
  final ProjectModel? initialProject;
  final ProjectsRepository? _projectsRepository;
  final SessionStorage? _sessionStorage;

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  late final ProjectsRepository _projectsRepository =
      widget._projectsRepository ?? ProjectsRepository();
  late final SessionStorage _sessionStorage =
      widget._sessionStorage ?? SessionStorage();

  ProjectModel? _project;
  String? _errorMessage;
  bool _isLoading = true;
  bool _isDeleting = false;
  bool _canManageProjects = false;

  @override
  void initState() {
    super.initState();
    _loadPermissions();
    _loadProject();
  }

  Future<void> _loadPermissions() async {
    final user = await _sessionStorage.getUser();
    if (!mounted) return;
    setState(() {
      _canManageProjects = PermissionHelper.canManageProjects(
        user?.roles ?? const <String>[],
      );
    });
  }

  Future<void> _loadProject() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final project = widget.initialProject ??
          await _projectsRepository.getProjectById(widget.projectId);
      if (!mounted) return;
      setState(() => _project = project);
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = _cleanError(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _editProject() async {
    final project = _project;
    if (project == null) return;
    await context.push('/projects/${project.id}/edit', extra: project);
  }

  Future<void> _deleteProject() async {
    final project = _project;
    if (project == null) return;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: const Text('Are you sure you want to delete this project?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete != true) return;

    setState(() => _isDeleting = true);
    try {
      await _projectsRepository.deleteProject(project.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Project deleted successfully.')),
      );
      context.pop(true);
    } catch (error) {
      if (mounted) _showError(_cleanError(error));
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Project Details')),
        body: const LoadingView(),
      );
    }

    if (_errorMessage != null || _project == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Project Details')),
        body: Center(
          child: AppButton(label: 'Retry', onPressed: _loadProject),
        ),
      );
    }

    final project = _project!;

    return Scaffold(
      appBar: AppBar(title: const Text('Project Details')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              project.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          ProjectStatusChip(status: project.status),
                        ],
                      ),
                      if (project.description != null) ...<Widget>[
                        const SizedBox(height: 12),
                        Text(project.description!),
                      ],
                      const SizedBox(height: 16),
                      Text('Target: ${formatRupees(project.targetAmount)}'),
                      Text('Collected: ${formatRupees(project.collectedAmount)}'),
                      Text('Spent: ${formatRupees(project.spentAmount)}'),
                      const SizedBox(height: 16),
                      ProjectProgressBar(
                        progressPercentage: project.progressPercentage,
                      ),
                      const Divider(height: 28),
                      Text('Start Date: ${formatReadableDate(parseApiDate(project.startDate))}'),
                      Text('End Date: ${formatReadableDate(parseApiDate(project.endDate))}'),
                      Text('Created: ${project.createdAt ?? '-'}'),
                      if (_canManageProjects) ...<Widget>[
                        const SizedBox(height: 20),
                        AppButton(label: 'Edit Project', onPressed: _editProject),
                        const SizedBox(height: 12),
                        AppButton(
                          label: 'Delete / Cancel Project',
                          isOutlined: true,
                          isLoading: _isDeleting,
                          onPressed: _deleteProject,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
