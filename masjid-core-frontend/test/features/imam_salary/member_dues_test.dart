import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/features/imam_salary/data/models/member_dues.dart';

void main() {
  const dues = MemberDues(
    totalDue: 1300,
    months: <DueMonth>[
      DueMonth(assignmentId: 'aug', month: 8, year: 2026, dueAmount: 500),
      DueMonth(assignmentId: 'sep', month: 9, year: 2026, dueAmount: 300),
      DueMonth(assignmentId: 'oct', month: 10, year: 2026, dueAmount: 500),
    ],
  );

  test('an amount fills the oldest months first', () {
    final parts = dues.cover(1000);
    expect(parts.map((p) => (p.$1.assignmentId, p.$2)).toList(), [
      ('aug', 500.0),
      ('sep', 300.0),
      ('oct', 200.0),
    ]);
  });

  test('paise are exact and nothing is spread past what is due', () {
    expect(dues.cover(500.5).map((p) => p.$2).toList(), [500.0, 0.5]);
    expect(dues.cover(5000).map((p) => p.$2).toList(), [500.0, 300.0, 500.0]);
  });

  test('reads the API shape', () {
    final parsed = MemberDues.fromJson(<String, dynamic>{
      'totalDue': 250.5,
      'months': <Map<String, dynamic>>[
        <String, dynamic>{
          'assignmentId': 'a',
          'month': 10,
          'year': 2026,
          'dueAmount': 250.5,
        },
      ],
    });
    expect(parsed.totalDue, 250.5);
    expect(parsed.months.single.month, 10);
  });
}
