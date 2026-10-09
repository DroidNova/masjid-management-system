import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/errors/error_text.dart';
import 'package:masjid_core_frontend/features/masjid_request/application/track_application_controller.dart';
import 'package:masjid_core_frontend/features/masjid_request/data/models/track_masjid_application_result.dart';
import 'package:masjid_core_frontend/features/masjid_request/presentation/widgets/request_timeline.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/models/country_code.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';
import 'package:masjid_core_frontend/shared/utils/country_code_utils.dart';

/// Public: look up masjid requests by the requester's phone number and see
/// each one's progress as a timeline.
class TrackMasjidApplicationScreen extends ConsumerStatefulWidget {
  const TrackMasjidApplicationScreen({super.key});

  @override
  ConsumerState<TrackMasjidApplicationScreen> createState() =>
      _TrackMasjidApplicationScreenState();
}

class _TrackMasjidApplicationScreenState
    extends ConsumerState<TrackMasjidApplicationScreen> {
  CountryCode _country = getDefaultCountryCode();
  String _digits = '';

  Future<void> _track() async {
    if (!PhoneEntry.isValid(_country, _digits)) return;
    await ref
        .read(trackApplicationControllerProvider.notifier)
        .track(normalizePhone(countryCode: _country, nationalNumber: _digits));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final result = ref.watch(trackApplicationControllerProvider);
    final isLoading = result?.isLoading ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.trackRequest),
        leading: Navigator.canPop(context)
            ? null
            : IconButton(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                icon: const BackButtonIcon(),
                onPressed: () => context.go('/auth'),
              ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: PageBody.form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                ScreenHeader(
                  icon: AppIcons.track,
                  tone: AppTones.namaz,
                  title: l10n.trackRequest,
                  subtitle: l10n.trackHelp,
                ),
                PhoneEntry(
                  country: _country,
                  digits: _digits,
                  enabled: !isLoading,
                  onCountryChanged: (country) => setState(() {
                    _country = country;
                    _digits = '';
                  }),
                  onDigitsChanged: (digits) => setState(() => _digits = digits),
                ),
                const SizedBox(height: AppSpace.l),
                BusyButton(
                  label: l10n.check,
                  icon: AppIcons.search,
                  busy: isLoading,
                  color: AppTones.namaz.color,
                  onPressed: PhoneEntry.isValid(_country, _digits)
                      ? _track
                      : null,
                ),
                const SizedBox(height: AppSpace.xl),
                if (result != null && !result.isLoading)
                  ..._results(l10n, result),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _results(
    AppLocalizations l10n,
    AsyncValue<List<TrackMasjidApplicationResult>> result,
  ) {
    final error = result.error;
    if (error != null) {
      return <Widget>[MessageBanner(text: errorText(l10n, error))];
    }
    final items = result.value ?? const <TrackMasjidApplicationResult>[];
    if (items.isEmpty) {
      return <Widget>[
        MessageBanner(text: l10n.noRequestFound, kind: StatusKind.neutral),
      ];
    }
    return items.map((item) => _ApplicationCard(item: item)).toList();
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({required this.item});

  final TrackMasjidApplicationResult item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final status = item.status.toUpperCase();
    final imam = item.imamName;
    final (StatusKind kind, String label) = switch (status) {
      'APPROVED' => (StatusKind.done, l10n.stepApproved),
      'REJECTED' => (StatusKind.problem, l10n.stepRejected),
      _ => (StatusKind.waiting, l10n.stepChecking),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.l),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const ToneIcon(icon: AppIcons.mosque, tone: AppTones.namaz),
                  const SizedBox(width: AppSpace.m),
                  Expanded(
                    child: Text(item.masjidName, style: textTheme.titleLarge),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.m),
              StatusBadge(kind: kind, label: label),
              if (imam != null && imam.isNotEmpty) ...<Widget>[
                const SizedBox(height: AppSpace.m),
                Row(
                  children: <Widget>[
                    const Icon(AppIcons.imam, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpace.s),
                    Expanded(child: Text(imam, style: textTheme.bodyLarge)),
                  ],
                ),
              ],
              const Divider(height: AppSpace.xxl),
              RequestTimeline(
                status: item.status,
                requestedAt: item.requestedAt,
                reviewedAt: item.reviewedAt,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
