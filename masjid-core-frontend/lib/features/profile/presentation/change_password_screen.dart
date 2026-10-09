import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/errors/error_text.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/core/providers.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// Change password (imam, committee, admins): the current one, then the new
/// one twice. Other devices are signed out by the server; this one stays.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  static const int minLength = 8;

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _current = TextEditingController();
  final TextEditingController _new = TextEditingController();
  final TextEditingController _repeat = TextEditingController();
  bool _obscure = true;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _repeat.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .changePassword(
            currentPassword: _current.text,
            newPassword: _new.text,
          );
      if (!mounted) return;
      await showSuccess(context, title: l10n.passwordChanged);
      if (mounted) context.pop();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = switch (apiErrorCode(error)) {
          ApiErrorCodes.invalidCredentials => l10n.errorWrongCurrentPassword,
          ApiErrorCodes.passwordUnchanged => l10n.errorSamePassword,
          _ => errorText(l10n, error),
        };
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    required FormFieldValidator<String> validator,
    TextInputAction action = TextInputAction.next,
    Iterable<String> autofill = const <String>[AutofillHints.newPassword],
  }) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.l),
      child: TextFormField(
        controller: controller,
        obscureText: _obscure,
        enabled: !_saving,
        textInputAction: action,
        autofillHints: autofill,
        validator: validator,
        onFieldSubmitted: action == TextInputAction.done
            ? (_) => _save()
            : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(AppIcons.password),
          suffixIcon: IconButton(
            tooltip: _obscure ? l10n.showPassword : l10n.hidePassword,
            icon: Icon(
              _obscure ? AppIcons.showPassword : AppIcons.hidePassword,
            ),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final error = _error;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.changePassword)),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: PageBody.form(
            child: Form(
              key: _formKey,
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    ScreenHeader(
                      icon: AppIcons.password,
                      title: l10n.changePassword,
                      subtitle: l10n.changePasswordHelp,
                    ),
                    _field(
                      _current,
                      l10n.currentPassword,
                      autofill: const <String>[AutofillHints.password],
                      validator: (value) =>
                          (value ?? '').isEmpty ? l10n.fieldRequired : null,
                    ),
                    _field(
                      _new,
                      l10n.newPassword,
                      validator: (value) =>
                          (value ?? '').length < ChangePasswordScreen.minLength
                          ? l10n.passwordTooShort(
                              ChangePasswordScreen.minLength,
                            )
                          : null,
                    ),
                    _field(
                      _repeat,
                      l10n.repeatNewPassword,
                      action: TextInputAction.done,
                      validator: (value) =>
                          value != _new.text ? l10n.passwordsDiffer : null,
                    ),
                    if (error != null) ...<Widget>[
                      MessageBanner(text: error),
                      const SizedBox(height: AppSpace.l),
                    ],
                    BusyButton(
                      label: l10n.save,
                      icon: AppIcons.done,
                      busy: _saving,
                      onPressed: _save,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
