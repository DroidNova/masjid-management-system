import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/tokens.dart';

/// A button that only fires after being pressed and held for [duration].
/// A colour fills it while held; letting go early empties it again.
///
/// Used for actions that cannot be undone. Holding works for people who
/// cannot read a "type LEAVE to confirm" box, and a pocket tap never fires
/// it. Keyboard: hold Enter or Space. Screen readers: long-press action.
class HoldToConfirmButton extends StatefulWidget {
  const HoldToConfirmButton({
    super.key,
    required this.label,
    required this.onConfirmed,
    this.icon,
    this.tone = AppTones.danger,
    this.duration = AppDurations.holdToConfirm,
  });

  final String label;
  final IconData? icon;

  /// Null disables the button.
  final VoidCallback? onConfirmed;
  final AppTone tone;
  final Duration duration;

  @override
  State<HoldToConfirmButton> createState() => _HoldToConfirmButtonState();
}

class _HoldToConfirmButtonState extends State<HoldToConfirmButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: widget.duration,
    reverseDuration: AppDurations.slow,
  )..addStatusListener(_onStatus);

  bool get _enabled => widget.onConfirmed != null;

  void _onStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    HapticFeedback.heavyImpact();
    _progress.value = 0;
    widget.onConfirmed?.call();
  }

  void _start() {
    if (!_enabled) return;
    HapticFeedback.selectionClick();
    _progress.forward();
  }

  void _release() {
    if (_progress.isAnimating && _progress.status == AnimationStatus.forward) {
      _progress.reverse();
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    final key = event.logicalKey;
    if (key != LogicalKeyboardKey.enter &&
        key != LogicalKeyboardKey.numpadEnter &&
        key != LogicalKeyboardKey.space) {
      return KeyEventResult.ignored;
    }
    if (event is KeyDownEvent) _start();
    if (event is KeyUpEvent) _release();
    return KeyEventResult.handled;
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final tone = widget.tone;
    final foreground = _enabled ? tone.color : AppColors.textSecondary;
    final icon = widget.icon;

    return Semantics(
      button: true,
      enabled: _enabled,
      label: l10n.holdTo(widget.label),
      onLongPress: widget.onConfirmed,
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Focus(
            onKeyEvent: _onKey,
            child: Builder(
              builder: (context) {
                final focused = Focus.of(context).hasFocus;
                return MouseRegion(
                  cursor: _enabled
                      ? SystemMouseCursors.click
                      : SystemMouseCursors.basic,
                  child: Listener(
                    onPointerDown: (_) => _start(),
                    onPointerUp: (_) => _release(),
                    onPointerCancel: (_) => _release(),
                    child: Container(
                      height: AppSizes.minTouch,
                      decoration: BoxDecoration(
                        color: _enabled ? tone.container : AppColors.background,
                        borderRadius: BorderRadius.circular(AppRadius.m),
                        border: Border.all(
                          color: foreground,
                          width: focused ? 3 : 2,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          AnimatedBuilder(
                            animation: _progress,
                            builder: (context, _) => FractionallySizedBox(
                              alignment: AlignmentDirectional.centerStart,
                              widthFactor: _progress.value,
                              child: ColoredBox(
                                color: tone.color.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              if (icon != null) ...<Widget>[
                                Icon(icon, color: foreground),
                                const SizedBox(width: AppSpace.s),
                              ],
                              Flexible(
                                child: Text(
                                  widget.label,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.labelLarge?.copyWith(
                                    color: foreground,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpace.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.touch_app_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpace.xs),
              Flexible(
                child: Text(
                  l10n.pressAndHold,
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
