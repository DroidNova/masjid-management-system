import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/features/masjid_request/application/masjid_request_form_controller.dart';
import 'package:masjid_core_frontend/features/masjid_request/application/masjid_request_validators.dart';
import 'package:masjid_core_frontend/features/masjid_request/presentation/masjid_request_form_fields.dart';
import 'package:masjid_core_frontend/features/masjid_request/presentation/widgets/committee_members_section.dart';
import 'package:masjid_core_frontend/features/masjid_request/presentation/widgets/imam_details_section.dart';
import 'package:masjid_core_frontend/features/masjid_request/presentation/widgets/masjid_details_section.dart';
import 'package:masjid_core_frontend/features/masjid_request/presentation/widgets/requester_details_section.dart';
import 'package:masjid_core_frontend/shared/widgets/app_button.dart';

/// Public masjid registration form (no login). Field state lives in
/// [MasjidRequestFormFields]; checks across fields and sending live in
/// [MasjidRequestFormController].
class MasjidRequestFormScreen extends ConsumerStatefulWidget {
  const MasjidRequestFormScreen({super.key});

  @override
  ConsumerState<MasjidRequestFormScreen> createState() =>
      _MasjidRequestFormScreenState();
}

class _MasjidRequestFormScreenState
    extends ConsumerState<MasjidRequestFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final MasjidRequestFormFields _fields = MasjidRequestFormFields();
  bool _hasSubmitted = false;

  @override
  void dispose() {
    _fields.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  Future<void> _submit() async {
    setState(() => _hasSubmitted = true);
    if (!_formKey.currentState!.validate()) return;

    final submitted = await ref
        .read(masjidRequestFormControllerProvider.notifier)
        .submit(_fields.toDraft());
    if (!mounted) return;
    if (submitted) {
      context.go('/masjid-request/submitted');
      return;
    }
    final error = ref.read(masjidRequestFormControllerProvider).error;
    if (error != null) _showError(masjidRequestErrorMessage(error));
  }

  void _addCommitteeMember() {
    setState(() => _fields.committeeMembers.add(CommitteeMemberFields()));
  }

  void _removeCommitteeMember(int index) {
    if (_fields.committeeMembers.length == 1) {
      _showError(MasjidRequestValidators.committeeRequired);
      return;
    }
    final member = _fields.committeeMembers.removeAt(index);
    setState(() {});
    // Dispose after the removed fields have left the tree.
    WidgetsBinding.instance.addPostFrameCallback((_) => member.dispose());
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSubmitting = ref
        .watch(masjidRequestFormControllerProvider)
        .isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Register Your Masjid')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Form(
                key: _formKey,
                autovalidateMode: _hasSubmitted
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'Register Your Masjid',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Submit your masjid details. Admin will review and approve your request.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    MasjidDetailsSection(fields: _fields, onChanged: _refresh),
                    const SizedBox(height: 16),
                    RequesterDetailsSection(fields: _fields),
                    const SizedBox(height: 16),
                    ImamDetailsSection(fields: _fields, onChanged: _refresh),
                    const SizedBox(height: 16),
                    CommitteeMembersSection(
                      members: _fields.committeeMembers,
                      onAdd: _addCommitteeMember,
                      onRemove: _removeCommitteeMember,
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: 'Submit Request',
                      isLoading: isSubmitting,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      label: 'Back',
                      isOutlined: true,
                      onPressed: () => context.go('/auth'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
