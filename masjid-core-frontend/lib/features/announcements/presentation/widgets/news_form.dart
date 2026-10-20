import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// Title and message of a piece of news, for adding and editing. The
/// message box is big, and a tip points to the keyboard's microphone for
/// speaking instead of typing (free, built into the phone's keyboard).
/// "Who can see this?" starts on Members only; choosing Everyone shows a
/// warning, because then people outside the masjid can read it too.
class NewsForm extends StatefulWidget {
  const NewsForm({
    super.key,
    required this.saving,
    required this.onSave,
    this.initialTitle = '',
    this.initialMessage = '',
    this.initialIsPublic = false,
    this.error,
  });

  final String initialTitle;
  final String initialMessage;
  final bool initialIsPublic;
  final bool saving;

  /// The server's or the app's message after a failed save.
  final String? error;
  final void Function(String title, String message, bool isPublic) onSave;

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
  late bool _isPublic = widget.initialIsPublic;

  @override
  void dispose() {
    _title.dispose();
    _message.dispose();
    super.dispose();
  }

  void _submit() {
    if (widget.saving || !_formKey.currentState!.validate()) return;
    widget.onSave(_title.text, _message.text, _isPublic);
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
              Text(l10n.audienceTitle, style: textTheme.titleMedium),
              const SizedBox(height: AppSpace.s),
              _AudienceChoice(
                icon: AppIcons.people,
                label: l10n.audienceMembers,
                hint: l10n.audienceMembersHint,
                selected: !_isPublic,
                onTap: widget.saving
                    ? null
                    : () => setState(() => _isPublic = false),
              ),
              const SizedBox(height: AppSpace.s),
              _AudienceChoice(
                icon: AppIcons.everyone,
                label: l10n.audienceEveryone,
                hint: l10n.audienceEveryoneHint,
                selected: _isPublic,
                onTap: widget.saving
                    ? null
                    : () => setState(() => _isPublic = true),
              ),
              if (_isPublic) ...<Widget>[
                const SizedBox(height: AppSpace.s),
                MessageBanner(
                  kind: StatusKind.waiting,
                  text: l10n.audienceEveryoneWarning,
                ),
              ],
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

/// One "who can see this" option: a big card with a picture, the name, a
/// short hint, and a filled circle when chosen.
class _AudienceChoice extends StatelessWidget {
  const _AudienceChoice({
    required this.icon,
    required this.label,
    required this.hint,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String hint;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const tone = AppTones.news;
    return Semantics(
      selected: selected,
      button: true,
      child: Card(
        margin: EdgeInsets.zero,
        color: selected ? tone.container : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.l),
          side: BorderSide(
            color: selected ? tone.color : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.l),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpace.m),
            child: Row(
              children: <Widget>[
                ToneIcon(icon: icon, tone: tone, size: 44),
                const SizedBox(width: AppSpace.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(label, style: textTheme.titleMedium),
                      Text(
                        hint,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: selected ? tone.color : AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
