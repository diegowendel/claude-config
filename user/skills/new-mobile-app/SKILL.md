---
name: new-mobile-app
description: Bootstrap a new iOS or Android app (or bring an existing one up to standard) with the standard setup — project CLAUDE.md and Claude settings, legal pages on Firebase Hosting, 15 locales, fastlane release, automated screenshots and privacy declarations. Use when starting a new app or when asked to align an older app with the current conventions.
---

# New mobile app checklist

Rules this implements: `~/Workspace/claude-config/mobile/CLAUDE.md` plus the platform file. Work through the steps in order; confirm the app name, bundle/package ID and platform with the user first. Ask before creating anything outward-facing (GitHub repo, Firebase project, store records).

## 1. Repo and Claude config

- Android: `~/Workspace/android-projects/<app>/` with `mobile/`, `firebase/`, `tools/`, `docs/`. iOS: `~/Workspace/ios-projects/<app>/`.
- `git init`, branch `master` (Android) or the one the user picks.
- Copy `~/Workspace/claude-config/templates/project-CLAUDE.<android|ios>.md` → `<repo>/CLAUDE.md` and fill it in.
- Copy `templates/project-settings.json` → `<repo>/.claude/settings.json`; add the app's build/test commands.
- `.gitignore`: `.claude/settings.local.json`, `CLAUDE.local.md`, keystores, `keystore.properties`, `*.p8`, `*.p12`, service-account JSON, `build/`, `screenshots/raw`.

## 2. App skeleton

- Android: copy the Gradle setup from calcly (`mobile/settings.gradle`, `build.gradle`, `gradle.properties` keys, `gradle/libs.versions.toml`, lint config, Kover, `res/resources.properties`). Depend on androidcommons.
- iOS: XcodeGen `project.yml`, `Config/{Base,Debug,Release}.xcconfig` (+ git-ignored `Local.xcconfig`), `PrivacyInfo.xcprivacy`, `Localizable.xcstrings`. Reference: salary-calculator-ie.

## 3. Legal pages and hosting

- Run the `legal-pages` skill: `legal/{privacy,terms,support,disclaimer?}.md` from `templates/legal/`, adapted to the SDKs the app uses.
- Firebase Hosting with routes/redirects/headers from `salary-calculator-ie/firebase.json`. Firebase project creation is the user's action.

## 4. Localization

- All 15 locales from day one (`localize` skill), unless the user states an override → record it in `CLAUDE.md`.

## 5. fastlane

- Android: copy `calcly/mobile/{Gemfile,fastlane/Appfile,fastlane/Fastfile}`. Change: `PACKAGE_NAME`, the archive folder (`~/<App>Releases`), the androidcommons catalog key, the Kover task name, and whether `promo` builds a feature graphic. Commit `Gemfile.lock`.
- iOS: copy `salary-calculator-ie/{Gemfile,.ruby-version,fastlane/Appfile,fastlane/Fastfile}`; update app identifier and platforms. Commit `Gemfile.lock`.
- `fastlane/metadata/` for every locale (ASO rules in `~/.claude/rules/store-listing.md`).

## 6. Screenshots

- Android: `StoreScreenshotsTest` (instrumented, demo data) + `tools/screenshots/{capture.sh,compose.py,captions.py}` from calcly.
- iOS: `StoreScreenshotsUITests` + `scripts/capture-screenshots.sh` + `scripts/compose-store-screenshots.swift` from salary-calculator-ie.

## 7. Privacy, ads, analytics

- Decide with the user: ads (AdMob + UMP), analytics/crash reporting. Reflect every choice in the legal text, `PrivacyInfo.xcprivacy` / Data safety, and the listing claims.

## 8. Verify

- Platform verification from the platform `CLAUDE.md` (Android: `./gradlew testDebugUnitTest lintDebug`; iOS: tests + signed `generic/platform=iOS` build).
- `bundle exec fastlane lanes` lists the lanes; legal sync script passes with `--strict` before the first release.
