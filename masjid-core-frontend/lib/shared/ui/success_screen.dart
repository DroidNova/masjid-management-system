import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/settings/app_settings.dart';
import 'package:masjid_core_frontend/core/settings/speaker.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/app_icons.dart';
import 'package:masjid_core_frontend/shared/ui/tokens.dart';

/// Shows a full-screen "it worked" page: a big tick, a title, and an
/// optional detail (usually the amount). Closes itself after [autoClose],
/// or on tap (rule 9). Reads [title] and [detail] aloud when read-aloud is
/// on. Completes when the page is closed.
Future<void> showSuccess(
  BuildContext context, {
  required String title,
  String? detail,
  IconData icon = AppIcons.done,
  AppTone tone = AppTones.done,
  Duration autoClose = const Duration(seconds: 3),
}) {
  return Navigator.of(context, rootNavigator: true).push<void>(
    PageRouteBuilder<void>(
      reverseTransitionDuration: AppDurations.normal,
      pageBuilder: (_, _, _) => SuccessScreen(
        title: title,
        detail: detail,
        icon: icon,
        tone: tone,
        autoClose: autoClose,
      ),
      transitionsBuilder: (_, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  );
}

class SuccessScreen extends ConsumerStatefulWidget {
  const SuccessScreen({
    super.key,
    required this.title,
    this.detail,
    this.icon = AppIcons.done,
    this.tone = AppTones.done,
    this.autoClose = const Duration(seconds: 3),
  });

  final String title;
  final String? detail;
  final IconData icon;
  final AppTone tone;
  final Duration autoClose;

  @override
  ConsumerState<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends ConsumerState<SuccessScreen> {
  Timer? _timer;
  bool _closed = false;

  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();
    _timer = Timer(widget.autoClose, _close);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !ref.read(appSettingsProvider).readAloud) return;
      final spoken = <String?>[
        widget.title,
        widget.detail,
      ].whereType<String>().join('. ');
      ref
          .read(readAloudControllerProvider.notifier)
          .speak(
            spoken,
            languageCode: Localizations.localeOf(context).languageCode,
          );
    });
  }

  void _close() {
    if (_closed || !mounted) return;
    _closed = true;
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final detail = widget.detail;
    final animate = !MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      backgroundColor: widget.tone.container,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _close,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpace.xl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: animate ? 0.4 : 1, end: 1),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.elasticOut,
                      builder: (context, scale, child) =>
                          Transform.scale(scale: scale, child: child),
                      child: Center(
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: widget.tone.color,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.icon,
                            size: 104,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpace.xl),
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: textTheme.headlineMedium?.copyWith(
                          color: widget.tone.color,
                        ),
                      ),
                    ),
                    if (detail != null) ...<Widget>[
                      const SizedBox(height: AppSpace.s),
                      Text(
                        detail,
                        textAlign: TextAlign.center,
                        style: textTheme.headlineSmall,
                      ),
                    ],
                    const SizedBox(height: AppSpace.xxl),
                    FilledButton(
                      autofocus: true,
                      style: FilledButton.styleFrom(
                        backgroundColor: widget.tone.color,
                      ),
                      onPressed: _close,
                      child: Text(l10n.done),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
