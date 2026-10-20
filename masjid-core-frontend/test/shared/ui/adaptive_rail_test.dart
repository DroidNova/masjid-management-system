import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

import 'ui_test_helpers.dart';

/// The side rail (tablet width) on a short window, like a phone turned on
/// its side: entries must not overlap; they scroll, and dots say so.
void main() {
  Widget frame() => AdaptiveScaffold(
    destinations: const <AppDestination>[
      AppDestination(icon: Icons.home, label: 'Home'),
      AppDestination(icon: Icons.list, label: 'Requests'),
      AppDestination(icon: Icons.mosque, label: 'Masjids'),
      AppDestination(icon: Icons.people, label: 'Users'),
      AppDestination(icon: Icons.person, label: 'Profile'),
    ],
    selectedIndex: 0,
    onSelected: (_) {},
    title: const Text('Super admin'),
    body: const SizedBox.shrink(),
  );

  testWidgets('a short window scrolls the rail and shows more-dots', (
    tester,
  ) async {
    await pumpUi(tester, frame(), size: const Size(800, 360));

    final users = tester.getRect(find.text('Users'));
    final profile = tester.getRect(find.text('Profile'));
    expect(users.overlaps(profile), isFalse);
    expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);

    // Scrolled to the end: the dots move to the top.
    await tester.drag(find.byType(NavigationRail), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);
    expect(
      tester.getRect(find.byIcon(Icons.more_horiz_rounded)).top,
      lessThan(60),
    );
  });

  testWidgets('a tall window keeps Profile pinned and shows no dots', (
    tester,
  ) async {
    await pumpUi(tester, frame(), size: const Size(800, 1000));

    expect(find.byIcon(Icons.more_horiz_rounded), findsNothing);
    expect(tester.getRect(find.text('Profile')).top, greaterThan(800));
  });
}
