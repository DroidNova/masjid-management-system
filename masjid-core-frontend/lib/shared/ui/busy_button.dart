import 'package:flutter/material.dart';

/// The main button of a screen: full width, icon + label, and a spinner in
/// place of the icon while its action runs (it cannot be pressed twice).
class BusyButton extends StatelessWidget {
  const BusyButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.busy = false,
    this.color,
  });

  final String label;
  final IconData icon;

  /// Null disables the button.
  final VoidCallback? onPressed;
  final bool busy;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      style: color == null
          ? null
          : FilledButton.styleFrom(backgroundColor: color),
      onPressed: busy ? null : onPressed,
      icon: busy
          ? const SizedBox.square(
              dimension: 22,
              child: CircularProgressIndicator(strokeWidth: 3),
            )
          : Icon(icon),
      label: Text(label),
    );
  }
}
