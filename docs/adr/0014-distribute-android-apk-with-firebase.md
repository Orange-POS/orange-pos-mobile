# ADR 0014: Distribution Android APK with Firebase Dsitribution

## Status
Finished

## Context 

App already build using the Github Actions 

Before this decision, APK sharing is manual after CI produced the artifact. Manual Hard to track , Less secure, and less convinent to tester and the Customer

So Firebase app distribution provides a controlled tester distibuiton channel for Android builds

## Decision

Upload androd release APKs to firebase app distibution from APK Github actions workflow

Distribution is limited to manual workflow runs with `workflow_dispatch

The workflow keeps uploading the APK as a GitHub artifact and additionally uploads the APK to Firebase App Distribution.

Required GitHub secrets:

- `FIREBASE_ANDROID_APP_ID`
- `FIREBASE_APP_DISTRIBUTION_SERVICE_ACCOUNT_JSON`

Firebase tester group:

- `orangeone-android-testers`

## Consequences

Internal testers can receive Android APK builds through Firebase App Distribution.

Build distribution is auditable through GitHub Actions and Firebase.

APK upload does not happen automatically on every pull request or push; it only runs when manually dispatched.

The service account JSON must remain in GitHub secrets and must never be committed.

## Validation

Run locally:

```bash
flutter analyze
flutter test
flutter build apk --release --dart-define=APP_ENV=production