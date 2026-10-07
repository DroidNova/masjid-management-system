import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/features/masjid_request/data/masjid_request_repository.dart';
import 'package:masjid_core_frontend/features/masjid_request/presentation/masjid_request_form_screen.dart';
import 'package:mocktail/mocktail.dart';

class _MockMasjidRequestRepository extends Mock
    implements MasjidRequestRepository {}

Future<void> _pump(WidgetTester tester, MasjidRequestRepository repository) {
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        masjidRequestRepositoryProvider.overrideWithValue(repository),
      ],
      child: const MaterialApp(home: MasjidRequestFormScreen()),
    ),
  );
}

Future<void> _tapText(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text));
  await tester.pumpAndSettle();
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('submitting an empty form shows the field messages', (
    tester,
  ) async {
    final repository = _MockMasjidRequestRepository();
    await _pump(tester, repository);

    await _tapText(tester, 'Submit Request');

    for (final message in <String>[
      'Masjid name is required.',
      'State is required.',
      'District is required.',
      'City / Village / Town is required.',
      'Address is required.',
      'Your name is required.',
      'Imam name is required.',
      'Imam father name is required.',
      'Imam age is required.',
      'Imam gender is required.',
      'Imam address is required.',
      'Committee member name is required.',
      'Father name is required.',
      'Age is required.',
      'Gender is required.',
    ]) {
      expect(find.text(message), findsOneWidget, reason: message);
    }
    // Requester, imam and committee mobile numbers.
    expect(find.text('Phone number is required'), findsNWidgets(3));
    verifyZeroInteractions(repository);
  });

  testWidgets('committee members can be added; the last cannot be removed', (
    tester,
  ) async {
    await _pump(tester, _MockMasjidRequestRepository());

    expect(find.text('Member 1'), findsOneWidget);
    await _tapText(tester, '+ Add Committee Member');
    expect(find.text('Member 2'), findsOneWidget);

    await tester.ensureVisible(find.text('Remove').last);
    await tester.tap(find.text('Remove').last);
    await tester.pumpAndSettle();
    expect(find.text('Member 2'), findsNothing);

    await tester.ensureVisible(find.text('Remove'));
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    expect(find.text('Member 1'), findsOneWidget);
    expect(
      find.text('At least one committee member is required.'),
      findsOneWidget,
    );
  });

  testWidgets('India (the default) asks for a state and a district', (
    tester,
  ) async {
    await _pump(tester, _MockMasjidRequestRepository());

    expect(find.text('District *'), findsOneWidget);
    expect(find.text('State *'), findsOneWidget);
  });
}
