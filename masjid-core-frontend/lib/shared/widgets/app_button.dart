import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.loading = false,
    this.isOutlined = false,
    this.icon,
    this.fullWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool loading;
  final bool isOutlined;
  final IconData? icon;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final effectiveLoading = isLoading || loading;
    final effectiveOnPressed = effectiveLoading ? null : onPressed;
    final content = effectiveLoading
        ? const SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : _ButtonLabel(label: label, icon: icon);

    final button = isOutlined
        ? OutlinedButton(onPressed: effectiveOnPressed, child: content)
        : FilledButton(onPressed: effectiveOnPressed, child: content);

    if (!fullWidth) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}

class _ButtonLabel extends StatelessWidget {
  const _ButtonLabel({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final iconData = icon;
    if (iconData == null) return Text(label);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(iconData, size: 20),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
