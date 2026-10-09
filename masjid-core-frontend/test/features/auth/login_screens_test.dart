// mocktail needs `when(() => mock.call())` closures, not tear-offs.
// ignore_for_file: unnecessary_lambdas

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/core/providers.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/auth/data/auth_repository.dart';
import 'package:masjid_core_frontend/features/auth/data/models/app_user.dart';
import 'package:masjid_core_frontend/features/auth/data/models/auth_session.dart';
import 'package:masjid_core_frontend/features/auth/data/models/login_start_response.dart';
import 'package:masjid_core_frontend/features/auth/presentation/login_password_screen.dart';
import 'package:masjid_core_frontend/features/auth/presentation/login_phone_screen.dart';
import 'package:masjid_core_frontend/features/auth/presentation/otp_screen.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

import '../../shared/ui/ui_test_helpers.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

/// Auth state without storage; records sign-ins.
class _FakeAuth extends AuthController {
  AuthSession? signedIn;

  @override
  AuthState build() => const AuthSignedOut();

  @override
  void signIn(AuthSession session) {
    signedIn = session;
    state = AuthSignedIn(session.user);
  }
}

const _session = AuthSession(
  user: AppUser(id: 'u1', fullName: 'Imam Sahab'),
  tokens: AuthTokens(accessToken: 'a', refreshToken: 'r'),
);

class _Harness {
  _Harness(this.repository);

  final _MockAuthRepository repository;
  late final ProviderContainer container;
  late final GoRouter router;
  Object? otpExtra;
  Object? passwordExtra;

  _FakeAuth get auth =>
      container.read(authControllerProvider.notifier) as _FakeAuth;

