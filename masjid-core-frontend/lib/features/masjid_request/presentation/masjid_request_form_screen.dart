import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/errors/error_text.dart';
import 'package:masjid_core_frontend/core/format/formatters.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/features/masjid_request/application/masjid_request_form_controller.dart';
import 'package:masjid_core_frontend/features/masjid_request/application/masjid_request_validators.dart';
import 'package:masjid_core_frontend/features/masjid_request/presentation/masjid_request_form_fields.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/constants/indian_states.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// Public masjid registration (no login), one topic per page: masjid,
/// place, imam, committee, the person asking, then a review page. Field
/// state lives in [MasjidRequestFormFields]; checks across fields and
/// sending live in [MasjidRequestFormController].
class MasjidRequestFormScreen extends ConsumerStatefulWidget {
  const MasjidRequestFormScreen({super.key});

  @override
  ConsumerState<MasjidRequestFormScreen> createState() =>
      _MasjidRequestFormScreenState();
}

class _MasjidRequestFormScreenState
    extends ConsumerState<MasjidRequestFormScreen> {
  static const int _imamStep = 2;
  static const int _committeeStep = 3;

  final GlobalKey<StepFlowState> _flowKey = GlobalKey<StepFlowState>();

  /// One form per page that has fields (masjid, place, imam, committee,
  /// you); the review page has none.
  final List<GlobalKey<FormState>> _formKeys = List.generate(
    5,
    (_) => GlobalKey<FormState>(),
  );
  final MasjidRequestFormFields _fields = MasjidRequestFormFields();

  /// Phones the server said already belong to another masjid; their fields
  /// show a message until the number is changed.
  final Set<String> _takenPhones = <String>{};
  CommitteeProblem? _committeeProblem;
  String? _submitError;

  @override
  void dispose() {
    _fields.dispose();
    super.dispose();
  }

  bool _validateStep(int step) =>
      _formKeys[step].currentState?.validate() ?? true;

  bool _validateCommittee() {
    final fieldsOk = _validateStep(_committeeStep);
    final draft = _fields.toDraft();
    final problem = MasjidRequestValidators.committeePhones(
      imamPhone: draft.imamPhone.normalized,
      committeePhones: draft.committeeMembers
          .map((member) => member.phone.normalized)
          .toList(),
    );
    setState(() => _committeeProblem = problem);
    return fieldsOk && problem == null;
  }

  String? _takenPhoneMessage(AppLocalizations l10n, String phone) =>
      _takenPhones.contains(phone) ? l10n.phoneInAnotherMasjid : null;

  String _committeeProblemText(AppLocalizations l10n, CommitteeProblem p) =>
      switch (p) {
        CommitteeProblem.missing => l10n.committeeMissing,
        CommitteeProblem.imamIsMember => l10n.imamIsCommitteeMember,
        CommitteeProblem.duplicatePhone => l10n.duplicateCommitteePhone,
      };

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _submitError = null);
    final submitted = await ref
        .read(masjidRequestFormControllerProvider.notifier)
        .submit(_fields.toDraft());
    if (!mounted) return;
    if (submitted) {
      context.go('/masjid-request/submitted');
      return;
    }

    final error = ref.read(masjidRequestFormControllerProvider).error;
    if (error is MasjidRequestInvalid) {
      setState(() => _committeeProblem = error.problem);
      _flowKey.currentState?.goTo(_committeeStep);
      return;
    }
    if (error is ApiException &&
        error.code == ApiErrorCodes.userInAnotherMasjid) {
      // Not awaited: the send button stops spinning while the message shows.
      unawaited(_showPhoneTaken(error));
      return;
    }
    if (error != null) setState(() => _submitError = errorText(l10n, error));
  }

  /// The server's message names the imam or committee member (as entered
  /// on this form) whose phone already belongs to another masjid. After
  /// the message, the page with that phone opens with the field marked.
  Future<void> _showPhoneTaken(ApiException error) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _takenPhones.addAll(error.fieldErrors['phones'] ?? []));

    await showAppSheet<void>(
      context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ScreenHeader(
            icon: AppIcons.phone,
            tone: AppTones.problem,
            title: l10n.phoneAlreadyRegistered,
            subtitle: error.message,
          ),
          FilledButton(
            onPressed: () => Navigator.of(sheetContext).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
    if (!mounted) return;

    final imamTaken = _takenPhones.contains(
      _fields.toDraft().imamPhone.normalized,
    );
    final step = imamTaken ? _imamStep : _committeeStep;
    _flowKey.currentState?.goTo(step);
    WidgetsBinding.instance.addPostFrameCallback((_) => _validateStep(step));
  }

  void _addCommitteeMember() {
    setState(() => _fields.committeeMembers.add(CommitteeMemberFields()));
  }

  void _removeCommitteeMember(CommitteeMemberFields member) {
    setState(() => _fields.committeeMembers.remove(member));
    // Dispose after the removed fields have left the tree.
    WidgetsBinding.instance.addPostFrameCallback((_) => member.dispose());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isSubmitting = ref
        .watch(masjidRequestFormControllerProvider)
        .isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.registerMasjid)),
      body: SafeArea(
        top: false,
        child: StepFlow(
          key: _flowKey,
          tone: AppTones.namaz,
          finishLabel: l10n.sendRequest,
          finishIcon: AppIcons.send,
          onFinish: _submit,
          steps: <FlowStep>[
            FlowStep(
              title: l10n.stepMasjid,
              icon: AppIcons.mosque,
              validate: () => _validateStep(0),
              builder: (_) => _form(0, _masjidFields(l10n)),
            ),
            FlowStep(
              title: l10n.stepPlace,
              icon: AppIcons.place,
              validate: () => _validateStep(1),
              builder: (_) => _form(1, _placeFields(l10n)),
            ),
            FlowStep(
              title: l10n.stepImam,
              icon: AppIcons.imam,
              validate: () => _validateStep(_imamStep),
              builder: (_) => _form(_imamStep, _imamFields(l10n)),
            ),
            FlowStep(
              title: l10n.stepCommittee,
              icon: AppIcons.people,
              validate: _validateCommittee,
              builder: (_) => _form(_committeeStep, _committeeFields(l10n)),
            ),
            FlowStep(
              title: l10n.stepYou,
              icon: AppIcons.person,
              validate: () => _validateStep(4),
              builder: (_) => _form(4, _requesterFields(l10n)),
            ),
            FlowStep(
              title: l10n.stepReview,
              icon: AppIcons.review,
              canContinue: !isSubmitting,
              builder: (_) => _review(l10n),
            ),
          ],
        ),
      ),
    );
  }

  Widget _form(int step, List<Widget> children) => Form(
    key: _formKeys[step],
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    ),
  );

  String? Function(String?) _required(AppLocalizations l10n) =>
      (value) => MasjidRequestValidators.required(value, l10n.fieldRequired);

  String? Function(String?) _age(AppLocalizations l10n) =>
      (value) => MasjidRequestValidators.age(
        value,
        requiredMessage: l10n.fieldRequired,
        rangeMessage: l10n.invalidAge,
      );

  String? Function(String?) _email(AppLocalizations l10n) =>
      (value) => MasjidRequestValidators.email(value, l10n.invalidEmail);

  List<Widget> _masjidFields(AppLocalizations l10n) => <Widget>[
    AppFormField(
      controller: _fields.masjidName,
      label: l10n.masjidName,
      icon: AppIcons.mosque,
      validator: _required(l10n),
    ),
    PhoneFormField(
      controller: _fields.contactNo,
      country: _fields.contactCountry,
      onCountryChanged: (country) =>
          setState(() => _fields.contactCountry = country),
      label: l10n.masjidPhoneOptional,
      isRequired: false,
    ),
    AppFormField(
      controller: _fields.welcomeMsg,
      label: l10n.welcomeMessageOptional,
      icon: Icons.waving_hand_rounded,
      maxLines: 3,
      textCapitalization: TextCapitalization.sentences,
    ),
    AppFormField(
      controller: _fields.description,
      label: l10n.aboutMasjidOptional,
      icon: AppIcons.info,
      maxLines: 4,
      textCapitalization: TextCapitalization.sentences,
    ),
  ];

  List<Widget> _placeFields(AppLocalizations l10n) {
    final isIndia = _fields.isIndia;
    final country = _fields.masjidCountry;
    return <Widget>[
      Padding(
        padding: const EdgeInsets.only(bottom: AppSpace.l),
        child: OutlinedButton(
          onPressed: () async {
            final picked = await showCountryPicker(context);
            if (picked != null) {
              setState(() => _fields.changeMasjidCountry(picked));
            }
          },
          style: OutlinedButton.styleFrom(
            alignment: AlignmentDirectional.centerStart,
            minimumSize: const Size.fromHeight(58),
          ),
          child: Row(
            children: <Widget>[
              Text(country.flagEmoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: AppSpace.m),
              Expanded(child: Text('${l10n.country}: ${country.name}')),
              const Icon(Icons.expand_more_rounded),
            ],
          ),
        ),
      ),
      if (isIndia)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpace.l),
          child: DropdownButtonFormField<String>(
            // Rebuilt with the country so a cleared state shows empty.
            key: ValueKey<String>('state-${country.isoCode}'),
            initialValue: _fields.state.text.isEmpty
                ? null
                : _fields.state.text,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: l10n.state,
              prefixIcon: const Icon(Icons.map_rounded),
            ),
            items: indianStates
                .map(
                  (state) => DropdownMenuItem<String>(
                    value: state,
                    child: Text(state),
                  ),
                )
                .toList(),
            onChanged: (state) => _fields.state.text = state ?? '',
            validator: _required(l10n),
          ),
        )
      else
        AppFormField(
          controller: _fields.state,
          label: l10n.state,
          icon: Icons.map_rounded,
          validator: _required(l10n),
        ),
      if (isIndia)
        AppFormField(
          controller: _fields.district,
          label: l10n.district,
          icon: Icons.location_city_rounded,
          validator: _required(l10n),
        ),
      AppFormField(
        controller: _fields.locality,
        label: l10n.cityOrVillage,
        icon: Icons.holiday_village_rounded,
        validator: _required(l10n),
      ),
      AppFormField(
        controller: _fields.address,
        label: l10n.address,
        icon: AppIcons.place,
        maxLines: 3,
        validator: _required(l10n),
        textCapitalization: TextCapitalization.sentences,
      ),
    ];
  }

  List<Widget> _imamFields(AppLocalizations l10n) => <Widget>[
    AppFormField(
      controller: _fields.imamName,
      label: l10n.fullName,
      icon: AppIcons.person,
      validator: _required(l10n),
    ),
    PhoneFormField(
      controller: _fields.imamPhone,
      country: _fields.imamCountry,
      onCountryChanged: (country) =>
          setState(() => _fields.imamCountry = country),
      label: l10n.phoneNumber,
      extraValidator: (phone) => _takenPhoneMessage(l10n, phone),
    ),
    AppFormField(
      controller: _fields.imamFatherName,
      label: l10n.fatherName,
      icon: AppIcons.family,
      validator: _required(l10n),
    ),
    AgeFormField(
      controller: _fields.imamAge,
      label: l10n.age,
      validator: _age(l10n),
    ),
    GenderFormField(
      value: _fields.imamGender,
      onChanged: (gender) => setState(() => _fields.imamGender = gender),
    ),
    AppFormField(
      controller: _fields.imamAddress,
      label: l10n.address,
      icon: AppIcons.place,
      maxLines: 3,
      validator: _required(l10n),
      textCapitalization: TextCapitalization.sentences,
    ),
    AppFormField(
      controller: _fields.imamEmail,
      label: l10n.emailOptional,
      icon: AppIcons.email,
      keyboardType: TextInputType.emailAddress,
      textCapitalization: TextCapitalization.none,
      validator: _email(l10n),
    ),
  ];

  List<Widget> _committeeFields(AppLocalizations l10n) {
    final problem = _committeeProblem;
    final members = _fields.committeeMembers;
    return <Widget>[
      Text(
        l10n.committeeHelp,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
      ),
      const SizedBox(height: AppSpace.l),
      for (var i = 0; i < members.length; i++)
        Padding(
          key: members[i].key,
          padding: const EdgeInsets.only(bottom: AppSpace.l),
          child: _CommitteeMemberCard(
            number: i + 1,
            member: members[i],
            canRemove: members.length > 1,
            onRemove: () => _removeCommitteeMember(members[i]),
            onChanged: () => setState(() {}),
            required: _required(l10n),
            age: _age(l10n),
            takenPhone: (phone) => _takenPhoneMessage(l10n, phone),
          ),
        ),
      if (problem != null) ...<Widget>[
        MessageBanner(text: _committeeProblemText(l10n, problem)),
        const SizedBox(height: AppSpace.l),
      ],
      OutlinedButton.icon(
        onPressed: _addCommitteeMember,
        icon: const Icon(AppIcons.add),
        label: Text(l10n.addMember),
      ),
    ];
  }

  List<Widget> _requesterFields(AppLocalizations l10n) => <Widget>[
    Text(
      l10n.requesterHelp,
      style: Theme.of(
        context,
      ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
    ),
    const SizedBox(height: AppSpace.l),
    AppFormField(
      controller: _fields.requesterName,
      label: l10n.yourName,
      icon: AppIcons.person,
      validator: _required(l10n),
      autofillHints: const <String>[AutofillHints.name],
    ),
    PhoneFormField(
      controller: _fields.requesterPhone,
      country: _fields.requesterCountry,
      onCountryChanged: (country) =>
          setState(() => _fields.requesterCountry = country),
      label: l10n.yourPhoneNumber,
    ),
    AppFormField(
      controller: _fields.requesterEmail,
      label: l10n.emailOptional,
      icon: AppIcons.email,
      keyboardType: TextInputType.emailAddress,
      textCapitalization: TextCapitalization.none,
      textInputAction: TextInputAction.done,
      validator: _email(l10n),
    ),
  ];

  Widget _review(AppLocalizations l10n) {
    final draft = _fields.toDraft();
    final submitError = _submitError;
    final place = <String>[
      draft.locality,
      if (_fields.isIndia) draft.district,
      draft.state,
      draft.masjidCountry.name,
    ].map((part) => part.trim()).where((part) => part.isNotEmpty).join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          l10n.reviewHelp,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpace.l),
        _ReviewCard(
          icon: AppIcons.mosque,
          lines: <String>[draft.masjidName.trim(), place],
          onEdit: () => _flowKey.currentState?.goTo(0),
        ),
        _ReviewCard(
          icon: AppIcons.imam,
          lines: <String>[
            draft.imamName.trim(),
            AppFormat.phone(draft.imamPhone.normalized),
          ],
          onEdit: () => _flowKey.currentState?.goTo(_imamStep),
        ),
        _ReviewCard(
          icon: AppIcons.people,
          lines: <String>[
            l10n.membersCount(draft.committeeMembers.length),
            draft.committeeMembers.map((m) => m.name.trim()).join(', '),
          ],
          onEdit: () => _flowKey.currentState?.goTo(_committeeStep),
        ),
        _ReviewCard(
          icon: AppIcons.person,
          lines: <String>[
            draft.requesterName.trim(),
            draft.requesterPhone.normalized,
          ],
          onEdit: () => _flowKey.currentState?.goTo(4),
        ),
        if (submitError != null) ...<Widget>[
          const SizedBox(height: AppSpace.s),
          MessageBanner(text: submitError),
        ],
      ],
    );
  }
}

