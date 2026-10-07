import 'package:masjid_core_frontend/core/format/formatters.dart';

const Map<String, String> collectionTypeLabels = <String, String>{
  'JUMMA_COLLECTION': 'Jumma Collection',
  'DONATION_BOX': 'Donation Box',
  'RAMADAN_FUND': 'Ramadan Fund',
  'ZAKAT': 'Zakat',
  'SADAQAH': 'Sadaqah',
  'CONSTRUCTION_FUND': 'Construction Fund',
  'OTHER': 'Other',
};

const Map<String, String> expenseTypeLabels = <String, String>{
  'ELECTRICITY_BILL': 'Electricity Bill',
  'WATER_BILL': 'Water Bill',
  'IMAM_SALARY': 'Imam Salary',
  'CLEANING': 'Cleaning',
  'REPAIR': 'Repair',
  'CONSTRUCTION': 'Construction',
  'OTHER': 'Other',
};

String financeTypeLabel(String type, {required bool isExpense}) {
  final labels = isExpense ? expenseTypeLabels : collectionTypeLabels;
  return labels[type] ?? type.replaceAll('_', ' ');
}

/// Kept for existing callers; same output as AppFormat.rupees.
String formatRupees(double amount) => AppFormat.rupees(amount);
