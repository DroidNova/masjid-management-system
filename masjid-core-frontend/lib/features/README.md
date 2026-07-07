# Feature Boundaries

This directory contains **platform-level business features** (auth, admin, profile, settings).

## Conventions
- `core/`: infrastructure and technical building blocks.
- `shared/`: reusable UI, models, and helpers shared across features.
- `features/`: platform modules aligned to backend modules.

## Clone Guidance
When cloning into `edutech-core-frontend` (or client products), add new domain modules as new features instead of modifying platform feature boundaries.
