import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/shared/ui/tokens.dart';

/// The one big coloured card at the top of a screen (next namaz, balance,
/// project progress). Text and icons inside are white.
class HeroCard extends StatelessWidget {
  const HeroCard({
    super.key,
    required this.tone,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpace.xl),
  });

  final AppTone tone;
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final darker = Color.lerp(tone.color, Colors.black, 0.25)!;
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.l),
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: <Color>[tone.color, darker],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: tone.color.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.l),
          child: Padding(
            padding: padding,
            child: IconTheme(
              data: const IconThemeData(color: Colors.white),
              child: DefaultTextStyle.merge(
                style: theme.textTheme.bodyLarge!.copyWith(color: Colors.white),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
