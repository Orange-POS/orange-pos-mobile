# Release Process

This document defines the release process for OrangeONE.

## Release Principles

1. Release builds must be created through CI/CD.
2. Local machines should not be the source of production iOS builds.
3. Build numbers must always increase.
4. App Store metadata must match app behavior.
5. Demo Mode must be tested before App Review submission.
6. No new release should be submitted with failing analyzer or tests.

## Current CI/CD

Current workflows:

```text
.github/workflows/flutter_ci.yml
.github/workflows/ios_testflight.yml