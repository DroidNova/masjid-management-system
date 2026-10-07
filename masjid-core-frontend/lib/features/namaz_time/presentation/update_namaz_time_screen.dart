import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/errors/user_message.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/namaz_time/application/namaz_time_controller.dart';
import 'package:masjid_core_frontend/features/namaz_time/data/models/namaz_time_model.dart';
import 'package:masjid_core_frontend/features/namaz_time/data/models/update_namaz_time_request.dart';
import 'package:masjid_core_frontend/features/namaz_time/presentation/widgets/namaz_time_form_section.dart';
import 'package:masjid_core_frontend/shared/widgets/app_button.dart';
import 'package:masjid_core_frontend/shared/widgets/loading_view.dart';

/// Edits a masjid's namaz times. [masjidId] defaults to the signed-in
/// user's masjid.
class UpdateNamazTimeScreen extends ConsumerWidget {
  const UpdateNamazTimeScreen({super.key, this.masjidId});

  final String? masjidId;

  static const String _title = 'Update Namaz Time';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fromRoute = masjidId;
    final resolvedMasjidId = fromRoute != null && fromRoute.isNotEmpty
        ? fromRoute
        : ref.watch(currentUserProvider.select((user) => user?.masjidId));

    if (resolvedMasjidId == null || resolvedMasjidId.isEmpty) {
      return const _NamazTimeErrorView(
        message: 'Masjid not found for this user.',
      );
    }

    final provider = namazTimeControllerProvider(resolvedMasjidId);
    return ref
        .watch(provider)
        .when(
          // Keep the form (and what the user typed) while it reloads.
          skipLoadingOnReload: true,
          loading: () => Scaffold(
            appBar: AppBar(title: const Text(_title)),
            body: const LoadingView(),
          ),
          error: (error, _) => _NamazTimeErrorView(
            message: userMessage(error),
            onRetry: () => ref.invalidate(provider),
          ),
          data: (namazTime) =>
              _NamazTimeForm(masjidId: resolvedMasjidId, initial: namazTime),
        );
  }
}

class _NamazTimeForm extends ConsumerStatefulWidget {
  const _NamazTimeForm({required this.masjidId, required this.initial});

  final String masjidId;
  final NamazTimeModel initial;

  @override
  ConsumerState<_NamazTimeForm> createState() => _NamazTimeFormState();
}

class _NamazTimeFormState extends ConsumerState<_NamazTimeForm> {
  late final _fajrController = TextEditingController(text: widget.initial.fajr);
  late final _zuhrController = TextEditingController(text: widget.initial.zuhr);
  late final _asrController = TextEditingController(text: widget.initial.asr);
  late final _maghribController = TextEditingController(
    text: widget.initial.maghrib,
  );
  late final _ishaController = TextEditingController(text: widget.initial.isha);
  late final _jummaController = TextEditingController(
    text: widget.initial.jumma,
  );
  late final _noteController = TextEditingController(text: widget.initial.note);

  @override
  void dispose() {
    _fajrController.dispose();
    _zuhrController.dispose();
    _asrController.dispose();
    _maghribController.dispose();
    _ishaController.dispose();
    _jummaController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final saved = await ref
        .read(namazTimeSaveControllerProvider.notifier)
        .save(
          masjidId: widget.masjidId,
          request: UpdateNamazTimeRequest.fromForm(
            fajr: _fajrController.text,
            zuhr: _zuhrController.text,
            asr: _asrController.text,
            maghrib: _maghribController.text,
            isha: _ishaController.text,
            jumma: _jummaController.text,
            note: _noteController.text,
          ),
        );
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    if (!saved) {
      final error = ref.read(namazTimeSaveControllerProvider).error;
      if (error != null) {
        messenger.showSnackBar(SnackBar(content: Text(userMessage(error))));
      }
      return;
    }
    messenger.showSnackBar(
      const SnackBar(content: Text('Namaz timings updated successfully.')),
    );
    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final saveState = ref.watch(namazTimeSaveControllerProvider);
    final error = saveState.error;

    return Scaffold(
      appBar: AppBar(title: const Text(UpdateNamazTimeScreen._title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    UpdateNamazTimeScreen._title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text('Set daily prayer timings for your masjid'),
                  const SizedBox(height: 16),
                  NamazTimeFormSection(
                    fajrController: _fajrController,
                    zuhrController: _zuhrController,
                    asrController: _asrController,
                    maghribController: _maghribController,
                    ishaController: _ishaController,
                    jummaController: _jummaController,
                    noteController: _noteController,
                    fieldErrorFor: (field) => fieldError(error, field),
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    label: 'Save Namaz Time',
                    isLoading: saveState.isLoading,
                    onPressed: _save,
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

class _NamazTimeErrorView extends StatelessWidget {
  const _NamazTimeErrorView({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(UpdateNamazTimeScreen._title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(message, textAlign: TextAlign.center),
                if (onRetry != null) ...<Widget>[
                  const SizedBox(height: 16),
                  AppButton(label: 'Retry', onPressed: onRetry),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
