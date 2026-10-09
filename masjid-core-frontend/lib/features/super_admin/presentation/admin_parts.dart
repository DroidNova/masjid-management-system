import 'dart:async';

import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/core/errors/error_text.dart';
import 'package:masjid_core_frontend/core/format/formatters.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// Badge look for a request, masjid, or user status.
(StatusKind, String) adminStatusLook(AppLocalizations l10n, String? status) =>
    switch ((status ?? '').toUpperCase()) {
      'ACTIVE' => (StatusKind.done, l10n.statusActive),
      'APPROVED' => (StatusKind.done, l10n.stepApproved),
      'PENDING' => (StatusKind.waiting, l10n.statusPending),
      'INACTIVE' => (StatusKind.neutral, l10n.statusInactive),
      'REJECTED' => (StatusKind.problem, l10n.stepRejected),
      'SUSPENDED' => (StatusKind.problem, l10n.statusSuspended),
      final other => (StatusKind.neutral, other),
    };

String adminStatusLabel(AppLocalizations l10n, String? status) =>
    adminStatusLook(l10n, status).$2;

String adminRoleLabel(AppLocalizations l10n, String role) => switch (role) {
  PermissionHelper.superAdmin => l10n.roleSuperAdmin,
  PermissionHelper.imam => l10n.roleImam,
  PermissionHelper.committeeMember => l10n.roleCommittee,
  PermissionHelper.member => l10n.roleMember,
  final other => other,
};

/// "Address, place, district, state, country" without the empty parts.
String placeLine(List<String?> parts) => parts
    .whereType<String>()
    .map((part) => part.trim())
    .where((part) => part.isNotEmpty)
    .join(', ');

/// The date a record was made, or nothing.
String? dateOrNull(DateTime? value) =>
    value == null ? null : AppFormat.date(value);

/// Runs an admin change; shows its error in the app's language.
/// Returns true when it worked.
///
/// USER_IN_ANOTHER_MASJID gets a sheet with the server's message (it names
/// the person and what to do); other errors a snackbar.
Future<bool> runAdminAction(
  BuildContext context,
  Future<void> Function() action,
) async {
  try {
    await action();
    return true;
  } catch (error) {
    if (!context.mounted) return false;
    final l10n = AppLocalizations.of(context);
    if (apiErrorCode(error) == ApiErrorCodes.userInAnotherMasjid) {
      await showAppSheet<void>(
        context,
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ScreenHeader(
              icon: AppIcons.problem,
              tone: AppTones.problem,
              title: l10n.cannotApprove,
              subtitle: errorText(l10n, error),
            ),
            const SizedBox(height: AppSpace.l),
            FilledButton(
              onPressed: () => Navigator.of(sheetContext).pop(),
              child: Text(l10n.ok),
            ),
          ],
        ),
      );
      return false;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(errorText(l10n, error))));
    return false;
  }
}

/// One choice in [pickOption].
typedef AdminOption = ({String value, String label, IconData icon});

/// A sheet of big choices; returns the picked value or null.
Future<String?> pickOption(
  BuildContext context, {
  required String title,
  required List<AdminOption> options,
  String? current,
}) => showAppSheet<String>(
  context,
  builder: (sheetContext) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      Text(title, style: Theme.of(sheetContext).textTheme.titleLarge),
      const SizedBox(height: AppSpace.m),
      for (final option in options)
        ListTile(
          leading: Icon(option.icon),
          title: Text(option.label),
          trailing: option.value == current ? const Icon(AppIcons.done) : null,
          selected: option.value == current,
          onTap: () => Navigator.of(sheetContext).pop(option.value),
        ),
    ],
  ),
);

/// Asks for a reason. Returns the trimmed text (maybe empty when not
/// [required]), or null when cancelled.
Future<String?> askReason(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  bool required = false,
}) {
  final l10n = AppLocalizations.of(context);
  // Not disposed here: the sheet still uses it while it closes.
  final controller = TextEditingController();
  return showAppSheet<String>(
    context,
    builder: (sheetContext) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(title, style: Theme.of(sheetContext).textTheme.titleLarge),
        const SizedBox(height: AppSpace.l),
        TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: required ? l10n.reason : l10n.reasonOptional,
          ),
        ),
        const SizedBox(height: AppSpace.l),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (_, value, _) => FilledButton(
            onPressed: required && value.text.trim().isEmpty
                ? null
                : () => Navigator.of(sheetContext).pop(controller.text.trim()),
            child: Text(confirmLabel),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(sheetContext).pop(),
          child: Text(l10n.cancel),
        ),
      ],
    ),
  );
}

