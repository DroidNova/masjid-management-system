import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// Title and message of a piece of news, for adding and editing. The
/// message box is big, and a tip points to the keyboard's microphone for
/// speaking instead of typing (free, built into the phone's keyboard).
class NewsForm extends StatefulWidget {
  const NewsForm({
    super.key,
    required this.saving,
    required this.onSave,
    this.initialTitle = '',
    this.initialMessage = '',
    this.error,
  });

  final String initialTitle;
  final String initialMessage;
  final bool saving;

  /// The server's or the app's message after a failed save.
  final String? error;
  final void Function(String title, String message) onSave;

  /// The server's limits (CreateAnnouncementDto).
  static const int titleMax = 150;
  static const int messageMax = 2000;

  @override
  State<NewsForm> createState() => _NewsFormState();
}

class _NewsFormState extends State<NewsForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _title = TextEditingController(
    text: widget.initialTitle,
  );
  late final TextEditingController _message = TextEditingController(
    text: widget.initialMessage,
  );

  @override
  void dispose() {
    _title.dispose();
    _message.dispose();
    super.dispose();
  }

  void _submit() {
    if (widget.saving || !_formKey.currentState!.validate()) return;
    widget.onSave(_title.text, _message.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final error = widget.error;
    String? required(String? value) =>
        (value ?? '').trim().isEmpty ? l10n.fieldRequired : null;

    return SingleChildScrollView(
      child: PageBody.form(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _title,
                enabled: !widget.saving,
                maxLength: NewsForm.titleMax,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                style: textTheme.titleMedium,
                validator: required,
                decoration: InputDecoration(
                  labelText: l10n.newsTitle,
                  prefixIcon: const Icon(AppIcons.announcements),
                ),
              ),
              const SizedBox(height: AppSpace.s),
              TextFormField(
                controller: _message,
                enabled: !widget.saving,
                maxLength: NewsForm.messageMax,
                minLines: 6,
                maxLines: 14,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                style: textTheme.bodyLarge,
                validator: required,
                decoration: InputDecoration(
                  labelText: l10n.newsMessage,
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: AppSpace.s),
              Row(
                children: <Widget>[
                  Icon(Icons.mic_rounded, color: AppTones.news.color),
                  const SizedBox(width: AppSpace.s),
                  Expanded(
                    child: Text(
                      l10n.dictationTip,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.xl),
              if (error != null) ...<Widget>[
                MessageBanner(text: error),
                const SizedBox(height: AppSpace.l),
              ],
              BusyButton(
                label: l10n.save,
                icon: AppIcons.done,
                busy: widget.saving,
                color: AppTones.news.color,
                onPressed: _submit,
              ),
              const SizedBox(height: AppSpace.xl),
            ],
          ),
        ),
      ),
    );
  }
}
