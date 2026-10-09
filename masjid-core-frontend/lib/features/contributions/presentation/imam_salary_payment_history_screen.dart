import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/format/formatters.dart';
import 'package:masjid_core_frontend/features/contributions/application/my_contributions_controllers.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/my_imam_salary_payment.dart';
import 'package:masjid_core_frontend/features/contributions/presentation/widgets/giver_tile.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// The signed-in member's imam salary payments for one month.
class ImamSalaryPaymentHistoryScreen extends ConsumerWidget {
  const ImamSalaryPaymentHistoryScreen({
    super.key,
    required this.month,
    required this.year,
  });

  final int month;
  final int year;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final provider = myImamSalaryPaymentsProvider((month: month, year: year));

    return Scaffold(
      appBar: AppBar(title: Text(AppFormat.monthYear(month, year))),
      body: PagedListView<MyImamSalaryPayment>(
        value: ref.watch(provider),
        dayOf: (payment) => payment.paidAt,
        onRefresh: () => ref.read(provider.notifier).refresh(),
        onLoadMore: ref.read(provider.notifier).loadMore,
        onRetry: () => ref.invalidate(provider),
        empty: EmptyState(
          icon: AppIcons.salary,
          tone: AppTones.salary,
          title: l10n.noSalaryHistory,
        ),
        itemBuilder: (context, payment) => GiverTile(
          name: payment.collectedByName,
          amount: payment.amount,
          paymentMode: payment.paymentMode,
          note: payment.note,
        ),
      ),
    );
  }
}
