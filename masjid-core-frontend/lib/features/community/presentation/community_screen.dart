import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/errors/error_text.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/community/application/community_controller.dart';
import 'package:masjid_core_frontend/features/community/data/models/community_user_model.dart';
import 'package:masjid_core_frontend/features/community/data/models/masjid_detail_model.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// Which people the list shows.
enum PeopleGroup { all, committee, imam, members }

/// The People tab: the masjid's card, then everyone with a picture, role,
/// and active / inactive badge, searchable and filtered by role. Tapping a
/// person opens their details; managers can edit or deactivate there.
class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  String _search = '';
  PeopleGroup _group = PeopleGroup.all;

  List<CommunityUserModel> _visible(CommunityData data) {
    final people = switch (_group) {
      PeopleGroup.all => data.users,
      PeopleGroup.committee => data.committeeUsers,
      PeopleGroup.imam => data.imamUsers,
      PeopleGroup.members => data.memberUsers,
    };
    final query = _search.toLowerCase();
    if (query.isEmpty) return people;
    return people
        .where(
          (person) =>
              person.fullName.toLowerCase().contains(query) ||
              (person.phone ?? '').contains(query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final permissions = ref.watch(currentPermissionsProvider);
    final canAdd = PermissionHelper.canAddCommunityUser(permissions);
    final community = ref.watch(communityControllerProvider);

    final Widget body = community.when(
      skipLoadingOnRefresh: true,
      skipLoadingOnReload: true,
      loading: () => const SingleChildScrollView(
        child: PageBody.form(child: SkeletonList()),
      ),
      error: (error, _) {
        final noMasjid =
            error is ApiException &&
            error.code == ApiErrorCodes.userMasjidNotAssigned;
        return EmptyState(
          icon: noMasjid ? AppIcons.mosque : AppIcons.problem,
          tone: noMasjid ? AppTones.neutral : AppTones.problem,
          title: noMasjid ? l10n.noMasjidAssigned : errorText(l10n, error),
          actionLabel: noMasjid ? null : l10n.tryAgain,
          onAction: () => ref.invalidate(communityControllerProvider),
        );
      },
      data: (data) {
        final people = _visible(data);
        return RefreshIndicator(
          onRefresh: () =>
              ref.read(communityControllerProvider.notifier).refresh(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(bottom: canAdd ? 96 : AppSpace.xl),
            children: <Widget>[
              PageBody.form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _MasjidCard(masjid: data.masjid, count: data.users.length),
                    const SizedBox(height: AppSpace.l),
                    TextField(
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(AppIcons.search),
                        hintText: l10n.searchPeople,
                      ),
                      onChanged: (value) =>
                          setState(() => _search = value.trim()),
                    ),
                    const SizedBox(height: AppSpace.s),
                    SizedBox(
                      height: 56,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: <Widget>[
                          for (final (group, icon, label)
                              in <(PeopleGroup, IconData?, String)>[
                                (PeopleGroup.all, null, l10n.all),
                                (
                                  PeopleGroup.committee,
                                  AppIcons.people,
                                  l10n.roleCommittee,
                                ),
                                (
                                  PeopleGroup.imam,
                                  AppIcons.imam,
                                  l10n.roleImam,
                                ),
                                (
                                  PeopleGroup.members,
                                  AppIcons.person,
                                  l10n.peopleMembers,
                                ),
                              ]) ...<Widget>[
                            ChoiceChip(
                              avatar: icon == null
                                  ? null
                                  : Icon(icon, size: 20),
                              label: Text(label),
                              selected: _group == group,
                              onSelected: (_) => setState(() => _group = group),
                            ),
                            const SizedBox(width: AppSpace.s),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpace.s),
                    if (people.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpace.xl),
                        child: listEmptyState(
                          l10n: l10n,
                          icon: AppIcons.people,
                          tone: AppTones.people,
                          title: l10n.noPeopleYet,
                          filtered:
                              _search.isNotEmpty || _group != PeopleGroup.all,
                          actionLabel: canAdd ? l10n.addPerson : null,
                          onAction: () => context.push('/community/add-user'),
                        ),
                      )
                    else
                      for (final person in people)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpace.s),
                          child: PersonTile(
                            person: person,
                            onTap: () => showPersonDetails(context, person),
                          ),
                        ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );

    return Scaffold(
      floatingActionButton: canAdd
          ? FloatingActionButton.extended(
              backgroundColor: AppTones.people.color,
              foregroundColor: Colors.white,
              onPressed: () => context.push('/community/add-user'),
              icon: const Icon(Icons.person_add_rounded),
              label: Text(l10n.addPerson),
            )
          : null,
      body: body,
    );
  }
}

class _MasjidCard extends StatelessWidget {
  const _MasjidCard({required this.masjid, required this.count});

  final MasjidDetailModel masjid;
  final int count;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final place = <String?>[
      masjid.locality,
      masjid.district,
      masjid.state,
    ].whereType<String>().where((part) => part.trim().isNotEmpty).join(', ');
    final welcome = masjid.welcomeMsg?.trim() ?? '';

    return HeroCard(
      tone: AppTones.people,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(AppIcons.mosque, size: 40),
              const SizedBox(width: AppSpace.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      masjid.name,
                      style: textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    if (place.isNotEmpty)
                      Text(
                        place,
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (welcome.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpace.m),
            Text(welcome),
          ],
          const SizedBox(height: AppSpace.m),
          Row(
            children: <Widget>[
              const Icon(AppIcons.people, size: 22),
              const SizedBox(width: AppSpace.s),
              Text(l10n.peopleCount(count)),
            ],
          ),
        ],
      ),
    );
  }
}

/// The role a person is shown with.
String personRoleLabel(AppLocalizations l10n, CommunityUserModel person) {
  if (person.isImam) return l10n.roleImam;
  if (person.isCommitteeMember || person.isMasjidAdmin) {
    return l10n.roleCommittee;
  }
  return l10n.roleMember;
}

IconData personRoleIcon(CommunityUserModel person) {
  if (person.isImam) return AppIcons.imam;
  if (person.isCommitteeMember || person.isMasjidAdmin) return AppIcons.people;
  return AppIcons.person;
}

bool _isActive(CommunityUserModel person) =>
    (person.status ?? 'ACTIVE').toUpperCase() == 'ACTIVE';

/// One person: picture, name, role, family head, phone (when allowed),
/// and an active / inactive badge.
class PersonTile extends StatelessWidget {
  const PersonTile({super.key, required this.person, this.onTap});

  final CommunityUserModel person;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final phone = person.phone;
    final active = _isActive(person);

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.m),
          child: Row(
            children: <Widget>[
              PersonAvatar(name: person.fullName),
              const SizedBox(width: AppSpace.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      person.fullName,
                      style: textTheme.titleMedium?.copyWith(
                        color: active ? null : AppColors.textSecondary,
                      ),
                    ),
                    if (phone != null && phone.isNotEmpty)
                      Text(
                        phone,
                        textDirection: TextDirection.ltr,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    const SizedBox(height: AppSpace.xs),
                    Wrap(
                      spacing: AppSpace.s,
                      runSpacing: AppSpace.xs,
                      children: <Widget>[
                        _RolePill(
                          icon: personRoleIcon(person),
                          label: personRoleLabel(l10n, person),
                        ),
                        if (person.isFamilyHead)
                          _RolePill(
                            icon: AppIcons.family,
                            label: l10n.familyHead,
                          ),
                        if (!active)
                          StatusBadge(
                            kind: StatusKind.problem,
                            label: l10n.statusInactive,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (onTap != null) const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _RolePill extends StatelessWidget {
  const _RolePill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpace.s,
        AppSpace.xs,
        AppSpace.m,
        AppSpace.xs,
      ),
      decoration: BoxDecoration(
        color: AppTones.people.container,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: AppTones.people.color),
          const SizedBox(width: AppSpace.xs),
          Flexible(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: AppTones.people.color),
            ),
          ),
        ],
      ),
    );
  }
}

/// A person's details in a sheet. Managers get Edit and Deactivate (held)
/// or Activate.
Future<void> showPersonDetails(
  BuildContext context,
  CommunityUserModel person,
) => showAppSheet<void>(
  context,
  builder: (_) => _PersonDetails(person: person, pageContext: context),
);

class _PersonDetails extends ConsumerWidget {
  const _PersonDetails({required this.person, required this.pageContext});

  final CommunityUserModel person;

  /// The page under the sheet: dialogs opened after the sheet closes use it.
  final BuildContext pageContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final canManage = PermissionHelper.canManageCommunityUser(
      currentUserPermissions: ref.watch(currentPermissionsProvider),
      targetUserRoles: person.roles,
    );
    final active = _isActive(person);
    final controller = ref.read(communityControllerProvider.notifier);
    final phone = person.phone;
    final email = person.email;
    final details = <(IconData, String)>[
      if (phone != null && phone.isNotEmpty) (AppIcons.phone, phone),
      if (email != null && email.isNotEmpty) (AppIcons.email, email),
      if ((person.fatherName ?? '').isNotEmpty)
        (AppIcons.family, '${l10n.fatherName}: ${person.fatherName}'),
      if (person.age != null) (AppIcons.age, '${l10n.age}: ${person.age}'),
      if (person.isFamilyHead && person.familyMemberCount != null)
        (AppIcons.people, l10n.familyMembersCount(person.familyMemberCount!)),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Center(child: PersonAvatar(name: person.fullName, size: 80)),
        const SizedBox(height: AppSpace.m),
        Text(
          person.fullName,
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpace.s),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpace.s,
          runSpacing: AppSpace.s,
          children: <Widget>[
            _RolePill(
              icon: personRoleIcon(person),
              label: personRoleLabel(l10n, person),
            ),
            if (person.isFamilyHead)
              _RolePill(icon: AppIcons.family, label: l10n.familyHead),
            StatusBadge(
              kind: active ? StatusKind.done : StatusKind.problem,
              label: active ? l10n.statusActive : l10n.statusInactive,
            ),
          ],
        ),
        const SizedBox(height: AppSpace.l),
        for (final (icon, text) in details)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpace.xs),
            child: Row(
              children: <Widget>[
                Icon(icon, color: AppColors.textSecondary),
                const SizedBox(width: AppSpace.m),
                Expanded(child: Text(text, style: textTheme.bodyLarge)),
              ],
            ),
          ),
        const SizedBox(height: AppSpace.xl),
        if (canManage) ...<Widget>[
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppTones.people.color,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              pageContext.push(
                '/community/users/${person.id}/edit',
                extra: person,
              );
            },
            icon: const Icon(AppIcons.edit),
            label: Text(l10n.edit),
          ),
          const SizedBox(height: AppSpace.m),
          if (active)
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTones.danger.color,
                side: BorderSide(color: AppTones.danger.color, width: 2),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await showDangerDialog(
                  pageContext,
                  title: l10n.deactivateQuestion,
                  subject: person.fullName,
                  confirmLabel: l10n.deactivate,
                  confirmIcon: Icons.person_off_rounded,
                  points: <DangerPoint>[
                    DangerPoint(
                      icon: AppIcons.login,
                      text: l10n.deactivatePointLogin,
                    ),
                    DangerPoint(
                      icon: AppIcons.myPayments,
                      text: l10n.deactivatePointHistory,
                    ),
                  ],
                  onConfirm: () =>
                      controller.changeUserStatus(person.id, 'INACTIVE'),
                );
              },
              icon: const Icon(Icons.person_off_rounded),
              label: Text(l10n.deactivate),
            )
          else
            OutlinedButton.icon(
              onPressed: () async {
                Navigator.of(context).pop();
                final yes = await showConfirmSheet(
                  pageContext,
                  icon: Icons.person_rounded,
                  title: l10n.activateQuestion,
                  message: person.fullName,
                  confirmLabel: l10n.activate,
                  tone: AppTones.done,
                );
                if (!yes || !pageContext.mounted) return;
                try {
                  await controller.changeUserStatus(person.id, 'ACTIVE');
                } catch (error) {
                  if (pageContext.mounted) {
                    ScaffoldMessenger.of(pageContext).showSnackBar(
                      SnackBar(
                        content: Text(
                          errorText(AppLocalizations.of(pageContext), error),
                        ),
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.person_rounded),
              label: Text(l10n.activate),
            ),
        ] else
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.close),
          ),
      ],
    );
  }
}
