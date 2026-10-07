import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/errors/user_message.dart';
import 'package:masjid_core_frontend/core/format/formatters.dart';
import 'package:masjid_core_frontend/features/masjid_request/application/track_application_controller.dart';
import 'package:masjid_core_frontend/features/masjid_request/data/models/track_masjid_application_result.dart';
import 'package:masjid_core_frontend/shared/models/country_code.dart';
import 'package:masjid_core_frontend/shared/utils/country_code_utils.dart';
import 'package:masjid_core_frontend/shared/widgets/app_button.dart';
import 'package:masjid_core_frontend/shared/widgets/app_phone_field.dart';

/// Public: look up masjid applications by the requester's phone number.
class TrackMasjidApplicationScreen extends ConsumerStatefulWidget {
  const TrackMasjidApplicationScreen({super.key});

  @override
  ConsumerState<TrackMasjidApplicationScreen> createState() =>
      _TrackMasjidApplicationScreenState();
}

class _TrackMasjidApplicationScreenState
    extends ConsumerState<TrackMasjidApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  CountryCode _selectedCountry = getDefaultCountryCode();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _trackApplication() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(trackApplicationControllerProvider.notifier)
        .track(
          normalizePhone(
            countryCode: _selectedCountry,
            nationalNumber: _phoneController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final result = ref.watch(trackApplicationControllerProvider);
    final isLoading = result?.isLoading ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Application'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/auth'),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        'Track Application',
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter the phone number used during masjid registration.',
                        style: textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 20),
                      AppPhoneField(
                        phoneController: _phoneController,
                        initialCountry: _selectedCountry,
                        onCountryChanged: (country) =>
                            _selectedCountry = country,
                        label: 'Registered Phone Number *',
                        isRequired: true,
                        textInputAction: TextInputAction.search,
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        label: 'Track',
                        icon: Icons.search,
                        isLoading: isLoading,
                        onPressed: _trackApplication,
                      ),
                      const SizedBox(height: 24),
                      if (result != null) ..._results(result),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _results(AsyncValue<List<TrackMasjidApplicationResult>> result) {
    if (result.isLoading) {
      return const <Widget>[Center(child: CircularProgressIndicator())];
    }
    final error = result.error;
    if (error != null) {
      return <Widget>[_TrackMessageCard(message: userMessage(error))];
    }
    final items = result.value ?? const <TrackMasjidApplicationResult>[];
    if (items.isEmpty) {
      return const <Widget>[
        _TrackMessageCard(
          message: 'No application found for this phone number.',
        ),
      ];
    }
    return items.map(_ApplicationCard.new).toList();
  }
}

class _TrackMessageCard extends StatelessWidget {
  const _TrackMessageCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard(this.item);

  final TrackMasjidApplicationResult item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Text(
                    item.masjidName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _StatusChip(status: item.status),
              ],
            ),
            const SizedBox(height: 12),
            Text('Imam: ${item.imamName ?? 'Not available'}'),
            const SizedBox(height: 6),
            Text(
              'Requested: ${item.requestedAt == null ? 'Not available' : AppFormat.date(item.requestedAt!)}',
            ),
            const SizedBox(height: 6),
            const Text('Contact us: support@yourdomain.com'),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toUpperCase();
    final color = switch (normalized) {
      'APPROVED' => Colors.green,
      'REJECTED' => Colors.red,
      _ => Colors.orange,
    };

    return Chip(
      label: Text(normalized),
      backgroundColor: color.withValues(alpha: 0.12),
      labelStyle: TextStyle(color: color.shade700, fontWeight: FontWeight.w700),
    );
  }
}
