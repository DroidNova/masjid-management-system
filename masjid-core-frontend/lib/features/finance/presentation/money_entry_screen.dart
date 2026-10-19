import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:masjid_core_frontend/core/errors/error_text.dart';
import 'package:masjid_core_frontend/features/finance/application/finance_entry_controller.dart';
import 'package:masjid_core_frontend/features/finance/data/models/create_collection_request.dart';
import 'package:masjid_core_frontend/features/finance/data/models/create_expense_request.dart';
import 'package:masjid_core_frontend/features/finance/presentation/money_categories.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// Records money in (a collection) or money out (an expense) in two
/// steps: pick the kind by its picture (this moves on by itself), then the
/// amount on big keys with the day (today already chosen) and an optional
/// note. A ₹500 Jumma collection is: Money in → Jumma → ₹500 → Save.
class MoneyEntryScreen extends ConsumerStatefulWidget {
  const MoneyEntryScreen({super.key, required this.isExpense, this.today});

  final bool isExpense;

  /// Overrides "now" in tests.
  final DateTime? today;

  @override
  ConsumerState<MoneyEntryScreen> createState() => _MoneyEntryScreenState();
}

class _MoneyEntryScreenState extends ConsumerState<MoneyEntryScreen> {
  final GlobalKey<StepFlowState> _flow = GlobalKey<StepFlowState>();
  final TextEditingController _note = TextEditingController();
  MoneyCategory? _category;
  String _amount = '';
  late DateTime _date = DateUtils.dateOnly(widget.today ?? DateTime.now());
  bool _showNote = false;
  String? _error;

  AppTone get _tone => widget.isExpense ? AppTones.moneyOut : AppTones.moneyIn;
  List<MoneyCategory> get _categories =>
      widget.isExpense ? moneyOutCategories : moneyInCategories;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  /// Kinds usually given by one known person: ask who, so it shows in
  /// their own payments. Jumma and the donation box have no name.
  static const Set<String> _personalKinds = <String>{
    'RAMADAN_FUND',
    'ZAKAT',
    'SADAQAH',
    'CONSTRUCTION_FUND',
    'OTHER',
  };

  Future<void> _pick(MoneyCategory category) async {
    setState(() => _category = category);
    if (!widget.isExpense && _personalKinds.contains(category.value)) {
      final person = await _askWhoGave();
      if (!mounted || person == null) return;
      if (person) {
        // The givers flow records it against the person; this kind is set.
        final saved = await context.push<bool>(
          Uri(
            path: '/contributions/new',
            queryParameters: <String, String>{'category': category.value},
          ).toString(),
        );
        if (mounted && saved == true) context.pop(true);
        return;
      }
    }
    // Choosing the kind is the whole step: go on to the amount.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _flow.currentState?.next(),
    );
  }

  /// "Who gave?": a person (true), no name (false), or closed (null).
  Future<bool?> _askWhoGave() {
    final l10n = AppLocalizations.of(context);
    return showAppSheet<bool>(
      context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ScreenHeader(
            icon: AppIcons.person,
            title: l10n.whoGave,
            tone: AppTones.moneyIn,
          ),
          SizedBox(
            height: 190,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: _GiverChoice(
                    icon: AppIcons.person,
                    label: l10n.giverPerson,
                    hint: l10n.giverPersonHint,
                    tone: AppTones.people,
                    onTap: () => Navigator.of(sheetContext).pop(true),
                  ),
                ),
                const SizedBox(width: AppSpace.m),
                Expanded(
                  child: _GiverChoice(
                    icon: AppIcons.donationBox,
                    label: l10n.giverNoName,
                    hint: l10n.giverNoNameHint,
                    tone: AppTones.neutral,
                    onTap: () => Navigator.of(sheetContext).pop(false),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final category = _category;
    final amount = AmountPad.parse(_amount);
    if (category == null || amount == null) return;
    setState(() => _error = null);

    final note = _note.text.trim();
    final day = DateFormat('yyyy-MM-dd', 'en').format(_date);
    final controller = ref.read(financeEntryControllerProvider.notifier);
    final saved = widget.isExpense
        ? await controller.addExpense(
            CreateExpenseRequest(
              type: category.value,
              amount: amount.toDouble(),
              description: note.isEmpty ? null : note,
              spentAt: day,
            ),
          )
        : await controller.addCollection(
            CreateCollectionRequest(
              type: category.value,
              amount: amount.toDouble(),
              description: note.isEmpty ? null : note,
              collectedAt: day,
            ),
          );
    if (!mounted) return;
    if (!saved) {
      final error = ref.read(financeEntryControllerProvider).error;
      setState(
        () => _error = errorText(l10n, error ?? l10n.somethingWentWrong),
      );
      return;
    }
    await showSuccess(
      context,
      title: widget.isExpense ? l10n.moneyOutSaved : l10n.moneyInSaved,
      detail:
          '${AmountText.format(amount, kind: widget.isExpense ? AmountKind.moneyOut : AmountKind.moneyIn)} · ${category.label(l10n)}',
      icon: widget.isExpense ? AppIcons.moneyOut : AppIcons.moneyIn,
      tone: _tone,
    );
    if (mounted) context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final error = _error;
    final category = _category;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isExpense ? l10n.moneyOut : l10n.moneyIn),
      ),
      body: SafeArea(
        top: false,
        child: StepFlow(
          key: _flow,
          tone: _tone,
          finishLabel: l10n.save,
          onFinish: _save,
          steps: <FlowStep>[
            FlowStep(
              title: l10n.whatKind,
              icon: widget.isExpense ? AppIcons.moneyOut : AppIcons.moneyIn,
              canContinue: category != null,
              builder: (_) => ActionTileGrid(
                tiles: _categories
                    .map(
                      (option) => ActionTile(
                        icon: option.icon,
                        label: option.label(l10n),
                        tone: _tone,
                        selected: option.value == category?.value,
                        onTap: () => _pick(option),
                      ),
                    )
                    .toList(),
              ),
            ),
            FlowStep(
              title: category == null
                  ? l10n.howMuch
                  : '${l10n.howMuch} · ${category.label(l10n)}',
              icon: category?.icon ?? AppIcons.money,
              canContinue: AmountPad.parse(_amount) != null,
              builder: (_) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  AmountPad(
                    value: _amount,
                    onChanged: (value) => setState(() {
                      _amount = value;
                      _error = null;
                    }),
                    quickAmounts: widget.isExpense
                        ? const <int>[100, 500, 1000, 5000]
                        : const <int>[100, 500, 1000, 2000],
                  ),
                  const SizedBox(height: AppSpace.l),
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

/// One big choice in "Who gave?": picture, word, and a short hint.
class _GiverChoice extends StatelessWidget {
  const _GiverChoice({
    required this.icon,
    required this.label,
    required this.hint,
    required this.tone,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String hint;
  final AppTone tone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Pressable(
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpace.m),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ToneIcon(icon: icon, tone: tone, size: 56),
                const SizedBox(height: AppSpace.s),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium,
                ),
                Text(
                  hint,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
