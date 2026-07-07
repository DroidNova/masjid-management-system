import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:platform_core_frontend/core/storage/session_storage.dart';
import 'package:platform_core_frontend/features/namaz_time/data/models/namaz_time_model.dart';
import 'package:platform_core_frontend/features/namaz_time/data/models/update_namaz_time_request.dart';
import 'package:platform_core_frontend/features/namaz_time/data/namaz_time_repository.dart';
import 'package:platform_core_frontend/features/namaz_time/presentation/widgets/namaz_time_form_section.dart';
import 'package:platform_core_frontend/shared/widgets/app_button.dart';
import 'package:platform_core_frontend/shared/widgets/loading_view.dart';

class UpdateNamazTimeScreen extends StatefulWidget {
  const UpdateNamazTimeScreen({
    super.key,
    this.masjidId,
    this.initialNamazTime,
    NamazTimeRepository? namazTimeRepository,
    SessionStorage? sessionStorage,
  })  : _namazTimeRepository = namazTimeRepository,
        _sessionStorage = sessionStorage;

  final String? masjidId;
  final NamazTimeModel? initialNamazTime;
  final NamazTimeRepository? _namazTimeRepository;
  final SessionStorage? _sessionStorage;

  @override
  State<UpdateNamazTimeScreen> createState() => _UpdateNamazTimeScreenState();
}

class _UpdateNamazTimeScreenState extends State<UpdateNamazTimeScreen> {
  final _fajrController = TextEditingController();
  final _zuhrController = TextEditingController();
  final _asrController = TextEditingController();
  final _maghribController = TextEditingController();
  final _ishaController = TextEditingController();
  final _jummaController = TextEditingController();
  final _noteController = TextEditingController();

  late final NamazTimeRepository _namazTimeRepository =
      widget._namazTimeRepository ?? NamazTimeRepository();
  late final SessionStorage _sessionStorage =
      widget._sessionStorage ?? SessionStorage();

  String? _masjidId;
  String? _errorMessage;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadNamazTime();
  }

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

  Future<void> _loadNamazTime() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final masjidId = await _resolveMasjidId();
      if (masjidId == null || masjidId.isEmpty) {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'Masjid not found for this user.';
          _isLoading = false;
        });
        return;
      }

      _masjidId = masjidId;
      final namazTime = await _namazTimeRepository.getNamazTime(masjidId) ??
          widget.initialNamazTime;
      if (!mounted) return;
      if (namazTime != null) _fill(namazTime);
      setState(() => _isLoading = false);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _cleanError(error);
        _isLoading = false;
      });
    }
  }

  Future<String?> _resolveMasjidId() async {
    if (widget.masjidId != null && widget.masjidId!.isNotEmpty) {
      return widget.masjidId;
    }
    final user = await _sessionStorage.getUser();
    return user?.masjidId;
  }

  void _fill(NamazTimeModel namazTime) {
    _fajrController.text = namazTime.fajr ?? '';
    _zuhrController.text = namazTime.zuhr ?? '';
    _asrController.text = namazTime.asr ?? '';
    _maghribController.text = namazTime.maghrib ?? '';
    _ishaController.text = namazTime.isha ?? '';
    _jummaController.text = namazTime.jumma ?? '';
    _noteController.text = namazTime.note ?? '';
  }

  Future<void> _save() async {
    final masjidId = _masjidId;
    if (masjidId == null || masjidId.isEmpty) {
      _showError('Masjid not found for this user.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _namazTimeRepository.updateNamazTime(
        masjidId: masjidId,
        request: UpdateNamazTimeRequest(
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Namaz timings updated successfully.')),
      );
      context.pop(true);
    } catch (error) {
      if (mounted) _showError(_cleanError(error));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Update Namaz Time')),
        body: const LoadingView(),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Update Namaz Time')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(_errorMessage!, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  AppButton(label: 'Retry', onPressed: _loadNamazTime),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Update Namaz Time')),
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
                    'Update Namaz Time',
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
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    label: 'Save Namaz Time',
                    isLoading: _isSaving,
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
