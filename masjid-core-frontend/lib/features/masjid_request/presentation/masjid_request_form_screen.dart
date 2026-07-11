import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:platform_core_frontend/features/masjid_request/data/masjid_request_repository.dart';
import 'package:platform_core_frontend/features/masjid_request/data/models/committee_member_input.dart';
import 'package:platform_core_frontend/features/masjid_request/data/models/create_masjid_request.dart';
import 'package:platform_core_frontend/features/masjid_request/data/models/imam_input.dart';
import 'package:platform_core_frontend/shared/models/country_code.dart';
import 'package:platform_core_frontend/shared/utils/country_code_utils.dart';
import 'package:platform_core_frontend/shared/widgets/app_button.dart';
import 'package:platform_core_frontend/shared/widgets/app_phone_field.dart';
import 'package:platform_core_frontend/shared/widgets/app_text_field.dart';

class MasjidRequestFormScreen extends StatefulWidget {
  const MasjidRequestFormScreen({
    super.key,
    MasjidRequestRepository? repository,
  }) : _repository = repository;

  final MasjidRequestRepository? _repository;

  @override
  State<MasjidRequestFormScreen> createState() =>
      _MasjidRequestFormScreenState();
}

class _MasjidRequestFormScreenState extends State<MasjidRequestFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _requesterNameController = TextEditingController();
  final TextEditingController _requesterPhoneController = TextEditingController();
  final TextEditingController _requesterEmailController = TextEditingController();
  final TextEditingController _masjidNameController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactNoController = TextEditingController();
  final TextEditingController _welcomeMsgController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imamNameController = TextEditingController();
  final TextEditingController _imamPhoneController = TextEditingController();
  final TextEditingController _imamEmailController = TextEditingController();
  final TextEditingController _imamAddressController = TextEditingController();
  final List<_CommitteeMemberControllers> _committeeMembers = [];

  late final MasjidRequestRepository _repository =
      widget._repository ?? MasjidRequestRepository();

  CountryCode _requesterCountry = getDefaultCountryCode();
  CountryCode _contactCountry = getDefaultCountryCode();
  CountryCode _imamCountry = getDefaultCountryCode();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _requesterNameController.dispose();
    _requesterPhoneController.dispose();
    _requesterEmailController.dispose();
    _masjidNameController.dispose();
    _villageController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _addressController.dispose();
    _contactNoController.dispose();
    _welcomeMsgController.dispose();
    _descriptionController.dispose();
    _imamNameController.dispose();
    _imamPhoneController.dispose();
    _imamEmailController.dispose();
    _imamAddressController.dispose();
    for (final member in _committeeMembers) {
      member.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await _repository.submitMasjidRequest(_buildRequest());

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Request Submitted'),
          content: const Text(
            'Your masjid request has been submitted successfully. Admin will review and approve it.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.go('/auth');
              },
              child: const Text('Back to Login'),
            ),
          ],
        ),
      );
    } catch (error) {
      if (mounted) _showError(_cleanError(error));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  CreateMasjidRequest _buildRequest() {
    return CreateMasjidRequest(
      requesterName: _requesterNameController.text,
      requesterPhone: normalizePhone(countryCode: _requesterCountry, nationalNumber: _requesterPhoneController.text),
      requesterEmail: _requesterEmailController.text,
      masjidName: _masjidNameController.text,
      village: _villageController.text,
      city: _cityController.text,
      district: _districtController.text,
      state: _stateController.text,
      address: _addressController.text,
      contactNo: _contactNoController.text.trim().isEmpty ? '' : normalizePhone(countryCode: _contactCountry, nationalNumber: _contactNoController.text),
      description: _descriptionController.text,
      welcomeMsg: _welcomeMsgController.text,
      imam: ImamInput(
        name: _imamNameController.text,
        email: _imamEmailController.text,
        phone: _imamPhoneController.text.trim().isEmpty ? '' : normalizePhone(countryCode: _imamCountry, nationalNumber: _imamPhoneController.text),
        address: _imamAddressController.text,
      ),
      committeeMembers: _committeeMembers
          .map(
            (member) => CommitteeMemberInput(
              name: member.nameController.text,
              phone: member.phoneController.text.trim().isEmpty ? '' : normalizePhone(countryCode: member.countryCode, nationalNumber: member.phoneController.text),
            ),
          )
          .toList(),
    );
  }

  void _addCommitteeMember() {
    setState(() => _committeeMembers.add(_CommitteeMemberControllers()));
  }

  void _removeCommitteeMember(int index) {
    final member = _committeeMembers.removeAt(index);
    member.dispose();
    setState(() {});
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  String? _requiredValidator(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required.';
    }
    return null;
  }

  String? _phoneValidator(String? value, String label, {bool required = false}) {
    final trimmedValue = value?.trim() ?? '';
    if (trimmedValue.isEmpty) {
      return required ? '$label is required.' : null;
    }
    if (trimmedValue.length < 10) {
      return '$label must be at least 10 digits.';
    }
    return null;
  }

  String? _emailValidator(String? value, String label) {
    final trimmedValue = value?.trim() ?? '';
    if (trimmedValue.isEmpty) return null;
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(trimmedValue)) {
      return 'Enter a valid $label.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'Register Your Masjid',
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Submit your masjid details. Admin will review and approve your request.',
                      style: textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _FormSection(
                      title: 'Requester Details',
                      children: <Widget>[
                        AppTextField(
                          controller: _requesterNameController,
                          label: 'Your Name *',
                          textInputAction: TextInputAction.next,
                          validator: (value) =>
                              _requiredValidator(value, 'Your name'),
                        ),
                        AppPhoneField(
                          phoneController: _requesterPhoneController,
                          initialCountry: _requesterCountry,
                          onCountryChanged: (country) => _requesterCountry = country,
                          label: 'Your Phone *',
                          isRequired: true,
                          textInputAction: TextInputAction.next,
                        ),
                        AppTextField(
                          controller: _requesterEmailController,
                          label: 'Your Email',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (value) =>
                              _emailValidator(value, 'email address'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _FormSection(
                      title: 'Masjid Details',
                      children: <Widget>[
                        AppTextField(
                          controller: _masjidNameController,
                          label: 'Masjid Name *',
                          textInputAction: TextInputAction.next,
                          validator: (value) =>
                              _requiredValidator(value, 'Masjid name'),
                        ),
                        AppTextField(
                          controller: _villageController,
                          label: 'Village',
                          textInputAction: TextInputAction.next,
                        ),
                        AppTextField(
                          controller: _cityController,
                          label: 'City',
                          textInputAction: TextInputAction.next,
                        ),
                        AppTextField(
                          controller: _districtController,
                          label: 'District',
                          textInputAction: TextInputAction.next,
                        ),
                        AppTextField(
                          controller: _stateController,
                          label: 'State',
                          textInputAction: TextInputAction.next,
                        ),
                        AppTextField(
                          controller: _addressController,
                          label: 'Address',
                          maxLines: 2,
                          textInputAction: TextInputAction.newline,
                        ),
                        AppPhoneField(
                          phoneController: _contactNoController,
                          initialCountry: _contactCountry,
                          onCountryChanged: (country) => _contactCountry = country,
                          label: 'Contact Number',
                          isRequired: false,
                          textInputAction: TextInputAction.next,
                        ),
                        AppTextField(
                          controller: _welcomeMsgController,
                          label: 'Welcome Message',
                          maxLines: 2,
                          textInputAction: TextInputAction.newline,
                        ),
                        AppTextField(
                          controller: _descriptionController,
                          label: 'Description',
                          maxLines: 3,
                          textInputAction: TextInputAction.newline,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _FormSection(
                      title: 'Imam Details',
                      children: <Widget>[
                        AppTextField(
                          controller: _imamNameController,
                          label: 'Imam Name',
                          textInputAction: TextInputAction.next,
                        ),
                        AppPhoneField(
                          phoneController: _imamPhoneController,
                          initialCountry: _imamCountry,
                          onCountryChanged: (country) => _imamCountry = country,
                          label: 'Imam Phone',
                          isRequired: false,
                          textInputAction: TextInputAction.next,
                        ),
                        AppTextField(
                          controller: _imamEmailController,
                          label: 'Imam Email',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (value) =>
                              _emailValidator(value, 'imam email'),
                        ),
                        AppTextField(
                          controller: _imamAddressController,
                          label: 'Imam Address',
                          maxLines: 2,
                          textInputAction: TextInputAction.newline,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _FormSection(
                      title: 'Committee Members',
                      children: <Widget>[
                        if (_committeeMembers.isEmpty)
                          Text(
                            'No committee members added yet.',
                            style: textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        for (var index = 0;
                            index < _committeeMembers.length;
                            index++)
                          _CommitteeMemberFields(
                            member: _committeeMembers[index],
                            index: index,
                            onRemove: () => _removeCommitteeMember(index),
                          ),
                        AppButton(
                          label: '+ Add Committee Member',
                          isOutlined: true,
                          onPressed: _addCommitteeMember,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: 'Submit Request',
                      isLoading: _isSubmitting,
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

class _FormSection extends StatelessWidget {
  const _FormSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...children.expand(
              (child) => <Widget>[child, const SizedBox(height: 14)],
            ),
          ],
        ),
      ),
    );
  }
}

class _CommitteeMemberFields extends StatelessWidget {
  const _CommitteeMemberFields({
    required this.member,
    required this.index,
    required this.onRemove,
  });

  final _CommitteeMemberControllers member;
  final int index;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Member ${index + 1}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            TextButton.icon(
              onPressed: onRemove,
              icon: const Icon(Icons.remove_circle_outline),
              label: const Text('Remove'),
            ),
          ],
        ),
        AppTextField(
          controller: member.nameController,
          label: 'Member Name',
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 14),
        AppPhoneField(
          phoneController: member.phoneController,
          initialCountry: member.countryCode,
          onCountryChanged: (country) => member.countryCode = country,
          label: 'Member Phone',
          textInputAction: TextInputAction.next,
        ),
        const Divider(height: 28),
      ],
    );
  }
}

class _CommitteeMemberControllers {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  CountryCode countryCode = getDefaultCountryCode();

  void dispose() {
    nameController.dispose();
    phoneController.dispose();
  }
}
