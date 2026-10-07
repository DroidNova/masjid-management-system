// mocktail needs `when(() => mock.call())` closures, not tear-offs.
// ignore_for_file: unnecessary_lambdas

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/refresh/data_scopes.dart';
import 'package:masjid_core_frontend/features/announcements/application/announcements_controller.dart';
import 'package:masjid_core_frontend/features/announcements/data/announcements_repository.dart';
import 'package:masjid_core_frontend/features/announcements/data/models/announcement_model.dart';
import 'package:masjid_core_frontend/features/announcements/data/models/create_announcement_request.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/namaz_time/application/namaz_time_controller.dart';
import 'package:masjid_core_frontend/features/namaz_time/data/models/namaz_time_model.dart';
import 'package:masjid_core_frontend/features/namaz_time/data/models/update_namaz_time_request.dart';
import 'package:masjid_core_frontend/features/namaz_time/data/namaz_time_repository.dart';
import 'package:masjid_core_frontend/features/projects/application/project_detail_controller.dart';
import 'package:masjid_core_frontend/features/projects/data/models/create_project_request.dart';
import 'package:masjid_core_frontend/features/projects/data/models/project_model.dart';
import 'package:masjid_core_frontend/features/projects/data/models/update_project_request.dart';
import 'package:masjid_core_frontend/features/projects/data/projects_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockAnnouncements extends Mock implements AnnouncementsRepository {}

class _MockNamaz extends Mock implements NamazTimeRepository {}

class _MockProjects extends Mock implements ProjectsRepository {}

class _SignedOut extends AuthController {
  @override
  AuthState build() => const AuthSignedOut();
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  setUpAll(() {
    registerFallbackValue(const UpdateNamazTimeRequest());
    registerFallbackValue(
      const CreateAnnouncementRequest(title: 't', message: 'm'),
    );
  });

  // The screen closes while saving (nothing listens any more): the save
  // must still finish and tell the other screens.
  test('namaz save marks changes even if the screen closed', () async {
    final namaz = _MockNamaz();
    final reply = Completer<NamazTimeModel>();
    when(() => namaz.updateMyNamazTime(any())).thenAnswer((_) => reply.future);
    final container = ProviderContainer(
      overrides: [namazTimeRepositoryProvider.overrideWithValue(namaz)],
    );
    addTearDown(container.dispose);

    final sub = container.listen(namazTimeSaveControllerProvider, (_, _) {});
    final saving = container
        .read(namazTimeSaveControllerProvider.notifier)
        .save(const UpdateNamazTimeRequest(fajr: '05:00 AM'));
    sub.close();
    await _settle();

    reply.complete(const NamazTimeModel());
    expect(await saving, isTrue);
    expect(container.read(dataVersionProvider(DataScope.namazTimes)), 1);
    expect(container.read(dataVersionProvider(DataScope.dashboard)), 1);
  });

  test('announcement save marks changes even if the screen closed', () async {
    final announcements = _MockAnnouncements();
    final reply = Completer<AnnouncementModel>();
    when(
      () => announcements.createAnnouncement(any()),
    ).thenAnswer((_) => reply.future);
    final container = ProviderContainer(
      overrides: [
        announcementsRepositoryProvider.overrideWithValue(announcements),
      ],
    );
    addTearDown(container.dispose);

    final sub = container.listen(announcementFormControllerProvider, (_, _) {});
    final saving = container
        .read(announcementFormControllerProvider.notifier)
        .create(const CreateAnnouncementRequest(title: 't', message: 'm'));
    sub.close();
    await _settle();

    reply.complete(const AnnouncementModel(id: 'a', title: 't', message: 'm'));
    expect(await saving, isTrue);
    expect(container.read(dataVersionProvider(DataScope.announcements)), 1);
  });

  group('projects', () {
    test('requests never send collected or spent amounts', () {
      expect(
        const CreateProjectRequest(title: 'Roof').toJson().keys,
        isNot(anyOf(contains('collectedAmount'), contains('spentAmount'))),
      );
      expect(
        const UpdateProjectRequest(title: 'Roof', targetAmount: 5).toJson(),
        <String, dynamic>{'title': 'Roof', 'targetAmount': 5.0},
      );
    });

    test(
      'detail reloads on project changes, not on any contribution',
      () async {
        final projects = _MockProjects();
        when(
          () => projects.getProjectById('p1'),
        ).thenAnswer((_) async => const ProjectModel(id: 'p1', title: 'Roof'));
        final container = ProviderContainer(
          overrides: [
            projectsRepositoryProvider.overrideWithValue(projects),
            authControllerProvider.overrideWith(_SignedOut.new),
          ],
        );
        addTearDown(container.dispose);
        final provider = projectDetailProvider('p1');
        container.listen(provider, (_, _) {});
        await container.read(provider.future);

        // E.g. a general collection contribution (DataChanges.money).
        container
            .read(dataVersionProvider(DataScope.contributions).notifier)
            .state++;
        await container.read(provider.future);
        verify(() => projects.getProjectById('p1')).called(1);

        // A project contribution also marks DataScope.projects.
        container
            .read(dataVersionProvider(DataScope.projects).notifier)
            .state++;
        await container.read(provider.future);
        verify(() => projects.getProjectById('p1')).called(1);
      },
    );
  });
}
