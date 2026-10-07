import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/core/storage/session_storage.dart';
import 'package:masjid_core_frontend/features/auth/data/models/app_user.dart';
import 'package:masjid_core_frontend/shared/widgets/account_menu_button.dart';

class _FakeSessionStorage extends SessionStorage {
  _FakeSessionStorage(this.user);

  final AppUser? user;

  @override
  Future<AppUser?> getUser() async => user;
}

AppUser _user({required List<String> permissions, String? masjidId}) => AppUser(
  id: 'u1',
  fullName: 'Rafiq',
  roles: const ['MEMBER'],
  permissions: permissions,
  masjidId: masjidId,
);

Future<void> _pump(WidgetTester tester, AppUser? user) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          actions: [
            AccountMenuButton(sessionStorage: _FakeSessionStorage(user)),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('offers "Leave masjid" to a member of a masjid', (tester) async {
    await _pump(
      tester,
      _user(permissions: const [AppPermissions.masjidLeave], masjidId: 'm1'),
    );

    await tester.tap(find.byTooltip('Account'));
    await tester.pumpAndSettle();
    expect(find.text('Leave masjid'), findsOneWidget);
  });

  testWidgets('is hidden when the user has no masjid', (tester) async {
    await _pump(tester, _user(permissions: const [AppPermissions.masjidLeave]));
    expect(find.byTooltip('Account'), findsNothing);
  });

  testWidgets('is hidden without the masjid.leave permission', (tester) async {
    await _pump(tester, _user(permissions: const [], masjidId: 'm1'));
    expect(find.byTooltip('Account'), findsNothing);
  });
}
