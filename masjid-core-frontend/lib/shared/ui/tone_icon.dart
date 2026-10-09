import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/shared/ui/tokens.dart';

/// An icon on a soft coloured square: the app's main picture element.
class ToneIcon extends StatelessWidget {
  const ToneIcon({
    super.key,
    required this.icon,
    required this.tone,
    this.size = 48,
    this.circle = false,
  });

  final IconData icon;
  final AppTone tone;
  final double size;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tone.container,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(size * 0.3),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: size * 0.55, color: tone.color),
    );
  }
}
