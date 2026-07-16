# ADR 0004: Plan Firebase Behind Service Wrappers

## Status

Accepted

## Context

OrangeONE needs crash reporting, remote configuration, tester distribution, and possibly analytics.

Firebase can provide these capabilities, but direct Firebase SDK usage inside widgets would make the app harder to test and maintain.

Firebase also affects Android, iOS, CI/CD, App Store privacy, and release workflows.

## Decision

Introduce Firebase gradually and keep Firebase SDK calls behind app services or provider-backed wrappers.

Planned Firebase services:

- Crashlytics
- Remote Config
- App Distribution
- Analytics only if needed after reviewing backend analytics

## Alternatives Considered

- Install all Firebase services immediately
- Call Firebase directly from widgets
- Use only backend analytics and no Firebase

## Consequences

Positive:

- Safer rollout.
- Easier testing.
- Widgets stay independent from Firebase SDKs.
- App Store privacy impact can be reviewed per service.

Negative:

- Firebase integration takes more phases.
- Wrapper interfaces must be maintained.