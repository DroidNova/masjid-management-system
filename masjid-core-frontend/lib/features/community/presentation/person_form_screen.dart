import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/errors/error_text.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/community/application/add_community_user_controller.dart';
import 'package:masjid_core_frontend/features/community/application/community_controller.dart';
import 'package:masjid_core_frontend/features/community/data/models/community_user_model.dart';
import 'package:masjid_core_frontend/features/community/data/models/update_community_user_request.dart';
import 'package:masjid_core_frontend/features/masjid_request/application/masjid_request_validators.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/models/country_code.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';
import 'package:masjid_core_frontend/shared/utils/country_code_utils.dart';

/// Adds a person to the masjid ([initial] null) or edits one, a few
/// questions per page: who (phone and name), details (father, age,
/// gender, email), then role and family.
class PersonFormScreen extends ConsumerStatefulWidget {
  const PersonFormScreen({super.key, this.initial});

  final CommunityUserModel? initial;

  @override
  ConsumerState<PersonFormScreen> createState() => _PersonFormScreenState();
}

class _PersonFormScreenState extends ConsumerState<PersonFormScreen> {
  final List<GlobalKey<FormState>> _forms = List.generate(
    3,
    (_) => GlobalKey<FormState>(),
  );
  late final PhoneNumberParts _phoneParts = parsePhoneNumber(
    widget.initial?.phone,
  );
  late CountryCode _country = _phoneParts.countryCode;
  late final TextEditingController _phone = TextEditingController(
    text: _phoneParts.nationalNumber,
  );
  late final TextEditingController _name = TextEditingController(
    text: widget.initial?.fullName ?? '',
  );
  late final TextEditingController _father = TextEditingController(
    text: widget.initial?.fatherName ?? '',
  );
  late final TextEditingController _age = TextEditingController(
    text: widget.initial?.age?.toString() ?? '',
  );
  late final TextEditingController _email = TextEditingController(
    text: widget.initial?.email ?? '',
  );
  late final TextEditingController _familyCount = TextEditingController(
    text: widget.initial?.familyMemberCount?.toString() ?? '',
  );
  final TextEditingController _masjidId = TextEditingController();
  late String? _gender = widget.initial?.gender;
  late bool _familyHead = widget.initial?.isFamilyHead ?? false;
  String? _role;
  bool _saving = false;
  String? _error;

