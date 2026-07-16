# ADR 0003: Centralize Widget Navigation

## Status

Accepted

## Context

Several screens created routes directly using `MaterialPageRoute` or used replacement navigation directly inside widgets.

This made navigation harder to audit and increased duplication across screens.

## Decision

Centralize route creation and stack replacement helpers in `AppRoutes`.

Screen widgets should call named route helpers instead of creating `MaterialPageRoute` directly.

## Alternatives Considered

- Keep navigation directly inside screens
- Add a full router package immediately
- Use named routes through `MaterialApp`

## Consequences

Positive:

- Route creation is easier to find and test.
- Screens are smaller.
- Navigation behavior is more consistent.
- Future router migration is easier.

Negative:

- `AppRoutes` grows as more routes are added.
- This is not yet a full declarative routing solution.