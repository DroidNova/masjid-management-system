import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/features/finance/presentation/money_entry_screen.dart';

/// Money out: an expense (electricity, repairs, salary...).
class AddExpenseScreen extends StatelessWidget {
  const AddExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) => const MoneyEntryScreen(isExpense: true);
}
