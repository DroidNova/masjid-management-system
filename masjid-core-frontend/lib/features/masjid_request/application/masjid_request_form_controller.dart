import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/errors/user_message.dart';
import 'package:masjid_core_frontend/features/masjid_request/application/masjid_request_draft.dart';
import 'package:masjid_core_frontend/features/masjid_request/application/masjid_request_validators.dart';
import 'package:masjid_core_frontend/features/masjid_request/data/masjid_request_repository.dart';

/// A rule across fields failed before anything was sent.
class MasjidRequestInvalid implements Exception {
  const MasjidRequestInvalid(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Text to show for a failed submit.
String masjidRequestErrorMessage(Object error) =>
    error is MasjidRequestInvalid ? error.message : userMessage(error);

final masjidRequestFormControllerProvider =
    NotifierProvider.autoDispose<MasjidRequestFormController, AsyncValue<void>>(
      MasjidRequestFormController.new,
    );

/// Submits the public masjid registration form. State: data when idle or
/// submitted, loading while sending, error ([MasjidRequestInvalid] or
/// ApiException) when it failed.
class MasjidRequestFormController
    extends AutoDisposeNotifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Checks the rules across fields, then sends. True when submitted.
  /// Call after the form's own field validation passed.
  Future<bool> submit(MasjidRequestDraft draft) async {
    if (state.isLoading) return false;

    final invalid = MasjidRequestValidators.committeePhones(
      imamPhone: draft.imamPhone.normalized,
      committeePhones: draft.committeeMembers
          .map((member) => member.phone.normalized)
          .toList(),
    );
    if (invalid != null) {
      state = AsyncError(MasjidRequestInvalid(invalid), StackTrace.current);
      return false;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(masjidRequestRepositoryProvider)
          .submitMasjidRequest(draft.toRequest()),
    );
    return !state.hasError;
  }
}
