import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/features/record_history/data/record_history.dart';
import 'package:masjid_core_frontend/features/record_history/presentation/record_history_button.dart';

import '../shared/ui/ui_test_helpers.dart';

void main() {
  const target = (entity: HistoryEntity.collectionContribution, id: 'cc-1');

  Future<void> open(WidgetTester tester, RecordHistory history) async {
    await pumpUi(
      tester,
      const Scaffold(body: Center(child: RecordHistoryButton(target: target))),
      overrides: [
        recordHistoryProvider(target).overrideWith((ref) async => history),
      ],
    );
    await tester.tap(find.byType(RecordHistoryButton));
    await tester.pumpAndSettle();
  }

  testWidgets('shows who added, changed and cancelled, and who got the money', (
    tester,
  ) async {
    await open(
      tester,
      RecordHistory.fromJson(<String, dynamic>{
        'createdAt': '2026-10-01T10:00:00.000Z',
        'collectedByName': 'Karim',
        'events': <Map<String, dynamic>>[
          <String, dynamic>{
            'action': 'CREATE',
            'actorName': 'Yusuf',
            'at': '2026-10-01T10:00:00.000Z',
          },
          <String, dynamic>{
            'action': 'UPDATE',
            'actorName': 'Rahim',
            'at': '2026-10-02T10:00:00.000Z',
            'changes': <Map<String, dynamic>>[
              <String, dynamic>{
                'field': 'amount',
                'kind': 'money',
                'from': 500,
                'to': 700,
              },
            ],
          },
          <String, dynamic>{
            'action': 'CANCEL',
            'actorName': 'Rahim',
            'at': '2026-10-03T10:00:00.000Z',
          },
        ],
      }),
    );

    expect(find.text('History'), findsOneWidget);
    expect(find.text('Added by Yusuf'), findsOneWidget);
    expect(find.text('Changed by Rahim'), findsOneWidget);
    expect(find.text('Amount: ₹500 → ₹700'), findsOneWidget);
    expect(find.text('Cancelled by Rahim'), findsOneWidget);
    expect(find.text('Money received by Karim'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('says when a record is older than the history', (tester) async {
    await open(
      tester,
      RecordHistory.fromJson(<String, dynamic>{
        'createdAt': '2026-07-05T10:00:00.000Z',
        'collectedByName': null,
        'events': <Map<String, dynamic>>[],
      }),
    );

    expect(
      find.text('Added on 5 Jul 2026, before history was kept'),
      findsOneWidget,
    );
  });
}
