# Release Process

This document defines the release process for OrangeONE.

## Release Principles

1. Release builds must be created through CI/CD.
2. Local machines should not be the source of production iOS builds.
3. Build numbers must always increase.
4. App Store metadata must match app behavior.
5. Demo Mode must be tested before App Review submission.
6. No new release should be submitted with failing analyzer or tests.
7. TestFlight upload should only happen after formatting, analyzer, and tests pass.

## Current CI/CD

Current workflows:

```text
.github/workflows/flutter_ci.yml
.github/workflows/ios_testflight.yml
```

## Flutter CI

Workflow:

```text
.github/workflows/flutter_ci.yml
```

Runs on:

```text
push to main
pull request to main
```

Checks:

```text
flutter pub get
flutter pub deps
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test --coverage
flutter build ios --release --no-codesign
```

Purpose:

- Catch formatting issues.
- Catch analyzer issues.
- Run automated tests with coverage.
- Upload coverage as a short-lived artifact.
- Confirm the iOS project can build without signing.
- Upload the unsigned iOS build as a short-lived artifact.

## TestFlight CI

Workflow:

```text
.github/workflows/ios_testflight.yml
```

Runs on:

```text
manual workflow_dispatch
```

Checks before upload:

```text
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Build and upload:

```text
flutter build ipa --release
fastlane ios beta
```

Purpose:

- Build a signed iOS IPA on GitHub Actions.
- Upload the IPA artifact for debugging.
- Upload the build to TestFlight through Fastlane.
- Keep signing assets and App Store Connect credentials inside GitHub secrets.

## Required TestFlight Secrets

The TestFlight workflow expects these GitHub environment secrets:

```text
IOS_DISTRIBUTION_CERTIFICATE_BASE64
IOS_DISTRIBUTION_CERTIFICATE_PASSWORD
IOS_PROVISIONING_PROFILE_BASE64
TEMP_KEYCHAIN_PASSWORD
APPLE_TEAM_ID
IOS_BUNDLE_ID
APP_STORE_CONNECT_API_KEY_ID
APP_STORE_CONNECT_ISSUER_ID
APP_STORE_CONNECT_PRIVATE_KEY
```

## Build Number Strategy

The TestFlight workflow uses:

```text
github.run_number
```

as the iOS build number.

This keeps uploaded build numbers increasing automatically.

## Pre-Release Checklist

Before submitting a build to Apple review:

1. Run Flutter CI successfully.
2. Confirm the CI coverage artifact was generated.
3. Run TestFlight workflow successfully.
4. Confirm Demo Mode works for Apple review.
5. Confirm camera permission text is correct.
6. Confirm app privacy details are complete in App Store Connect.
7. Confirm no routing app coverage file is attached unless the app is a routing app.
8. Confirm screenshots and app metadata match the current app behavior.

