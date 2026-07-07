import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:platform_core_frontend/core/permissions/permission_helper.dart';
import 'package:platform_core_frontend/features/auth/data/auth_repository.dart';
import 'package:platform_core_frontend/shared/widgets/app_button.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({
    super.key,
    required this.phone,
    required this.challengeId,
    AuthRepository? authRepository,
  }) : _authRepository = authRepository;

  final String phone;
  final String challengeId;
  final AuthRepository? _authRepository;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const int _otpLength = 6;

  late final List<TextEditingController> _controllers =
      List<TextEditingController>.generate(
    _otpLength,
    (_) => TextEditingController(),
  );
  late final List<FocusNode> _focusNodes = List<FocusNode>.generate(
    _otpLength,
    (_) => FocusNode(),
  );
  late final AuthRepository _authRepository =
      widget._authRepository ?? AuthRepository();
  bool _isLoading = false;

  bool get _isOtpComplete {
    return _controllers.every((controller) => controller.text.length == 1);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNodes.first.requestFocus();
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  Future<void> _verify() async {
    if (!_isOtpComplete) return;

    final otp = _controllers.map((controller) => controller.text).join();
    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      _showError('OTP must be 6 digits.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final session = await _authRepository.verifyOtp(
        widget.phone,
        widget.challengeId,
        otp,
      );

      if (!mounted) return;

      context.go(
        PermissionHelper.isSuperAdmin(session.user) ? '/super-admin' : '/main',
      );
    } catch (error) {
      if (mounted) _showError(_cleanError(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onOtpChanged(int index, String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 1) {
      _fillFromPaste(index, digits);
      return;
    }

    if (digits != value) {
      _controllers[index].text = digits;
      _controllers[index].selection = TextSelection.collapsed(
        offset: digits.length,
      );
    }

    if (digits.isNotEmpty && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    setState(() {});
  }

  KeyEventResult _onOtpKey(int index, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey != LogicalKeyboardKey.backspace) {
      return KeyEventResult.ignored;
    }
    if (_controllers[index].text.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].selection = TextSelection.collapsed(
        offset: _controllers[index - 1].text.length,
      );
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _fillFromPaste(int startIndex, String rawDigits) {
    final digits = rawDigits.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return;

    var currentIndex = startIndex;
    for (final digit in digits.split('').take(_otpLength - startIndex)) {
      _controllers[currentIndex].text = digit;
      currentIndex++;
      if (currentIndex >= _otpLength) break;
    }

    final focusIndex = currentIndex >= _otpLength ? _otpLength - 1 : currentIndex;
    _focusNodes[focusIndex].requestFocus();
    _controllers[focusIndex].selection = TextSelection.collapsed(
      offset: _controllers[focusIndex].text.length,
    );
    setState(() {});
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
      appBar: AppBar(title: const Text('Verify OTP')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'Verify OTP',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter the 6 digit code sent to your phone',
                    style: textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List<Widget>.generate(_otpLength, _buildOtpBox),
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Verify',
                    isLoading: _isLoading,
                    onPressed: _isOtpComplete ? _verify : null,
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


  TextInputFormatter _pasteFormatter(int index) {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
      if (digits.length <= 1) return newValue;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _fillFromPaste(index, digits);
      });
      return oldValue;
    });
  }

  Widget _buildOtpBox(int index) {
    return Flexible(
      child: Padding(
        padding: EdgeInsets.only(right: index == _otpLength - 1 ? 0 : 8),
        child: Focus(
          onKeyEvent: (_, event) => _onOtpKey(index, event),
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textInputAction: index == _otpLength - 1
                ? TextInputAction.done
                : TextInputAction.next,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
            inputFormatters: <TextInputFormatter>[
              _pasteFormatter(index),
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(1),
            ],
            decoration: InputDecoration(
              counterText: '',
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
            onChanged: (value) => _onOtpChanged(index, value),
            onSubmitted: (_) {
              if (_isOtpComplete) _verify();
            },
          ),
        ),
      ),
    );
  }
}
