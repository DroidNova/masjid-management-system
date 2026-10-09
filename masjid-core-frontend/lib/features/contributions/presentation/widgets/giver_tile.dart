import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/features/finance/presentation/money_categories.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// One gift: the giver's avatar and name, what it was for, cash or online,
/// and the amount in green.
class GiverTile extends StatelessWidget {
  const GiverTile({
    super.key,
    required this.name,
    required this.amount,
    required this.paymentMode,
    this.phone,
    this.kind,
    this.note,
  });

  final String name;
  final String? phone;
  final double amount;
  final String paymentMode;

  /// The collection kind; null for project contributions.
  final String? kind;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final type = kind;
    final text = note?.trim() ?? '';
    final secondary = textTheme.bodyMedium?.copyWith(
      color: AppColors.textSecondary,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.m),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            PersonAvatar(name: name),
            const SizedBox(width: AppSpace.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(name, style: textTheme.titleMedium),
                  Wrap(
                    spacing: AppSpace.m,
                    runSpacing: AppSpace.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      if (type != null && type.isNotEmpty)
                        _IconText(
                          icon: moneyCategoryIcon(type, isExpense: false),
                          text: moneyCategoryLabel(l10n, type),
                          style: secondary,
                        ),
                      _IconText(
                        icon: paymentModeIcon(paymentMode),
                        text: paymentModeLabel(l10n, paymentMode),
                        style: secondary,
                      ),
                    ],
                  ),
                  if (text.isNotEmpty)
                    Text(
                      text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: secondary,
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpace.s),
            // At the end of the row; shrinks only for very big amounts.
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: AmountText(
                amount,
                kind: AmountKind.moneyIn,
                size: AmountSize.small,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconText extends StatelessWidget {
  const _IconText({required this.icon, required this.text, this.style});

  final IconData icon;
  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: AppSpace.xs),
        Flexible(child: Text(text, style: style)),
      ],
    );
  }
}
