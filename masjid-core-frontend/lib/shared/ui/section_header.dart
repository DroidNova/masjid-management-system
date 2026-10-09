import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/shared/ui/tokens.dart';

/// A heading above a group of cards, with an optional link on the far side
/// ("See all").
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final leading = icon;
    final action = actionLabel;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.l, bottom: AppSpace.s),
      child: Row(
        children: <Widget>[
          if (leading != null) ...<Widget>[
            Icon(leading, size: 24, color: AppColors.textSecondary),
            const SizedBox(width: AppSpace.s),
          ],
          Expanded(
            child: Semantics(
              header: true,
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
          ),
          if (action != null && onAction != null)
            TextButton(onPressed: onAction, child: Text(action)),
        ],
      ),
    );
  }
}
