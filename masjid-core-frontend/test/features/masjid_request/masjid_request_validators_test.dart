import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/features/masjid_request/application/masjid_request_validators.dart';

void main() {
  group('required', () {
    test('empty or blank is "<label> is required."', () {
      expect(
        MasjidRequestValidators.required(null, 'Masjid name'),
        'Masjid name is required.',
      );
      expect(
        MasjidRequestValidators.required('   ', 'Address'),
        'Address is required.',
      );
      expect(MasjidRequestValidators.required('Jama', 'Masjid name'), isNull);
    });
  });

  group('email', () {
    test('optional, but must look like an email when given', () {
      expect(MasjidRequestValidators.email('', 'email address'), isNull);
      expect(MasjidRequestValidators.email('a@b.co', 'email address'), isNull);
      expect(
        MasjidRequestValidators.email('not-an-email', 'imam email'),
        'Enter a valid imam email.',
      );
      expect(
        MasjidRequestValidators.email('a@b', 'email address'),
        'Enter a valid email address.',
      );
    });
  });

  group('age', () {
    test('required whole number from 1 to 120', () {
      expect(
        MasjidRequestValidators.age('', 'Imam age'),
        'Imam age is required.',
      );
      expect(
        MasjidRequestValidators.age('0', 'Imam age'),
        'Imam age must be between 1 and 120.',
      );
      expect(
        MasjidRequestValidators.age('121', 'Age'),
        'Age must be between 1 and 120.',
      );
      expect(MasjidRequestValidators.age('1', 'Age'), isNull);
      expect(MasjidRequestValidators.age('120', 'Age'), isNull);
    });
  });

  group('committeePhones', () {
    test('needs at least one committee member', () {
      expect(
        MasjidRequestValidators.committeePhones(
          imamPhone: '+919800000000',
          committeePhones: const [],
        ),
        MasjidRequestValidators.committeeRequired,
      );
    });

    test('the imam cannot also be on the committee', () {
      expect(
        MasjidRequestValidators.committeePhones(
          imamPhone: '+919800000000',
          committeePhones: const ['+919800000001', '+919800000000'],
        ),
        'Imam cannot also be a committee member.',
      );
    });

    test('committee phones must be different', () {
      expect(
        MasjidRequestValidators.committeePhones(
          imamPhone: '+919800000000',
          committeePhones: const ['+919800000001', '+919800000001'],
        ),
        'Committee member mobile number is duplicated.',
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
