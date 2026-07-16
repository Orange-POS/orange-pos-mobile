# ADR 0001: Use Build-Time Environment Config

## Status

Accepted

## Context

OrangeONE needs a clear way to separate production, staging, and development configuration.

The app previously used one main runtime setup. This made it harder to reason about release builds, CI/CD behavior, and future staging or development workflows.

## Decision

Use `APP_ENV` as a Dart define to select the app environment at build/run time.

Supported values:

- `development`
- `dev`
- `staging`
- `stage`
- `production`
- `prod`

Production remains the default when no environment is provided.

## Alternatives Considered

- Native Android/iOS flavors immediately
- Runtime environment selection inside the app UI
- Keeping only one production configuration

## Consequences

Positive:

- CI/CD can explicitly build production artifacts.
- Development and staging modes can be introduced safely.
- Production remains the default.
- Environment behavior is documented.

Negative:

- Native platform flavors are still not configured.
- Developers must remember to pass `--dart-define=APP_ENV=...` for non-production runs.