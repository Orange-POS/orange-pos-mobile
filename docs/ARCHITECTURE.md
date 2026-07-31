# OrangeONE Architecture

OrangeONE is a mobile POS companion app for scanning, viewing, creating, and updating products connected to an Odoo POS backend.

## Current Engineering Goal

The current engineering goal is to stop feature expansion and strengthen the project foundation.

Priorities:

1. Stable project structure
2. Clear separation between UI, business logic, and data access
3. Reliable CI/CD
4. Test coverage for core flows
5. Feature flags and environment configuration
6. Demo Mode isolated from production logic
7. Safe release process

## Current High-Level Flow

```text
Flutter screens
  -> use cases
    -> repositories / services
      -> ApiClient
        -> Odoo backend
```

For product workflows:

```text
screens
  -> ProductUseCases
    -> ProductRepository
      -> OdooProductRepository / DemoProductRepository
        -> ProductService / DemoProductStore
```

For auth/session workflows:

```text
screens
  -> AuthUseCases
    -> AuthService / SessionService / TokenStorage
      -> ApiClient / secure storage
```

## State Management Direction

OrangeONE uses Riverpod as the state management foundation.

Current Phase 27 usage:

- `ProviderScope` wraps the app at startup.
- `appDependenciesProvider` exposes `AppDependencies`.
- Existing constructor-based dependency injection remains in place.
- Screens are not rewritten yet.

Rules:

1. Do not move screen logic into providers without a focused phase.
2. Use providers first for shared dependencies and feature state.
3. Keep business logic in use cases, not widgets.
4. Keep API calls inside services/repositories, not widgets.
5. Add tests for new providers.

## Dependency Injection

App-level dependencies are created in:

```text
lib/core/di/app_dependencies.dart
```

`AppDependencies` owns:

- `AppConfig`
- `ApiClient`
- `FeatureFlagController`
- `FeatureFlagProvider`
- `ProductRepositoryFactory`
- `AnalyticsService`
- `AuthService`
- `SessionService`
- `TokenStorage`
- `CrashReportingService`
- `AuthUseCases`

Screens receive dependencies from the app root and pass them through navigation routes.

Navigation helpers live in:

```text
lib/core/navigation/app_routes.dart
```

## Product Layer

Product application logic lives in:

```text
lib/features/products/application/product_use_cases.dart
```

Product repository contract lives in:

```text
lib/features/products/domain/product_repository.dart
```

Product repository implementations live in:

```text
lib/features/products/data/
```

Current implementations:

- `OdooProductRepository`
- `DemoProductRepository`
- `ProductRepositoryFactory`

## Auth Layer

Auth/session application logic lives in:

```text
lib/features/auth/application/auth_use_cases.dart
```

Auth use cases handle:

- QR login
- saving token and backend URL
- restoring saved session
- validating saved session
- clearing session on logout

## Services

Backend-facing services live in:

```text
lib/services/
```

Current services:

- `ApiClient`
- `AuthService`
- `SessionService`
- `ProductService`
- `AnalyticsService`
- `CrashReportingService`
- `TokenStorage`

Services support dependency injection where needed, especially `ApiClient`.

## Demo Mode

Demo Mode exists for Apple App Review and internal testing.

Demo files live in:

```text
lib/demo/
```

Demo Mode uses:

- demo auth token
- demo backend URL marker
- demo product store
- demo product repository

Demo Mode must not send product changes to Odoo.

## UI Design System

Shared UI tokens live in:

```text
lib/core/theme/
```

Shared UI widgets live in:

```text
lib/core/widgets/
```

Current shared widgets include:

- `AppButton`
- `AppTextField`
- `AppErrorState`
- `AppSurface`
- `AppBadge`
- `AppScannerOverlay`

More UI details are documented in:

```text
docs/UI_DESIGN_SYSTEM.md
```

## Testing

Testing strategy is documented in:

```text
docs/TESTING.md
```

Current testing includes:

- model tests
- service constructor tests
- use case tests
- repository factory tests
- dependency injection tests
- shared widget tests
- route tests
- responsive smoke tests

## CI/CD

CI/CD is documented in:

```text
docs/RELEASE.md
```

Current workflows:

```text
.github/workflows/flutter_ci.yml
.github/workflows/ios_testflight.yml
```

Flutter CI runs formatting, analyzer, coverage tests, and unsigned iOS build.

TestFlight CI builds and uploads signed iOS builds through GitHub Actions.

## Architecture Rules

1. Screens should focus on UI state, navigation, and rendering.
2. Business workflows should live in use cases.
3. Backend access should go through services or repositories.
4. Product screens should use `ProductUseCases`, not repositories directly.
5. Auth/session screens should use `AuthUseCases`, not services directly.
6. Shared visual patterns should live in `lib/core/widgets/`.
7. Repeated styling should use `lib/core/theme/` tokens.
8. Demo Mode must remain isolated from Odoo production behavior.
9. New features should come with tests before release work.