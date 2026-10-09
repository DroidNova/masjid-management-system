import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/features/masjid_request/presentation/widgets/request_timeline.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// After a masjid request is sent: a big tick, what happens next as a
/// timeline, and the way to follow it.
class MasjidRequestSubmittedScreen extends StatelessWidget {
  const MasjidRequestSubmittedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: PageBody.form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  ScreenHeader(
                    icon: AppIcons.done,
                    tone: AppTones.done,
                    title: l10n.requestSent,
                    subtitle: l10n.requestSentHelp,
                    trailing: ReadAloudButton(
                      text: '${l10n.requestSent}. ${l10n.requestSentHelp}',
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpace.xl),
                      child: RequestTimeline(
                        status: 'PENDING',
                        requestedAt: DateTime.now(),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpace.xl),
                  FilledButton.icon(
                    onPressed: () => context.go('/masjid-request/track'),
                    icon: const Icon(AppIcons.track),
                    label: Text(l10n.trackRequest),
                  ),
                  const SizedBox(height: AppSpace.m),
                  OutlinedButton.icon(
                    onPressed: () => context.go('/auth'),
                    icon: const Icon(AppIcons.home),
                    label: Text(l10n.home),
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
