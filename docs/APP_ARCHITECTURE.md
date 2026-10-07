# Flutter app architecture

How every feature in `masjid-core-frontend/lib` is built. The dashboard
(`features/dashboard`) is the reference implementation.

## Folder layout per feature

```
features/<feature>/
  data/
    models/            freezed + json_serializable models (*.freezed.dart, *.g.dart generated)
    <feature>_api.dart          HTTP calls only, through ApiClient
    <feature>_repository.dart   provider + class the rest of the app uses
  application/
    <thing>_controller.dart     Riverpod notifiers: loading, error, data, mutations
  presentation/
    <screen>.dart               ConsumerWidget / ConsumerStatefulWidget, rendering only
    widgets/
```

## Rules

1. **Network.** Use `ApiClient` from `apiClientProvider` (`core/providers.dart`):
   `get/post/patch/put/delete` return the envelope's `data` and throw
   `ApiException` (`core/network/api_exception.dart`). Never catch
   `DioException` or parse error bodies in a feature. API shapes:
   `docs/openapi.json` (regenerate with `npm run openapi` in masjid-core).
2. **Paged lists** return `{ items, meta }`. Parse with `Page.fromJson`
   (`core/pagination/page.dart`) and extend `PagedController`
   (`core/pagination/paged_controller.dart`) for infinite scroll.
3. **State.** Screens hold no `_isLoading` / `_errorMessage` fields for server
   data. A controller (`AsyncNotifier`, `AutoDisposeAsyncNotifier`, or a
   `.family` by id) loads data; the screen renders `asyncValue.when(...)`.
   Local UI state (form fields, a selected tab) may stay in a
   `ConsumerStatefulWidget`.
4. **Who is signed in.** `ref.watch(currentUserProvider)` and
   `ref.watch(currentPermissionsProvider)`. Never read `SessionStorage` or
   `TokenStorage` in a feature. Log out with
   `ref.read(authControllerProvider.notifier).signOut()`; never navigate to
   login yourself (the router redirect does it).
5. **Permissions.** Show or hide actions with `PermissionHelper.canX(permissions)`
   or wrap with `PermissionGate`. Never compare role names to decide what a
   user may do. Names mirror `masjid-core/src/access/permissions.ts`.
6. **Refreshing other screens.** After a change, call
   `ref.markChanged([...])` with the affected `DataScope`s
   (`core/refresh/data_scopes.dart`); money changes use `DataChanges.money`.
   Controllers `ref.watch(dataVersionProvider(DataScope.x))` for the data they
   show. Do not import another feature to refresh it.
7. **Errors on screen.** `userMessage(error)` (`core/errors/user_message.dart`)
   for text, `fieldError(error, 'field')` for form validation. Branch on
   `ApiException.code` (`ApiErrorCodes`), never on message text.
8. **Formatting.** Money with `AppFormat.rupees`, dates with `AppFormat.date`
   / `dateTime` / `monthYear` (`core/format/formatters.dart`).
9. **Routes.** A detail route must work from a fresh URL (web refresh): load
   by id from the path; an object passed in `extra` may only be used to show
   something instantly while the real data loads.
10. **Models.** `@freezed` + `fromJson` via json_serializable, JSON keys exactly
    as the backend sends them. Money fields are `double` (the API sends
    numbers). Regenerate with
    `dart run build_runner build --delete-conflicting-outputs`; generated
    files are committed.
11. **Tests.** Each feature has at least one widget test for its main screen
    (provider overrides, no network) and unit tests for any non-trivial
    controller logic. `mocktail` for repositories.
12. **No visual redesign** until the UI milestone: keep existing widgets and
    layout; change wiring only.
