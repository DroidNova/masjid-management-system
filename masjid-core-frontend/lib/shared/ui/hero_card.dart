import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/shared/ui/geometric_pattern.dart';
import 'package:masjid_core_frontend/shared/ui/motion.dart';
import 'package:masjid_core_frontend/shared/ui/tokens.dart';

/// The one big coloured card at the top of a screen (next namaz, balance,
/// project progress). Text and icons inside are white. A faint star
/// pattern and a soft light in the corner make it feel special; it eases
/// in when the screen opens and shrinks a little when pressed.
class HeroCard extends StatelessWidget {
  const HeroCard({
    super.key,
    required this.tone,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpace.xl),
    this.animateIn = true,
  });

  final AppTone tone;
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  /// Plays the entrance animation the first time the card is shown.
  final bool animateIn;

  @override
  Widget build(BuildContext context) {
    final lighter = Color.lerp(tone.color, Colors.white, 0.12)!;
    final darker = Color.lerp(tone.color, Colors.black, 0.38)!;
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(AppRadius.l);

    Widget card = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: <Color>[lighter, tone.color, darker],
          stops: const <double>[0, 0.45, 1],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: tone.color.withValues(alpha: 0.35),
            blurRadius: 24,
            spreadRadius: -4,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          // The content gets the card's full width (a Column inside then
          // centres like it would outside the card).
          fit: StackFit.passthrough,
          children: <Widget>[
            // Star lattice, strongest at the top corner and fading out.
            Positioned.fill(
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (rect) => const LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: <Color>[Colors.white, Colors.transparent],
                  stops: <double>[0, 0.85],
                ).createShader(rect),
                child: const GeometricPattern(opacity: 0.13),
              ),
            ),
            // Soft light in the top corner.
            PositionedDirectional(
              top: -80,
              end: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: <Color>[
                      Colors.white.withValues(alpha: 0.22),
                      Colors.white.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onTap,
                borderRadius: radius,
                child: Padding(
                  padding: padding,
                  child: IconTheme(
                    data: const IconThemeData(color: Colors.white),
                    child: DefaultTextStyle.merge(
                      style: theme.textTheme.bodyLarge!.copyWith(
                        color: Colors.white,
                      ),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (onTap != null) card = Pressable(pressedScale: 0.97, child: card);
    if (!animateIn) return card;
    return FadeSlideIn(scale: 0.96, offset: 18, child: card);
  }
}
