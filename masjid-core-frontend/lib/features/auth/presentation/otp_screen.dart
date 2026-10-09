import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/core/providers.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/auth/presentation/auth_error_text.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// Login's last step: the code sent by SMS, typed on big number keys. It is
/// checked as soon as the last digit is in, with no extra button to find.
///
/// SMS auto-fill arrives with the real SMS provider (milestone M6); it will
/// feed [_code] the same way the keys do.
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({
    super.key,
    required this.phone,
    required this.challengeId,
    required this.otpLength,
  });

  final String phone;
  final String challengeId;

  /// Number of digits the server expects (4 in development: 1111).
  final int otpLength;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  late String _challengeId = widget.challengeId;
  late int _otpLength = widget.otpLength;
  String _code = '';
  bool _verifying = false;
  bool _resending = false;
  String? _error;
  bool _expired = false;
  bool _newCodeSent = false;

  void _onKey(String key) {
    if (_verifying) return;
    setState(() {
      _error = null;
      _newCodeSent = false;
      if (key == NumberKeypad.backspace) {
        if (_code.isNotEmpty) _code = _code.substring(0, _code.length - 1);
      } else if (_code.length < _otpLength) {
        _code = '$_code$key';
      }
    });
    if (_code.length == _otpLength) _verify();
  }

  Future<void> _verify() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _verifying = true);
    try {
      final session = await ref
          .read(authRepositoryProvider)
          .verifyOtp(widget.phone, _challengeId, _code);
      if (!mounted) return;
      // The router moves the signed-in user to their home page.
      ref.read(authControllerProvider.notifier).signIn(session);
    } catch (error) {
      if (!mounted) return;
      final code = apiErrorCode(error);
      setState(() {
        _error = authErrorText(l10n, error);
        _expired =
            code == ApiErrorCodes.otpExpired ||
            code == ApiErrorCodes.otpChallengeInvalid;
        // A wrong or dead code is cleared so the next try starts fresh.
        _code = '';
        _verifying = false;
      });
    }
  }

  /// Starts the login again for the same phone to get a new code.
  Future<void> _sendNewCode() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _resending = true;
      _error = null;
    });
    try {
      final response = await ref
          .read(authRepositoryProvider)
          .startLogin(widget.phone);
      if (!mounted) return;
      final challengeId = response.challengeId;
      if (!response.requiresOtp || challengeId == null || challengeId.isEmpty) {
        // This account needs its password first.
        context.go('/login-phone');
        return;
      }
      setState(() {
        _challengeId = challengeId;
        _otpLength = response.otpLength;
        _code = '';
        _expired = false;
        _newCodeSent = true;
      });
    } catch (error) {
      if (mounted) setState(() => _error = authErrorText(l10n, error));
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final error = _error;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.login)),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: PageBody.form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                ScreenHeader(
                  icon: AppIcons.code,
                  title: l10n.enterCode,
                  subtitle: l10n.codeSentTo(widget.phone),
                ),
                CodeBoxes(
                  length: _otpLength,
                  code: _code,
                  hasError: error != null,
                ),
                const SizedBox(height: AppSpace.l),
                if (_verifying)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      ),
                      const SizedBox(width: AppSpace.m),
                      Text(l10n.pleaseWait),
                    ],
                  ),
                if (error != null)
                  MessageBanner(
                    text: error,
                    action: _expired
                        ? BusyButton(
                            label: l10n.sendNewCode,
                            icon: AppIcons.send,
                            busy: _resending,
                            onPressed: _sendNewCode,
                          )
                        : null,
                  ),
                if (_newCodeSent)
                  MessageBanner(text: l10n.newCodeSent, kind: StatusKind.done),
                const SizedBox(height: AppSpace.l),
                Center(
                  child: NumberKeypad(
                    onKey: _onKey,
                    enabled: !_verifying && !_resending,
                  ),
                ),
                const SizedBox(height: AppSpace.m),
                TextButton.icon(
                  onPressed: () => context.go('/login-phone'),
                  icon: const Icon(AppIcons.phone),
                  label: Text(l10n.changeNumber),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One box per code digit; the next empty box is highlighted.
class CodeBoxes extends StatelessWidget {
  const CodeBoxes({
    super.key,
    required this.length,
    required this.code,
    this.hasError = false,
  });

  final int length;
  final String code;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      liveRegion: true,
      value: code,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(length, (index) {
            final filled = index < code.length;
            final current = index == code.length;
            final borderColor = hasError
                ? AppTones.problem.color
                : current || filled
                ? AppTones.brand.color
                : AppColors.border;
            return Flexible(
              child: Container(
                width: 60,
                height: 68,
                margin: const EdgeInsets.symmetric(horizontal: AppSpace.xs),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.m),
                  border: Border.all(
                    color: borderColor,
                    width: current ? 3 : 2,
                  ),
                ),
                child: Text(
                  filled ? code[index] : '',
                  style: textTheme.headlineMedium,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
