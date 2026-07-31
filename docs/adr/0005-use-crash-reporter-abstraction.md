# ADR 0005: Use Crash Reporter Abstraction

## Status

Accepted

## Context

OrangeONE needs crash reporting that can later integrate with Firebase Crashlytics without making widgets or app startup depend directly on Firebase SDKs.

The app already captures Flutter framework errors and uncaught async errors from `main.dart`. The existing implementation uses `CrashReportingService`, which currently logs locally.

## Decision

Introduce a `CrashReporter` abstraction in `lib/core/crash/`.

`CrashReportingService` implements `CrashReporter` and remains the default local implementation.

`AppDependencies` exposes the abstraction instead of the concrete service.

`main.dart` records Flutter and zoned errors through the abstraction.

Firebase Crashlytics can later be added as another implementation without changing widgets or startup error handling flow.

## Consequences

Benefits:

- Firebase can be added behind a service boundary.
- Widgets do not call crash SDKs directly.
- Tests can inject fake crash reporters.
- Current crash flow remains stable.

Tradeoffs:

- Adds one small abstraction before Firebase is installed.
- Requires dependency tests to use the new abstraction name.

## Validation

Validated with:

```bash
flutter analyze
flutter test