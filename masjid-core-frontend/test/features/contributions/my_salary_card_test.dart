import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/features/contributions/application/my_contributions_controllers.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/my_contribution_summary.dart';
import 'package:masjid_core_frontend/features/contributions/presentation/widgets/my_salary_card.dart';

import '../../shared/ui/ui_test_helpers.dart';

class _Summary extends MyContributionSummaryController {
  _Summary(this.value);

  final MyContributionSummary value;

  @override
  Future<MyContributionSummary> build() async => value;
}

MyContributionSummary _summary({
  required double totalDue,
  MySalaryThisMonth? now,
  int months = 2,
}) => MyContributionSummary(
  user: const MyContributionUser(id: 'u1', isFamilyHead: true),
  imamSalary: ImamSalaryContributionSummary(
    monthsShown: months,
    totalDue: totalDue,
    currentMonth: now,
  ),
);

Future<void> _pump(WidgetTester tester, MyContributionSummary summary) =>
    pumpUi(
      tester,
      Scaffold(body: MySalaryCard(onOpen: () {})),
      overrides: [
        myContributionSummaryProvider.overrideWith(() => _Summary(summary)),
      ],
    );

void main() {
  testWidgets('all paid: one green line', (tester) async {
    await _pump(
      tester,
      _summary(
        totalDue: 0,
        now: const MySalaryThisMonth(
          month: 10,
          year: 2026,
          expectedAmount: 500,
          paidAmount: 500,
          status: 'PAID',
        ),
      ),
    );
    expect(find.text('This month is paid'), findsOneWidget);
    expect(find.textContaining('to pay'), findsNothing);
  });

  testWidgets('this month due: the total is the big line', (tester) async {
    await _pump(
      tester,
      _summary(
        totalDue: 500,
        now: const MySalaryThisMonth(
          month: 10,
          year: 2026,
          expectedAmount: 500,
          dueAmount: 500,
        ),
      ),
    );
    expect(find.text('₹500 to pay in all'), findsOneWidget);
    expect(find.text('₹500 to pay this month'), findsOneWidget);
    expect(find.textContaining('Earlier months'), findsNothing);
  });

  testWidgets('this month paid but an old month is not', (tester) async {
    await _pump(
      tester,
      _summary(
        totalDue: 500,
        now: const MySalaryThisMonth(
          month: 10,
          year: 2026,
          expectedAmount: 500,
          paidAmount: 500,
          status: 'PAID',
        ),
      ),
    );
    expect(find.text('₹500 to pay in all'), findsOneWidget);
    expect(find.text('This month is paid'), findsOneWidget);
    expect(find.text('Earlier months: ₹500 to pay'), findsOneWidget);
  });

  testWidgets('no salary months at all: nothing shown', (tester) async {
    await _pump(tester, _summary(totalDue: 0, months: 0));
    expect(find.byType(Card), findsNothing);
  });
}