  Future<void> pump(WidgetTester tester, String initialLocation) async {
    tester.view.physicalSize = const Size(420, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    container = ProviderContainer(
      overrides: [
        ...await testAppOverrides(),
        authRepositoryProvider.overrideWithValue(repository),
        authControllerProvider.overrideWith(_FakeAuth.new),
      ],
    );
    addTearDown(container.dispose);
    router = GoRouter(
      initialLocation: initialLocation,
      routes: <RouteBase>[
        GoRoute(
          path: '/login-phone',
          builder: (context, state) => const LoginPhoneScreen(),
        ),
        GoRoute(
          path: '/login-password',
          builder: (context, state) {
            passwordExtra = state.extra;
            return const LoginPasswordScreen(phone: '+919876543210');
          },
        ),
        GoRoute(
          path: '/login-otp',
          builder: (context, state) {
            otpExtra = state.extra;
            return const OtpScreen(
              phone: '+919876543210',
              challengeId: 'c1',
              otpLength: 4,
            );
          },
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
}

Finder _button(String label) => find.widgetWithText(FilledButton, label);

void main() {
  late _MockAuthRepository repository;

  setUp(() => repository = _MockAuthRepository());

  group('LoginPhoneScreen', () {
    testWidgets('Continue waits for a full number, then opens the code step', (
      tester,
    ) async {
      when(() => repository.startLogin(any())).thenAnswer(
        (_) async => const LoginStartResponse(
          nextStep: 'OTP_REQUIRED',
          phone: '+919876543210',
          challengeId: 'c1',
          otpLength: 6,
        ),
      );
      final harness = _Harness(repository);
      await harness.pump(tester, '/login-phone');

      await tapKeypad(tester, '98765');
      expect(
        tester.widget<FilledButton>(_button('Continue')).onPressed,
        isNull,
      );
      expect(find.text('98765'), findsOneWidget);

      await tapKeypad(tester, '43210');
      expect(find.text('98765 43210'), findsOneWidget);
      await tester.tap(_button('Continue'));
      await tester.pumpAndSettle();

      verify(() => repository.startLogin('+919876543210')).called(1);
      expect(harness.otpExtra, <String, String>{
        'phone': '+919876543210',
        'challengeId': 'c1',
        'otpLength': '6',
      });
    });

    testWidgets('a computer keyboard can type the number and press Enter', (
      tester,
    ) async {
      when(() => repository.startLogin(any())).thenAnswer(
        (_) async => const LoginStartResponse(
          nextStep: 'OTP_REQUIRED',
          phone: '+919876543210',
          challengeId: 'c1',
        ),
      );
      final harness = _Harness(repository);
      await harness.pump(tester, '/login-phone');

      for (final digit in '9876543210'.split('')) {
        await tester.sendKeyEvent(
          LogicalKeyboardKey(
            LogicalKeyboardKey.digit0.keyId + int.parse(digit),
          ),
        );
        // A real keyboard gets a frame between key presses.
        await tester.pump();
      }
      await tester.pump();
      expect(find.text('98765 43210'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      verify(() => repository.startLogin('+919876543210')).called(1);
      expect(harness.otpExtra, isNotNull);
    });

    testWidgets('goes to the password step when the server asks', (
      tester,
    ) async {
      when(() => repository.startLogin(any())).thenAnswer(
        (_) async => const LoginStartResponse(
          nextStep: 'PASSWORD_REQUIRED',
          phone: '+919876543210',
        ),
      );
      final harness = _Harness(repository);
      await harness.pump(tester, '/login-phone');

      await tapKeypad(tester, '9876543210');
      await tester.tap(_button('Continue'));
      await tester.pumpAndSettle();

      expect(harness.passwordExtra, <String, String>{'phone': '+919876543210'});
    });

    testWidgets('TOO_MANY_REQUESTS shows the wait message on the page', (
      tester,
    ) async {
      when(() => repository.startLogin(any())).thenThrow(
        const ApiException(
          message: 'ThrottlerException: Too Many Requests',
          code: ApiErrorCodes.tooManyRequests,
          statusCode: 429,
        ),
      );
      final harness = _Harness(repository);
      await harness.pump(tester, '/login-phone');

      await tapKeypad(tester, '9876543210');
      await tester.tap(_button('Continue'));
      await tester.pump();

      expect(
        find.text('Too many tries. Please wait a minute and try again.'),
        findsOneWidget,
      );
      expect(find.byType(LoginPhoneScreen), findsOneWidget);
    });
  });

  group('LoginPasswordScreen', () {
    testWidgets('submits the password and opens the code step', (tester) async {
      when(() => repository.submitPassword(any(), any())).thenAnswer(
        (_) async => const LoginStartResponse(
          nextStep: 'OTP_REQUIRED',
          phone: '+919876543210',
          challengeId: 'c2',
        ),
      );
      final harness = _Harness(repository);
      await harness.pump(tester, '/login-password');

      await tester.enterText(find.byType(TextField), 'secret123');
      await tester.pump();
      await tester.tap(_button('Continue'));
      await tester.pumpAndSettle();

      verify(
        () => repository.submitPassword('+919876543210', 'secret123'),
      ).called(1);
      expect(harness.otpExtra, <String, String>{
        'phone': '+919876543210',
        'challengeId': 'c2',
        'otpLength': '${LoginStartResponse.defaultOtpLength}',
      });
    });

    testWidgets('a wrong password shows the message and clears the field', (
      tester,
    ) async {
      when(() => repository.submitPassword(any(), any())).thenThrow(
        const ApiException(
          message: 'Invalid phone or password',
          code: ApiErrorCodes.invalidCredentials,
          statusCode: 401,
        ),
      );
      final harness = _Harness(repository);
      await harness.pump(tester, '/login-password');

      await tester.enterText(find.byType(TextField), 'wrongpass');
      await tester.pump();
      await tester.tap(_button('Continue'));
      await tester.pump();

      expect(find.text('Wrong password. Please try again.'), findsOneWidget);
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, isEmpty);
    });
  });

  group('OtpScreen', () {
    testWidgets('shows one box per digit and checks the code by itself', (
      tester,
    ) async {
      when(
        () => repository.verifyOtp(any(), any(), any()),
      ).thenAnswer((_) async => _session);
      final harness = _Harness(repository);
      await harness.pump(tester, '/login-otp');

      final boxes = tester.widget<CodeBoxes>(find.byType(CodeBoxes));
      expect(boxes.length, 4);

      await tapKeypad(tester, '1111');
      await tester.pump();

      verify(
        () => repository.verifyOtp('+919876543210', 'c1', '1111'),
      ).called(1);
      expect(harness.auth.signedIn, _session);
      // No navigation from the screen itself; the router does it.
      expect(find.byType(OtpScreen), findsOneWidget);
    });

    testWidgets('an expired code offers a new one for the same phone', (
      tester,
    ) async {
      when(() => repository.verifyOtp(any(), any(), any())).thenThrow(
        const ApiException(
          message: 'OTP has expired. Please request a new one.',
          code: ApiErrorCodes.otpExpired,
          statusCode: 400,
        ),
      );
      when(() => repository.startLogin(any())).thenAnswer(
        (_) async => const LoginStartResponse(
          nextStep: 'OTP_REQUIRED',
          phone: '+919876543210',
          challengeId: 'c9',
        ),
      );
      final harness = _Harness(repository);
      await harness.pump(tester, '/login-otp');

      await tapKeypad(tester, '1111');
      await tester.pumpAndSettle();

      expect(
        find.text('This code has expired. Get a new code.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Send new code'));
      await tester.pumpAndSettle();

      verify(() => repository.startLogin('+919876543210')).called(1);
      expect(find.text('A new code has been sent.'), findsOneWidget);
      expect(harness.auth.signedIn, isNull);

      // The next code is checked against the new challenge.
      when(
        () => repository.verifyOtp(any(), any(), any()),
      ).thenAnswer((_) async => _session);
      await tapKeypad(tester, '2222');
      await tester.pump();
      verify(
        () => repository.verifyOtp('+919876543210', 'c9', '2222'),
      ).called(1);
    });

    testWidgets('a wrong code shows the message and empties the boxes', (
      tester,
    ) async {
      when(() => repository.verifyOtp(any(), any(), any())).thenThrow(
        const ApiException(
          message: 'Invalid OTP',
          code: ApiErrorCodes.otpInvalid,
          statusCode: 400,
        ),
      );
      final harness = _Harness(repository);
      await harness.pump(tester, '/login-otp');

      await tapKeypad(tester, '9999');
      await tester.pump();

      expect(find.text('Wrong code. Please try again.'), findsOneWidget);
      expect(find.text('Send new code'), findsNothing);
      expect(tester.widget<CodeBoxes>(find.byType(CodeBoxes)).code, isEmpty);
    });
  });
}
