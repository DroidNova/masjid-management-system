import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/core/format/formatters.dart';
import 'package:masjid_core_frontend/features/announcements/data/models/announcement_model.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// One piece of news: amber, the megaphone picture, title, when, and the
/// message. Long messages open fully with "Read more". The speaker reads
/// title and message aloud.
class AnnouncementCard extends StatefulWidget {
  const AnnouncementCard({
    super.key,
    required this.announcement,
    this.isNew = false,
    this.onEdit,
    this.onDelete,
    this.today,
  });

  final AnnouncementModel announcement;
  final bool isNew;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  /// Overrides "now" in tests.
  final DateTime? today;

  /// Messages longer than this many lines start folded.
  static const int foldedLines = 5;

  @override
  State<AnnouncementCard> createState() => _AnnouncementCardState();
}

class _AnnouncementCardState extends State<AnnouncementCard> {
  bool _expanded = false;

  /// "Today", "Yesterday", or the date.
  String _when(AppLocalizations l10n, DateTime date) {
    final today = DateUtils.dateOnly(widget.today ?? DateTime.now());
    final day = DateUtils.dateOnly(date.toLocal());
    final days = today.difference(day).inDays;
    if (days == 0) return l10n.today;
    if (days == 1) return l10n.yesterday;
    return AppFormat.date(date);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final item = widget.announcement;
    final title = item.title.trim();
    final message = item.message.trim();
    final date = item.createdAt;
    const tone = AppTones.news;
    final spoken = <String>[
      title,
      message,
    ].where((part) => part.isNotEmpty).join('. ');

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.l),
        side: BorderSide(
          color: widget.isNew ? tone.color : AppColors.border,
          width: widget.isNew ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const ToneIcon(
                  icon: AppIcons.announcements,
                  tone: tone,
                  size: 44,
                ),
                const SizedBox(width: AppSpace.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(title, style: textTheme.titleMedium),
                      Wrap(
                        spacing: AppSpace.s,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          if (date != null)
                            Text(
                              _when(l10n, date),
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          if (widget.isNew)
                            StatusBadge(
                              kind: StatusKind.waiting,
                              label: l10n.newLabel,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                ReadAloudButton(text: spoken, color: tone.color),
              ],
            ),
            if (message.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpace.m),
              LayoutBuilder(
                builder: (context, constraints) {
                  final style = textTheme.bodyLarge;
                  final painter = TextPainter(
                    text: TextSpan(text: message, style: style),
                    maxLines: AnnouncementCard.foldedLines,
                    textDirection: Directionality.of(context),
                    textScaler: MediaQuery.textScalerOf(context),
                  )..layout(maxWidth: constraints.maxWidth);
                  final long = painter.didExceedMaxLines;
                  painter.dispose();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        message,
                        style: style,
                        maxLines: _expanded || !long
                            ? null
                            : AnnouncementCard.foldedLines,
                        overflow: _expanded || !long
                            ? null
                            : TextOverflow.ellipsis,
                      ),
                      if (long)
                        TextButton(
                          onPressed: () =>
                              setState(() => _expanded = !_expanded),
                          child: Text(
                            _expanded ? l10n.showLess : l10n.readMore,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
            if (widget.onEdit != null || widget.onDelete != null) ...<Widget>[
              const Divider(height: AppSpace.xl),
              // Wraps when the words are long (Urdu, large text).
              Wrap(
                alignment: WrapAlignment.end,
                spacing: AppSpace.s,
                children: <Widget>[
                  if (widget.onEdit != null)
                    TextButton.icon(
                      onPressed: widget.onEdit,
                      icon: const Icon(AppIcons.edit),
                      label: Text(l10n.edit),
                    ),
                  if (widget.onDelete != null)
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: AppTones.danger.color,
                      ),
                      onPressed: widget.onDelete,
                      icon: const Icon(AppIcons.delete),
                      label: Text(l10n.delete),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
