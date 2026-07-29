# ADR 0013: Plan iOS Crashlytics Validation

## Status

Pending

## Context

Currently the firebase crash anlaytics is works on the android app successfully but i did'nt test on the iphone 

## Decision

Document iOS Crashlytics validation as a TestFlight/manual QA requirement.

The repository will:

- ignore `ios/Runner/GoogleService-Info.plist`
- write `GoogleService-Info.plist` in iOS CI/TestFlight workflows from GitHub secrets
- keep the controlled crash trigger hidden unless `ENABLE_CRASH_TEST=true`
- require a real iPhone/TestFlight tester to validate iOS Crashlytics runtime reporting


## Validation

Run:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test