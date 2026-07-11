import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:platform_core_frontend/features/auth/data/auth_repository.dart';
import 'package:platform_core_frontend/shared/widgets/app_button.dart';
import 'package:platform_core_frontend/shared/models/country_code.dart';
import 'package:platform_core_frontend/shared/utils/country_code_utils.dart';
import 'package:platform_core_frontend/shared/widgets/app_phone_field.dart';

class LoginPhoneScreen extends StatefulWidget {
  const LoginPhoneScreen({super.key, AuthRepository? authRepository})
      : _authRepository = authRepository;

  final AuthRepository? _authRepository;

  @override
  State<LoginPhoneScreen> createState() => _LoginPhoneScreenState();
}

class _LoginPhoneScreenState extends State<LoginPhoneScreen> {
  final TextEditingController _phoneController = TextEditingController();
  late final AuthRepository _authRepository =
      widget._authRepository ?? AuthRepository();
  CountryCode _selectedCountry = getDefaultCountryCode();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final parts = parsePhoneNumber(_phoneController.text);
    final phone = normalizePhone(
      countryCode: _selectedCountry,
      nationalNumber: parts.nationalNumber,
    );

    final min = _selectedCountry.minLength ?? 6;
    final max = _selectedCountry.maxLength ?? 15;
    if (parts.nationalNumber.length < min || parts.nationalNumber.length > max) {
      _showError('Enter a valid phone number');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _authRepository.startLogin(phone);

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
      if (mounted) _showError(_cleanError(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
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
                    label: 'Phone number',
                    required: true,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Continue',
                    isLoading: _isLoading,
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
