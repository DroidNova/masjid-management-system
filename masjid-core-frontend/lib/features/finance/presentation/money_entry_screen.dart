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

  void _pick(MoneyCategory category) {
    setState(() => _category = category);
    // Choosing the kind is the whole step: go on to the amount.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _flow.currentState?.next(),
    );
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final category = _category;
    final amount = AmountPad.parse(_amount);
    if (category == null || amount == null) return;
    setState(() => _error = null);

    final note = _note.text.trim();
    final day = DateFormat('yyyy-MM-dd').format(_date);
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
