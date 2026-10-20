# Mobile apps — rules for both iOS and Android

These apply to every app I ship, on either platform. A project's `CLAUDE.md` may override one only with a stated reason.

## Every app ships with

- **Privacy policy, terms of use and a support page**, hosted per app on Firebase Hosting (`<project>.web.app`):
  - Routes `/privacy`, `/terms`, `/support`; redirects from `/privacy-policy`, `/terms-of-use`, `/contact`, `/help`.
  - One markdown source per document with `{{APP_NAME}}`-style placeholders, synced into the website and (on iOS) bundled in the app. Reference: `salary-calculator-ie/legal/` + `scripts/sync-website.sh --strict`.
  - Linked from the in-app About screen and from the store listing.
  - Details: `~/.claude/rules/legal.md` (loads when you touch legal files). Templates: `claude-config/templates/legal/`.
- **Light and dark mode**, localized accessibility labels, layouts checked on small and large screens.
- **15 locales** (below), store metadata included.
- **Automated release** via fastlane and **automated store screenshots**.

## Backend

- No backend unless the feature needs one. When it does, use **Firebase**.
- **Cloud Functions (TypeScript) take priority over any dedicated server, VM or container.** Pick Firestore / Hosting / Functions before anything that needs a machine running.
- Shared cross-app services, the brand site and `app-ads.txt` live in `~/Workspace/appcraftlabs`.
- Details: `~/.claude/rules/firebase.md`.

## Localization

- Default: **15 locales** — en-US (default), es-419, es-ES, pt-BR, pt-PT, fr-FR, de-DE, it-IT, ja-JP, ko-KR, ru-RU, hi-IN, tr-TR, nl-NL, id.
- Every new user-facing string goes into **all** locales in the same commit. No hardcoded user-facing strings.
- es-ES vs es-419 and pt-PT vs pt-BR are written independently — never copy one into the other.
- Excluded for now: Chinese (low ROI on Play) and Arabic (needs RTL work first).
- Overrides (e.g. a country-specific app) must be written in the project's `CLAUDE.md` with the reason.
- Full table and per-platform folder/codes: `~/.claude/rules/localization.md`. Use the `localize` skill.

## Release and store

- **fastlane** through Bundler (`bundle exec fastlane …`), `Gemfile.lock` committed.
- Store metadata lives in `fastlane/metadata/` for every supported locale.
- **Screenshots are automated, never hand-made:** a UI test drives the app in a demo state per locale, then a script frames and captions them.
  - Android reference: `calcly/tools/screenshots/{capture.sh,compose.py}` + `StoreScreenshotsTest`.
  - iOS reference: `salary-calculator-ie/scripts/capture-screenshots.sh` + `compose-store-screenshots.swift` + `StoreScreenshotsUITests`.
- Listing text follows the ASO rules in `~/.claude/rules/store-listing.md` (accurate claims only, localize don't translate).
- Before any submission, run the `store-review` agent (Apple Review Guidelines / Google Play policy, privacy declarations vs code).
- Skills: `release`, `store-screenshots`, `new-mobile-app`.

## Privacy and ads

- Collect as little data as possible. Keep the iOS privacy manifest (`PrivacyInfo.xcprivacy`) / Play Data safety form in sync with the SDKs actually linked.
- Ads: AdMob, test ad IDs in debug builds, UMP consent before ads (calcly pattern). On iOS, ads sit behind a build flag (salary-calculator-ie `ADS_ENABLED`).
- Never claim "no ads" / "no tracking" in a listing for an app that has ads or analytics.

## Image generation

- Default: Replicate **`google/nano-banana-pro`**, token from `$REPLICATE_API_TOKEN` (never inline it).
- Use an `aspect_ratio` matching the target asset; save to `screenshots/generated/` before processing into final locations.
- Use the `generate-image` skill.
