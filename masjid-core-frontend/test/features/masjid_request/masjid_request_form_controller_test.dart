import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/features/masjid_request/application/masjid_request_draft.dart';
import 'package:masjid_core_frontend/features/masjid_request/application/masjid_request_form_controller.dart';
import 'package:masjid_core_frontend/features/masjid_request/application/masjid_request_validators.dart';
import 'package:masjid_core_frontend/features/masjid_request/data/masjid_request_repository.dart';
import 'package:masjid_core_frontend/features/masjid_request/data/models/create_masjid_request.dart';
import 'package:masjid_core_frontend/shared/constants/country_codes.dart';
import 'package:masjid_core_frontend/shared/models/country_code.dart';
import 'package:masjid_core_frontend/shared/utils/country_code_utils.dart';
import 'package:mocktail/mocktail.dart';

class _MockMasjidRequestRepository extends Mock
    implements MasjidRequestRepository {}

final CountryCode _india = getDefaultCountryCode();

PhoneInput _phone(String number) => PhoneInput(country: _india, number: number);

MasjidRequestDraft _draft({
  CountryCode? country,
  String imamPhone = '9800000000',
  List<String> committeePhones = const ['9800000001'],
  String contactNo = '',
}) => MasjidRequestDraft(
  masjidName: '  Jama Masjid ',
  masjidCountry: country ?? _india,
  state: 'Uttar Pradesh',
  district: 'Kheri',
  locality: 'Nighasan',
  address: 'Main road',
  contactNo: _phone(contactNo),
  welcomeMsg: '',
  description: '',
  requesterName: 'Rafiq',
  requesterPhone: _phone('9811111111'),
  requesterEmail: '',
  imamName: 'Imam Sahab',
  imamPhone: _phone(imamPhone),
  imamEmail: '',
  imamFatherName: 'Abdul',
  imamAge: '45',
  imamGender: 'MALE',
  imamAddress: 'Near masjid',
  committeeMembers: committeePhones
      .map(
        (phone) => CommitteeMemberDraft(
          name: 'Member $phone',
          phone: _phone(phone),
          fatherName: 'Father',
          age: '40',
          gender: 'MALE',
        ),
      )
      .toList(),
);

void main() {
  late _MockMasjidRequestRepository repository;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(
      const CreateMasjidRequest(
        requesterName: '',
        requesterPhone: '',
        masjidName: '',
        country: '',
        locality: '',
        state: '',
        address: '',
        imamName: '',
        imamPhone: '',
        imamAddress: '',
        imamFatherName: '',
        imamAge: 1,
        imamGender: 'MALE',
        committeeMembers: [],
      ),
    );
  });

  setUp(() {
    repository = _MockMasjidRequestRepository();
    container = ProviderContainer(
      overrides: [
        masjidRequestRepositoryProvider.overrideWithValue(repository),
      ],
    );
    // Keep the auto-dispose controller alive for the whole test.
    container.listen(masjidRequestFormControllerProvider, (_, _) {});
  });

  tearDown(() => container.dispose());

  MasjidRequestFormController controller() =>
      container.read(masjidRequestFormControllerProvider.notifier);

  test('sends a cleaned request and reports success', () async {
    when(() => repository.submitMasjidRequest(any())).thenAnswer((_) async {});

    final ok = await controller().submit(_draft());

    expect(ok, isTrue);
    final request =
        verify(
              () => repository.submitMasjidRequest(captureAny()),
            ).captured.single
            as CreateMasjidRequest;
    expect(request.toJson(), <String, Object?>{
      'requesterName': 'Rafiq',
      'requesterPhone': '+919811111111',
      'masjidName': 'Jama Masjid',
      'country': 'India',
      'district': 'Kheri',
      'locality': 'Nighasan',
      'state': 'Uttar Pradesh',
      'address': 'Main road',
      'imamName': 'Imam Sahab',
      'imamPhone': '+919800000000',
      'imamAddress': 'Near masjid',
      'imamFatherName': 'Abdul',
      'imamAge': 45,
      'imamGender': 'MALE',
      'committeeMembers': [
        {
          'name': 'Member 9800000001',
          'phone': '+919800000001',
          'fatherName': 'Father',
          'age': 40,
          'gender': 'MALE',
        },
      ],
    });
  });

  test('outside India no district is sent; a contact number is', () async {
    when(() => repository.submitMasjidRequest(any())).thenAnswer((_) async {});
    final other = countryCodes.firstWhere((c) => c.isoCode != 'IN');

    await controller().submit(_draft(country: other, contactNo: '9822222222'));

    final request =
        verify(
              () => repository.submitMasjidRequest(captureAny()),
            ).captured.single
            as CreateMasjidRequest;
    expect(request.district, isNull);
    expect(request.toJson().containsKey('district'), isFalse);
    expect(request.country, other.name);
    expect(request.contactNo, '+919822222222');
  });

  test(
    'the imam on the committee is refused without calling the API',
    () async {
      final ok = await controller().submit(
        _draft(committeePhones: const ['9800000000']),
      );

      expect(ok, isFalse);
      final error = container.read(masjidRequestFormControllerProvider).error!;
      expect(
        (error as MasjidRequestInvalid).problem,
        CommitteeProblem.imamIsMember,
      );
      verifyNever(() => repository.submitMasjidRequest(any()));
    },
  );

  test('duplicate committee phones are refused', () async {
    final ok = await controller().submit(
      _draft(committeePhones: const ['9800000001', '9800000001']),
    );

    expect(ok, isFalse);
    final error = container.read(masjidRequestFormControllerProvider).error;
    expect(
      (error! as MasjidRequestInvalid).problem,
      CommitteeProblem.duplicatePhone,
    );
  });

  test('a server error is kept as is for the screen', () async {
    when(() => repository.submitMasjidRequest(any())).thenThrow(
      const ApiException(
        message: 'This phone number already belongs to another masjid',
        code: ApiErrorCodes.userInAnotherMasjid,
        statusCode: 409,
      ),
    );

    final ok = await controller().submit(_draft());

    expect(ok, isFalse);
    final error = container.read(masjidRequestFormControllerProvider).error!;
    expect(error, isA<ApiException>());
    expect(
      (error as ApiException).message,
      'This phone number already belongs to another masjid',
    );
  });
}
