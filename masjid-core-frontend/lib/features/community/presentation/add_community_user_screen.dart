import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/errors/user_message.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/community/application/add_community_user_controller.dart';
import 'package:masjid_core_frontend/features/community/data/models/community_user_model.dart';
import 'package:masjid_core_frontend/features/community/presentation/widgets/add_user_role_dropdown.dart';
import 'package:masjid_core_frontend/features/community/presentation/widgets/gender_dropdown.dart';
import 'package:masjid_core_frontend/shared/models/country_code.dart';
import 'package:masjid_core_frontend/shared/utils/country_code_utils.dart';
import 'package:masjid_core_frontend/shared/widgets/app_button.dart';
import 'package:masjid_core_frontend/shared/widgets/app_phone_field.dart';
import 'package:masjid_core_frontend/shared/widgets/not_allowed_view.dart';

class AddCommunityUserScreen extends ConsumerStatefulWidget {
  const AddCommunityUserScreen({super.key});

  @override
  ConsumerState<AddCommunityUserScreen> createState() =>
      _AddCommunityUserScreenState();
}

class _AddCommunityUserScreenState
    extends ConsumerState<AddCommunityUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _familyMemberCountController = TextEditingController();
  final _masjidIdController = TextEditingController();

  String? _selectedRole;
  String? _selectedGender;
  bool _isFamilyHead = false;
  CountryCode _selectedCountry = getDefaultCountryCode();

  @override
  void initState() {
    super.initState();
    final allowedRoles = PermissionHelper.allowedCommunityRolesToCreate(
      ref.read(currentPermissionsProvider),
    );
    _selectedRole = allowedRoles.isEmpty ? null : allowedRoles.first;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _fatherNameController.dispose();
    _ageController.dispose();
    _familyMemberCountController.dispose();
    _masjidIdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final request = buildCreateCommunityUserRequest(
      fullName: _fullNameController.text,
      phone: normalizePhone(
        countryCode: _selectedCountry,
        nationalNumber: _phoneController.text,
      ),
      email: _emailController.text,
      role: _selectedRole!,
      fatherName: _fatherNameController.text,
      age: _ageController.text,
      gender: _selectedGender!,
      isFamilyHead: _isFamilyHead,
      familyMemberCount: _familyMemberCountController.text,
      masjidId: _masjidIdController.text,
    );
    final createdUser = await ref
        .read(addCommunityUserControllerProvider.notifier)
        .submit(request);
    if (!mounted) return;

    if (createdUser == null) {
      final error = ref.read(addCommunityUserControllerProvider).error;
      // Shown in a banner above the save button instead.
      if (_isAlreadyLinkedError(error)) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error == null ? 'Unable to add user.' : userMessage(error),
          ),
        ),
      );
      return;
    }

    await _showSuccess(createdUser);
    if (mounted) context.pop(true);
  }

  Future<void> _showSuccess(CommunityUserModel createdUser) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Added'),
        content: Text(addUserSuccessMessage(createdUser, _selectedRole)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final permissions = ref.watch(currentPermissionsProvider);
    final allowedRoles = PermissionHelper.allowedCommunityRolesToCreate(
      permissions,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Add User')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: allowedRoles.isEmpty
                  ? const NotAllowedView()
                  : _form(allowedRoles),
            ),
          ),
        ),
      ),
    );
  }

  Widget _form(List<String> allowedRoles) {
    final user = ref.watch(currentUserProvider);
    final saveState = ref.watch(addCommunityUserControllerProvider);
    final error = saveState.error;
    final showMasjidIdField =
        PermissionHelper.has(user, AppPermissions.platformRolesAssign) &&
        (user?.masjidId == null || user!.masjidId!.trim().isEmpty);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Add User',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text('Create a user for your masjid community.'),
          const SizedBox(height: 24),
          TextFormField(
            controller: _fullNameController,
            decoration: InputDecoration(
              labelText: 'Full Name *',
              border: const OutlineInputBorder(),
              errorText: fieldError(error, 'fullName'),
            ),
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter full name.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AppPhoneField(
            phoneController: _phoneController,
            initialCountry: _selectedCountry,
            onCountryChanged: (country) => _selectedCountry = country,
            label: 'Phone *',
            isRequired: true,
            textInputAction: TextInputAction.next,
          ),
          if (fieldError(error, 'phone') case final phoneError?)
            _FieldErrorText(phoneError),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email optional',
              border: const OutlineInputBorder(),
              errorText: fieldError(error, 'email'),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (value) {
              final email = value?.trim() ?? '';
              if (email.isNotEmpty && !email.contains('@')) {
                return 'Please enter a valid email.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _fatherNameController,
            decoration: InputDecoration(
              labelText: 'Father Name *',
              border: const OutlineInputBorder(),
              errorText: fieldError(error, 'fatherName'),
            ),
            textInputAction: TextInputAction.next,
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Please enter father name.'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _ageController,
            decoration: InputDecoration(
              labelText: 'Age *',
              border: const OutlineInputBorder(),
              errorText: fieldError(error, 'age'),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            validator: (value) {
              final age = int.tryParse(value?.trim() ?? '');
              if (age == null) return 'Please enter age.';
              if (age < 1 || age > 120) return 'Age must be between 1 and 120.';
              return null;
            },
          ),
          const SizedBox(height: 16),
          GenderDropdown(
            value: _selectedGender,
            requiredMessage: 'Please select gender.',
            onChanged: (value) => setState(() => _selectedGender = value),
          ),
          const SizedBox(height: 16),
          AddUserRoleDropdown(
            allowedRoles: allowedRoles,
            value: _selectedRole,
            onChanged: (role) => setState(() => _selectedRole = role),
          ),
          if (_selectedRole == PermissionHelper.member) ...<Widget>[
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Is Family Head *'),
              value: _isFamilyHead,
              onChanged: (value) => setState(() => _isFamilyHead = value),
            ),
            if (_isFamilyHead) ...<Widget>[
              const SizedBox(height: 16),
              TextFormField(
                controller: _familyMemberCountController,
                decoration: InputDecoration(
                  labelText: 'Family Member Count',
                  border: const OutlineInputBorder(),
                  errorText: fieldError(error, 'familyMemberCount'),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return null;
                  final count = int.tryParse(text);
                  if (count == null || count < 0) {
                    return 'Family member count cannot be negative.';
                  }
                  return null;
                },
              ),
            ],
          ],
          if (showMasjidIdField) ...<Widget>[
            const SizedBox(height: 16),
            TextFormField(
              controller: _masjidIdController,
              decoration: InputDecoration(
                labelText: 'Masjid ID',
                helperText:
                    'Required only for super admin when not assigned to a masjid.',
                border: const OutlineInputBorder(),
                errorText: fieldError(error, 'masjidId'),
              ),
              textInputAction: TextInputAction.done,
            ),
          ],
          if (_isAlreadyLinkedError(error)) ...<Widget>[
            const SizedBox(height: 16),
            _LinkedElsewhereBanner(message: userMessage(error!)),
          ],
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: AppButton(
              label: 'Save User',
              isLoading: saveState.isLoading,
              onPressed: _submit,
            ),
          ),
        ],
      ),
    );
  }
}

/// The phone already belongs to a masjid: the person must leave it first.
bool _isAlreadyLinkedError(Object? error) =>
    error is ApiException &&
    (error.code == ApiErrorCodes.userInAnotherMasjid ||
        error.code == ApiErrorCodes.masjidUserAlreadyLinked);

class _LinkedElsewhereBanner extends StatelessWidget {
  const _LinkedElsewhereBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.error_outline, color: colorScheme.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: colorScheme.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldErrorText extends StatelessWidget {
  const _FieldErrorText(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 6),
      child: Text(
        message,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.error,
        ),
      ),
    );
  }
}
