// mocktail needs `when(() => mock.call())` closures, not tear-offs.
// ignore_for_file: unnecessary_lambdas

import 'package:flutter/material.dart';
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
import 'package:mocktail/mocktail.dart';

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
    container = ProviderContainer(
      overrides: [
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
        GoRoute(
          path: '/auth',
          builder: (context, state) => const Scaffold(body: Text('landing')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }
}

Future<void> _enterOtp(WidgetTester tester, String otp) async {
  final boxes = find.byType(TextField);
  for (var i = 0; i < otp.length; i++) {
    await tester.enterText(boxes.at(i), otp[i]);
  }
  await tester.pump();
}

void main() {
  late _MockAuthRepository repository;

  setUp(() => repository = _MockAuthRepository());

  group('LoginPhoneScreen', () {
    testWidgets('starts login and opens OTP with the server otpLength', (
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

      await tester.enterText(find.byType(TextFormField), '9876543210');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      final phone =
          verify(() => repository.startLogin(captureAny())).captured.single
              as String;
      expect(phone, endsWith('9876543210'));
      expect(harness.otpExtra, <String, String>{
        'phone': '+919876543210',
        'challengeId': 'c1',
        'otpLength': '6',
      });
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

      await tester.enterText(find.byType(TextFormField), '9876543210');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(harness.passwordExtra, <String, String>{'phone': '+919876543210'});
    });

    testWidgets('TOO_MANY_REQUESTS shows a wait hint, by code', (tester) async {
      when(() => repository.startLogin(any())).thenThrow(
        const ApiException(
          message: 'ThrottlerException: Too Many Requests',
          code: ApiErrorCodes.tooManyRequests,
          statusCode: 429,
        ),
      );
      final harness = _Harness(repository);
      await harness.pump(tester, '/login-phone');

      await tester.enterText(find.byType(TextFormField), '9876543210');
      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(
        find.text('Too many attempts. Please wait a minute and try again.'),
        findsOneWidget,
      );
      expect(find.byType(LoginPhoneScreen), findsOneWidget);
    });
  });

  group('LoginPasswordScreen', () {
    testWidgets('submits the password and opens OTP', (tester) async {
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
      await tester.tap(find.text('Continue'));
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

    testWidgets('INVALID_CREDENTIALS shows the message and clears the field', (
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
      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(find.text('Invalid phone or password'), findsOneWidget);
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, isEmpty);
    });
  });

  group('OtpScreen', () {
    testWidgets('verifies and signs in (router does the navigation)', (
      tester,
    ) async {
      when(
        () => repository.verifyOtp(any(), any(), any()),
      ).thenAnswer((_) async => _session);
      final harness = _Harness(repository);
      await harness.pump(tester, '/login-otp');

      await _enterOtp(tester, '1111');
      await tester.tap(find.text('Verify'));
      await tester.pump();

      verify(
        () => repository.verifyOtp('+919876543210', 'c1', '1111'),
      ).called(1);
      expect(harness.auth.signedIn, _session);
      // No navigation from the screen itself.
      expect(find.byType(OtpScreen), findsOneWidget);
    });

    testWidgets('OTP_EXPIRED offers to request a new OTP', (tester) async {
      when(() => repository.verifyOtp(any(), any(), any())).thenThrow(
        const ApiException(
          message: 'OTP has expired. Please request a new one.',
          code: ApiErrorCodes.otpExpired,
          statusCode: 400,
        ),
      );
      final harness = _Harness(repository);
      await harness.pump(tester, '/login-otp');

      await _enterOtp(tester, '1111');
      await tester.tap(find.text('Verify'));
      await tester.pumpAndSettle();

      expect(
        find.text('OTP has expired. Please request a new one.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Request new OTP'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginPhoneScreen), findsOneWidget);
      expect(harness.auth.signedIn, isNull);
    });

    testWidgets('OTP_INVALID shows the message and clears the boxes', (
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

      await _enterOtp(tester, '9999');
      await tester.tap(find.text('Verify'));
      await tester.pump();

      expect(find.text('Invalid OTP'), findsOneWidget);
      expect(find.text('Request new OTP'), findsNothing);
      for (final field in tester.widgetList<TextField>(
        find.byType(TextField),
      )) {
        expect(field.controller!.text, isEmpty);
      }
    });
  });
}
