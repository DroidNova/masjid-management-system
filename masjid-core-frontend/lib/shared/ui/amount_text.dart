import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/core/format/formatters.dart';
import 'package:masjid_core_frontend/shared/ui/tokens.dart';

/// Whether an amount is money coming in, going out, or just a figure.
enum AmountKind { neutral, moneyIn, moneyOut }

enum AmountSize { small, medium, large, hero }

/// A rupee amount in Indian format. Money in is green with "+", money out
/// is red with "−", so the meaning shows without reading (rule 3).
class AmountText extends StatelessWidget {
  const AmountText(
    this.amount, {
    super.key,
    this.kind = AmountKind.neutral,
    this.size = AmountSize.medium,
    this.color,
  });

  final num amount;
  final AmountKind kind;
  final AmountSize size;

  /// Overrides the kind's colour (for example white on a [HeroCard]).
  final Color? color;

  /// "+₹500", "−₹1,25,000", "₹12.50". Uses the true minus sign.
  static String format(num amount, {AmountKind kind = AmountKind.neutral}) {
    final text = AppFormat.rupees(amount.abs());
    return switch (kind) {
      AmountKind.moneyIn => '+$text',
      AmountKind.moneyOut => '−$text',
      AmountKind.neutral => amount < 0 ? '−$text' : text,
    };
  }

  static Color colorFor(AmountKind kind) => switch (kind) {
    AmountKind.moneyIn => AppTones.moneyIn.color,
    AmountKind.moneyOut => AppTones.moneyOut.color,
    AmountKind.neutral => AppColors.textPrimary,
  };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final base = switch (size) {
      AmountSize.small => textTheme.titleSmall,
      AmountSize.medium => textTheme.titleLarge,
      AmountSize.large => textTheme.headlineMedium,
      AmountSize.hero => textTheme.displayMedium,
    };
    return Text(
      format(amount, kind: kind),
      // Digits keep their order in Urdu (right-to-left) text.
      textDirection: TextDirection.ltr,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: base?.copyWith(
        color: color ?? colorFor(kind),
        fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
      ),
    );
  }
}
