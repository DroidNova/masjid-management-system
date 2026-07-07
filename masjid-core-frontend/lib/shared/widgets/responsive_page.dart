import 'package:flutter/material.dart';

class ResponsivePage extends StatelessWidget {
  const ResponsivePage({
    super.key,
    required this.child,
    this.maxWidth = 800,
    this.padding = const EdgeInsets.all(16),
    this.scrollable = false,
  });

  const ResponsivePage.form({
    super.key,
    required this.child,
    this.maxWidth = 700,
    this.padding = const EdgeInsets.all(20),
  }) : scrollable = true;

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final content = SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );

    if (!scrollable) return content;
    return SingleChildScrollView(child: content);
  }
}
