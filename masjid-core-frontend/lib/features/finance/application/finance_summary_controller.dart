import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/refresh/data_scopes.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/finance/data/finance_repository.dart';
import 'package:masjid_core_frontend/features/finance/data/models/finance_summary_model.dart';

/// Money totals for the signed-in user's masjid (finance screen header).
final financeSummaryProvider =
    AsyncNotifierProvider.autoDispose<
      FinanceSummaryController,
      FinanceSummaryModel
    >(FinanceSummaryController.new);

class FinanceSummaryController
    extends AutoDisposeAsyncNotifier<FinanceSummaryModel> {
  @override
  Future<FinanceSummaryModel> build() {
    ref.watch(currentUserProvider.select((user) => user?.id));
    // Collections, expenses, contributions and salary payments all mark
    // DataScope.finance (DataChanges.money).
    ref.watch(dataVersionProvider(DataScope.finance));
    return ref.watch(financeRepositoryProvider).getFinanceSummary();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
