import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/features/finance/presentation/money_entry_screen.dart';

/// Money in: a collection (Jumma, donation box, zakat...).
class AddCollectionScreen extends StatelessWidget {
  const AddCollectionScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const MoneyEntryScreen(isExpense: false);
}
