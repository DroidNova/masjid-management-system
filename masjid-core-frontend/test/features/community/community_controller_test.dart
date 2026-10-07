// mocktail needs `when(() => mock.call())` closures, not tear-offs.
// ignore_for_file: unnecessary_lambdas

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/refresh/data_scopes.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/community/application/community_controller.dart';
import 'package:masjid_core_frontend/features/community/application/leave_masjid_controller.dart';
import 'package:masjid_core_frontend/features/community/data/community_repository.dart';
import 'package:masjid_core_frontend/features/community/data/models/community_user_model.dart';
import 'package:masjid_core_frontend/features/community/data/models/masjid_detail_model.dart';
import 'package:mocktail/mocktail.dart';

import 'community_test_helpers.dart';

const _masjid = MasjidDetailModel(id: 'm1', name: 'Barota Masjid');

CommunityUserModel _member(String status) =>
    CommunityUserModel.fromJson(<String, dynamic>{
      'id': 'u1',
      'fullName': 'Villager',
      'roles': <String>['MEMBER'],
      'status': status,
    });

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  late MockCommunityRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockCommunityRepository();
    when(() => repository.getMyMasjid()).thenAnswer((_) async => _masjid);
    when(
      () => repository.getMyMasjidUsers(),
    ).thenAnswer((_) async => <CommunityUserModel>[_member('ACTIVE')]);
    container = ProviderContainer(
      overrides: [
        communityRepositoryProvider.overrideWithValue(repository),
        authControllerProvider.overrideWith(() => FixedAuth(testUser())),
      ],
    );
    addTearDown(container.dispose);
    container.listen(communityControllerProvider, (_, _) {});
  });

  int version(DataScope scope) => container.read(dataVersionProvider(scope));

  test('a status change updates in place without reloading the list', () async {
    await container.read(communityControllerProvider.future);
    when(
      () => repository.updateMasjidUserStatus('u1', 'INACTIVE'),
    ).thenAnswer((_) async => _member('INACTIVE'));

    await container
        .read(communityControllerProvider.notifier)
        .changeUserStatus('u1', 'INACTIVE');
    await _settle();

    final data = container.read(communityControllerProvider).requireValue;
    expect(data.users.single.status, 'INACTIVE');
    // Other screens (dashboard, contributor pickers) are told...
    expect(version(DataScope.dashboard), 1);
    expect(version(DataScope.members), 1);
    // ...but this screen does not fetch what it already shows.
    verify(() => repository.getMyMasjidUsers()).called(1);
    verify(() => repository.getMyMasjid()).called(1);
    expect(container.read(communityBusyUserIdsProvider), isEmpty);
  });

  test('a members change from elsewhere still reloads', () async {
    await container.read(communityControllerProvider.future);

    container.read(dataVersionProvider(DataScope.members).notifier).state++;
    await container.read(communityControllerProvider.future);

    verify(() => repository.getMyMasjidUsers()).called(2);
  });

  test('a second change to the same user is ignored while busy', () async {
    await container.read(communityControllerProvider.future);
    final reply = Completer<CommunityUserModel>();
    when(
      () => repository.updateMasjidUserStatus('u1', any()),
    ).thenAnswer((_) => reply.future);

    final notifier = container.read(communityControllerProvider.notifier);
    final first = notifier.changeUserStatus('u1', 'INACTIVE');
    expect(container.read(communityBusyUserIdsProvider), <String>{'u1'});
    await notifier.changeUserStatus('u1', 'SUSPENDED');

    reply.complete(_member('INACTIVE'));
    await first;
    verify(() => repository.updateMasjidUserStatus('u1', any())).called(1);
    expect(container.read(communityBusyUserIdsProvider), isEmpty);
  });

  test('leaving the masjid marks nothing (sign-out follows)', () async {
    when(() => repository.leaveMyMasjid()).thenAnswer((_) async {});
    container.listen(leaveMasjidControllerProvider, (_, _) {});

    final left = await container
        .read(leaveMasjidControllerProvider.notifier)
        .leave();

    expect(left, isTrue);
    for (final scope in DataScope.values) {
      expect(version(scope), 0, reason: scope.name);
    }
  });
}
