import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/shared/ui/amount_pad.dart';
import 'package:masjid_core_frontend/shared/ui/amount_text.dart';
import 'package:masjid_core_frontend/shared/ui/person_avatar.dart';

String _type(List<String> keys, {bool allowDecimal = true}) => keys.fold(
  '',
  (value, key) => AmountPad.applyKey(value, key, allowDecimal: allowDecimal),
);

void main() {
  group('AmountText.format', () {
    test('money in and out carry a sign, Indian grouping', () {
      expect(AmountText.format(500, kind: AmountKind.moneyIn), '+₹500');
      expect(
        AmountText.format(1250.5, kind: AmountKind.moneyOut),
        '−₹1,250.50',
      );
      expect(AmountText.format(125000), '₹1,25,000');
    });

    test('a negative neutral amount uses the minus sign', () {
      expect(AmountText.format(-20), '−₹20');
    });
  });

  group('AmountPad.applyKey', () {
    test('typing digits builds the amount without a leading zero', () {
      expect(_type(<String>['0', '5', '0', '0']), '500');
    });

    test('keeps at most two decimals and one dot', () {
      expect(_type(<String>['1', '2', '.', '5', '6', '7']), '12.56');
      expect(_type(<String>['.', '.', '5']), '0.5');
    });

    test('backspace removes the last character', () {
      expect(_type(<String>['1', '2', AmountPad.backspaceKey]), '1');
      expect(_type(<String>[AmountPad.backspaceKey]), '');
    });

    test('caps whole digits', () {
      expect(_type(List<String>.filled(12, '9')).length, 9);
    });

    test('ignores the dot when decimals are not allowed', () {
      expect(_type(<String>['5', '.', '5'], allowDecimal: false), '55');
    });
  });

  test('AmountPad.parse treats empty and zero as nothing entered', () {
    expect(AmountPad.parse(''), isNull);
    expect(AmountPad.parse('0'), isNull);
    expect(AmountPad.parse('0.'), isNull);
    expect(AmountPad.parse('12.'), 12);
    expect(AmountPad.parse('99.5'), 99.5);
  });

  test('AmountPad.display groups while typing', () {
    expect(AmountPad.display(''), '₹0');
    expect(AmountPad.display('125000'), '₹1,25,000');
    expect(AmountPad.display('1250.5'), '₹1,250.5');
    expect(AmountPad.display('0.'), '₹0.');
  });

  group('PersonAvatar', () {
    test('initials from the first two words, in any script', () {
      expect(PersonAvatar.initials('Mohammed Rafiq Khan'), 'MR');
      expect(PersonAvatar.initials('  imran  '), 'I');
      expect(PersonAvatar.initials(''), '?');
      expect(PersonAvatar.initials('अब्दुल करीम'), 'अक');
      expect(PersonAvatar.initials('سلیم احمد'), 'سا');
    });

    test('the same name always gets the same colour', () {
      expect(
        PersonAvatar.toneFor('Rafiq'),
        same(PersonAvatar.toneFor(' rafiq ')),
      );
    });
  });
}
