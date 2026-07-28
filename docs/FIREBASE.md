# Firebase Foundation Plan

This document defines how Firebase should be introduced into OrangeONE.

## Goal

Firebase should improve release quality and operational visibility without making widgets depend directly on Firebase SDKs.

Target services:

- Firebase Crashlytics
- Firebase Remote Config
- Firebase App Distribution
- Firebase Analytics, only if needed after backend analytics is reviewed

## Current App Status

OrangeONE currently has:

- `AnalyticsService`
- `CrashReportingService`
- Backend analytics endpoints
- Local feature flag foundation
- CI/CD for Flutter checks
- CI/CD for Android APK build
- CI/CD for iOS TestFlight build

Firebase is not currently installed.

## Rules

1. Do not call Firebase directly from widgets.
2. Keep Firebase behind app services or provider-backed wrappers.
3. Keep current backend analytics working unless intentionally replaced.
4. Add Firebase one service at a time.
5. Validate Android and iOS setup separately.
6. Update App Store privacy details when Firebase SDKs are added.
7. Keep Demo Mode independent from Firebase configuration.

## Service Responsibilities

### Crashlytics

Purpose:

- Capture fatal crashes.
- Capture non-fatal exceptions.
- Attach useful diagnostic context.

Should integrate with:

- `CrashReportingService`
- `FlutterError.onError`
- `runZonedGuarded`

Should not be called directly from screens.

### Remote Config

Purpose:

- Backend-driven feature flags.
- Runtime rollout control.

Should integrate with:

- `FeatureFlagProvider`
- `FeatureFlagController`

Should not replace local defaults. The app must still start with safe local defaults if Firebase is unavailable.

### App Distribution

Purpose:

- Internal Android tester distribution.
- Faster testing before public release.

Should integrate with:

- GitHub Actions
- Firebase CLI or Fastlane

Should not replace TestFlight for iOS App Store review.

### Firebase Analytics

Purpose:

- Optional usage analytics if backend analytics is not enough.

Current backend analytics already tracks:

- Login success
- Product scan
- Product found/not found
- Product added
- Product updated
- Price updated
- Logout
- App opened

Firebase Analytics should be added only after deciding whether duplicate analytics is useful.

## Recommended Rollout

1. Phase 30: Crashlytics wrapper and Firebase setup.
2. Phase 31: Remote Config feature flag provider.
3. Phase 32: Firebase App Distribution for Android.
4. Later: Firebase Analytics if required.

## Platform Setup Checklist

### Android

Required later:

- Firebase project
- Android app registration
- `google-services.json`
- Gradle Google services plugin
- Crashlytics Gradle plugin
- CI secret strategy for Firebase config if needed

### iOS

Required later:

- Firebase project
- iOS app registration
- `GoogleService-Info.plist`
- CocoaPods update
- Crashlytics upload symbols setup
- App Store privacy review update

## CI/CD Checklist

When Firebase is added:

1. CI must still run formatting, analyzer, and tests.
2. Android APK workflow must still build.
3. iOS TestFlight workflow must still build.
4. Firebase config files must not expose secrets.
5. Distribution tokens or service account credentials must be stored in GitHub secrets.

## Privacy Notes

Before adding Firebase SDKs, confirm App Store Connect privacy answers for:

- Crash data
- Diagnostics
- Usage data, only if Analytics is enabled
- Device identifiers, depending on Firebase configuration

## Definition Of Done For This Planning Phase

- Firebase responsibilities are documented.
- Rollout order is documented.
- Firebase is not installed yet.
- No app behavior changes.
- Analyzer and tests pass.
# Firebase

This document defines how Firebase should be integrated into OrangeONE.

## Current Firebase Usage

OrangeONE currently integrates Firebase packages for Crashlytics preparation:

## Crashlytics Validation

Crashlytics has three validation layers.

### Unit Tests

Automated tests cover:

- Firebase startup initializes Firebase and enables Crashlytics collection.
- Firebase startup failures are propagated to the resolver.
- Crash reporter resolution returns Firebase reporting when startup succeeds.
- Crash reporter resolution falls back and records the startup failure when Firebase is unavailable.
- App startup routes Flutter framework errors to the resolved crash reporter.
- App startup routes uncaught async errors as fatal reports.
- Feature flag refresh still runs before the app is started.
- Firebase crash reporter forwards Flutter, non-fatal, and fatal errors to the Crashlytics client.

### Build Validation

CI validates native platform setup by running:

```bash
flutter analyze
flutter test
flutter build apk --release --dart-define=APP_ENV=production
flutter build ios --release --no-codesign --dart-define=APP_ENV=production

## Crashlytics End-To-End Validation

Crashlytics fallback keeps the app usable if Firebase startup fails, but fallback reporting alone does not prove Firebase is working.

For that reason, Crashlytics must be validated in two ways.

### Build-Time Validation

CI must prove the native Firebase wiring is buildable:

```bash
flutter build apk --release --dart-define=APP_ENV=production
flutter build ios --release --no-codesign --dart-define=APP_ENV=production
## Controlled Crash Test

Crashlytics can be validated with an internal-only crash trigger.

The trigger is hidden by default and only appears when the app is built with:

```bash
--dart-define=ENABLE_CRASH_TEST=true

## App Error Observability

OrangeONE reports selected app/backend communication failures to Firebase Crashlytics as non-fatal errors through `AppErrorReporter`.

Current non-fatal reporting covers:

- saved session validation failures
- QR login failures
- product lookup failures from the scanner
- product reference loading failures
- product creation failures
- product update failures
- product price update failures

Reported safe context:

- screen
- action
- app environment
- API endpoint path
- HTTP status code, when available

Sensitive data must not be reported:

- auth tokens
- raw QR login payloads
- full backend URLs with sensitive query parameters
- response bodies
- customer-sensitive product data

API errors are sanitized before reporting so Firebase receives safe diagnostic information instead of raw backend URLs or response bodies.

Crashlytics should be used for crash/error visibility, not real-time operational dashboards. Console counts can be delayed or require refresh while Firebase processes events.

```text
firebase_core
firebase_crashlytics

