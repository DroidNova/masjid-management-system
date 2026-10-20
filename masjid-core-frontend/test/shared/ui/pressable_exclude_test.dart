import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

import 'ui_test_helpers.dart';

/// A tappable card shrinks while pressed, but not when the press is on a
/// button inside it (the speaker on the namaz card).
void main() {
  Future<void> pumpCard(WidgetTester tester) => pumpUi(
    tester,
    Scaffold(
      body: Center(
        child: HeroCard(
          tone: AppTones.namaz,
          onTap: () {},
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Next namaz'),
              ReadAloudButton(text: 'Asr 17:05'),
            ],
          ),
        ),
      ),
    ),
    // Read-aloud is on by default; keep it on.
    prefs: const <String, Object>{'settings.language': 'en'},
  );

  double cardScale(WidgetTester tester) => tester
      .widget<AnimatedScale>(
        find.ancestor(
          of: find.text('Next namaz'),
          matching: find.byType(AnimatedScale),
        ),
      )
      .scale;

  testWidgets('pressing the speaker leaves the card still', (tester) async {
    await pumpCard(tester);

    final press = await tester.startGesture(
      tester.getCenter(find.byType(ReadAloudButton)),
    );
    await tester.pump(const Duration(milliseconds: 50));
    expect(cardScale(tester), 1);
    await press.up();
    await tester.pumpAndSettle();
  });

  testWidgets('pressing the card itself still shrinks it', (tester) async {
    await pumpCard(tester);

    final press = await tester.startGesture(
      tester.getCenter(find.text('Next namaz')),
    );
    await tester.pump(const Duration(milliseconds: 50));
    expect(cardScale(tester), lessThan(1));
    await press.up();
    await tester.pumpAndSettle();
  });
}
