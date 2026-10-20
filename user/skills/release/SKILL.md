---
name: release
description: Prepare and run a store release for an iOS or Android app with fastlane — pre-release checks, version bump, localized release notes, build/upload and the release commit/tag. Use when the user asks to release, ship, deploy to a store track, promote, roll out or submit for review.
---

# Release

Uploading, promoting and submitting are outward-facing: **confirm with the user before each publishing step.** Read the project's `CLAUDE.md` and `docs/RELEASING.md` (Android) or `README.md` "Releasing" (iOS) first — lane options differ per app.

## 1. Pre-release checks (both platforms)

- Clean working tree on the release branch; up to date with origin.
- Tests and build pass (platform verification in the platform `CLAUDE.md`).
- What's new written for **every supported locale** (≤500 chars on Play).
- Listing and privacy declarations still match the app; run the `store-review` agent.
- Screenshots current (`store-screenshots` skill) if the UI changed.
- Legal pages current; iOS: `scripts/sync-website.sh --strict` passes.

## 2. Android (local fastlane, from `mobile/`)

```bash
bundle exec fastlane deploy                       # next versionCode, same versionName, internal track
bundle exec fastlane deploy version_name:X.Y.Z    # new marketing version
bundle exec fastlane deploy track:production      # other track
bundle exec fastlane promote rollout:0.1          # internal → production at 10 %
bundle exec fastlane rollout percent:1.0          # complete rollout
bundle exec fastlane metadata                     # store texts/images only
bundle exec fastlane validate                     # dry run, publishes nothing
```

`deploy` = preflight → tests → version bump → signed bundle → upload with mapping → archive → `releases.json` → commit `release: vX.Y.Z (code)` + tag `vX.Y.Z-code` → push (`push:false` to skip).

Common failures: missing `PLAY_STORE_JSON_KEY_PATH`, missing keystore, androidcommons not in Maven Local (`android-commons/gradle-publish-local.sh`), dirty tree.

## 3. iOS (fastlane + App Store Connect API key)

- Bump `MARKETING_VERSION` in `Config/Base.xcconfig` after a version went live; build numbers are automatic.
- Release notes in `fastlane/release_notes.txt` (or per-locale metadata).
- Local: `ASC_KEY_ID=… ASC_ISSUER_ID=… ASC_KEY_PATH=… bundle exec fastlane beta` (TestFlight) or `release` (TestFlight + metadata + submit for review).
- Projects with CI (salary-calculator-ie): pushing to `master` triggers the release workflow; manual runs via GitHub Actions. Tag `release/<version>-<build>`.
- Releasing to the public after approval is always manual in App Store Connect.

## 4. After

- Report version/build, track, and what's pending (review, rollout %).
