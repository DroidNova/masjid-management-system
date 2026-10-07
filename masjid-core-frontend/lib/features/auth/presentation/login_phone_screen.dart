import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/providers.dart';
import 'package:masjid_core_frontend/features/auth/presentation/auth_error_text.dart';
import 'package:masjid_core_frontend/shared/models/country_code.dart';
import 'package:masjid_core_frontend/shared/utils/country_code_utils.dart';
import 'package:masjid_core_frontend/shared/widgets/app_button.dart';
import 'package:masjid_core_frontend/shared/widgets/app_phone_field.dart';

class LoginPhoneScreen extends ConsumerStatefulWidget {
  const LoginPhoneScreen({super.key});

  @override
  ConsumerState<LoginPhoneScreen> createState() => _LoginPhoneScreenState();
}

class _LoginPhoneScreenState extends ConsumerState<LoginPhoneScreen> {
  final TextEditingController _phoneController = TextEditingController();
  CountryCode _selectedCountry = getDefaultCountryCode();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final nationalPhone = _phoneController.text.trim();

    if (nationalPhone.isEmpty ||
        nationalPhone.length < (_selectedCountry.minLength ?? 6) ||
        nationalPhone.length > (_selectedCountry.maxLength ?? 15)) {
      _showError('Enter a valid phone number');
      return;
    }

    final phone = normalizePhone(
      countryCode: _selectedCountry,
      nationalNumber: nationalPhone,
    );

    setState(() => _isSubmitting = true);

    try {
      final response = await ref.read(authRepositoryProvider).startLogin(phone);

      if (!mounted) return;

      if (response.requiresOtp) {
        final challengeId = response.challengeId;
        if (challengeId == null || challengeId.isEmpty) {
          _showError('OTP challenge is missing. Please try again.');
          return;
        }

        context.go(
          '/login-otp',
          extra: <String, String>{
            'phone': response.phone,
            'challengeId': challengeId,
            'otpLength': response.otpLength.toString(),
          },
        );
        return;
      }

      if (response.requiresPassword) {
        context.go(
          '/login-password',
          extra: <String, String>{'phone': response.phone},
        );
        return;
      }

      _showError('Unsupported login step. Please try again.');
    } catch (error) {
      if (mounted) _showError(authErrorText(error));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'Login',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your phone number to continue',
                    style: textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppPhoneField(
                    phoneController: _phoneController,
                    initialCountry: _selectedCountry,
                    onCountryChanged: (country) => _selectedCountry = country,
                    isRequired: true,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Continue',
                    isLoading: _isSubmitting,
                    onPressed: _continue,
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'Back',
                    isOutlined: true,
                    onPressed: () => context.go('/auth'),
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
