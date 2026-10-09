import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/errors/error_text.dart';
import 'package:masjid_core_frontend/features/community/application/community_controller.dart';
import 'package:masjid_core_frontend/features/community/data/models/community_user_model.dart';
import 'package:masjid_core_frontend/features/community/presentation/person_form_screen.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// Edits a person. [initial] (from the People page) fills the form at once;
/// from a fresh URL the person is found in the masjid's people by [userId].
class EditCommunityUserScreen extends ConsumerWidget {
  const EditCommunityUserScreen({
    super.key,
    required this.userId,
    this.initial,
  });

  final String userId;
  final CommunityUserModel? initial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passed = initial;
    if (passed != null && passed.id == userId) {
      return PersonFormScreen(initial: passed);
    }
    final l10n = AppLocalizations.of(context);
    final community = ref.watch(communityControllerProvider);
    final person = community.valueOrNull?.users
        .where((user) => user.id == userId)
        .firstOrNull;
    if (person != null) return PersonFormScreen(initial: person);

    final Widget body;
    if (community.hasError) {
      body = EmptyState(
        icon: AppIcons.problem,
        tone: AppTones.problem,
        title: errorText(l10n, community.error!),
        actionLabel: l10n.tryAgain,
        onAction: () => ref.invalidate(communityControllerProvider),
      );
    } else if (community.hasValue) {
      body = EmptyState(icon: AppIcons.personSearch, title: l10n.nothingFound);
    } else {
      body = const SingleChildScrollView(
        child: PageBody.form(child: SkeletonList(itemCount: 3)),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(l10n.editPerson)),
      body: body,
    );
  }
}
