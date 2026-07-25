import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:platform_core_frontend/core/errors/error_message_helper.dart';
import 'package:platform_core_frontend/core/permissions/permission_helper.dart';
import 'package:platform_core_frontend/core/storage/session_storage.dart';
import 'package:platform_core_frontend/core/storage/token_storage.dart';
import 'package:platform_core_frontend/features/auth/data/models/app_user.dart';
import 'package:platform_core_frontend/features/community/data/community_repository.dart';
import 'package:platform_core_frontend/features/community/data/models/create_community_user_request.dart';
import 'package:platform_core_frontend/features/community/data/models/community_user_model.dart';
import 'package:platform_core_frontend/features/community/presentation/widgets/add_user_role_dropdown.dart';
import 'package:platform_core_frontend/shared/models/country_code.dart';
import 'package:platform_core_frontend/shared/utils/country_code_utils.dart';
import 'package:platform_core_frontend/shared/widgets/app_button.dart';
import 'package:platform_core_frontend/shared/widgets/app_phone_field.dart';
import 'package:platform_core_frontend/shared/widgets/loading_view.dart';
import 'package:platform_core_frontend/shared/widgets/not_allowed_view.dart';

class AddCommunityUserScreen extends StatefulWidget {
  const AddCommunityUserScreen({
    super.key,
    CommunityRepository? communityRepository,
    SessionStorage? sessionStorage,
    TokenStorage? tokenStorage,
  })  : _communityRepository = communityRepository,
        _sessionStorage = sessionStorage,
        _tokenStorage = tokenStorage;

  final CommunityRepository? _communityRepository;
  final SessionStorage? _sessionStorage;
  final TokenStorage? _tokenStorage;

  @override
  State<AddCommunityUserScreen> createState() => _AddCommunityUserScreenState();
}

class _AddCommunityUserScreenState extends State<AddCommunityUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _familyMemberCountController = TextEditingController();
  final _masjidIdController = TextEditingController();

  late final CommunityRepository _communityRepository =
      widget._communityRepository ?? CommunityRepository();
  late final SessionStorage _sessionStorage =
      widget._sessionStorage ?? SessionStorage();
  late final TokenStorage _tokenStorage = widget._tokenStorage ?? TokenStorage();

  AppUser? _currentUser;
  List<String> _allowedRoles = const <String>[];
  String? _selectedRole;
  String? _selectedGender;
  bool _isFamilyHead = false;
  bool _isLoadingUser = true;
  CountryCode _selectedCountry = getDefaultCountryCode();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await _sessionStorage.getUser();
    if (!mounted) return;
    final allowedRoles = user == null
        ? const <String>[]
        : PermissionHelper.allowedCommunityRolesToCreate(user.roles);
    setState(() {
      _currentUser = user;
      _allowedRoles = allowedRoles;
      _selectedRole = allowedRoles.isEmpty ? null : allowedRoles.first;
      _isLoadingUser = false;
    });
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

    setState(() => _isSaving = true);
    try {
      final createdUser = await _communityRepository.createMasjidUser(
        CreateCommunityUserRequest(
          fullName: _fullNameController.text,
          phone: normalizePhone(countryCode: _selectedCountry, nationalNumber: _phoneController.text),
          email: _emailController.text,
          role: _selectedRole!,
          fatherName: _fatherNameController.text,
          age: int.parse(_ageController.text.trim()),
          gender: _selectedGender!,
          isFamilyHead: _selectedRole == PermissionHelper.member ? _isFamilyHead : null,
          familyMemberCount: _familyMemberCountController.text.trim().isEmpty ? null : int.parse(_familyMemberCountController.text.trim()),
          masjidId: _masjidIdController.text,
        ),
      );

      if (!mounted) return;
      await _showSuccess(createdUser);
      if (mounted) context.pop(true);
    } catch (error) {
      if (!mounted) return;
      await _handleError(error);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _showSuccess(CommunityUserModel createdUser) async {
    final message = _successMessage(createdUser);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Added'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _successMessage(CommunityUserModel user) {
    if (user.message != null && user.message!.isNotEmpty) return user.message!;
    if (user.temporaryPassword != null && user.temporaryPassword!.isNotEmpty) {
      return 'User added successfully. Temporary password is ${user.temporaryPassword}.';
    }
    if (_selectedRole == PermissionHelper.member) {
      return 'Member added successfully. This user can login using phone OTP.';
    }
    return 'User added successfully.';
  }

  Future<void> _handleError(Object error) async {
    final message = getReadableErrorMessage(error, fallbackMessage: 'Unable to add user.');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );

    final lower = error.toString().toLowerCase();
    if (lower.contains('unauthorized') || lower.contains('401')) {
      await _tokenStorage.clearTokens();
      await _sessionStorage.clearUser();
      if (mounted) context.go('/auth');
    }
  }

  bool get _shouldShowMasjidIdField {
    final user = _currentUser;
    if (user == null) return false;
    return PermissionHelper.hasRole(
          user,
          PermissionHelper.superAdmin,
        ) &&
        (user.masjidId == null || user.masjidId!.trim().isEmpty);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUser) return const LoadingView();

    return Scaffold(
      appBar: AppBar(title: const Text('Add User')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: _allowedRoles.isEmpty ? const NotAllowedView() : _form(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _form() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Add User',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 6),
          const Text('Create a user for your masjid community.'),
          const SizedBox(height: 24),
          TextFormField(
            controller: _fullNameController,
            decoration: const InputDecoration(
              labelText: 'Full Name *',
              border: OutlineInputBorder(),
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
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email optional',
              border: OutlineInputBorder(),
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
            decoration: const InputDecoration(labelText: 'Father Name *', border: OutlineInputBorder()),
            textInputAction: TextInputAction.next,
            validator: (value) => (value == null || value.trim().isEmpty) ? 'Please enter father name.' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _ageController,
            decoration: const InputDecoration(labelText: 'Age *', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              final age = int.tryParse(value?.trim() ?? '');
              if (age == null) return 'Please enter age.';
              if (age < 1 || age > 120) return 'Age must be between 1 and 120.';
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedGender,
            decoration: const InputDecoration(labelText: 'Gender *', border: OutlineInputBorder()),
            items: const <DropdownMenuItem<String>>[
              DropdownMenuItem(value: 'MALE', child: Text('Male')),
              DropdownMenuItem(value: 'FEMALE', child: Text('Female')),
              DropdownMenuItem(value: 'OTHER', child: Text('Other')),
            ],
            onChanged: (value) => setState(() => _selectedGender = value),
            validator: (value) => value == null ? 'Please select gender.' : null,
          ),
          const SizedBox(height: 16),
          AddUserRoleDropdown(
            allowedRoles: _allowedRoles,
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
                decoration: const InputDecoration(labelText: 'Family Member Count', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return null;
                  final count = int.tryParse(text);
                  if (count == null || count < 0) return 'Family member count cannot be negative.';
                  return null;
                },
              ),
            ],
          ],
          if (_shouldShowMasjidIdField) ...<Widget>[
            const SizedBox(height: 16),
            TextFormField(
              controller: _masjidIdController,
              decoration: const InputDecoration(
                labelText: 'Masjid ID',
                helperText:
                    'Required only for super admin when not assigned to a masjid.',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.done,
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: AppButton(
              label: 'Save User',
              isLoading: _isSaving,
              onPressed: _submit,
            ),
          ),
        ],
      ),
    );
  }
}
