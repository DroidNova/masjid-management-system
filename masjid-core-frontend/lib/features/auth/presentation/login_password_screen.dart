import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/format/formatters.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/core/providers.dart';
import 'package:masjid_core_frontend/features/auth/presentation/auth_error_text.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// Login step 2 for people with a password (imam, committee): the
/// password, then the code.
class LoginPasswordScreen extends ConsumerStatefulWidget {
  const LoginPasswordScreen({super.key, required this.phone});

  final String phone;

  @override
  ConsumerState<LoginPasswordScreen> createState() =>
      _LoginPasswordScreenState();
}

class _LoginPasswordScreenState extends ConsumerState<LoginPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isSubmitting = false;
  bool _obscure = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final l10n = AppLocalizations.of(context);
    final password = _passwordController.text;
    if (password.isEmpty || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final response = await ref
          .read(authRepositoryProvider)
          .submitPassword(widget.phone, password);
      if (!mounted) return;

      final challengeId = response.challengeId;
      if (!response.requiresOtp || challengeId == null || challengeId.isEmpty) {
        setState(() => _error = l10n.somethingWentWrong);
        return;
      }
      await context.push(
        '/login-otp',
        extra: <String, String>{
          'phone': response.phone,
          'challengeId': challengeId,
          'otpLength': response.otpLength.toString(),
        },
      );
    } catch (error) {
      if (!mounted) return;
      if (apiErrorCode(error) == ApiErrorCodes.invalidCredentials) {
        // Wrong password: clear the field so it can be typed again.
        _passwordController.clear();
      }
      setState(() => _error = authErrorText(l10n, error));
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
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  ScreenHeader(
                    icon: AppIcons.password,
                    title: l10n.yourPassword,
                    subtitle: AppFormat.phone(widget.phone),
                  ),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscure,
                    autofocus: true,
                    enabled: !_isSubmitting,
                    textInputAction: TextInputAction.done,
                    autofillHints: const <String>[AutofillHints.password],
                    onSubmitted: (_) => _continue(),
                    style: Theme.of(context).textTheme.titleLarge,
                    decoration: InputDecoration(
                      labelText: l10n.password,
                      prefixIcon: const Icon(AppIcons.password),
                      suffixIcon: IconButton(
                        tooltip: _obscure
                            ? l10n.showPassword
                            : l10n.hidePassword,
                        icon: Icon(
                          _obscure
                              ? AppIcons.showPassword
                              : AppIcons.hidePassword,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
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
                    onPressed: _passwordController.text.isEmpty
                        ? null
                        : _continue,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
