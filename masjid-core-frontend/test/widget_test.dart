import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platform_core_frontend/core/widgets/app_scaffold.dart';

void main() {
  testWidgets('AppScaffold renders title and body', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AppScaffold(
          title: 'Test Title',
          child: Text('Test Body'),
        ),
      ),
    );

    expect(find.text('Test Title'), findsOneWidget);
    expect(find.text('Test Body'), findsOneWidget);
  });
}
