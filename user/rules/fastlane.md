---
paths:
  - "**/fastlane/**"
  - "**/Gemfile"
  - "**/Gemfile.lock"
---

# fastlane

- Always run through Bundler: `bundle exec fastlane <lane>`. `Gemfile` pins fastlane; **`Gemfile.lock` is committed**. Ruby via rbenv/Homebrew (≥ 3.1), never the macOS system Ruby.
- Credentials come from environment variables, never from files in the repo:
  - Android: `PLAY_STORE_JSON_KEY_PATH` → `~/.config/playstore/<app>.json`.
  - iOS: `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_PATH` (local) or `ASC_KEY_P8` (CI).
- Generated files (`fastlane/README.md`, `report.xml`) are not edited by hand.

## Lanes (keep names consistent across apps)

| Android (`mobile/fastlane/Fastfile`) | iOS (`fastlane/Fastfile`) |
|---|---|
| `test`, `ui_test` | — (xcodebuild / CI) |
| `preflight` — clean tree, branch, keys, androidcommons in `~/.m2` | |
| `deploy` — tests → version → signed bundle → upload → archive → commit + tag | `beta` — build + TestFlight |
| `promote`, `rollout` | `release` — beta + metadata + submit for review |
| `metadata`, `validate`, `screenshots`, `promo`, `release_log` | |

## Release record

- Commit: `release: vX.Y.Z (code)`.
- Tags: Android `vX.Y.Z-code`; iOS `release/<version>-<build>`.
- Android also appends to `mobile/fastlane/releases.json` and archives `.aab` + `mapping.txt` outside the repo (`~/<App>Releases/`).
- The Android Fastfiles in calcly and koin are near-identical; a new app starts from calcly's (see the `new-mobile-app` skill).
