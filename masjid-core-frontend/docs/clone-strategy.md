# Clone Strategy

This document explains how to evolve the frontend safely across three layers.

---

## Layer 1: `platform-core-frontend` (Current Base)

Purpose:
- Generic platform frontend
- Reusable infrastructure + platform modules

Allowed here:
- auth/session/admin/settings/basic profile foundations
- reusable shared UI and technical infrastructure

Not allowed here:
- education-domain logic
- client-specific branding or workflows

---

## Layer 2: `edutech-core-frontend` (Future Domain Extension)

Purpose:
- Add education domain modules while preserving platform base patterns

Examples added at this layer:
- institutes/organizations
- students
- teachers
- batches
- courses
- education dashboards

Rules:
- extend via new feature modules
- avoid rewriting base core/shared unless broadly reusable

---

## Layer 3: Client-specific Frontend Products

Purpose:
- Deliver productized client experience on top of base + domain layers

Examples added at this layer:
- branding/theme variants
- client-specific dashboards/menus
- contract-specific feature toggles and custom flows

Rules:
- keep custom behavior isolated
- avoid polluting shared platform core with one-client assumptions

---

## Decision Matrix Before Adding a Feature

| Question | If YES | If NO |
|---|---|---|
| Is it generic across multiple products? | Add to platform base | Continue matrix |
| Is it education-domain specific? | Add to edutech layer | Continue matrix |
| Is it specific to one client or contract? | Add to client layer | Re-evaluate requirement |

---

## Anti-pollution Principles

- Do not add domain-specific strings/flows to base widgets/controllers
- Do not add client-specific flags in platform modules without clear abstraction
- Prefer composition/extension over conditional branching in base layer

---

## Practical Clone Workflow

1. Stabilize platform base contracts and shared patterns
2. Clone for `edutech-core-frontend`
3. Add edutech modules as new features
4. Clone/branch for client products
5. Apply client customization in top layer only

