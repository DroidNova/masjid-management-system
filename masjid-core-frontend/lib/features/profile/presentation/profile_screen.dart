import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/format/formatters.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/core/settings/app_settings.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/auth/data/models/app_user.dart';
import 'package:masjid_core_frontend/features/community/data/community_repository.dart';
import 'package:masjid_core_frontend/features/dashboard/application/dashboard_controller.dart';
import 'package:masjid_core_frontend/features/dashboard/data/models/masjid_summary.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// The Profile tab, last tab for everyone (UI_REDESIGN_PLAN.md, section 4):
/// who you are, your account's status, settings, log out, and at the very
/// bottom, in red, leaving the masjid.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const SizedBox.shrink();

    final hasMasjid = user.masjidId?.isNotEmpty ?? false;
    // Super admins have no masjid, so no dashboard to read.
    final masjid = hasMasjid
        ? ref.watch(
            dashboardControllerProvider.select(
              (dashboard) => dashboard.valueOrNull?.masjid,
            ),
          )
        : null;
    final canLeave =
        hasMasjid && PermissionHelper.has(user, AppPermissions.masjidLeave);

    return SingleChildScrollView(
      child: PageBody.form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _Header(user: user),
            const SizedBox(height: AppSpace.xl),
            _StatusCard(user: user, masjid: masjid),
            const SizedBox(height: AppSpace.l),
            _SettingsCard(user: user),
            const SizedBox(height: AppSpace.xl),
            const _LogoutButton(),
            if (canLeave) ...<Widget>[
              const SizedBox(height: AppSpace.xxl * 2),
              _LeaveMasjidButton(masjidName: masjid?.name),
            ],
            const SizedBox(height: AppSpace.xxl),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final phone = user.phone;
    final badges = <(String, IconData)>[
      if (PermissionHelper.hasRole(user, PermissionHelper.superAdmin))
        (l10n.roleSuperAdmin, Icons.admin_panel_settings_rounded),
      if (PermissionHelper.hasRole(user, PermissionHelper.imam))
        (l10n.roleImam, AppIcons.imam),
      if (PermissionHelper.hasRole(user, PermissionHelper.committeeMember))
        (l10n.roleCommittee, AppIcons.people),
      if (PermissionHelper.hasRole(user, PermissionHelper.member))
        (l10n.roleMember, AppIcons.person),
      if (user.isFamilyHead) (l10n.familyHead, AppIcons.family),
    ];

    return Column(
      children: <Widget>[
        const SizedBox(height: AppSpace.l),
        PersonAvatar(name: user.fullName, size: 96),
        const SizedBox(height: AppSpace.m),
        Text(
          user.fullName,
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall,
        ),
        if (phone != null && phone.isNotEmpty)
          Text(
            phone,
            textDirection: TextDirection.ltr,
            style: textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        const SizedBox(height: AppSpace.m),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpace.s,
          runSpacing: AppSpace.s,
          children: badges
              .map(
                (badge) => Chip(
                  avatar: Icon(badge.$2, size: 20, color: AppTones.brand.color),
                  label: Text(badge.$1),
                  backgroundColor: AppTones.brand.container,
                  side: BorderSide.none,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

/// Account status, phone check, masjid, and joining date.
class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.user, required this.masjid});

  final AppUser user;
  final MasjidSummary? masjid;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = (user.status ?? 'ACTIVE').toUpperCase();
    final (StatusKind kind, String label) = switch (status) {
      'ACTIVE' => (StatusKind.done, l10n.statusActive),
      'PENDING' => (StatusKind.waiting, l10n.statusPending),
      _ => (StatusKind.problem, l10n.statusInactive),
    };
    final place = masjid == null
        ? null
        : <String?>[
            masjid!.locality,
            masjid!.district,
            masjid!.state,
          ].whereType<String>().where((part) => part.isNotEmpty).join(', ');
    final masjidName = masjid?.name;
    final joined = user.createdAt;

    return Card(
      child: Column(
        children: <Widget>[
          _InfoRow(
            icon: AppIcons.person,
            label: l10n.account,
            trailing: StatusBadge(kind: kind, label: label),
          ),
          const Divider(indent: AppSpace.l, endIndent: AppSpace.l),
          _InfoRow(
            icon: AppIcons.phone,
            label: l10n.phoneNumber,
            trailing: user.isPhoneVerified
                ? StatusBadge(kind: StatusKind.done, label: l10n.verified)
                : StatusBadge(
                    kind: StatusKind.waiting,
                    label: l10n.notVerified,
                  ),
          ),
          if (masjidName != null && masjidName.isNotEmpty) ...<Widget>[
            const Divider(indent: AppSpace.l, endIndent: AppSpace.l),
            _InfoRow(icon: AppIcons.mosque, label: masjidName, detail: place),
          ],
          if (joined != null) ...<Widget>[
            const Divider(indent: AppSpace.l, endIndent: AppSpace.l),
            _InfoRow(
              icon: AppIcons.calendar,
              label: l10n.memberSince,
              detail: AppFormat.date(joined),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    this.detail,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String? detail;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final info = detail;
    return Padding(
      padding: const EdgeInsets.all(AppSpace.l),
      child: Row(
        children: <Widget>[
          ToneIcon(icon: icon, tone: AppTones.neutral, size: 40),
          const SizedBox(width: AppSpace.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(label, style: textTheme.titleMedium),
                if (info != null && info.isNotEmpty)
                  Text(
                    info,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                // Under the label, not beside it: long words in Hindi or
                // Urdu and large text still fit.
                if (trailing != null) ...<Widget>[
                  const SizedBox(height: AppSpace.xs),
                  trailing!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends ConsumerWidget {
  const _SettingsCard({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(appSettingsProvider);
    final controller = ref.read(appSettingsProvider.notifier);

    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            leading: const Icon(AppIcons.language),
            title: Text(l10n.chooseLanguage),
            subtitle: Text(settings.language?.nativeName ?? ''),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/language'),
          ),
          SwitchListTile(
            secondary: const Icon(AppIcons.textSize),
            title: Text(l10n.largeText),
            value: settings.largeText,
            onChanged: controller.setLargeText,
          ),
          SwitchListTile(
            secondary: const Icon(AppIcons.readAloud),
            title: Text(l10n.readAloud),
            value: settings.readAloud,
            onChanged: controller.setReadAloud,
          ),
          if (PermissionHelper.hasPassword(user))
            ListTile(
              leading: const Icon(AppIcons.password),
              title: Text(l10n.changePassword),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push('/profile/password'),
            ),
        ],
      ),
    );
  }
}

class _LogoutButton extends ConsumerWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return OutlinedButton.icon(
      onPressed: () async {
        final confirmed = await showConfirmSheet(
          context,
          icon: AppIcons.logout,
          title: l10n.logoutQuestion,
          confirmLabel: l10n.logout,
        );
        if (confirmed) {
          // The router sends the signed-out person to the start screen.
          await ref.read(authControllerProvider.notifier).signOut();
        }
      },
      icon: const Icon(AppIcons.logout),
      label: Text(l10n.logout),
    );
  }
}

/// The red "Leave masjid" button and its danger dialog: Cancel is the big
/// button, Leave must be held. After leaving the person is signed out,
/// since the app needs a masjid.
class _LeaveMasjidButton extends ConsumerWidget {
  const _LeaveMasjidButton({required this.masjidName});

  final String? masjidName;

  Future<void> _leave(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final name = masjidName ?? '';
    final repository = ref.read(communityRepositoryProvider);

    final left = await showDangerDialog(
      context,
      title: l10n.leaveMasjidQuestion,
      subject: name.isEmpty ? null : name,
      confirmLabel: l10n.leave,
      confirmIcon: AppIcons.leave,
      points: <DangerPoint>[
        DangerPoint(icon: AppIcons.mosque, text: l10n.leavePointAccess),
        DangerPoint(icon: AppIcons.myPayments, text: l10n.leavePointHistory),
        DangerPoint(icon: AppIcons.people, text: l10n.leavePointJoin),
      ],
      // The dialog shows progress and the server's reason on failure; no
      // data needs marking changed because sign-out follows.
      onConfirm: repository.leaveMyMasjid,
    );
    if (!left || !context.mounted) return;

    await showSuccess(
      context,
      title: name.isEmpty ? l10n.youLeftTheMasjid : l10n.youLeft(name),
      icon: AppIcons.leave,
      tone: AppTones.neutral,
    );
    await ref.read(authControllerProvider.notifier).signOut();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final danger = AppTones.danger.color;
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: danger,
        side: BorderSide(color: danger, width: 2),
      ),
      onPressed: () => _leave(context, ref),
      icon: const Icon(AppIcons.leave),
      label: Text(l10n.leaveMasjid),
    );
  }
}
