# ADR 0009: Add Controlled Crash Test Trigger

## Status
Finished 

## Plan 
Add a button for the enabel the firebase crash analytics button this for the development beacuse we need to make sure the crash routes are send succesfully to the firebase when its only for devlopment stage when we need to release the app we can disabel using the feature flags method 

We set this button inside the setting screen 

Crashlytics must be validated with a real crash event. Waiting for accidental crashes is not a reliable QA process, but exposing a crash button to customers would be unsafe.

## Decision 
So when we build the app just ENABLE_CRASH_TEST=true  set this parameter true value so its enable deafult false value to true so the build conatain the Button on the setting page  

## test
flutter build apk --release --dart-define=APP_ENV=production --dart-define=ENABLE_CRASH_TEST=true   