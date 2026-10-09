import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/errors/error_text.dart';
import 'package:masjid_core_frontend/features/contributions/application/contribution_list_controllers.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/contributor_option.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/new_contribution.dart';
import 'package:masjid_core_frontend/features/finance/presentation/money_categories.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/models/country_code.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';
import 'package:masjid_core_frontend/shared/utils/country_code_utils.dart';

/// Records who gave money, one question per page: who (a member from the
/// list, or someone else by name), what for (collections only), then how
/// much, cash or online, and which day. With [projectId] it records a
/// project contribution; without, a general collection contribution.
class ContributionFlowScreen extends ConsumerStatefulWidget {
  const ContributionFlowScreen({super.key, this.projectId, this.today});

  final String? projectId;

  /// Overrides "now" in tests.
  final DateTime? today;

  bool get isCollection => projectId == null;

  @override
  ConsumerState<ContributionFlowScreen> createState() =>
      _ContributionFlowScreenState();
}

class _ContributionFlowScreenState
    extends ConsumerState<ContributionFlowScreen> {
  final GlobalKey<StepFlowState> _flow = GlobalKey<StepFlowState>();
  final GlobalKey<FormState> _otherForm = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _note = TextEditingController();
  CountryCode _country = getDefaultCountryCode();

  ContributorOption? _member;
  bool _someoneElse = false;
  MoneyCategory? _category;
  String _amount = '';
  String _mode = 'CASH';
  late DateTime _date = DateUtils.dateOnly(widget.today ?? DateTime.now());
  bool _showNote = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _note.dispose();
    super.dispose();
  }

  String get _giverName => _member?.fullName ?? _name.text.trim();

  Future<void> _pickMember() async {
    final l10n = AppLocalizations.of(context);
    final picked = await showPersonPicker(
      context,
      title: l10n.whoGave,
      search: (query) async {
        final members = await ref.read(contributorOptionsProvider.future);
        final q = query.toLowerCase();
        return members
            .where(
              (member) =>
                  member.fullName.toLowerCase().contains(q) ||
                  (member.phone ?? '').contains(q),
            )
            .map(
              (member) => PickablePerson(
                id: member.id,
                name: member.fullName,
                subtitle: member.phone,
              ),
            )
            .toList();
      },
    );
    if (picked == null) return;
    final members = await ref.read(contributorOptionsProvider.future);
    final member = members.where((m) => m.id == picked.id).firstOrNull;
    if (member == null || !mounted) return;
    setState(() {
      _member = member;
      _someoneElse = false;
    });
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _flow.currentState?.next(),
    );
  }

  void _pickCategory(MoneyCategory category) {
    setState(() => _category = category);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _flow.currentState?.next(),
    );
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final amount = AmountPad.parse(_amount);
    if (amount == null) return;
    final digits = _phone.text.replaceAll(RegExp(r'\D'), '');
    final contribution = NewContribution(
      memberId: _member?.id,
      contributorName: _giverName,
      contributorPhone:
          _member?.phone ??
          (digits.isEmpty
              ? null
              : normalizePhone(countryCode: _country, nationalNumber: digits)),
      amount: amount.toDouble(),
      paymentMode: _mode,
      paidAt: _date,
      note: _note.text,
      collectionType: widget.isCollection ? _category?.value : null,
    );

    setState(() {
      _saving = true;
      _error = null;
    });
    final recorder = ref.read(contributionRecorderProvider);
    try {
      if (widget.isCollection) {
        await recorder.recordCollectionContribution(contribution);
      } else {
        await recorder.recordProjectContribution(
          widget.projectId!,
          contribution,
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = errorText(l10n, error);
        });
      }
      return;
    }
    if (!mounted) return;
    await showSuccess(
      context,
      title: l10n.saved,
      detail:
          '${AmountText.format(amount, kind: AmountKind.moneyIn)} · $_giverName',
      icon: AppIcons.zakat,
    );
    if (mounted) context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final member = _member;
    final error = _error;
    final giverChosen =
        member != null || (_someoneElse && _name.text.trim().isNotEmpty);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addGiver)),
      body: SafeArea(
        top: false,
        child: StepFlow(
          key: _flow,
          tone: AppTones.moneyIn,
          finishLabel: l10n.save,
          onFinish: _save,
          steps: <FlowStep>[
            FlowStep(
              title: l10n.whoGave,
              icon: AppIcons.person,
              canContinue: giverChosen,
              validate: () =>
                  member != null ||
                  (_otherForm.currentState?.validate() ?? true),
              builder: (_) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (member != null) ...<Widget>[
                    Card(
                      color: AppTones.moneyIn.container,
                      child: ListTile(
                        leading: PersonAvatar(name: member.fullName),
                        title: Text(member.fullName),
                        subtitle: member.phone == null
                            ? null
                            : Text(
                                member.phone!,
                                textDirection: TextDirection.ltr,
                              ),
                        trailing: Icon(
                          AppIcons.done,
                          color: AppTones.moneyIn.color,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpace.m),
                  ],
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTones.moneyIn.color,
                      minimumSize: const Size.fromHeight(64),
                    ),
                    onPressed: _pickMember,
                    icon: const Icon(AppIcons.personSearch),
                    label: Text(
                      member == null ? l10n.pickMember : l10n.pickAnother,
                    ),
                  ),
                  const SizedBox(height: AppSpace.m),
                  OutlinedButton.icon(
                    onPressed: () => setState(() {
                      _someoneElse = true;
                      _member = null;
                    }),
                    icon: const Icon(AppIcons.person),
                    label: Text(l10n.someoneElse),
                  ),
                  if (_someoneElse) ...<Widget>[
                    const SizedBox(height: AppSpace.l),
                    Form(
                      key: _otherForm,
                      child: Column(
                        children: <Widget>[
                          AppFormField(
                            controller: _name,
                            label: l10n.fullName,
                            icon: AppIcons.person,
                            validator: (value) => (value ?? '').trim().isEmpty
                                ? l10n.fieldRequired
                                : null,
                          ),
                          PhoneFormField(
                            controller: _phone,
                            country: _country,
                            onCountryChanged: (country) =>
                                setState(() => _country = country),
                            label: l10n.phoneOptional,
                            isRequired: false,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (widget.isCollection)
              FlowStep(
                title: l10n.whatFor,
                icon: AppIcons.money,
                canContinue: _category != null,
                builder: (_) => ActionTileGrid(
                  tiles: moneyInCategories
                      .map(
                        (option) => ActionTile(
                          icon: option.icon,
                          label: option.label(l10n),
                          tone: AppTones.moneyIn,
                          selected: option.value == _category?.value,
                          onTap: () => _pickCategory(option),
                        ),
                      )
                      .toList(),
                ),
              ),
            FlowStep(
              title: l10n.howMuch,
              icon: AppIcons.salary,
              canContinue: AmountPad.parse(_amount) != null && !_saving,
              builder: (_) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  AmountPad(
                    value: _amount,
                    onChanged: (value) => setState(() {
                      _amount = value;
                      _error = null;
                    }),
                  ),
                  const SizedBox(height: AppSpace.l),
                  Wrap(
                    spacing: AppSpace.s,
                    children: <String>['CASH', 'ONLINE']
                        .map(
                          (mode) => ChoiceChip(
                            avatar: Icon(paymentModeIcon(mode), size: 20),
                            label: Text(paymentModeLabel(l10n, mode)),
                            selected: _mode == mode,
                            onSelected: (_) => setState(() => _mode = mode),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: AppSpace.m),
                  DateChips(
                    value: _date,
                    first: DateTime(2000),
                    today: widget.today,
                    onChanged: (value) => setState(() => _date = value),
                  ),
                  const SizedBox(height: AppSpace.m),
                  if (_showNote)
                    AppFormField(
                      controller: _note,
                      label: l10n.noteOptional,
                      icon: AppIcons.info,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                    )
                  else
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton.icon(
                        onPressed: () => setState(() => _showNote = true),
                        icon: const Icon(Icons.edit_note_rounded),
                        label: Text(l10n.addNote),
                      ),
                    ),
                  if (error != null) ...<Widget>[
                    const SizedBox(height: AppSpace.s),
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
