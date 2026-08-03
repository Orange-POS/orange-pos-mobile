# ADR 0012: Observe Analytics Failures

## Status

Finished 

## Context

App send the analytics like login successFull, Product Updated messages to odoo backend on this setup if thr analytics message is not sned to odoo backend the app should return error 

## Decision

Introduce `ObservableAnalyticsService` as a wrapper around `AnalyticsService`.

`AnalyticsService` keeps the default safe behavior of swallowing failures. It can also be configured with `swallowFailures: false` so callers can observe failures.

`ObservableAnalyticsService` uses `AnalyticsService(swallowFailures: false)` and reports analytics send failures through `AppErrorReporter` as non-fatal errors.

Screens use `ObservableAnalyticsService` instead of raw `AnalyticsService`.

This setup if the analytics data failed to send to odoo backend app still works fine but it's catcj the error and sent it to the firebase console so user is not ssee any crash messages 

Initial coverage includes analytics calls from:

- splash
- login
- scanner
- add product
- edit product
- update price

Reported context remains limited to safe diagnostic metadata:

- screen
- action
- app environment
- API endpoint path
- HTTP status code

The reporting must not include:

- auth tokens
- backend URLs
- barcodes
- product names
- product prices
- tax IDs
- analytics metadata payloads
- raw backend responses

## Consequences

Analytics failures remain non-blocking for users.

Persistent analytics delivery issues become visible in Crashlytics as non-fatal reports.

Screens no longer directly depend on raw analytics sending behavior.

Future work can add sampling, rate limiting, or backend-driven controls if analytics failure reporting becomes too noisy.

## Validation

Run:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter test --coverage