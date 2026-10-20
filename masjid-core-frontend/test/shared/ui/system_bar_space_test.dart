import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// The app draws behind the system navigation bar. Pages keep their end
/// above it, and never add the space twice.
void main() {
  Widget withBar(double bar, Widget child) => MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(padding: EdgeInsets.only(bottom: bar)),
      child: Material(child: child),
    ),
  );

  EdgeInsets paddingOf(WidgetTester tester) =>
      tester
              .widget<Padding>(
                find
                    .descendant(
                      of: find.byType(PageBody),
                      matching: find.byType(Padding),
                    )
                    .first,
              )
              .padding
          as EdgeInsets;

  testWidgets('PageBody keeps its end above the system buttons', (
    tester,
  ) async {
    await tester.pumpWidget(withBar(48, const PageBody(child: Text('x'))));

    expect(paddingOf(tester).bottom, AppSpace.l + 48);
  });

  testWidgets('PageBody adds nothing inside SafeArea (already clear)', (
    tester,
  ) async {
    await tester.pumpWidget(
      withBar(48, const SafeArea(child: PageBody(child: Text('x')))),
    );

    expect(paddingOf(tester).bottom, AppSpace.l);
  });

  testWidgets('the keypad layout pins its button above the system buttons', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      withBar(
        48,
        SafeArea(
          child: KeypadPageLayout(
            content: (compact) => <Widget>[
              Text(compact ? 'compact' : 'roomy'),
              const SizedBox(height: 900),
            ],
            action: FilledButton(onPressed: () {}, child: const Text('Go')),
          ),
        ),
      ),
    );

    // A short screen gets the compact header and keypad.
    expect(find.text('compact'), findsOneWidget);
    // The button ends above the 48 px bar, even with tall content.
    final button = tester.getRect(find.byType(FilledButton));
    expect(button.bottom, lessThanOrEqualTo(640 - 48));
  });
}
