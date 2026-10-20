# <App name> — Android

<!-- Project layer. Platform and mobile rules load automatically from ~/Workspace/android-projects/CLAUDE.md.
     Only write what is specific to this app or deviates from the baseline. Keep it under ~80 lines. -->

## Overview

- What it is: <one line>
- applicationId `<com.example>` · namespace `<com.example>` · branch `master`
- Firebase project `<id>` → privacy URL `https://<id>.web.app`
- Ads / billing / analytics: <AdMob + UMP | none> · <billing | none> · Analytics, Crashlytics, Performance

## Deviations from the Android baseline

<!-- e.g. no version catalog yet, minSdk 23, extra module, different Application class. Say why and whether to migrate. -->

- None.

## Architecture notes

<!-- Package root, key screens, data sources, backend (Cloud Functions?), caching rules, background work. -->

## Locales

- Standard 15. <!-- or: Override — <locales> because <reason>. -->

## Commands (from `mobile/`)

```bash
./gradlew testDebugUnitTest lintDebug <koverVerify|koverVerifyDebug>
bundle exec fastlane deploy        # see docs/RELEASING.md
```

## Gotchas

<!-- Things that have bitten us before. -->
