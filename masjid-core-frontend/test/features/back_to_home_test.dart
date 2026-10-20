import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/features/main_shell/back_to_home.dart';

/// Android back on a tab: a page opened in the tab closes first, then the
/// app goes to Home, and only back on Home would leave the app.
void main() {
  late GoRouter router;

  Future<void> pumpApp(WidgetTester tester) async {
    router = GoRouter(
      initialLocation: '/home',
      routes: <RouteBase>[
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => BackToHome(
            navigationShell: shell,
            child: Scaffold(body: shell),
          ),
          branches: <StatefulShellBranch>[
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/home',
                  builder: (context, state) => const Text('Home page'),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/news',
                  builder: (context, state) => const Text('News page'),
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'item',
                      builder: (context, state) => const Text('News item'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  }

  Future<void> pressBack(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  }

  testWidgets('back on another tab goes Home instead of leaving', (
    tester,
  ) async {
    await pumpApp(tester);
    router.go('/news');
    await tester.pumpAndSettle();
    expect(find.text('News page'), findsOneWidget);

    await pressBack(tester);
    expect(find.text('Home page'), findsOneWidget);
  });

  testWidgets('a page opened in a tab closes first, then Home', (tester) async {
    await pumpApp(tester);
    router.go('/news');
    await tester.pumpAndSettle();
    router.push('/news/item');
    await tester.pumpAndSettle();
    expect(find.text('News item'), findsOneWidget);

    await pressBack(tester);
    expect(find.text('News page'), findsOneWidget);

    await pressBack(tester);
    expect(find.text('Home page'), findsOneWidget);
  });
}
