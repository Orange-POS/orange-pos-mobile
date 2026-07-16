# ADR 0002: Use Riverpod For State Management

## Status

Accepted

## Context

OrangeONE is moving toward a cleaner architecture with better separation between UI, dependency access, feature state, and business logic.

The app currently uses constructor-based dependency injection and StatefulWidgets. This works, but future work such as Remote Config, feature flags, offline state, and shared app state needs a stronger state management foundation.

## Decision

Use Riverpod as the state management foundation.

Riverpod will first expose shared dependencies through providers. Screen logic will be migrated gradually in focused future phases.

## Alternatives Considered

- Bloc
- Provider
- Keeping only constructor-based dependency injection

## Consequences

Positive:

- Better dependency access.
- Easier testing of state and providers.
- Good fit for feature-first architecture.
- Works well with Remote Config and feature flags.

Negative:

- Adds a new dependency.
- Team must follow provider usage rules.
- Existing screens still need gradual cleanup.