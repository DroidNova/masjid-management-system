import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

import 'ui_test_helpers.dart';

void main() {
  Future<TextEditingController> pump(WidgetTester tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await pumpUi(
      tester,
      Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: NumberFormField(
            controller: controller,
            label: 'Number of family members (optional)',
            icon: AppIcons.people,
            min: 1,
            max: 50,
            startAt: 4,
          ),
        ),
      ),
    );
    return controller;
  }

  testWidgets('takes typed digits only', (tester) async {
    final controller = await pump(tester);

    await tester.enterText(find.byType(TextFormField), '7a');
    expect(controller.text, '7');
  });

  testWidgets('the wheel starts at the default and fills the field', (
    tester,
  ) async {
    final controller = await pump(tester);

    await tester.tap(find.byTooltip('Scroll to choose'));
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoPicker), findsOneWidget);

    // One row down from 4 (rows are 48 px).
    await tester.drag(find.byType(CupertinoPicker), const Offset(0, -48));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(controller.text, '5');
  });

  testWidgets('the wheel starts at what was typed', (tester) async {
    final controller = await pump(tester);
    await tester.enterText(find.byType(TextFormField), '9');

    await tester.tap(find.byTooltip('Scroll to choose'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(controller.text, '9');
  });
}
