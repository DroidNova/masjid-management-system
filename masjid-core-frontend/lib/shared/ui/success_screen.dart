import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/settings/app_settings.dart';
import 'package:masjid_core_frontend/core/settings/speaker.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/app_icons.dart';
import 'package:masjid_core_frontend/shared/ui/geometric_pattern.dart';
import 'package:masjid_core_frontend/shared/ui/motion.dart';
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
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: GeometricPattern(color: widget.tone.color, opacity: 0.07),
            ),
            SafeArea(
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
                          tween: Tween<double>(
                            begin: animate ? 0.4 : 1,
                            end: 1,
                          ),
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.elasticOut,
                          builder: (context, scale, child) =>
                              Transform.scale(scale: scale, child: child),
                          child: Center(
                            child: _Burst(
                              color: widget.tone.color,
                              animate: animate,
                              child: Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: <Color>[
                                      Color.lerp(
                                        widget.tone.color,
                                        Colors.white,
                                        0.15,
                                      )!,
                                      Color.lerp(
                                        widget.tone.color,
                                        Colors.black,
                                        0.2,
                                      )!,
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: widget.tone.color.withValues(
                                        alpha: 0.4,
                                      ),
                                      blurRadius: 28,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  widget.icon,
                                  size: 104,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpace.xl),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 220),
                          child: Semantics(
                            liveRegion: true,
                            child: Text(
                              widget.title,
                              textAlign: TextAlign.center,
                              style: textTheme.headlineMedium?.copyWith(
                                color: widget.tone.color,
                              ),
                            ),
                          ),
                        ),
                        if (detail != null) ...<Widget>[
                          const SizedBox(height: AppSpace.s),
                          FadeSlideIn(
                            delay: const Duration(milliseconds: 340),
                            child: Text(
                              detail,
                              textAlign: TextAlign.center,
                              style: textTheme.headlineSmall,
                            ),
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
          ],
        ),
      ),
    );
  }
}

/// Rings and little dots that fly out from the tick once, like a small
/// celebration.
class _Burst extends StatelessWidget {
  const _Burst({
    required this.color,
    required this.animate,
    required this.child,
  });

  final Color color;
  final bool animate;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!animate) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, t, child) => CustomPaint(
        painter: _BurstPainter(color: color, t: t),
        child: child,
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  _BurstPainter({required this.color, required this.t});

  final Color color;
  final double t;

  static const Color _gold = Color(0xFFE0A526);

  @override
  void paint(Canvas canvas, Size size) {
    if (t >= 1) return;
    final c = size.center(Offset.zero);
    final fade = 1 - t;
    for (final (delay, width) in <(double, double)>[(0, 6), (0.18, 3)]) {
      final p = ((t - delay) / (1 - delay)).clamp(0.0, 1.0);
      if (p <= 0) continue;
      canvas.drawCircle(
        c,
        80 + 110 * p,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = width * (1 - p) + 0.5
          ..color = color.withValues(alpha: 0.45 * (1 - p)),
      );
    }
    const count = 14;
    for (var i = 0; i < count; i++) {
      final angle = i * 2 * math.pi / count + 0.2;
      final distance = 90 + 120 * t + (i.isEven ? 0 : 18 * t);
      final dot = c + Offset(math.cos(angle), math.sin(angle)) * distance;
      canvas.drawCircle(
        dot,
        (i.isEven ? 6 : 4) * fade + 1,
        Paint()..color = (i % 3 == 0 ? _gold : color).withValues(alpha: fade),
      );
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) => old.t != t || old.color != color;
}
