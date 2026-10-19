import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Motion helpers. Every animation here is short, plays once, and is
/// skipped when the phone asks for less motion (accessibility setting), so
/// the app feels alive without slowing anyone down.

/// True when the person turned animations off in phone settings.
bool reduceMotion(BuildContext context) =>
    MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// Fades and slides [child] up into place when it first appears. Use
/// [delay] (or [FadeSlideIn.stagger]) so items in a list arrive one after
/// another.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 480),
    this.offset = 28,
    this.scale = 1,
  });

  /// The usual delay for the [index]th item of a list: 55 ms apart, capped
  /// so long lists never wait.
  FadeSlideIn.stagger({
    Key? key,
    required int index,
    required Widget child,
    Duration base = Duration.zero,
    double offset = 28,
  }) : this(
         key: key,
         delay: base + Duration(milliseconds: 55 * math.min(index, 9)),
         offset: offset,
         child: child,
       );

  final Widget child;
  final Duration delay;
  final Duration duration;

  /// How far below its place the child starts (logical pixels).
  final double offset;

  /// Starting scale (1 = no zoom). 0.9 gives a gentle "pop".
  final double scale;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );
  Timer? _timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller.isAnimating || _controller.isCompleted) return;
    if (reduceMotion(context)) {
      _controller.value = 1;
    } else if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      _timer ??= Timer(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      child: widget.child,
      builder: (context, child) {
        final t = _curve.value;
        final scale = widget.scale + (1 - widget.scale) * t;
        return Opacity(
          opacity: t.clamp(0, 1),
          child: Transform.translate(
            offset: Offset(0, widget.offset * (1 - t)),
            child: scale == 1
                ? child
                : Transform.scale(scale: scale, child: child),
          ),
        );
      },
    );
  }
}

/// Shrinks [child] a little while a finger is on it and springs back on
/// release, so every big button feels pressable. It only listens to the
/// pointer; taps still go to the child's own InkWell or button.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.pressedScale = 0.95,
    this.enabled = true,
  });

  final Widget child;
  final double pressedScale;
  final bool enabled;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool down) {
    if (_down != down && mounted) setState(() => _down = down);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || reduceMotion(context)) return widget.child;
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _down ? widget.pressedScale : 1,
        duration: Duration(milliseconds: _down ? 90 : 260),
        curve: _down ? Curves.easeOut : Curves.elasticOut,
        child: widget.child,
      ),
    );
  }
}

/// Counts a number up from 0 (first time) or from the old value (later)
/// to [value], then shows it with [format].
class CountUp extends StatelessWidget {
  const CountUp({
    super.key,
    required this.value,
    required this.builder,
    this.duration = const Duration(milliseconds: 1100),
  });

  final double value;
  final Widget Function(BuildContext context, double value) builder;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    if (reduceMotion(context) || value == 0) return builder(context, value);
    final whole = value == value.roundToDouble();
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutExpo,
      builder: (context, current, _) => builder(
        context,
        // Whole-rupee targets count in whole rupees (no flickering paise).
        whole ? current.roundToDouble() : current,
      ),
    );
  }
}

/// A soft glow that slowly breathes behind [child] (the next namaz icon,
/// a "due" warning) a few times, then rests, so it catches the eye without
/// running forever (battery). Skipped when animations are off.
class Breathing extends StatefulWidget {
  const Breathing({
    super.key,
    required this.child,
    required this.color,
    this.size = 72,
    this.period = const Duration(milliseconds: 2400),
    this.breaths = 3,
  });

  final Widget child;
  final Color color;
  final double size;
  final Duration period;

  /// How many times to grow and shrink before resting.
  final int breaths;

  @override
  State<Breathing> createState() => _BreathingState();
}

class _BreathingState extends State<Breathing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.period,
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotion(context)) {
      _controller
        ..stop()
        ..value = 0.5;
    } else if (!_started) {
      _started = true;
      _breathe(widget.breaths);
    }
  }

  Future<void> _breathe(int left) async {
    for (var i = 0; i < left && mounted; i++) {
      await _controller.forward().orCancel.catchError((_) {});
      if (!mounted) return;
      await _controller.reverse().orCancel.catchError((_) {});
    }
    // Rest half-open so the glow stays visible.
    if (mounted) await _controller.animateTo(0.5).orCancel.catchError((_) {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The child alone decides the size; the glow spills around it without
    // pushing anything else on the page.
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: <Widget>[
        Positioned.fill(
          child: OverflowBox(
            maxWidth: widget.size,
            maxHeight: widget.size,
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final t = Curves.easeInOut.transform(_controller.value);
                  return Container(
                    width: widget.size * (0.7 + 0.3 * t),
                    height: widget.size * (0.7 + 0.3 * t),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.color.withValues(alpha: 0.10 + 0.14 * t),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}
