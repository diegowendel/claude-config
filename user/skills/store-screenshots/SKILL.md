---
name: store-screenshots
description: Capture and compose the store screenshots for an iOS or Android app in all supported locales, using the project's own automated UI-test harness and compose scripts. Use when screenshots need regenerating after UI changes, a new locale, or before a release.
---

# Store screenshots

Screenshots are always produced by automation — never edited by hand.

## Android (calcly / koin pattern)

1. Needs a connected device or emulator with USB debugging. Check with `adb devices`.
2. From `mobile/`: `bundle exec fastlane screenshots` — runs `tools/screenshots/capture.sh` (per-app language, demo-mode status bar, all 15 locales → `screenshots/raw/<play-locale>/`) then `promo` (`tools/screenshots/compose.py` adds captions from `captions.py` and the phone frame).
3. Only some locales: `tools/screenshots/capture.sh en-US de-DE`, then `bundle exec fastlane promo`.
4. Captions changed only? Edit `tools/screenshots/captions.py` (all locales) and run `bundle exec fastlane promo`.
5. Upload with `bundle exec fastlane metadata` — **ask first**, it publishes to Google Play.

## iOS (salary-calculator-ie pattern)

1. `scripts/capture-screenshots.sh` — iPhone 6.9" and iPad 13" via `StoreScreenshotsUITests` on simulators, Mac by the app photographing its own window, then `scripts/compose-store-screenshots.swift` frames and captions. Output `fastlane/screenshots/{ios,mac}/<locale>/`.
2. Partial runs: `--skip-mac`, `--skip-ios`, `--only iphone|ipad|mac`.
3. The Mac must be unlocked with the display on for the Mac capture.
4. Upload happens through the release workflow / `fastlane release` with screenshots enabled — **ask first**.

## Projects without a harness

Set one up from the references above (see `new-mobile-app` step 6) rather than capturing manually. Demo data must be deterministic and contain nothing personal.

## Check

- Every supported locale has the full set, at the store's required sizes.
- Captions are localized (not English in every locale) and fit.
- Status bar is clean (9:41 / full battery / no notifications).
