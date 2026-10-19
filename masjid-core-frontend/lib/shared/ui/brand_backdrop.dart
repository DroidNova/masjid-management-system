import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:masjid_core_frontend/shared/ui/geometric_pattern.dart';
import 'package:masjid_core_frontend/shared/ui/motion.dart';
import 'package:masjid_core_frontend/shared/ui/tokens.dart';

/// The deep green welcome header: gradient, star pattern, and a glowing
/// round picture in the middle. [child] sits under the picture (title and
/// tagline, in white). Used on the start and language screens.
class BrandBackdrop extends StatelessWidget {
  const BrandBackdrop({
    super.key,
    required this.icon,
    this.child,
    this.top,
    this.tone = AppTones.brand,
  });

  final IconData icon;
  final Widget? child;

  /// A row above the picture (for example the language button).
  final Widget? top;
  final AppTone tone;

  @override
  Widget build(BuildContext context) {
    final darker = Color.lerp(tone.color, Colors.black, 0.45)!;
    final lighter = Color.lerp(tone.color, Colors.white, 0.1)!;
    final padding = MediaQuery.paddingOf(context);
    final extraTop = top;
    final body = child;

    // White status bar icons on the dark green.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ClipPath(
        clipper: _CurvedBottom(),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[darker, tone.color, lighter],
            ),
          ),
          child: Stack(
            children: <Widget>[
              const Positioned.fill(
                child: GeometricPattern(opacity: 0.10, cell: 64),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpace.l,
                  padding.top + AppSpace.s,
                  AppSpace.l,
                  AppSpace.xxl + AppSpace.l,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    ?extraTop,
                    const SizedBox(height: AppSpace.m),
                    FadeSlideIn(
                      scale: 0.7,
                      offset: 0,
                      duration: const Duration(milliseconds: 700),
                      child: Center(
                        child: Breathing(
                          color: Colors.white,
                          size: 150,
                          child: Container(
                            width: 104,
                            height: 104,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 24,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(icon, size: 60, color: tone.color),
                          ),
                        ),
                      ),
                    ),
                    if (body != null) ...<Widget>[
                      const SizedBox(height: AppSpace.m),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 150),
                        child: DefaultTextStyle.merge(
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                          child: IconTheme(
                            data: const IconThemeData(color: Colors.white),
                            child: body,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A gentle downward curve along the bottom edge.
class _CurvedBottom extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const depth = 36.0;
    return Path()
      ..lineTo(0, size.height - depth)
      ..quadraticBezierTo(
        size.width / 2,
        size.height + depth * 0.6,
        size.width,
        size.height - depth,
      )
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(_CurvedBottom oldClipper) => false;
}
