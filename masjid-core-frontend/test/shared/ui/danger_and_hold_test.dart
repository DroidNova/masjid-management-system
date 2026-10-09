import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

import 'ui_test_helpers.dart';

/// Presses and holds [finder] for [duration], then lets go.
Future<void> _hold(
  WidgetTester tester,
  Finder finder,
  Duration duration,
) async {
  final gesture = await tester.startGesture(tester.getCenter(finder));
  // The first frame starts the animation clock; the second lets time pass.
  await tester.pump();
  await tester.pump(duration);
  await gesture.up();
  await tester.pumpAndSettle();
}

class _DangerHost extends StatefulWidget {
  const _DangerHost({required this.onConfirm});

  final Future<void> Function() onConfirm;

  @override
  State<_DangerHost> createState() => _DangerHostState();
}

class _DangerHostState extends State<_DangerHost> {
  bool? result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FilledButton(
          onPressed: () async {
            final value = await showDangerDialog(
              context,
              title: 'Leave masjid?',
              subject: 'Barota Masjid',
              confirmLabel: 'Leave',
              points: const <DangerPoint>[
                DangerPoint(icon: AppIcons.mosque, text: 'You lose access.'),
              ],
              onConfirm: widget.onConfirm,
            );
            setState(() => result = value);
          },
          child: const Text('open'),
        ),
      ),
    );
  }
}

void main() {
  group('HoldToConfirmButton', () {
    testWidgets('a tap or a short press does nothing', (tester) async {
      var fired = 0;
      await pumpUi(
        tester,
        Scaffold(
          body: HoldToConfirmButton(label: 'Leave', onConfirmed: () => fired++),
        ),
      );

      await tester.tap(find.text('Leave'));
      await tester.pumpAndSettle();
      await _hold(tester, find.text('Leave'), const Duration(seconds: 1));
      expect(fired, 0);
    });

    testWidgets('holding for two seconds fires once', (tester) async {
      var fired = 0;
      await pumpUi(
        tester,
        Scaffold(
          body: HoldToConfirmButton(label: 'Leave', onConfirmed: () => fired++),
        ),
      );

      await _hold(
        tester,
        find.text('Leave'),
        const Duration(milliseconds: 2100),
      );
      expect(fired, 1);
    });

    testWidgets('a disabled button never fires', (tester) async {
      await pumpUi(
        tester,
        const Scaffold(
          body: HoldToConfirmButton(label: 'Leave', onConfirmed: null),
        ),
      );
      await _hold(tester, find.text('Leave'), const Duration(seconds: 3));
      expect(tester.takeException(), isNull);
    });
  });

  group('showDangerDialog', () {
    testWidgets('Cancel closes it without running the action', (tester) async {
      var ran = false;
      await pumpUi(tester, _DangerHost(onConfirm: () async => ran = true));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Barota Masjid'), findsOneWidget);
      expect(find.text('You lose access.'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(ran, isFalse);
      expect(find.text('Barota Masjid'), findsNothing);
      expect(
        tester.state<_DangerHostState>(find.byType(_DangerHost)).result,
        isFalse,
      );
    });

    testWidgets('holding Leave runs the action and returns true', (
      tester,
    ) async {
      var ran = 0;
      await pumpUi(tester, _DangerHost(onConfirm: () async => ran++));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await _hold(
        tester,
        find.text('Leave'),
        const Duration(milliseconds: 2100),
      );

      expect(ran, 1);
      expect(find.text('Barota Masjid'), findsNothing);
      expect(
        tester.state<_DangerHostState>(find.byType(_DangerHost)).result,
        isTrue,
      );
    });

    testWidgets('a failure shows the server reason and returns false', (
      tester,
    ) async {
      await pumpUi(
        tester,
        _DangerHost(
          onConfirm: () async => throw const ApiException(
            message: 'You are the last committee member.',
            code: 'CANNOT_LEAVE_MASJID',
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await _hold(
        tester,
        find.text('Leave'),
        const Duration(milliseconds: 2100),
      );

      expect(find.text('You are the last committee member.'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(
        tester.state<_DangerHostState>(find.byType(_DangerHost)).result,
        isFalse,
      );
    });
  });
}
