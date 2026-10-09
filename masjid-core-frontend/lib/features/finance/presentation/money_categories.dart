import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// One kind of money in or out (the API's `type` values) with its picture.
@immutable
class MoneyCategory {
  const MoneyCategory(this.value, this.icon);

  /// The API value, for example `JUMMA_COLLECTION`.
  final String value;
  final IconData icon;

  String label(AppLocalizations l10n) => moneyCategoryLabel(l10n, value);
}

/// Kinds of money coming in (masjid-core CollectionType), most used first.
const List<MoneyCategory> moneyInCategories = <MoneyCategory>[
  MoneyCategory('JUMMA_COLLECTION', AppIcons.jumma),
  MoneyCategory('DONATION_BOX', AppIcons.donationBox),
  MoneyCategory('RAMADAN_FUND', Icons.nights_stay_rounded),
  MoneyCategory('ZAKAT', AppIcons.zakat),
  MoneyCategory('SADAQAH', Icons.favorite_rounded),
  MoneyCategory('CONSTRUCTION_FUND', AppIcons.projects),
  MoneyCategory('OTHER', Icons.more_horiz_rounded),
];

/// Kinds of money going out (masjid-core ExpenseType).
const List<MoneyCategory> moneyOutCategories = <MoneyCategory>[
  MoneyCategory('ELECTRICITY_BILL', Icons.bolt_rounded),
  MoneyCategory('WATER_BILL', Icons.water_drop_rounded),
  MoneyCategory('IMAM_SALARY', AppIcons.salary),
  MoneyCategory('CLEANING', Icons.cleaning_services_rounded),
  MoneyCategory('REPAIR', Icons.build_rounded),
  MoneyCategory('CONSTRUCTION', AppIcons.projects),
  MoneyCategory('OTHER', Icons.more_horiz_rounded),
];

/// The picture for [value]; a plain wallet for unknown values.
IconData moneyCategoryIcon(String value, {required bool isExpense}) {
  final list = isExpense ? moneyOutCategories : moneyInCategories;
  for (final category in list) {
    if (category.value == value) return category.icon;
  }
  return AppIcons.money;
}

/// The name of [value] in the app's language. Unknown values (a newer
/// server) show as words: "NEW_TYPE" → "New type".
String moneyCategoryLabel(AppLocalizations l10n, String value) =>
    switch (value) {
      'JUMMA_COLLECTION' => l10n.catJumma,
      'DONATION_BOX' => l10n.catDonationBox,
      'RAMADAN_FUND' => l10n.catRamadanFund,
      'ZAKAT' => l10n.catZakat,
      'SADAQAH' => l10n.catSadaqah,
      'CONSTRUCTION_FUND' => l10n.catConstructionFund,
      'ELECTRICITY_BILL' => l10n.catElectricity,
      'WATER_BILL' => l10n.catWater,
      'IMAM_SALARY' => l10n.catImamSalary,
      'CLEANING' => l10n.catCleaning,
      'REPAIR' => l10n.catRepair,
      'CONSTRUCTION' => l10n.catConstruction,
      'OTHER' => l10n.catOther,
      _ => _words(value),
    };

String _words(String value) {
  final text = value.replaceAll('_', ' ').toLowerCase();
  return text.isEmpty ? text : '${text[0].toUpperCase()}${text.substring(1)}';
}

/// Cash or online (masjid-core PaymentMode).
String paymentModeLabel(AppLocalizations l10n, String mode) =>
    mode == 'ONLINE' ? l10n.payOnline : l10n.payCash;

IconData paymentModeIcon(String mode) =>
    mode == 'ONLINE' ? Icons.phone_iphone_rounded : Icons.payments_rounded;
