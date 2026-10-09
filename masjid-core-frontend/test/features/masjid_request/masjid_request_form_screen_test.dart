// mocktail needs `when(() => mock.call())` closures, not tear-offs.
// ignore_for_file: unnecessary_lambdas

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/features/masjid_request/data/masjid_request_repository.dart';
import 'package:masjid_core_frontend/features/masjid_request/data/models/create_masjid_request.dart';
import 'package:masjid_core_frontend/features/masjid_request/presentation/masjid_request_form_screen.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

import '../../shared/ui/ui_test_helpers.dart';

class _MockMasjidRequestRepository extends Mock
    implements MasjidRequestRepository {}

class _FakeRequest extends Fake implements CreateMasjidRequest {}

Future<void> _pump(
  WidgetTester tester,
  MasjidRequestRepository repository,
) async {
  tester.view.physicalSize = const Size(500, 2000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(
    overrides: [
      ...await testAppOverrides(),
      masjidRequestRepositoryProvider.overrideWithValue(repository),
    ],
  );
  addTearDown(container.dispose);
  final router = GoRouter(
    initialLocation: '/masjid-request',
    routes: <RouteBase>[
      GoRoute(
        path: '/masjid-request',
        builder: (context, state) => const MasjidRequestFormScreen(),
        routes: <RouteBase>[
          GoRoute(
            path: 'submitted',
            builder: (context, state) =>
                const Scaffold(body: Text('submitted page')),
          ),
        ],
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: testLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Types into the text field labelled [label] ([index] when the page has
/// several, such as committee members).
Future<void> _type(
  WidgetTester tester,
  String label,
  String text, {
  int index = 0,
}) async {
  final field = find.widgetWithText(TextFormField, label).at(index);
  await tester.ensureVisible(field);
  await tester.enterText(field, text);
  await tester.pump();
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _next(WidgetTester tester) =>
    _tap(tester, find.widgetWithText(FilledButton, 'Next'));

Future<void> _fillMasjid(WidgetTester tester) async {
  await _type(tester, 'Masjid name', 'Jama Masjid');
  await _next(tester);
}

Future<void> _fillPlace(WidgetTester tester) async {
  await _tap(tester, find.text('State'));
  await tester.tap(find.text('Bihar').last);
  await tester.pumpAndSettle();
  await _type(tester, 'District', 'Patna');
  await _type(tester, 'City or village', 'Barota');
  await _type(tester, 'Address', 'Main road');
  await _next(tester);
}

Future<void> _fillImam(
  WidgetTester tester, {
  String phone = '9800000000',
}) async {
  await _type(tester, 'Name', 'Imam Sahab');
  await _type(tester, 'Phone number', phone);
  await _type(tester, "Father's name", 'Abdul');
  await _type(tester, 'Age', '45');
  await _tap(tester, find.text('Man'));
  await _type(tester, 'Address', 'Near masjid');
  await _next(tester);
}

Future<void> _fillCommittee(
  WidgetTester tester, {
  String phone = '9800000001',
}) async {
  await _type(tester, 'Name', 'Rafiq');
  await _type(tester, 'Phone number', phone);
  await _type(tester, "Father's name", 'Karim');
  await _type(tester, 'Age', '50');
  await _tap(tester, find.text('Man'));
  await _next(tester);
}

Future<void> _fillRequester(WidgetTester tester) async {
  await _type(tester, 'Your name', 'Salim');
  await _type(tester, 'Your phone number', '9800000002');
  await _next(tester);
}

void main() {
  setUpAll(() => registerFallbackValue(_FakeRequest()));

  testWidgets('an empty page shows its messages and does not move on', (
    tester,
  ) async {
    final repository = _MockMasjidRequestRepository();
    await _pump(tester, repository);

    expect(find.text('Masjid'), findsWidgets);
    await _next(tester);

    expect(find.text('Please fill this in.'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Masjid name'), findsOneWidget);
    verifyZeroInteractions(repository);
  });

  testWidgets('India (the default) asks for a state and a district', (
    tester,
  ) async {
    await _pump(tester, _MockMasjidRequestRepository());
    await _fillMasjid(tester);

    expect(find.text('Country: India'), findsOneWidget);
    expect(find.text('State'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'District'), findsOneWidget);
  });

  testWidgets('the whole flow sends a cleaned request', (tester) async {
    final repository = _MockMasjidRequestRepository();
    when(() => repository.submitMasjidRequest(any())).thenAnswer((_) async {});
    await _pump(tester, repository);

    await _fillMasjid(tester);
    await _fillPlace(tester);
    await _fillImam(tester);
    await _fillCommittee(tester);
    await _fillRequester(tester);

    // Review page.
    expect(find.text('Jama Masjid'), findsOneWidget);
    expect(find.text('Barota, Patna, Bihar, India'), findsOneWidget);
    expect(find.text('1 member'), findsOneWidget);
    await _tap(tester, find.widgetWithText(FilledButton, 'Send request'));

    final request =
        verify(
              () => repository.submitMasjidRequest(captureAny()),
            ).captured.single
            as CreateMasjidRequest;
    expect(request.masjidName, 'Jama Masjid');
    expect(request.state, 'Bihar');
    expect(request.district, 'Patna');
    expect(request.imamPhone, '+919800000000');
    expect(request.imamGender, 'MALE');
    expect(request.committeeMembers.single.phone, '+919800000001');
    expect(request.requesterPhone, '+919800000002');
    expect(find.text('submitted page'), findsOneWidget);
  });

  testWidgets('the imam cannot also be on the committee', (tester) async {
    final repository = _MockMasjidRequestRepository();
    await _pump(tester, repository);

    await _fillMasjid(tester);
    await _fillPlace(tester);
    await _fillImam(tester);
    await _fillCommittee(tester, phone: '9800000000');

    expect(
      find.text('The imam cannot also be a committee member.'),
      findsOneWidget,
    );
    expect(find.text('Add member'), findsOneWidget);
    verifyZeroInteractions(repository);
  });

  testWidgets('committee members can be added; the last cannot be removed', (
    tester,
  ) async {
    await _pump(tester, _MockMasjidRequestRepository());
    await _fillMasjid(tester);
    await _fillPlace(tester);
    await _fillImam(tester);

    expect(find.text('Member 1'), findsOneWidget);
    expect(find.byTooltip('Remove member'), findsNothing);
    await _tap(tester, find.text('Add member'));
    expect(find.text('Member 2'), findsOneWidget);

    await _tap(tester, find.byTooltip('Remove member').last);
    expect(find.text('Member 2'), findsNothing);
    expect(find.byTooltip('Remove member'), findsNothing);
  });

  testWidgets('a phone already in another masjid is shown and marked', (
    tester,
  ) async {
    final repository = _MockMasjidRequestRepository();
    when(() => repository.submitMasjidRequest(any())).thenThrow(
      const ApiException(
        message:
            'Imam Sahab (+919800000000) is already registered with a '
            'different masjid. Please change the phone number.',
        code: ApiErrorCodes.userInAnotherMasjid,
        statusCode: 409,
        fieldErrors: <String, List<String>>{
          'phones': <String>['+919800000000'],
        },
      ),
    );
    await _pump(tester, repository);

    await _fillMasjid(tester);
    await _fillPlace(tester);
    await _fillImam(tester);
    await _fillCommittee(tester);
    await _fillRequester(tester);
    await _tap(tester, find.widgetWithText(FilledButton, 'Send request'));

    expect(find.text('Phone number already registered'), findsOneWidget);
    expect(find.textContaining('Imam Sahab (+919800000000)'), findsOneWidget);
    await _tap(tester, find.widgetWithText(FilledButton, 'OK'));

    // Back on the imam page with the phone marked.
    expect(find.text("Father's name"), findsOneWidget);
    expect(
      find.text('This number already belongs to another masjid.'),
      findsOneWidget,
    );

    // A different number clears the mark.
    await _type(tester, 'Phone number', '9811111111');
    await _next(tester);
    expect(
      find.text('This number already belongs to another masjid.'),
      findsNothing,
    );
  });
}
