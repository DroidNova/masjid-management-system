import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/constants/country_codes.dart';
import 'package:masjid_core_frontend/shared/models/country_code.dart';
import 'package:masjid_core_frontend/shared/ui/app_icons.dart';
import 'package:masjid_core_frontend/shared/ui/responsive.dart';
import 'package:masjid_core_frontend/shared/ui/tokens.dart';

/// Pick a country (flag, name, dialling code) from a searchable list.
/// Returns null when closed without picking.
Future<CountryCode?> showCountryPicker(BuildContext context) {
  const body = _CountryList();
  if (ScreenSize.of(context) == ScreenSize.compact) {
    return showModalBottomSheet<CountryCode>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => SizedBox(
        height: MediaQuery.sizeOf(sheetContext).height * 0.85,
        child: body,
      ),
    );
  }
  return showDialog<CountryCode>(
    context: context,
    builder: (_) =>
        const Dialog(child: SizedBox(width: 460, height: 600, child: body)),
  );
}

class _CountryList extends StatefulWidget {
  const _CountryList();

  @override
  State<_CountryList> createState() => _CountryListState();
}

class _CountryListState extends State<_CountryList> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final query = _query.toLowerCase();
    final countries = countryCodes
        .where(
          (country) => '${country.name} ${country.isoCode} ${country.dialCode}'
              .toLowerCase()
              .contains(query),
        )
        .toList();

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpace.l,
            AppSpace.s,
            AppSpace.l,
            AppSpace.s,
          ),
          child: TextField(
            autofocus: true,
            onChanged: (value) => setState(() => _query = value.trim()),
            decoration: InputDecoration(
              prefixIcon: const Icon(AppIcons.search),
              hintText: l10n.searchCountry,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: countries.length,
            itemBuilder: (context, index) {
              final country = countries[index];
              return ListTile(
                leading: Text(
                  country.flagEmoji,
                  style: const TextStyle(fontSize: 28),
                ),
                title: Text(country.name),
                trailing: Text(
                  country.dialCode,
                  textDirection: TextDirection.ltr,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                onTap: () => Navigator.of(context).pop(country),
              );
            },
          ),
        ),
      ],
    );
  }
}
