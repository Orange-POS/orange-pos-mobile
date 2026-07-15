# Environments and Flavors

This document defines the environment strategy for OrangeONE.

## Current Status

The app currently has one main build setup.

Current behavior:

- Production app configuration is used by default.
- Demo Mode exists inside the same app for Apple review.
- Flutter flavors are not configured yet.

## Current Runtime Modes

OrangeONE currently supports:

```text
production mode
demo mode
```

Production mode:

- Uses QR login data from the Odoo POS backend.
- Uses backend URLs from the scanned login QR code.
- Sends product, analytics, and session requests to the Odoo backend.

Demo mode:

- Does not require an Odoo backend.
- Uses sample products and sample barcodes.
- Exists for Apple App Review and internal testing.
- Must not accidentally change production data.

## Target Environments

The app supports these code-level environments:

```text
development
staging
production
```

Current status:

- `production` is the default.
- `development` is available through `APP_ENV`.
- `staging` is available through `APP_ENV`.
- Native Android/iOS flavors are not configured yet.

## Build-Time Environment Selection

The app can select its environment with the `APP_ENV` Dart define.

Default:

```bash
flutter run
```

uses:

```text
production
```

Development:

```bash
flutter run --dart-define=APP_ENV=development
```

Staging:

```bash
flutter run --dart-define=APP_ENV=staging
```

Production:

```bash
flutter run --dart-define=APP_ENV=production
```

Supported aliases:

```text
development, dev
staging, stage
production, prod
```

Unknown values fall back to production.

## Demo Mode Safety Rules

1. Demo Mode should only use demo auth token and demo backend URL.
2. Demo Mode should use demo repositories and stores.
3. Demo Mode should not send product changes to Odoo.
4. Demo Mode should be easy to remove or disable.
5. Demo Mode behavior must be documented for Apple review.

## Release Safety Checklist

1. Confirm production config is the default app config.
2. Confirm Demo Mode is intentional for the submitted build.
3. Confirm App Review notes explain Demo Mode.
4. Confirm backend URLs are not hardcoded for production users.
5. Confirm no local IP address is bundled as a production default.
6. Confirm CI and TestFlight workflows use the expected build configuration.