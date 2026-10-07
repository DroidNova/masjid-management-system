import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/refresh/data_scopes.dart';
import 'package:masjid_core_frontend/features/finance/data/finance_repository.dart';
import 'package:masjid_core_frontend/features/finance/data/models/create_collection_request.dart';
import 'package:masjid_core_frontend/features/finance/data/models/create_expense_request.dart';

/// Adds and cancels collections and expenses.
///
/// State is the last mutation: loading while saving, error if it failed.
/// Screens watch it for the busy state and read `.error` for messages
/// (`userMessage` / `fieldError`). Every success marks
/// [DataChanges.money] so totals and lists everywhere reload.
final financeEntryControllerProvider =
    AsyncNotifierProvider.autoDispose<FinanceEntryController, void>(
      FinanceEntryController.new,
    );

class FinanceEntryController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  FinanceRepository get _repository => ref.read(financeRepositoryProvider);

  Future<bool> addCollection(CreateCollectionRequest request) =>
      _run(() => _repository.createCollection(request));

  Future<bool> addExpense(CreateExpenseRequest request) =>
      _run(() => _repository.createExpense(request));

  Future<bool> cancelCollection(String id) =>
      _run(() => _repository.cancelCollection(id));

  Future<bool> cancelExpense(String id) =>
      _run(() => _repository.cancelExpense(id));

  Future<bool> _run(Future<Object?> Function() action) async {
    if (state.isLoading) return false;
    // Finish (and mark changes) even if the screen closes meanwhile.
    final keepAlive = ref.keepAlive();
    try {
      state = const AsyncLoading<void>();
      state = await AsyncValue.guard<void>(action);
      if (state.hasError) return false;
      ref.markChanged(DataChanges.money);
      return true;
    } finally {
      keepAlive.close();
    }
  }
}
