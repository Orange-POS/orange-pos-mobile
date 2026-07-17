# ADR 0006: Integrate Firebase Crashlytics Behind CrashReporter

## Status

Accepted

## Context

OrangeONE needs production crash reporting so runtime failures can be diagnosed after release.

Phase 30 introduced the `CrashReporter` abstraction. That boundary allows the app to add Firebase Crashlytics without coupling widgets, startup flow, or tests directly to Firebase SDK APIs.

Crashlytics requires native Firebase configuration for Android and iOS. Unit tests should not depend on real Firebase initialization or send crash events to Firebase.

## Decision

Integrate Firebase Crashlytics behind the existing `CrashReporter` abstraction.

Add Firebase-specific classes under `lib/core/crash/` and `lib/core/firebase/`:

- `CrashlyticsClient`
- `FirebaseCrashlyticsClient`
- `FirebaseCrashReporter`
- `FirebaseBootstrap`
- `FirebaseAppStartup`
- `CrashReporterResolver`

`main.dart` resolves a crash reporter at startup. If Firebase initializes successfully, the app uses `FirebaseCrashReporter`. If Firebase initialization fails or native config is missing, the app falls back to the existing local crash reporter.

Tests use fakes and do not call real Firebase services.

## Consequences

Benefits:

- Production crash reporting can be enabled through Firebase Crashlytics.
- Firebase SDK usage is isolated to core infrastructure.
- Widgets do not depend on Firebase.
- Tests remain deterministic and do not send data to Firebase.
- Missing native Firebase config does not block local app startup.

Tradeoffs:

- Startup has one additional initialization step.
- Native Android and iOS Firebase config must be managed carefully.
- A test Firebase project should be used before production rollout.

## Validation

Validated with:

```bash
flutter analyze
flutter test