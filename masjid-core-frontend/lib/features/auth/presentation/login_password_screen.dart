import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:platform_core_frontend/features/auth/data/auth_repository.dart';
import 'package:platform_core_frontend/shared/widgets/app_button.dart';
import 'package:platform_core_frontend/shared/widgets/app_text_field.dart';

class LoginPasswordScreen extends StatefulWidget {
  const LoginPasswordScreen({
    super.key,
    required this.phone,
    AuthRepository? authRepository,
  }) : _authRepository = authRepository;

  final String phone;
  final AuthRepository? _authRepository;

  @override
  State<LoginPasswordScreen> createState() => _LoginPasswordScreenState();
}

class _LoginPasswordScreenState extends State<LoginPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  late final AuthRepository _authRepository =
      widget._authRepository ?? AuthRepository();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final password = _passwordController.text.trim();

    if (password.isEmpty) {
      _showError('Please enter your password.');
      return;
    }

    if (password.length < 6) {
      _showError('Password must be at least 6 characters.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _authRepository.submitPassword(
        widget.phone,
        password,
      );

      if (!mounted) return;

      final challengeId = response.challengeId;
      if (!response.requiresOtp || challengeId == null || challengeId.isEmpty) {
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
      appBar: AppBar(title: const Text('Enter Password')),
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
                    'Enter Password',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Password is required for admin/imam/committee login',
                    style: textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppTextField(
                    controller: _passwordController,
                    label: 'Password',
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
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
                    onPressed: () => context.go('/login-phone'),
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
