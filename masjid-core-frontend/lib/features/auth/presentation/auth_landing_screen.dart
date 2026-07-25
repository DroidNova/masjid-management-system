import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:platform_core_frontend/shared/widgets/app_button.dart';

class AuthLandingScreen extends StatelessWidget {
  const AuthLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Icon(
                Icons.mosque_outlined,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Masjid Core',
                textAlign: TextAlign.center,
                style: textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Simple masjid management for your community',
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 40),
              AppButton(
                label: 'Login',
                onPressed: () => context.go('/login-phone'),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Register Your Masjid',
                isOutlined: true,
                onPressed: () => context.go('/masjid-request'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.go('/masjid-request/track'),
                child: const Text('Track your application'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
