import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/providers.dart';
import 'package:masjid_core_frontend/features/auth/presentation/auth_error_text.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/models/country_code.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';
import 'package:masjid_core_frontend/shared/utils/country_code_utils.dart';

/// Login step 1: the phone number, typed on big number keys.
class LoginPhoneScreen extends ConsumerStatefulWidget {
  const LoginPhoneScreen({super.key});

  @override
  ConsumerState<LoginPhoneScreen> createState() => _LoginPhoneScreenState();
}

class _LoginPhoneScreenState extends ConsumerState<LoginPhoneScreen> {
  CountryCode _country = getDefaultCountryCode();
  String _digits = '';
  bool _isSubmitting = false;
  String? _error;

  bool get _isValid => PhoneEntry.isValid(_country, _digits);

  Future<void> _continue() async {
    final l10n = AppLocalizations.of(context);
    if (!_isValid || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final response = await ref
          .read(authRepositoryProvider)
          .startLogin(
            normalizePhone(countryCode: _country, nationalNumber: _digits),
          );
      if (!mounted) return;

      final challengeId = response.challengeId;
      if (response.requiresOtp &&
          challengeId != null &&
          challengeId.isNotEmpty) {
        await context.push(
          '/login-otp',
          extra: <String, String>{
            'phone': response.phone,
            'challengeId': challengeId,
            'otpLength': response.otpLength.toString(),
          },
        );
      } else if (response.requiresPassword) {
        await context.push(
          '/login-password',
          extra: <String, String>{'phone': response.phone},
        );
      } else {
        setState(() => _error = l10n.somethingWentWrong);
      }
    } catch (error) {
      if (mounted) setState(() => _error = authErrorText(l10n, error));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
                ScreenHeader(icon: AppIcons.phone, title: l10n.yourPhoneNumber),
                PhoneEntry(
                  country: _country,
                  digits: _digits,
                  enabled: !_isSubmitting,
                  onCountryChanged: (country) => setState(() {
                    _country = country;
                    _digits = '';
                  }),
                  onDigitsChanged: (digits) => setState(() {
                    _digits = digits;
                    _error = null;
                  }),
                ),
                const SizedBox(height: AppSpace.l),
                if (error != null) ...<Widget>[
                  MessageBanner(text: error),
                  const SizedBox(height: AppSpace.l),
                ],
                BusyButton(
                  label: l10n.continueLabel,
                  icon: AppIcons.next,
                  busy: _isSubmitting,
                  onPressed: _isValid ? _continue : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
