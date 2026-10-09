import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/errors/error_text.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/app_icons.dart';
import 'package:masjid_core_frontend/shared/ui/empty_state.dart';
import 'package:masjid_core_frontend/shared/ui/tokens.dart';

/// A page that failed to load: what went wrong, in the app's language
/// where it can be, and Try again. No internet gets its own picture.
class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final offline = apiErrorCode(error) == ApiErrorCodes.network;
    return EmptyState(
      icon: offline ? AppIcons.noInternet : AppIcons.problem,
      tone: AppTones.problem,
      title: errorText(l10n, error),
      actionLabel: onRetry == null ? null : l10n.tryAgain,
      onAction: onRetry,
    );
  }
}

/// Shown instead of a page this person may not open.
class NotAllowedView extends StatelessWidget {
  const NotAllowedView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return EmptyState(
      icon: AppIcons.lock,
      title: l10n.notAllowedTitle,
      message: l10n.notAllowedMessage,
      actionLabel: l10n.goBack,
      actionIcon: AppIcons.back,
      onAction: () => leavePage(context),
    );
  }
}

/// A link to a page that does not exist (an old or mistyped address).
class NotFoundView extends StatelessWidget {
  const NotFoundView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: EmptyState(
        icon: AppIcons.notFound,
        title: l10n.pageNotFound,
        message: l10n.pageNotFoundHelp,
        actionLabel: l10n.goHome,
        actionIcon: AppIcons.home,
        onAction: () => context.go('/'),
      ),
    );
  }
}

/// Back to the previous page, or home when there is none (a link opened
/// straight on the website).
void leavePage(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go('/');
  }
}
