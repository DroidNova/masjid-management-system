import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/features/masjid_request/application/masjid_request_validators.dart';

void main() {
  group('required', () {
    test('empty or blank gives the message', () {
      expect(MasjidRequestValidators.required(null, 'fill'), 'fill');
      expect(MasjidRequestValidators.required('   ', 'fill'), 'fill');
      expect(MasjidRequestValidators.required('Jama', 'fill'), isNull);
    });
  });

  group('email', () {
    test('optional, but must look like an email when given', () {
      expect(MasjidRequestValidators.email('', 'bad'), isNull);
      expect(MasjidRequestValidators.email('a@b.co', 'bad'), isNull);
      expect(MasjidRequestValidators.email('not-an-email', 'bad'), 'bad');
      expect(MasjidRequestValidators.email('a@b', 'bad'), 'bad');
    });
  });

  group('age', () {
    String? age(String value) => MasjidRequestValidators.age(
      value,
      requiredMessage: 'fill',
      rangeMessage: 'range',
    );

    test('required whole number from 1 to 120', () {
      expect(age(''), 'fill');
      expect(age('0'), 'range');
      expect(age('121'), 'range');
      expect(age('1'), isNull);
      expect(age('120'), isNull);
    });
  });

  group('committeePhones', () {
    test('needs at least one committee member', () {
      expect(
        MasjidRequestValidators.committeePhones(
          imamPhone: '+919800000000',
          committeePhones: const [],
        ),
        CommitteeProblem.missing,
      );
    });

    test('the imam cannot also be on the committee', () {
      expect(
        MasjidRequestValidators.committeePhones(
          imamPhone: '+919800000000',
          committeePhones: const ['+919800000001', '+919800000000'],
        ),
        CommitteeProblem.imamIsMember,
      );
    });

    test('committee phones must be different', () {
      expect(
        MasjidRequestValidators.committeePhones(
          imamPhone: '+919800000000',
          committeePhones: const ['+919800000001', '+919800000001'],
        ),
        CommitteeProblem.duplicatePhone,
      );
    });

    test('distinct phones pass', () {
      expect(
        MasjidRequestValidators.committeePhones(
          imamPhone: '+919800000000',
          committeePhones: const ['+919800000001', '+919800000002'],
        ),
        isNull,
      );
    });
  });
}
