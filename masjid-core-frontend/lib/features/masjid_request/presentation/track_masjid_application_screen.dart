import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:platform_core_frontend/core/errors/error_message_helper.dart';
import 'package:platform_core_frontend/features/masjid_request/data/masjid_request_repository.dart';
import 'package:platform_core_frontend/features/masjid_request/data/models/track_masjid_application_result.dart';
import 'package:platform_core_frontend/shared/models/country_code.dart';
import 'package:platform_core_frontend/shared/utils/country_code_utils.dart';
import 'package:platform_core_frontend/shared/utils/date_format_utils.dart';
import 'package:platform_core_frontend/shared/widgets/app_button.dart';
import 'package:platform_core_frontend/shared/widgets/app_phone_field.dart';

class TrackMasjidApplicationScreen extends StatefulWidget {
  const TrackMasjidApplicationScreen({
    super.key,
    MasjidRequestRepository? repository,
  }) : _repository = repository;

  final MasjidRequestRepository? _repository;

  @override
  State<TrackMasjidApplicationScreen> createState() =>
      _TrackMasjidApplicationScreenState();
}

class _TrackMasjidApplicationScreenState
    extends State<TrackMasjidApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  late final MasjidRequestRepository _repository =
      widget._repository ?? MasjidRequestRepository();

  CountryCode _selectedCountry = getDefaultCountryCode();
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _errorMessage;
  List<TrackMasjidApplicationResult> _items =
      const <TrackMasjidApplicationResult>[];

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _trackApplication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _hasSearched = true;
    });

    try {
      final normalizedPhone = normalizePhone(
        countryCode: _selectedCountry,
        nationalNumber: _phoneController.text,
      );
      final items = await _repository.trackApplicationByPhone(normalizedPhone);
      if (!mounted) return;
      setState(() => _items = items);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _items = const <TrackMasjidApplicationResult>[];
        _errorMessage = getReadableErrorMessage(
          error,
          fallbackMessage: 'Something went wrong. Please try again.',
        );
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
                        isLoading: _isLoading,
                        onPressed: _trackApplication,
                      ),
                      const SizedBox(height: 24),
                      if (_errorMessage != null)
                        _TrackMessageCard(message: _errorMessage!),
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (_hasSearched &&
                          _errorMessage == null &&
                          _items.isEmpty)
                        const _TrackMessageCard(
                          message: 'No application found for this phone number.',
                        )
                      else
                        ..._items.map(_ApplicationCard.new),
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
              'Requested: ${formatReadableDate(item.requestedAt, nullText: 'Not available')}',
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
