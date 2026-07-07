# Frontend Development Checklist

Use this checklist before merging significant frontend work.

---

## A) Before starting a feature

- [ ] Confirm feature belongs to platform base (not edutech/client layer)
- [ ] Confirm backend module ownership and API references
- [ ] Define module boundaries (`data/domain/presentation`)
- [ ] Reuse existing shared abstractions before creating new ones

---

## B) Before integrating an API

- [ ] Verify contract from backend docs/team (do not guess)
- [ ] Add/adjust API model parsing in isolated files
- [ ] Map model -> domain entity in repository
- [ ] Ensure controller/UI uses domain entities only
- [ ] Validate auth requirements (public vs protected endpoint)

---

## C) Before creating a reusable widget

- [ ] Used by at least two modules or clearly intended for reuse
- [ ] Contains no module-specific business assumptions
- [ ] API is simple, documented by naming, and composable

---

## D) Before modifying auth/session flow

- [ ] Check splash/session restore behavior
- [ ] Validate token storage and refresh implications
- [ ] Ensure protected routes still redirect correctly
- [ ] Ensure logout remains resilient (clear local state even on API failure)

---

## E) Before adding role/permission-shaped UI

- [ ] Keep checks centralized (policy/helper)
- [ ] Treat frontend checks as UX shaping only
- [ ] Do not replace backend authorization authority

---

## F) Before adding list/pagination/search/filter

- [ ] Use shared query (`ListQueryParams`) and pagination (`PaginatedData/PageMeta`)
- [ ] Keep envelope assumptions in mappers/models, not pages
- [ ] Add loading/error/empty/retry states
- [ ] Keep search optional unless backend confirms support

---

## G) Before adding domain-specific modules

- [ ] Verify whether module belongs in edutech layer instead of platform base
- [ ] If domain-specific, avoid adding it directly to platform base repo

---

## H) Before cloning for edutech/client

- [ ] Confirm platform base is clean and generic
- [ ] Document extension points and intentional assumptions
- [ ] Ensure new layer changes do not back-propagate client specifics into base

---

## I) Pre-merge quality checks

- [ ] `flutter test`
- [ ] Static checks/analysis
- [ ] Manual smoke test for affected flows
- [ ] Documentation updated if architectural behavior changed

