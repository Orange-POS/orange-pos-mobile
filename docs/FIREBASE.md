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