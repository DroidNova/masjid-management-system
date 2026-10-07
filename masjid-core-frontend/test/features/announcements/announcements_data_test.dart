// mocktail needs `when(() => mock.call())` closures, not tear-offs.
// ignore_for_file: unnecessary_lambdas

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/core/refresh/data_scopes.dart';
import 'package:masjid_core_frontend/features/announcements/application/announcements_controller.dart';
import 'package:masjid_core_frontend/features/announcements/data/announcements_api.dart';
import 'package:masjid_core_frontend/features/announcements/data/announcements_repository.dart';
import 'package:masjid_core_frontend/features/announcements/data/models/announcement_model.dart';
import 'package:masjid_core_frontend/features/announcements/data/models/create_announcement_request.dart';
import 'package:masjid_core_frontend/features/announcements/data/models/update_announcement_request.dart';
import 'package:mocktail/mocktail.dart';

class _MockAnnouncementsApi extends Mock implements AnnouncementsApi {}

class _MockAnnouncementsRepository extends Mock
    implements AnnouncementsRepository {}

void main() {
  group('AnnouncementModel', () {
    test('reads the backend keys', () {
      final model = AnnouncementModel.fromJson(const <String, dynamic>{
        'id': 'a1',
        'masjidId': 'm1',
        'title': 'Eid',
        'message': 'Eid namaz at 7 AM',
        'isActive': false,
        'createdAt': '2026-10-07T10:00:00.000Z',
        'updatedAt': '2026-10-07T10:00:00.000Z',
      });
      expect(model.title, 'Eid');
      expect(model.isActive, isFalse);
      expect(model.createdAt, DateTime.utc(2026, 10, 7, 10));
    });
  });

  group('requests', () {
    test('create trims text', () {
      final json = CreateAnnouncementRequest.fromForm(
        title: '  Eid ',
        message: ' At 7 ',
        isActive: true,
      ).toJson();
      expect(json, <String, dynamic>{
        'title': 'Eid',
        'message': 'At 7',
        'isActive': true,
      });
    });

    test('update leaves out fields that are not set', () {
      expect(
        const UpdateAnnouncementRequest(isActive: false).toJson(),
        <String, dynamic>{'isActive': false},
      );
    });
  });

  group('AnnouncementsRepository.getAnnouncement', () {
    test('loads one announcement by id from the API', () async {
      final api = _MockAnnouncementsApi();
      when(
        () => api.getAnnouncement('a3'),
      ).thenAnswer((_) async => const AnnouncementModel(id: 'a3', title: 'a3'));

      final found = await AnnouncementsRepository(api).getAnnouncement('a3');

      expect(found.id, 'a3');
    });
  });

  group('AnnouncementFormController', () {
    late _MockAnnouncementsRepository repository;
    late ProviderContainer container;

    setUpAll(() {
      registerFallbackValue(
        const CreateAnnouncementRequest(title: '', message: ''),
      );
    });

    setUp(() {
      repository = _MockAnnouncementsRepository();
      container = ProviderContainer(
        overrides: [
          announcementsRepositoryProvider.overrideWithValue(repository),
        ],
      );
      // Keep the auto-dispose controller alive for the test.
      container.listen(announcementFormControllerProvider, (_, _) {});
    });

    tearDown(() => container.dispose());

    int version(DataScope scope) => container.read(dataVersionProvider(scope));

    test('create marks announcements and dashboard as changed', () async {
      when(
        () => repository.createAnnouncement(any()),
      ).thenAnswer((_) async => const AnnouncementModel(id: 'a1'));

      final saved = await container
          .read(announcementFormControllerProvider.notifier)
          .create(
            const CreateAnnouncementRequest(title: 'Eid', message: 'At 7'),
          );

      expect(saved, isTrue);
      expect(version(DataScope.announcements), 1);
      expect(version(DataScope.dashboard), 1);
      expect(
        container.read(announcementFormControllerProvider).hasError,
        isFalse,
      );
    });

    test('a failed save keeps the error and changes nothing', () async {
      const failure = ApiException(
        message: 'Validation failed',
        code: ApiErrorCodes.validation,
        statusCode: 400,
      );
      when(() => repository.createAnnouncement(any())).thenThrow(failure);

      final saved = await container
          .read(announcementFormControllerProvider.notifier)
          .create(
            const CreateAnnouncementRequest(title: 'Eid', message: 'At 7'),
          );

      expect(saved, isFalse);
      expect(container.read(announcementFormControllerProvider).error, failure);
      expect(version(DataScope.announcements), 0);
      expect(version(DataScope.dashboard), 0);
    });
  });
}
