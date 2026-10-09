import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/core/format/formatters.dart';
import 'package:masjid_core_frontend/features/finance/presentation/money_categories.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// One money in or out entry: the kind's picture, its name (or title), and
/// the amount in green "+" or red "−". A cancelled entry is grey with a
/// badge. Tapping opens the details, where [onCancel] (if allowed) cancels
/// it behind the hold-to-confirm dialog.
class MoneyEntryTile extends StatelessWidget {
  const MoneyEntryTile({
    super.key,
    required this.type,
    required this.amount,
    required this.isExpense,
    this.title,
    this.note,
    this.date,
    this.cancelled = false,
    this.onCancel,
  });

  final String type;
  final double amount;
  final bool isExpense;
  final String? title;
  final String? note;
  final DateTime? date;
  final bool cancelled;

  /// Cancels the entry; throws on failure (the dialog shows why).
  final Future<void> Function()? onCancel;

  String _name(AppLocalizations l10n) {
    final custom = title?.trim() ?? '';
    return custom.isNotEmpty ? custom : moneyCategoryLabel(l10n, type);
  }

  Future<void> _openDetails(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final tone = isExpense ? AppTones.moneyOut : AppTones.moneyIn;
    final text = note?.trim() ?? '';
    final cancel = onCancel;

    await showAppSheet<void>(
      context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: ToneIcon(
              icon: moneyCategoryIcon(type, isExpense: isExpense),
              tone: cancelled ? AppTones.neutral : tone,
              size: 72,
              circle: true,
            ),
          ),
          const SizedBox(height: AppSpace.m),
          Text(
            _name(l10n),
            textAlign: TextAlign.center,
            style: textTheme.titleLarge,
          ),
          Center(
            child: AmountText(
              amount,
              kind: isExpense ? AmountKind.moneyOut : AmountKind.moneyIn,
              size: AmountSize.large,
            ),
          ),
          if (date != null)
            Text(
              AppFormat.date(date!),
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          if (text.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpace.m),
            Text(text, textAlign: TextAlign.center, style: textTheme.bodyLarge),
          ],
          if (cancelled) ...<Widget>[
            const SizedBox(height: AppSpace.m),
            Center(
              child: StatusBadge(
                kind: StatusKind.problem,
                label: l10n.cancelled,
              ),
            ),
          ],
          const SizedBox(height: AppSpace.xl),
          if (cancel != null)
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTones.danger.color,
                side: BorderSide(color: AppTones.danger.color, width: 2),
              ),
              onPressed: () async {
                Navigator.of(sheetContext).pop();
                await showDangerDialog(
                  context,
                  title: l10n.cancelEntryQuestion,
                  subject:
                      '${_name(l10n)} · ${AmountText.format(amount, kind: isExpense ? AmountKind.moneyOut : AmountKind.moneyIn)}',
                  confirmLabel: l10n.cancelEntry,
                  confirmIcon: Icons.block_rounded,
                  points: <DangerPoint>[
                    DangerPoint(
                      icon: AppIcons.money,
                      text: l10n.cancelEntryPoint,
                    ),
                  ],
                  onConfirm: cancel,
                );
              },
              icon: const Icon(Icons.block_rounded),
              label: Text(l10n.cancelEntry),
            )
          else
            FilledButton(
              onPressed: () => Navigator.of(sheetContext).pop(),
              child: Text(l10n.close),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final tone = cancelled
        ? AppTones.neutral
        : (isExpense ? AppTones.moneyOut : AppTones.moneyIn);
    final text = note?.trim() ?? '';

    return Card(
      child: InkWell(
        onTap: () => _openDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.m),
          child: Row(
            children: <Widget>[
              ToneIcon(
                icon: moneyCategoryIcon(type, isExpense: isExpense),
                tone: tone,
              ),
              const SizedBox(width: AppSpace.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _name(l10n),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        color: cancelled ? AppColors.textSecondary : null,
                      ),
                    ),
                    if (text.isNotEmpty)
                      Text(
                        text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    if (cancelled)
                      StatusBadge(
                        kind: StatusKind.problem,
                        label: l10n.cancelled,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpace.s),
              // At the end of the row; shrinks only for very big amounts.
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: Text(
                  AmountText.format(
                    amount,
                    kind: isExpense ? AmountKind.moneyOut : AmountKind.moneyIn,
                  ),
                  textDirection: TextDirection.ltr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleLarge?.copyWith(
                    color: tone.color,
                    decoration: cancelled ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