  bool get _editing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final allowed = PermissionHelper.allowedCommunityRolesToCreate(
      ref.read(currentPermissionsProvider),
    );
    _role = allowed.isEmpty ? null : allowed.last;
  }

  @override
  void dispose() {
    for (final controller in <TextEditingController>[
      _phone,
      _name,
      _father,
      _age,
      _email,
      _familyCount,
      _masjidId,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Only villagers (members) can be family heads.
  bool get _isMember => _editing
      ? (widget.initial!.isMember &&
            !widget.initial!.isImam &&
            !widget.initial!.isCommitteeMember)
      : _role == PermissionHelper.member;

  bool _validate(int step) => _forms[step].currentState?.validate() ?? true;

  String get _normalizedPhone =>
      normalizePhone(countryCode: _country, nationalNumber: _phone.text);

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _saving = true;
      _error = null;
    });
    final count = _familyCount.text.trim();
    try {
      if (_editing) {
        await ref
            .read(communityControllerProvider.notifier)
            .updateUser(
              widget.initial!.id,
              UpdateCommunityUserRequest(
                fullName: _name.text.trim(),
                phone: _normalizedPhone,
                fatherName: _father.text.trim(),
                age: int.parse(_age.text.trim()),
                gender: _gender!,
                email: _email.text.trim().isEmpty ? null : _email.text.trim(),
                isFamilyHead: _isMember ? _familyHead : null,
                familyMemberCount: _isMember && _familyHead && count.isNotEmpty
                    ? int.parse(count)
                    : null,
              ),
            );
        if (!mounted) return;
        await showSuccess(
          context,
          title: l10n.saved,
          detail: _name.text.trim(),
          icon: AppIcons.person,
          tone: AppTones.people,
        );
      } else {
        final created = await ref
            .read(addCommunityUserControllerProvider.notifier)
            .submit(
              buildCreateCommunityUserRequest(
                fullName: _name.text,
                phone: _normalizedPhone,
                email: _email.text,
                role: _role!,
                fatherName: _father.text,
                age: _age.text,
                gender: _gender!,
                isFamilyHead: _familyHead,
                familyMemberCount: count,
                masjidId: _masjidId.text,
              ),
            );
        if (!mounted) return;
        if (created == null) {
          final error = ref.read(addCommunityUserControllerProvider).error;
          setState(() {
            _saving = false;
            _error = errorText(l10n, error ?? l10n.somethingWentWrong);
          });
          return;
        }
        await _showCreated(created);
      }
      if (mounted) context.pop(true);
    } catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = errorText(l10n, error);
        });
      }
    }
  }

  /// A new imam or committee member gets a temporary password: it stays on
  /// screen until OK, so it can be written down. Villagers log in with a
  /// code sent to their phone.
  Future<void> _showCreated(CommunityUserModel created) async {
    final l10n = AppLocalizations.of(context);
    final password = created.temporaryPassword;
    if (password == null || password.isEmpty) {
      await showSuccess(
        context,
        title: l10n.personAdded,
        detail: l10n.personCanLoginWithCode,
        icon: AppIcons.person,
        tone: AppTones.people,
      );
      return;
    }
    await showAppSheet<void>(
      context,
      dismissible: false,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ScreenHeader(
            icon: AppIcons.password,
            tone: AppTones.done,
            title: l10n.personAdded,
            subtitle: l10n.temporaryPasswordHelp,
          ),
          Container(
            padding: const EdgeInsets.all(AppSpace.l),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.m),
            ),
            child: SelectableText(
              password,
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              style: Theme.of(sheetContext).textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: AppSpace.s),
          TextButton.icon(
            onPressed: () => Clipboard.setData(ClipboardData(text: password)),
            icon: const Icon(Icons.copy_rounded),
            label: Text(l10n.copy),
          ),
          const SizedBox(height: AppSpace.l),
          FilledButton(
            onPressed: () => Navigator.of(sheetContext).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final permissions = ref.watch(currentPermissionsProvider);
    final allowed = PermissionHelper.allowedCommunityRolesToCreate(permissions);
    final user = ref.watch(currentUserProvider);
    final askMasjidId =
        !_editing &&
        PermissionHelper.has(user, AppPermissions.platformRolesAssign) &&
        (user?.masjidId == null || user!.masjidId!.trim().isEmpty);
    final error = _error;
    String? required(String? value) =>
        (value ?? '').trim().isEmpty ? l10n.fieldRequired : null;

    return Scaffold(
      appBar: AppBar(title: Text(_editing ? l10n.editPerson : l10n.addPerson)),
      body: SafeArea(
        top: false,
        child: StepFlow(
          tone: AppTones.people,
          finishLabel: l10n.save,
          onFinish: _save,
          steps: <FlowStep>[
            FlowStep(
              title: l10n.whoIsIt,
              icon: AppIcons.person,
              validate: () => _validate(0),
              builder: (_) => Form(
                key: _forms[0],
                child: Column(
                  children: <Widget>[
                    PhoneFormField(
                      controller: _phone,
                      country: _country,
                      onCountryChanged: (country) =>
                          setState(() => _country = country),
                      label: l10n.phoneNumber,
                    ),
                    AppFormField(
                      controller: _name,
                      label: l10n.fullName,
                      icon: AppIcons.person,
                      validator: required,
                    ),
                  ],
                ),
              ),
            ),
            FlowStep(
              title: l10n.details,
              icon: AppIcons.family,
              validate: () => _validate(1),
              builder: (_) => Form(
                key: _forms[1],
                child: Column(
                  children: <Widget>[
                    AppFormField(
                      controller: _father,
                      label: l10n.fatherName,
                      icon: AppIcons.family,
                      validator: required,
                    ),
                    AgeFormField(
                      controller: _age,
                      label: l10n.age,
                      validator: (value) => MasjidRequestValidators.age(
                        value,
                        requiredMessage: l10n.fieldRequired,
                        rangeMessage: l10n.invalidAge,
                      ),
                    ),
                    GenderFormField(
                      value: _gender,
                      onChanged: (gender) => setState(() => _gender = gender),
                    ),
                    AppFormField(
                      controller: _email,
                      label: l10n.emailOptional,
                      icon: AppIcons.email,
                      keyboardType: TextInputType.emailAddress,
                      textCapitalization: TextCapitalization.none,
                      validator: (value) => MasjidRequestValidators.email(
                        value,
                        l10n.invalidEmail,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            FlowStep(
              title: _editing ? l10n.family : l10n.roleAndFamily,
              icon: AppIcons.people,
              canContinue: !_saving && (_editing || _role != null),
              validate: () => _validate(2),
              builder: (_) => Form(
                key: _forms[2],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    if (!_editing && allowed.length > 1) ...<Widget>[
                      Text(
                        l10n.role,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: AppSpace.s),
                      Wrap(
                        spacing: AppSpace.s,
                        runSpacing: AppSpace.s,
                        children: allowed
                            .map(
                              (role) => ChoiceChip(
                                avatar: Icon(_roleIcon(role), size: 20),
                                label: Text(_roleLabel(l10n, role)),
                                selected: _role == role,
                                onSelected: (_) => setState(() => _role = role),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: AppSpace.l),
                    ],
                    if (_isMember) ...<Widget>[
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        secondary: const Icon(AppIcons.family),
                        title: Text(l10n.familyHead),
                        subtitle: Text(l10n.familyHeadHelp),
                        value: _familyHead,
                        onChanged: (value) =>
                            setState(() => _familyHead = value),
                      ),
                      if (_familyHead)
                        AppFormField(
                          controller: _familyCount,
                          label: l10n.familyMembersOptional,
                          icon: AppIcons.people,
                          keyboardType: TextInputType.number,
                          maxLength: 3,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                    ] else if (_editing)
                      Text(
                        l10n.noFamilyForRole,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    if (askMasjidId) ...<Widget>[
                      const SizedBox(height: AppSpace.m),
                      AppFormField(
                        controller: _masjidId,
                        label: l10n.masjidId,
                        icon: AppIcons.mosque,
                        textCapitalization: TextCapitalization.none,
                        validator: required,
                      ),
                    ],
                    if (error != null) ...<Widget>[
                      const SizedBox(height: AppSpace.m),
                      MessageBanner(text: error),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static IconData _roleIcon(String role) => switch (role) {
    PermissionHelper.imam => AppIcons.imam,
    PermissionHelper.committeeMember => AppIcons.people,
    _ => AppIcons.person,
  };

  static String _roleLabel(AppLocalizations l10n, String role) =>
      switch (role) {
        PermissionHelper.imam => l10n.roleImam,
        PermissionHelper.committeeMember => l10n.roleCommittee,
        _ => l10n.roleMember,
      };
}
