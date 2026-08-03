# ADR 0011: Observe Product Mutation Errors

## Status

Finished

## Plan

App already have some crassh analytics reporting method for app login errors and product scanning errors, Now i extend the feature to the add product , edite product and update price functions. Its useful when app return any errors to the user from these we can easily debug those 

## Decision

Extend `AppErrorReporter` usage to product mutation screens.

Initial coverage includes:

- `add_product` / `load_product_references`
- `add_product` / `create_product`
- `edit_product` / `load_product_references`
- `edit_product` / `update_product`
- `update_price` / `update_product_price`

These failures are reported as non-fatal errors through `CrashReporter.recordError`.

Reported context remains limited to safe diagnostic metadata:

- screen
- action
- app environment
- API endpoint path
- HTTP status code


## So

Product mutation failures become visible in Crashlytics without changing user-facing behavior.

Screens still show the existing validation or backend error messages.

The app keeps Firebase behind the existing `CrashReporter` and `AppErrorReporter` abstractions.

Future work can add observability for analytics send failures, offline queue failures, and stock adjustment flows.

## Validation

Run:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter test --coverage