/// A search box that reports the trimmed text after typing pauses.
class AdminSearchField extends StatefulWidget {
  const AdminSearchField({
    super.key,
    required this.hint,
    required this.onSearch,
    this.initialValue = '',
  });

  final String hint;
  final String initialValue;
  final ValueChanged<String> onSearch;

  @override
  State<AdminSearchField> createState() => _AdminSearchFieldState();
}

class _AdminSearchFieldState extends State<AdminSearchField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 350),
      () => widget.onSearch(value.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _onChanged,
      decoration: InputDecoration(
        prefixIcon: const Icon(AppIcons.search),
        hintText: widget.hint,
      ),
    );
  }
}

/// One status (or role) choice in [AdminFilterChips]; null value is "All".
typedef AdminFilter = ({String? value, String label});

/// A row of chips that scrolls sideways; one is picked.
class AdminFilterChips extends StatelessWidget {
  const AdminFilterChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<AdminFilter> options;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          for (final option in options)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: AppSpace.s),
              child: ChoiceChip(
                label: Text(option.label),
                selected: option.value == selected,
                onSelected: (_) => onSelected(option.value),
              ),
            ),
        ],
      ),
    );
  }
}

/// On desktop, the list on the left and the picked item's details on the
/// right; on phones and tablets, the list alone (details open as a page).
class AdminSplitView extends StatelessWidget {
  const AdminSplitView({super.key, required this.list, this.detail});

  final Widget list;

  /// The picked item's details, or null when nothing is picked yet.
  final Widget? detail;

  /// Whether details show beside the list here (else they open as a page).
  static bool isSplit(BuildContext context) =>
      ScreenSize.of(context) == ScreenSize.expanded;

  @override
  Widget build(BuildContext context) {
    if (!isSplit(context)) return list;
    final l10n = AppLocalizations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(width: 440, child: list),
        const VerticalDivider(width: 1),
        Expanded(
          child:
              detail ??
              EmptyState(icon: AppIcons.info, title: l10n.pickToSeeDetails),
        ),
      ],
    );
  }
}

/// A card in an admin list: icon or avatar, title, lines under it, and a
/// status badge.
class AdminListCard extends StatelessWidget {
  const AdminListCard({
    super.key,
    required this.leading,
    required this.title,
    required this.lines,
    required this.status,
    required this.onTap,
    this.selected = false,
  });

  final Widget leading;
  final String title;
  final List<String> lines;
  final String? status;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final (kind, label) = adminStatusLook(l10n, status);
    return Card(
      color: selected ? AppTones.brand.container : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.m),
          child: Row(
            children: <Widget>[
              leading,
              const SizedBox(width: AppSpace.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: textTheme.titleMedium),
                    for (final line in lines.where((line) => line.isNotEmpty))
                      Text(
                        line,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    const SizedBox(height: AppSpace.xs),
                    StatusBadge(kind: kind, label: label),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

/// The top of a details page: icon, name, place, and status.
class AdminDetailHeader extends StatelessWidget {
  const AdminDetailHeader({
    super.key,
    required this.icon,
    required this.tone,
    required this.title,
    required this.status,
    this.subtitle,
  });

  final IconData icon;
  final AppTone tone;
  final String title;
  final String? subtitle;
  final String? status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (kind, label) = adminStatusLook(l10n, status);
    final textTheme = Theme.of(context).textTheme;
    final detail = subtitle;
    return Row(
      children: <Widget>[
        ToneIcon(icon: icon, tone: tone, size: 64),
        const SizedBox(width: AppSpace.l),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: textTheme.headlineSmall),
              if (detail != null && detail.isNotEmpty)
                Text(
                  detail,
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              const SizedBox(height: AppSpace.xs),
              StatusBadge(kind: kind, label: label),
            ],
          ),
        ),
      ],
    );
  }
}

/// A titled card of [InfoLine]s; lines with no value are left out.
class InfoSection extends StatelessWidget {
  const InfoSection({
    super.key,
    required this.title,
    required this.icon,
    required this.lines,
  });

  final String title;
  final IconData icon;
  final List<InfoLine> lines;

  @override
  Widget build(BuildContext context) {
    final shown = lines.where((line) => line.hasValue).toList();
    if (shown.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SectionHeader(title: title, icon: icon),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpace.s),
              child: Column(children: shown),
            ),
          ),
        ],
      ),
    );
  }
}

/// One fact: an icon, what it is, and the value.
class InfoLine extends StatelessWidget {
  const InfoLine({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String? value;

  bool get hasValue => (value ?? '').trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(
        label,
        style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
      ),
      subtitle: SelectableText(value ?? '', style: textTheme.bodyLarge),
    );
  }
}
