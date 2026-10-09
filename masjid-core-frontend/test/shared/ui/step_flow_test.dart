import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

import 'ui_test_helpers.dart';

class _Flow extends StatefulWidget {
  const _Flow({required this.onFinish});

  final Future<void> Function() onFinish;

  @override
  State<_Flow> createState() => _FlowState();
}

class _FlowState extends State<_Flow> {
  bool ready = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StepFlow(
        finishLabel: 'Save',
        onFinish: widget.onFinish,
        steps: <FlowStep>[
          FlowStep(
            title: 'First',
            icon: AppIcons.money,
            builder: (_) => const Text('one'),
          ),
          FlowStep(
            title: 'Second',
            icon: AppIcons.calendar,
            canContinue: ready,
            builder: (_) => TextButton(
              onPressed: () => setState(() => ready = true),
              child: const Text('make ready'),
            ),
          ),
        ],
      ),
    );
  }
}

Finder _filled(String label) => find.widgetWithText(FilledButton, label);

void main() {
  testWidgets('Next moves on, Back returns, Save waits until ready', (
    tester,
  ) async {
    var finished = 0;
    await pumpUi(tester, _Flow(onFinish: () async => finished++));

    expect(find.text('First'), findsOneWidget);
    expect(find.text('Back'), findsNothing);
    await tester.tap(_filled('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Second'), findsOneWidget);
    expect(tester.widget<FilledButton>(_filled('Save')).onPressed, isNull);

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.text('First'), findsOneWidget);

    await tester.tap(_filled('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('make ready'));
    await tester.pumpAndSettle();
    await tester.tap(_filled('Save'));
    await tester.pumpAndSettle();
    expect(finished, 1);
  });

  testWidgets('the system back button goes to the previous step', (
    tester,
  ) async {
    await pumpUi(tester, _Flow(onFinish: () async {}));
    await tester.tap(_filled('Next'));
    await tester.pumpAndSettle();

    await tester.state<NavigatorState>(find.byType(Navigator)).maybePop();
    await tester.pumpAndSettle();

    expect(find.text('First'), findsOneWidget);
  });

  testWidgets('a failed save shows the reason and stays on the step', (
    tester,
  ) async {
    await pumpUi(
      tester,
      _Flow(
        onFinish: () async => throw const ApiException(
          message: 'Amount is too large',
          code: 'VALIDATION_ERROR',
        ),
      ),
    );
    await tester.tap(_filled('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('make ready'));
    await tester.pumpAndSettle();
    await tester.tap(_filled('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Amount is too large'), findsOneWidget);
    expect(find.text('Second'), findsOneWidget);
  });
}
