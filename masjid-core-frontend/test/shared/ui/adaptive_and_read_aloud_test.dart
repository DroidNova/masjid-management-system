import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

import 'ui_test_helpers.dart';

const List<AppDestination> _destinations = <AppDestination>[
  AppDestination(icon: AppIcons.home, label: 'Home'),
  AppDestination(icon: AppIcons.money, label: 'Money'),
  AppDestination(icon: AppIcons.profile, label: 'Profile'),
];

class _Shell extends StatefulWidget {
  const _Shell();

  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  int index = 0;

  @override
  Widget build(BuildContext context) => AdaptiveScaffold(
    destinations: _destinations,
    selectedIndex: index,
    onSelected: (value) => setState(() => index = value),
    body: Text('page $index'),
  );
}

void main() {
  group('AdaptiveScaffold', () {
    testWidgets('phones get a bottom bar', (tester) async {
      await pumpUi(tester, const _Shell(), size: const Size(400, 800));

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('page 2'), findsOneWidget);
    });

    testWidgets('tablets get a rail with Profile pinned at the bottom', (
      tester,
    ) async {
      await pumpUi(tester, const _Shell(), size: const Size(800, 900));

      expect(find.byType(NavigationBar), findsNothing);
      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.extended, isFalse);
      expect(rail.destinations, hasLength(2));

      final profileY = tester.getCenter(find.text('Profile')).dy;
      expect(profileY, greaterThan(tester.getCenter(find.text('Money')).dy));
      expect(profileY, greaterThan(700));

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('page 2'), findsOneWidget);
      expect(
        tester
            .widget<NavigationRail>(find.byType(NavigationRail))
            .selectedIndex,
        isNull,
      );
    });

    testWidgets('desktop gets the wide side menu', (tester) async {
      await pumpUi(tester, const _Shell(), size: const Size(1300, 900));
      expect(
        tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
        isTrue,
      );
    });
  });

  group('ReadAloudButton', () {
    testWidgets('reads the text in the app language', (tester) async {
      final speaker = FakeSpeaker();
      await pumpUi(
        tester,
        const Scaffold(body: ReadAloudButton(text: 'اعلان')),
        locale: const Locale('ur'),
        speaker: speaker,
      );

      await tester.tap(find.byIcon(AppIcons.readAloud));
      await tester.pumpAndSettle();

      expect(speaker.spoken, <(String, String)>[('اعلان', 'ur')]);
    });

    testWidgets('is hidden when read-aloud is turned off', (tester) async {
      await pumpUi(
        tester,
        const Scaffold(body: ReadAloudButton(text: 'hello')),
        prefs: const <String, Object>{'settings.readAloud': false},
      );
      expect(find.byType(IconButton), findsNothing);
    });
  });
}
