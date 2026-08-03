# ADR 0010: Add App Error Observability

## Status

Pending

## Plan

The plan is record the crash when the backend and app communication Example for login, auth validation , product scanning errors

So i planned to intergarate the these crashes also on the firbase crash analytics to monitor

Crashlytics is already available behind the `CrashReporter` abstraction its was finished and works on the android phone correctly also im not test on the ios app when i press the trigger crash button on the app its shows on the firebase console now i also implement the app functinality crashes

## Decision

Introduce `AppErrorReporter` as the application-level error observability boundary.

`AppErrorReporter` records non-fatal errors through `CrashReporter.recordError`.

Reported context may include:

- screen
- action
- app environment
- API endpoint path
- HTTP status code

Reported context must not include:

- auth tokens
- raw QR login data
- full backend URLs with sensitive query parameters
- response bodies
- customer-sensitive product data

Initial wiring covers:

- saved session validation on the splash screen
- QR login failures on the login screen
- product lookup failures on the scanner screen

## Validation