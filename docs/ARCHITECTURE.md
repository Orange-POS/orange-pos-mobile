# OrangeONE Architecture

OrangeONE is a mobile POS companion app for scanning, viewing, creating, and updating products connected to an Odoo POS backend.

## Current Goal

The current engineering goal is to stop feature expansion and strengthen the project foundation.

Priorities:

1. Stable project structure
2. Clear separation between UI, business logic, and data access
3. Reliable CI/CD
4. Test coverage for core flows
5. Feature flags and environment configuration
6. Demo mode isolated from production logic
7. Safe release process

## Architecture Direction

The app should move toward a feature-first structure:

```text
lib/
  app/
  core/
    config/
    errors/
    feature_flags/
    network/
    storage/
    theme/
  features/
    auth/
      data/
      domain/
      presentation/
    products/
      data/
      domain/
      presentation/
    scanner/
      presentation/
    settings/
      presentation/
    demo/
      data/
      domain/
  shared/
    widgets/
    utils/