/// One committee member's fields in a card, with a remove button.
class _CommitteeMemberCard extends StatelessWidget {
  const _CommitteeMemberCard({
    required this.number,
    required this.member,
    required this.canRemove,
    required this.onRemove,
    required this.onChanged,
    required this.required,
    required this.age,
    required this.takenPhone,
  });

  final int number;
  final CommitteeMemberFields member;
  final bool canRemove;
  final VoidCallback onRemove;
  final VoidCallback onChanged;
  final String? Function(String?) required;
  final String? Function(String?) age;
  final String? Function(String phone) takenPhone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                PersonAvatar(
                  name: member.name.text.isEmpty ? '$number' : member.name.text,
                  size: 40,
                ),
                const SizedBox(width: AppSpace.m),
                Expanded(
                  child: Text(
                    l10n.memberNumber(number),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (canRemove)
                  IconButton(
                    tooltip: l10n.removeMember,
                    color: AppTones.danger.color,
                    icon: const Icon(AppIcons.delete),
                    onPressed: onRemove,
                  ),
              ],
            ),
            const SizedBox(height: AppSpace.m),
            AppFormField(
              controller: member.name,
              label: l10n.fullName,
              icon: AppIcons.person,
              validator: required,
            ),
            PhoneFormField(
              controller: member.phone,
              country: member.country,
              onCountryChanged: (country) {
                member.country = country;
                onChanged();
              },
              label: l10n.phoneNumber,
              extraValidator: takenPhone,
            ),
            AppFormField(
              controller: member.fatherName,
              label: l10n.fatherName,
              icon: AppIcons.family,
              validator: required,
            ),
            AgeFormField(
              controller: member.age,
              label: l10n.age,
              validator: age,
            ),
            GenderFormField(
              value: member.gender,
              onChanged: (gender) {
                member.gender = gender;
                onChanged();
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// A summary block on the review page with an edit button.
class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.icon,
    required this.lines,
    required this.onEdit,
  });

  final IconData icon;
  final List<String> lines;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final shown = lines.where((line) => line.trim().isNotEmpty).toList();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.m),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.l),
          child: Row(
            children: <Widget>[
              ToneIcon(icon: icon, tone: AppTones.namaz),
              const SizedBox(width: AppSpace.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (var i = 0; i < shown.length; i++)
                      Text(
                        shown[i],
                        style: i == 0
                            ? textTheme.titleMedium
                            : textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                      ),
                  ],
                ),
              ),
              IconButton(
                tooltip: AppLocalizations.of(context).edit,
                icon: const Icon(AppIcons.edit),
                onPressed: onEdit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
