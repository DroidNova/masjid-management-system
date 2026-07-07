import 'package:flutter/material.dart';
import 'package:platform_core_frontend/core/constants/app_constants.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.resizeToAvoidBottomInset,
  });

  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final bool? resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: title == null
          ? null
          : AppBar(
              title: Text(title!),
              actions: actions,
            ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.pageHorizontalPadding,
            vertical: AppConstants.pageVerticalPadding,
          ),
          child: child,
        ),
      ),
    );
  }
}
