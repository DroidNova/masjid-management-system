import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/features/dev_gallery/presentation/design_gallery_screen.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

import '../../shared/ui/ui_test_helpers.dart';

/// Every design-system widget must lay out without overflow in every
/// language (Urdu is right-to-left) at phone, tablet, and desktop widths,
/// including with large text.
void main() {
  // The loading placeholders pulse forever; with animations off (a device
  // accessibility setting they respect) the page can settle.
  setUp(() {
    TestWidgetsFlutterBinding
        .instance
        .platformDispatcher
        .accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(
      disableAnimations: true,
    );
  });
  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher
        .clearAccessibilityFeaturesTestValue();
  });

  const sizes = <String, Size>{
    'phone': Size(360, 800),
    'tablet': Size(800, 1000),
    'desktop': Size(1280, 900),
  };
  const languages = <String>['en', 'hi', 'ur'];

  for (final language in languages) {
    for (final size in sizes.entries) {
      testWidgets('gallery lays out in $language on a ${size.key}', (
        tester,
      ) async {
        await pumpUi(
          tester,
          const DesignGalleryScreen(),
          locale: Locale(language),
          size: size.value,
        );
        expect(tester.takeException(), isNull);
        expect(find.byType(ActionTile), findsWidgets);
      });
    }
  }

  testWidgets('gallery lays out on a phone with a large device font', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpUi(
      tester,
      const DesignGalleryScreen(),
      size: const Size(360, 800),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('the danger dialog lays out right-to-left in Urdu', (
    tester,
  ) async {
    await pumpUi(
      tester,
      const DesignGalleryScreen(),
      locale: const Locale('ur'),
      size: const Size(360, 800),
    );
    await tester.scrollUntilVisible(
      find.text('Danger dialog'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Danger dialog'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.byType(HoldToConfirmButton),
      ),
      findsOneWidget,
    );
    // Urdu "Cancel" from the app's translations.
    expect(find.text('منسوخ کریں'), findsOneWidget);
  });
}
