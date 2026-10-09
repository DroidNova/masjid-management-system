// Writes every app sentence in English, Hindi, and Urdu to one CSV file, so
// a native speaker can check the Hindi and Urdu in a spreadsheet.
//
// Run from masjid-core-frontend:
//   dart run tool/export_translations.dart ../docs/translations_review.csv
//
// Columns: key, English, Hindi, Urdu, then empty "Problem?" and
// "Better wording" columns for the reviewer. Open it in Google Sheets or
// Excel (UTF-8).
import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final out = args.isEmpty ? '../docs/translations_review.csv' : args.first;
  Map<String, dynamic> read(String code) =>
      jsonDecode(File('lib/l10n/app_$code.arb').readAsStringSync())
          as Map<String, dynamic>;
  final en = read('en');
  final hi = read('hi');
  final ur = read('ur');

  String cell(Object? value) =>
      '"${(value ?? '').toString().replaceAll('"', '""')}"';

  final rows = <String>[
    <String>[
      'key',
      'English',
      'Hindi',
      'Urdu',
      'Problem?',
      'Better wording',
    ].map(cell).join(','),
    for (final key in en.keys)
      if (!key.startsWith('@'))
        <Object?>[key, en[key], hi[key], ur[key], '', ''].map(cell).join(','),
  ];
  // The byte-order mark makes Excel read the file as UTF-8 (Hindi, Urdu).
  File(out).writeAsStringSync('﻿${rows.join('\r\n')}\r\n');
  stdout.writeln('Wrote ${rows.length - 1} sentences to $out');
}
