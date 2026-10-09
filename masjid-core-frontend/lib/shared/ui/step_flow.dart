import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/core/errors/error_text.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/app_icons.dart';
import 'package:masjid_core_frontend/shared/ui/responsive.dart';
import 'package:masjid_core_frontend/shared/ui/tokens.dart';
import 'package:masjid_core_frontend/shared/ui/tone_icon.dart';

/// One question in a [StepFlow].
@immutable
class FlowStep {
  const FlowStep({
    required this.title,
    required this.icon,
    required this.builder,
    this.canContinue = true,
    this.validate,
  });

  final String title;
  final IconData icon;
  final WidgetBuilder builder;

  /// False keeps "Next" disabled (for example, no amount entered yet).
  /// The parent rebuilds the flow with a new value when its form changes.
  final bool canContinue;

  /// Runs when "Next" is pressed; returning false stays on this step (for
  /// example after a [Form] shows its field messages).
  final bool Function()? validate;
}

/// A form asked one question at a time (rule 7): progress dots, the step's
/// picture and title, its content, and big Back / Next buttons.
///
/// The system back button (and iOS swipe, browser back) goes to the
/// previous step before leaving the screen. [onFinish] runs on the last
/// step's button; if it throws, the error shows and the person stays put.
class StepFlow extends StatefulWidget {
  const StepFlow({
    super.key,
    required this.steps,
    required this.onFinish,
    required this.finishLabel,
    this.finishIcon = AppIcons.done,
    this.tone = AppTones.brand,
  });

  final List<FlowStep> steps;
  final Future<void> Function() onFinish;
  final String finishLabel;
  final IconData finishIcon;
  final AppTone tone;

  @override
  State<StepFlow> createState() => StepFlowState();
}

class StepFlowState extends State<StepFlow> {
  int _index = 0;
  bool _busy = false;

  int get index => _index;
  bool get _isLast => _index == widget.steps.length - 1;

  void back() {
    if (_index > 0 && !_busy) setState(() => _index--);
  }

  /// Jumps to step [index] (a review page's "Edit" buttons).
  void goTo(int index) {
    if (_busy || index < 0 || index >= widget.steps.length) return;
    setState(() => _index = index);
  }

  Future<void> next() async {
    final step = widget.steps[_index];
    if (_busy || !step.canContinue) return;
    if (step.validate?.call() == false) return;
    if (!_isLast) {
      setState(() => _index++);
      return;
    }
    setState(() => _busy = true);
    try {
      await widget.onFinish();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorText(AppLocalizations.of(context), error)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final step = widget.steps[_index];
    final total = widget.steps.length;

    return PopScope(
      canPop: _index == 0 && !_busy,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) back();
      },
      child: Column(
        children: <Widget>[
          PageBody.form(
            padding: const EdgeInsets.fromLTRB(
              AppSpace.l,
              AppSpace.l,
              AppSpace.l,
              0,
            ),
            child: Column(
              children: <Widget>[
                Semantics(
                  label: l10n.stepOf(_index + 1, total),
                  child: StepDots(
                    count: total,
                    index: _index,
                    color: widget.tone.color,
                  ),
                ),
                const SizedBox(height: AppSpace.l),
                Row(
                  children: <Widget>[
                    ToneIcon(icon: step.icon, tone: widget.tone, size: 56),
                    const SizedBox(width: AppSpace.m),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(step.title, style: textTheme.headlineSmall),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: PageBody.form(
                child: AnimatedSwitcher(
                  duration: AppDurations.normal,
                  child: KeyedSubtree(
                    key: ValueKey<int>(_index),
                    child: Builder(builder: step.builder),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: PageBody.form(
              child: Row(
                children: <Widget>[
                  if (_index > 0) ...<Widget>[
                    OutlinedButton.icon(
                      onPressed: _busy ? null : back,
                      icon: const Icon(AppIcons.back),
                      label: Text(l10n.back),
                    ),
                    const SizedBox(width: AppSpace.m),
                  ],
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: widget.tone.color,
                      ),
                      onPressed: step.canContinue && !_busy ? next : null,
                      icon: _busy
                          ? const SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              ),
                            )
                          : Icon(_isLast ? widget.finishIcon : AppIcons.next),
                      label: Text(_isLast ? widget.finishLabel : l10n.next),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Progress dots: done steps filled, the current one a wide pill.
class StepDots extends StatelessWidget {
  const StepDots({
    super.key,
    required this.count,
    required this.index,
    required this.color,
  });

  final int count;
  final int index;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(count, (i) {
        final current = i == index;
        return AnimatedContainer(
          duration: AppDurations.normal,
          margin: const EdgeInsets.symmetric(horizontal: AppSpace.xs),
          width: current ? 28 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: i <= index ? color : AppColors.border,
            borderRadius: BorderRadius.circular(5),
          ),
        );
      }),
    );
  }
}
