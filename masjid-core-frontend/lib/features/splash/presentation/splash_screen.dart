import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// Shown while the stored session is checked at startup. The auth state
/// (AuthController) and the router redirect decide where to go next.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const ToneIcon(
              icon: AppIcons.mosque,
              tone: AppTones.brand,
              size: 120,
              circle: true,
            ),
            const SizedBox(height: AppSpace.xl),
            Text(
              AppLocalizations.of(context).appTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpace.xl),
            const SizedBox.square(
              dimension: 32,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          ],
        ),
      ),
    );
  }
}
