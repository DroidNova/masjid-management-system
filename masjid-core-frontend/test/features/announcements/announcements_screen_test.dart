// mocktail needs `when(() => mock.call())` closures, not tear-offs.
// ignore_for_file: unnecessary_lambdas

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/core/pagination/page.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/features/announcements/data/announcements_repository.dart';
import 'package:masjid_core_frontend/features/announcements/data/models/announcement_model.dart';
import 'package:masjid_core_frontend/features/announcements/presentation/announcements_screen.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/auth/data/models/app_user.dart';
import 'package:mocktail/mocktail.dart';

class _MockAnnouncementsRepository extends Mock
    implements AnnouncementsRepository {}

class _SignedInAs extends AuthController {
  _SignedInAs(this.user);

  final AppUser user;

  @override
  AuthState build() => AuthSignedIn(user);
}

AppUser _user(List<String> permissions) => AppUser(
  id: 'u1',
  fullName: 'Test User',
  masjidId: 'm1',
  permissions: permissions,
);

PageResult<AnnouncementModel> _page(List<AnnouncementModel> items) =>
    PageResult.fromJson(<String, dynamic>{
      'items': items.map((item) => item.toJson()).toList(),
      'meta': <String, dynamic>{
        'page': 1,
        'limit': 20,
        'total': items.length,
        'totalPages': 1,
        'hasNextPage': false,
      },
    }, AnnouncementModel.fromJson);

const _jumma = AnnouncementModel(
  id: 'a1',
  title: 'Jumma Timing Update',
  message: 'Jumma namaz will be at 1:15 PM.',
);

Future<void> _pump(
  WidgetTester tester,
  AnnouncementsRepository repository, {
  List<String> permissions = const <String>[AppPermissions.announcementsRead],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        announcementsRepositoryProvider.overrideWithValue(repository),
        authControllerProvider.overrideWith(
          () => _SignedInAs(_user(permissions)),
        ),
      ],
      child: const MaterialApp(home: AnnouncementsScreen()),
    ),
  );
}

void main() {
  late _MockAnnouncementsRepository repository;

  setUp(() => repository = _MockAnnouncementsRepository());

  testWidgets('shows a spinner, then the announcements', (tester) async {
    final response = Completer<PageResult<AnnouncementModel>>();
    when(
      () => repository.getAnnouncements(),
    ).thenAnswer((_) => response.future);

    await _pump(tester, repository);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    response.complete(_page(<AnnouncementModel>[_jumma]));
    await tester.pumpAndSettle();

    expect(find.text('Jumma Timing Update'), findsOneWidget);
    expect(find.text('Jumma namaz will be at 1:15 PM.'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
  });

  testWidgets('shows the empty view when there are none', (tester) async {
    when(
      () => repository.getAnnouncements(),
    ).thenAnswer((_) async => _page(const <AnnouncementModel>[]));

    await _pump(tester, repository);
    await tester.pumpAndSettle();

    expect(find.text('No announcements added yet.'), findsOneWidget);
  });

  testWidgets('shows the server message and retries on error', (tester) async {
    when(() => repository.getAnnouncements()).thenThrow(
      const ApiException(
        message: 'Server is busy',
        code: ApiErrorCodes.unknown,
        statusCode: 500,
      ),
    );

    await _pump(tester, repository);
    await tester.pumpAndSettle();

    expect(find.text('Unable to load announcements.'), findsOneWidget);
    expect(find.text('Server is busy'), findsOneWidget);

    when(
      () => repository.getAnnouncements(),
    ).thenAnswer((_) async => _page(<AnnouncementModel>[_jumma]));
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Jumma Timing Update'), findsOneWidget);
  });

  testWidgets('says "not assigned" for USER_MASJID_NOT_ASSIGNED, by code', (
    tester,
  ) async {
    when(() => repository.getAnnouncements()).thenThrow(
      const ApiException(
        message: 'Current user is not assigned to a masjid',
        code: ApiErrorCodes.userMasjidNotAssigned,
        statusCode: 403,
      ),
    );

    await _pump(tester, repository);
    await tester.pumpAndSettle();

    expect(
      find.text('You are not assigned to any masjid yet.'),
      findsOneWidget,
    );
  });

  testWidgets('hides add / edit / delete without announcements.manage', (
    tester,
  ) async {
    when(
      () => repository.getAnnouncements(),
    ).thenAnswer((_) async => _page(<AnnouncementModel>[_jumma]));

    await _pump(tester, repository);
    await tester.pumpAndSettle();

    expect(find.text('Jumma Timing Update'), findsOneWidget);
    expect(find.text('Add Announcement'), findsNothing);
    expect(find.text('Edit'), findsNothing);
    expect(find.text('Delete'), findsNothing);
  });

  testWidgets('shows add / edit / delete with announcements.manage', (
    tester,
  ) async {
    when(
      () => repository.getAnnouncements(),
    ).thenAnswer((_) async => _page(<AnnouncementModel>[_jumma]));

    await _pump(
      tester,
      repository,
      permissions: const <String>[
        AppPermissions.announcementsRead,
        AppPermissions.announcementsManage,
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Add Announcement'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('delete deactivates after confirming and reloads the list', (
    tester,
  ) async {
    when(
      () => repository.getAnnouncements(),
    ).thenAnswer((_) async => _page(<AnnouncementModel>[_jumma]));
    when(
      () => repository.deactivateAnnouncement('a1'),
    ).thenAnswer((_) async => _jumma.copyWith(isActive: false));

    await _pump(
      tester,
      repository,
      permissions: const <String>[AppPermissions.announcementsManage],
    );
    await tester.pumpAndSettle();

    when(() => repository.getAnnouncements()).thenAnswer(
      (_) async => _page(<AnnouncementModel>[_jumma.copyWith(isActive: false)]),
    );
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    verify(() => repository.deactivateAnnouncement('a1')).called(1);
    expect(find.text('Announcement deleted successfully.'), findsOneWidget);
    expect(find.text('Inactive'), findsOneWidget);
  });
}
