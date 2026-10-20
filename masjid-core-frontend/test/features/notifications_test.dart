import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/auth/data/models/app_user.dart';
import 'package:masjid_core_frontend/features/notifications/application/notifications_controllers.dart';
import 'package:masjid_core_frontend/features/notifications/data/notifications_api.dart';
import 'package:masjid_core_frontend/features/notifications/presentation/notification_bell.dart';
import 'package:masjid_core_frontend/features/notifications/presentation/notifications_screen.dart';

import '../shared/ui/ui_test_helpers.dart';

class _Member extends AuthController {
  @override
  AuthState build() => const AuthSignedIn(
    AppUser(
      id: 'member-1',
      fullName: 'Rafiq',
      permissions: <String>['notifications.read'],
    ),
  );
}

class _Unread extends UnreadNotificationsController {
  @override
  Future<int> build() async => 3;
}

AppNotification _notice(
  String kind,
  Map<String, dynamic> data, {
  String? readAt,
}) => AppNotification.fromJson(<String, dynamic>{
  'id': 'n-1',
  'kind': kind,
  'entity': 'SALARY_PAYMENT',
  'entityId': 'sp-1',
  'actorName': 'Karim',
  'data': data,
  'readAt': readAt,
  'createdAt': '2026-10-20T10:00:00.000Z',
});

void main() {
  Future<void> pumpTile(WidgetTester tester, AppNotification notice) =>
      pumpUi(tester, Scaffold(body: NoticeTile(notice: notice)));

  testWidgets('says who recorded a salary payment, and marks it new', (
    tester,
  ) async {
    await pumpTile(
      tester,
      _notice('PAYMENT_RECORDED', <String, dynamic>{
        'amount': 500,
        'purpose': 'SALARY',
        'month': 10,
        'year': 2026,
      }),
    );

    expect(
      find.text(
        'Karim recorded ₹500 from you for Imam salary (October 2026)',
      ),
      findsOneWidget,
    );
    expect(find.text('New'), findsOneWidget);
  });

  testWidgets('shows the new amount after an edit, and no badge once read', (
    tester,
  ) async {
    await pumpTile(
      tester,
      _notice('PAYMENT_CHANGED', <String, dynamic>{
        'amount': 500,
        'newAmount': 700,
        'purpose': 'PROJECT',
        'projectTitle': 'New roof',
      }, readAt: '2026-10-20T11:00:00.000Z'),
    );

    expect(
      find.text('Karim changed your ₹500 entry for New roof'),
      findsOneWidget,
    );
    expect(find.text('Now ₹700'), findsOneWidget);
    expect(find.text('New'), findsNothing);
  });

  testWidgets('says who cancelled a donation entry', (tester) async {
    await pumpTile(
      tester,
      _notice('PAYMENT_CANCELLED', <String, dynamic>{
        'amount': 250,
        'purpose': 'DONATION',
        'collectionType': 'SADAQAH',
      }),
    );

    expect(
      find.textContaining('Karim cancelled your ₹250 entry for'),
      findsOneWidget,
    );
  });

  testWidgets('the bell shows how many notices are unread', (tester) async {
    await pumpUi(
      tester,
      Scaffold(appBar: AppBar(actions: const <Widget>[NotificationBell()])),
      overrides: [
        authControllerProvider.overrideWith(_Member.new),
        unreadNotificationsProvider.overrideWith(_Unread.new),
      ],
    );

    expect(find.text('3'), findsOneWidget);
    expect(find.byTooltip('Notifications'), findsOneWidget);
  });
}
