import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:masjid_core_frontend/core/errors/error_text.dart';
import 'package:masjid_core_frontend/core/format/formatters.dart';
import 'package:masjid_core_frontend/features/projects/application/project_editor_controller.dart';
import 'package:masjid_core_frontend/features/projects/data/models/create_project_request.dart';
import 'package:masjid_core_frontend/features/projects/data/models/project_model.dart';
import 'package:masjid_core_frontend/features/projects/data/models/update_project_request.dart';
import 'package:masjid_core_frontend/features/projects/presentation/widgets/project_card.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// Adds a project ([initial] null) or edits one, a question per page: the
/// name, how much money it needs (optional), then dates and status.
class ProjectFormScreen extends ConsumerStatefulWidget {
  const ProjectFormScreen({super.key, this.initial});

  final ProjectModel? initial;

  @override
  ConsumerState<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends ConsumerState<ProjectFormScreen> {
  final GlobalKey<FormState> _nameForm = GlobalKey<FormState>();
  late final TextEditingController _title = TextEditingController(
    text: widget.initial?.title ?? '',
  );
  late final TextEditingController _description = TextEditingController(
    text: widget.initial?.description ?? '',
  );
  late String _target = AmountPad.textOf(widget.initial?.targetAmount ?? 0);
  late String _status = widget.initial?.status ?? 'ONGOING';
  late DateTime? _start = widget.initial?.startDate;
  late DateTime? _end = widget.initial?.endDate;
  String? _error;

  bool get _editing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    _title.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  static String? _day(DateTime? date) =>
      date == null ? null : DateFormat('yyyy-MM-dd', 'en').format(date);

  Future<void> _pick({required bool start}) async {
    final current = start ? _start : _end;
    final picked = await pickDate(
      context,
      initial: current ?? DateTime.now(),
      first: DateTime(2000),
      last: DateTime(2100),
    );
    if (picked != null) {
      setState(() => start ? _start = picked : _end = picked);
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _error = null);
    final title = _title.text.trim();
    final description = _description.text.trim();
    final target = (AmountPad.parse(_target) ?? 0).toDouble();
    final editor = ref.read(projectEditorControllerProvider.notifier);
    final saved = _editing
        ? await editor.updateProject(
            widget.initial!.id,
            UpdateProjectRequest(
              title: title,
              description: description,
              targetAmount: target,
              status: _status,
              startDate: _day(_start),
              endDate: _day(_end),
            ),
          )
        : await editor.createProject(
            CreateProjectRequest(
              title: title,
              description: description.isEmpty ? null : description,
              targetAmount: target,
              status: _status,
              startDate: _day(_start),
              endDate: _day(_end),
            ),
          );
    if (!mounted) return;
    if (!saved) {
      final error = ref.read(projectEditorControllerProvider).error;
      setState(
        () => _error = errorText(l10n, error ?? l10n.somethingWentWrong),
      );
      return;
    }
    await showSuccess(
      context,
      title: _editing ? l10n.saved : l10n.projectAdded,
      detail: title,
      icon: AppIcons.projects,
      tone: AppTones.projects,
    );
    if (mounted) context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final error = _error;
    final start = _start;
    final end = _end;
    // Keep the editor alive so a failed save's error can be read.
    ref.listen(projectEditorControllerProvider, (_, _) {});

    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? l10n.editProject : l10n.addProject),
      ),
      body: SafeArea(
        top: false,
        child: StepFlow(
          tone: AppTones.projects,
          finishLabel: l10n.save,
          onFinish: _save,
          steps: <FlowStep>[
            FlowStep(
              title: l10n.projectName,
              icon: AppIcons.projects,
              canContinue: _title.text.trim().isNotEmpty,
              validate: () => _nameForm.currentState?.validate() ?? true,
              builder: (_) => Form(
                key: _nameForm,
                child: Column(
                  children: <Widget>[
                    AppFormField(
                      controller: _title,
                      label: l10n.projectName,
                      icon: AppIcons.projects,
                      textCapitalization: TextCapitalization.sentences,
                      validator: (value) => (value ?? '').trim().isEmpty
                          ? l10n.fieldRequired
                          : null,
                    ),
                    AppFormField(
                      controller: _description,
                      label: l10n.aboutProjectOptional,
                      icon: AppIcons.info,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ],
                ),
              ),
            ),
            FlowStep(
              title: l10n.moneyNeeded,
              icon: AppIcons.salary,
              builder: (_) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    l10n.moneyNeededHelp,
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpace.l),
                  AmountPad(
                    value: _target,
                    quickAmounts: const <int>[10000, 50000, 100000, 500000],
                    onChanged: (value) => setState(() => _target = value),
                  ),
                ],
              ),
            ),
            FlowStep(
              title: l10n.datesAndStatus,
              icon: AppIcons.calendar,
              builder: (_) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(l10n.status, style: textTheme.titleSmall),
                  const SizedBox(height: AppSpace.s),
                  Wrap(
                    spacing: AppSpace.s,
                    runSpacing: AppSpace.s,
                    children: projectStatuses
                        .where(
                          (status) =>
                              status != 'CANCELLED' || _status == 'CANCELLED',
                        )
                        .map((status) {
                          final (_, icon, label) = projectStatusLook(
                            l10n,
                            status,
                          );
                          return ChoiceChip(
                            avatar: Icon(icon, size: 20),
                            label: Text(label),
                            selected: _status == status,
                            onSelected: (_) => setState(() => _status = status),
                          );
                        })
                        .toList(),
                  ),
                  const SizedBox(height: AppSpace.xl),
                  OutlinedButton.icon(
                    onPressed: () => _pick(start: true),
                    icon: const Icon(AppIcons.calendar),
                    label: Text(
                      start == null
                          ? l10n.startDateOptional
                          : '${l10n.startDate}: ${AppFormat.date(start)}',
                    ),
                  ),
                  const SizedBox(height: AppSpace.m),
                  OutlinedButton.icon(
                    onPressed: () => _pick(start: false),
                    icon: const Icon(Icons.flag_rounded),
                    label: Text(
                      end == null
                          ? l10n.endDateOptional
                          : '${l10n.endDate}: ${AppFormat.date(end)}',
                    ),
                  ),
                  if (error != null) ...<Widget>[
                    const SizedBox(height: AppSpace.l),
                    MessageBanner(text: error),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
