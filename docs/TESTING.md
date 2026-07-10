# Testing Strategy

This document defines the testing direction for OrangeONE.

## Required Local Checks

Run these before every commit:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Run this before release work:

```bash
flutter test --coverage
```

## Current Automated Test Areas

Current test coverage includes:

- Models
- API exception formatting
- Feature flags
- App configuration
- Dependency injection
- Product repository factory
- Product use cases
- Auth use cases
- Services constructor injection
- Shared UI widgets
- Navigation route construction
- Responsive smoke tests

## CI Checks

GitHub Actions runs:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test --coverage
flutter build ios --release --no-codesign
```

The CI workflow uploads:

```text
coverage/lcov.info
```

as the `flutter-coverage` artifact.

## Responsive Testing

Responsive smoke tests live in:

```text
test/ui/responsive_smoke_test.dart
```

These tests catch common overflow problems on smaller phone sizes.

## Coverage Direction

At this stage, coverage is collected but no minimum threshold is enforced.

Future target:

1. Keep coverage visible in CI.
2. Add tests around business workflows before adding new features.
3. Add a minimum coverage threshold only after the baseline is stable.
4. Avoid blocking development with an unrealistic threshold too early.

## Manual Testing Before App Review

Before submitting a build to Apple review:

1. Test Demo Mode login.
2. Scan existing demo product.
3. Scan unknown demo barcode.
4. Add product from unknown barcode.
5. Update price.
6. Edit product name and tax.
7. Confirm no overflow on a small phone screen.
8. Confirm camera permission text is correct.