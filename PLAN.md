# Claude Code Organization Plan — iOS + Android

## Context

Today, Claude configuration is a single 240-line `android-projects/CLAUDE.md`. The file says it covers Koin, but it sits at the workspace root, so every Android app inherits it. It mixes generic Android rules, cross-platform rules (15 locales, image generation) and Koin-only details. Parts of it are out of date: it pins SDK 36 while calcly/koin/unseen are on 37, and it references a nonexistent `android-native` path.

Other problems:
- **iOS has no Claude config at all.** Its conventions exist only in READMEs, `~/.claude/plans/*.md` and one memory folder.
- **Settings have collected one-off approvals.** `~/.claude/settings.json` mixes Koin and salary-calculator-ie entries and contains a plaintext Replicate token. Neither `~/.claude` nor `android-projects/` is under git.

**Goal:** three layers, with each rule at the widest scope where it's true. The general layers go in a versioned `claude-config` repo. Each project's config goes in its own repo.

| Layer | Applies to | Lives in | Loaded via |
|---|---|---|---|
| Personal | every session, any project | `claude-config/user/CLAUDE.md` | symlink `~/.claude/CLAUDE.md` |
| Mobile (cross-platform) | all iOS + Android apps | `claude-config/mobile/CLAUDE.md` | `@import` from each platform file |
| Topic rules | only when matching files are touched | `claude-config/user/rules/*.md` (`paths:` frontmatter) | symlink `~/.claude/rules/` |
| Platform | everything under `android-projects/` or `ios-projects/` | `claude-config/platforms/{android,ios}/CLAUDE.md` | symlinked into those folders (Claude walks up from cwd) |
| Project | one app | `<repo>/CLAUDE.md` + `<repo>/.claude/` | committed in the app repo |
| Workflows | on demand | `claude-config/user/skills/*`, `user/agents/*` | symlinks in `~/.claude/` |
| Enforcement | always, deterministic | `claude-config/user/hooks/*` + `user/settings.json` | hooks in `~/.claude/settings.json` |

## 1. `claude-config` repo

Location `~/Workspace/claude-config`, remote `git@github.com:diegowendel/claude-config.git` (private), branch `main`.

```
claude-config/
├── PLAN.md                        # this plan
├── README.md                      # layers, install, how to add a project, Keychain token setup
├── install.sh                     # idempotent symlinker; --check mode diffs only
├── user/                          # → ~/.claude
│   ├── CLAUDE.md
│   ├── settings.json              # COPIED, not symlinked (Claude Code rewrites it atomically)
│   ├── rules/{localization,store-listing,fastlane,firebase,legal}.md
│   ├── skills/{localize,new-mobile-app,store-screenshots,release,generate-image,legal-pages}/SKILL.md
│   ├── agents/{store-review,translator}.md
│   └── hooks/guard-secrets.sh
├── mobile/CLAUDE.md
├── platforms/
│   ├── android/CLAUDE.md          # → ~/Workspace/android-projects/CLAUDE.md
│   ├── android/.mcp.json          # → ~/Workspace/android-projects/.mcp.json (token via ${REPLICATE_API_TOKEN})
│   └── ios/CLAUDE.md              # → ~/Workspace/ios-projects/CLAUDE.md
└── templates/
    ├── project-CLAUDE.android.md
    ├── project-CLAUDE.ios.md
    ├── project-settings.json
    └── legal/{privacy,terms,support,disclaimer}.md   # from salary-calculator-ie/legal/, {{APP_NAME}} placeholders
```

### File contents

**`user/CLAUDE.md`** (~40 lines, applies to every project):
- Identity: Diego Ferreira; `df.dev.ie@gmail.com` for support/contact everywhere; Apple team `86SW527Y9L`; GitHub `diegowendel`.
- Working agreements:
  - Don't commit unless asked.
  - Use conventional commits; release commits are `release: vX.Y.Z (code)`.
  - Never sweep unrelated changes into a commit.
  - Don't read `~/Downloads` without asking.
  - Before calling something done: run the tests, then the build.
- Secrets: never put tokens, keys or passwords in tracked files or Claude settings. Read them from env or Keychain. Keystores, `.p12`, `.pem` and service-account JSON files stay outside git.
- Pointer: the config lives in `~/Workspace/claude-config`. Edit it there, not in `~/.claude`.

**`mobile/CLAUDE.md`** (~80 lines). Your cross-platform rules:
- **Legal:** every app ships a privacy policy, terms of use and a support page.
  - Hosted per app on Firebase Hosting (`<project>.web.app`) at `/privacy`, `/terms` and `/support`, with redirects from `/privacy-policy` and `/terms-of-use`.
  - Single-source markdown with placeholders (pattern: `salary-calculator-ie/legal/` + `scripts/sync-website.sh --strict`).
  - Linked from the in-app About screen and the store listing.
- **Backend:** none unless needed. When needed, Firebase.
  - **Cloud Functions (TypeScript) take priority over any dedicated server or VM.**
  - Shared cross-app services and `app-ads.txt` live in `appcraftlabs`.
- **Localization:** 15 locales by default.
  - Every new user-facing string goes into all locales in the same commit.
  - es-ES/es-419 and pt-PT/pt-BR are written independently.
  - A project may override the default only with a documented reason in its CLAUDE.md.
  - Details: `rules/localization.md`.
- **Release:** fastlane through Bundler, with `Gemfile.lock` committed. Store metadata in `fastlane/metadata/` for every supported locale.
- **Screenshots:** always automated, never hand-made.
  - A UI test drives the app in a demo state per locale, then a script adds frames and captions.
  - Reference implementations: Android `tools/screenshots/{capture.sh,compose.py}` + `StoreScreenshotsTest` (calcly/koin). iOS `scripts/capture-screenshots.sh` + `compose-store-screenshots.swift` + `StoreScreenshotsUITests` (salary-calculator-ie).
- **Image generation:** Replicate `google/nano-banana-pro`, token from `$REPLICATE_API_TOKEN`, output to `screenshots/generated/`.
- **UX:** light and dark mode, localized accessibility labels, small and large screens.
- **Store:** follow the ASO rules (`rules/store-listing.md`). Run the `store-review` agent against Apple's Review Guidelines or Play policy before every submission.
- **Privacy:** collect as little as possible. Keep the privacy manifest / Data safety form in sync with the SDKs actually used.
- **Ads:** AdMob with test IDs in debug, UMP consent (calcly pattern). On iOS, ads sit behind a build flag (salary `ADS_ENABLED`).

**`platforms/android/CLAUDE.md`**. Starts with `@~/Workspace/claude-config/mobile/CLAUDE.md`, then the generic sections of the current root CLAUDE.md, updated:
- **Baseline is the calcly/koin "modern setup".** Versions come from `gradle/libs.versions.toml` and are never pinned in docs (state "currently SDK 37 / minSdk 24" only as information).
- **Kept:**
  - toolchain, MVVM/LiveData/Repository/manual DI, XML + ViewBinding, Material 3
  - navigation with generic wording
  - Groovy build + catalog + the custom `gradle.properties` keys, signing via `keystore.properties` kept out of git
  - androidcommons, Firebase, Room migrations, offline-first (generic)
  - "What NOT to do"
- **Added:**
  - **Repo layout:** `<app>/mobile` + `<app>/firebase` + `tools/` + `docs/`.
  - **androidcommons workflow:** local source in `android-projects/android-commons`, publish with `gradle-publish-local.sh` (debug + release artifacts), fastlane `preflight` checks `~/.m2`.
  - **Testing:** Kover gate; `MissingTranslation`/`ExtraTranslation`/`StringFormatMatches` are fatal; `StringResourcesTest`; `generateLocaleConfig`.
  - **Release:** local fastlane only, no CI by design; Play key at `~/.config/playstore/<app>.json` via `PLAY_STORE_JSON_KEY_PATH`.
- **Removed:** the Koin package tree, the dependency table, and Koin examples (`RateDto`, 3-hour cache, nav graph names). These move to `koin/CLAUDE.md`.
- **`platforms/android/.mcp.json`:** the current playstore server entry, with `"REPLICATE_API_TOKEN": "${REPLICATE_API_TOKEN}"` in place of the literal value.

**`platforms/ios/CLAUDE.md`**. Imports the mobile file, then the iOS conventions shared by salary-calculator-ie and budget-ai:
- SwiftUI only; UIKit/AppKit only inside platform wrappers.
- Swift 6 strict concurrency, zero warnings.
- **XcodeGen `project.yml` is the source of truth.** Never hand-edit `.xcodeproj`.
- `@Observable`; DI through Environment `@Entry` or init injection; no DI framework; no third-party packages by default.
- xcconfig is the single source for version, team, bundle ID and support email.
- String Catalogs (`Localizable.xcstrings`); `PrivacyInfo.xcprivacy` required.
- Swift Testing for unit tests (no mutating calls inside `#expect`), XCTest for UI tests.
- Money as `Decimal` or exact cents.
- **SwiftData rules:** explicit `inverse:`; new stored properties get defaults plus a migration test; never synthesize `Hashable`/`Equatable` from `@Model` types, compare by `id` (from budget-ai memory).
- **Verify before done:** tests on the `iPhone 17` simulator, then a signed `xcodebuild … -destination 'generic/platform=iOS'` build.
- **Release:** fastlane with the App Store Connect API key (`ASC_*` env), lanes `beta` and `release`. Check against Apple's Review Guidelines before submitting.

**`user/rules/*.md`** (path-scoped, so they cost no context until a matching file is touched):

| Rule | `paths:` | Content |
|---|---|---|
| `localization.md` | `**/res/values*/strings.xml`, `**/*.xcstrings`, `**/fastlane/metadata/**`, `**/tools/l10n/**` | Full 15-locale table with an Android folder column (from the current CLAUDE.md, incl. `values-in`), a new App Store locale code column (verify against deliver's supported list), regional notes, excluded languages, workflow |
| `store-listing.md` | `**/fastlane/metadata/**`, `**/playstore/**` | ASO rules from calcly/koin `docs/ASO.md` (title ≤30, short ≤80, no promo words or emoji, localize rather than translate, no unbackable claims) + App Store limits (name/subtitle 30, keywords 100, promo text 170) |
| `fastlane.md` | `**/fastlane/**`, `**/Gemfile` | Bundler, lockfile committed, lane names, key paths from env, release tag and commit format |
| `firebase.md` | `**/firebase/**`, `**/firebase.json`, `**/functions/**` | Hosting layout and deploy scripts, Functions in TypeScript on a current Node LTS, Functions-over-servers rationale, cost awareness |
| `legal.md` | `**/legal/**`, `**/privacy*.html`, `**/website/**` | Required pages, placeholders, sync script, contact email, "last updated" dates |

**Skills** (`user/skills/`). Each one points at the proven project scripts rather than duplicating them:
- `localize`: add or translate strings across the 15 locales on Android (`strings.xml`) or iOS (`.xcstrings`), then verify with `./gradlew lintDebug` + `StringResourcesTest`, or an Xcode build.
- `new-mobile-app`: bootstrap checklist plus templates.
  - project CLAUDE.md and settings
  - legal pages + Firebase Hosting (salary's `firebase.json` redirects and headers as the template)
  - fastlane skeleton: Android generalized from calcly's Fastfile, where the 5 values that differ from koin become parameters; iOS from salary
  - 15 locales, screenshot harness, privacy manifest / Data safety
- `store-screenshots`: run capture + compose for all locales using the project's scripts.
- `release`:
  - Android: `preflight` → `deploy` → `promote`/`rollout`.
  - iOS: `beta` → `release`.
  - Both: version bump, release notes in every locale, commit and tag convention, `store-review` agent first.
- `generate-image`: Replicate `nano-banana-pro` with `$REPLICATE_API_TOKEN`, aspect ratios for icon / feature graphic / screenshots, saved to `screenshots/generated/`.
- `legal-pages`: create or update privacy/terms/support from `templates/legal/` and deploy to Hosting.

**Agents:**
- `store-review`: pre-submission audit covering guidelines/policy, ASO rules, and whether the privacy declarations match the code.
- `translator`: bulk translation that respects regional variants; used by `localize`.

**Hook `user/hooks/guard-secrets.sh`** (PreToolUse on `Write|Edit|Bash`):
- Exits 2 with a message on Replicate tokens (`r8_[A-Za-z0-9]{30,}`), `-----BEGIN … PRIVATE KEY-----` and `"private_key":`.
- Also blocks `git add` of `*.jks`, `*.keystore`, `*.p12`, `*.pem`, `keystore.properties` and `*service-account*.json`.

**`user/settings.json`:**
- Keeps `model: opus` + `modelSettings`.
- Allowlist limited to generic safe commands: git read commands, `./gradlew tasks`, `bundle exec fastlane lanes`, `xcodebuild -list`.
- Registers the hook.
- **Drops** every project-specific entry, both token-bearing curl entries, and the `additionalDirectories` entry (`/tmp`, salary-calculator-ie). Each project-specific entry moves to its project's `.claude/settings.json` (below).

**`install.sh`:**
- Backs up any existing non-symlink target to `~/.claude/backups/claude-config-<ts>/`, then runs `ln -sfn` for:
  - `~/.claude/{CLAUDE.md,rules,agents,hooks}`
  - each `~/.claude/skills/<name>`, leaving the managed `skills/synced/` alone
  - `android-projects/{CLAUDE.md,.mcp.json}`
  - `ios-projects/CLAUDE.md`
- Copies `user/settings.json` only after showing a diff.
- `--check` reports drift without changing anything.
- README documents the token setup: store it in Keychain and add `export REPLICATE_API_TOKEN="$(security find-generic-password -s replicate-api-token -w 2>/dev/null)"` to `~/.zshenv`.

## 2. Per-project setup (each repo)

The same pattern in every repo:
- `CLAUDE.md` at the repo root, ≤80 lines, from the template. Sections: Overview (package/bundle, platforms) · **Deviations from the platform baseline** · Firebase (project ID, hosting URL, functions?) · Locales (default or override + reason) · Release (lanes, branch, CI or local) · Commands · Gotchas.
- `.claude/settings.json` (committed) allowing that project's build, test, fastlane and firebase commands.
- `.gitignore` gets `.claude/settings.local.json` and `CLAUDE.local.md`.

`calculadora-salario` and `appcraftlabs` sit outside the platform folders, so their CLAUDE.md imports `@~/Workspace/claude-config/mobile/CLAUDE.md` directly.

| Repo | Sources → content |
|---|---|
| `android-projects/koin` | Koin parts of the old root CLAUDE.md (package tree, dependencies, `ServerFunctions`/Functions backend, 3-hour rate cache, nav graphs) + the unique parts of `mobile/AGENTS.md`. Conflicts resolve to Groovy only; drop WorkManager unless it's actually used. **Delete `mobile/AGENTS.md`.** Notes: the old `playstore/` tooling is superseded by fastlane but still read by playstore-mcp; coverage task is `koverVerifyDebug`; catalog key `appcraftlabsCommons`. Permissions come from the koin entries in the user and android-projects settings (stale `android-native` paths and the token removed) |
| `android-projects/calcly` | AdMob + UMP, `CalculatorTestRunner`, `koverVerify`, catalog key `androidCommons`, generators in `tools/l10n/`, hand-written privacy page; source `docs/{PLAN,RELEASING,PUBLISHING}.md` |
| `android-projects/led-banner` | Marked **legacy**: no version catalog (migrate when touched), AGP 9.0.1 / SDK 36 / minSdk 23, 5 languages (documented override), `:colorpicker` module, no fastlane |
| `android-projects/unseen` | applicationId `com.diegowendel.showme` ≠ namespace `com.diegowendel.unseen` (**never "fix"**), billing + AdMob, `UnseenApplication`, 2 languages, legacy `enableJetifier`/`nonTransitiveRClass=false`, no `values-night` |
| `android-projects/android-commons` | Library rules: package `com.appcraftlabs.androidcommons`, bump `LIBRARY_VERSION_NAME`, publish both artifacts, then update the 4 apps' catalogs (key names differ), keep minSdk 23, public API changes break 4 apps |
| `ios-projects/salary-calculator-ie` | From README/PLAN/docs: iOS 18 + macOS 15 native, UserDefaults+Codable, `Packages/TaxKit` + yearly `rules/*.json`, branch `master`, **English-only override** (Ireland-only tax app), GitHub Actions release on master, legal single source + `sync-website.sh --strict`, `ADS_ENABLED` flag, no formspree (contact via the mail app), known issue: missing `Gemfile.lock`. Project skill `.claude/skills/annual-budget-update/` wraps `docs/ANNUAL_BUDGET_UPDATE.md`. Permissions from the salary entries in user settings |
| `ios-projects/budget-ai` | From the `lazy-stargazing-flask.md` handoff conventions + memory: iOS 26 iPhone portrait, SwiftData, `syncedFolder` (`.xcodeproj` ignored), `Local.xcconfig` secrets, branch `main`, real statements and the `.pem` never in git or fixtures, ask for real exports before touching parsers, `Tools/bank-callback-site/`, localization not started yet (documented override for now) |
| `calculadora-salario` | Minimal legacy note: RN 0.72 `mobile/` + native `android/` + privacy Hosting; don't apply the modern platform rules unasked |
| `appcraftlabs` | Shared brand site (Gatsby) + Cloud Functions (TS) + `app-ads.txt` covering every app's AdMob; GitHub Hosting workflows; home for cross-app functions |

**Commits:**
- Stage only `CLAUDE.md`, `.claude/`, the `.gitignore` hunk and (koin) the `AGENTS.md` deletion. Use `git add -p` where `.gitignore` already has unstaged edits.
- Message: `chore: add Claude Code project config`. Commit on the current branch (master/main), then push.
- **Stop and ask** if a repo is behind or diverged from origin, or isn't on its usual branch.
- Existing uncommitted work, especially in budget-ai and salary-calculator-ie, stays untouched.

## 3. Execution order

1. `mkdir ~/Workspace/claude-config && git init -b main`. Copy this plan to `PLAN.md` and commit it. Then `gh repo create diegowendel/claude-config --private --source . --push`.
2. Write `user/`, `mobile/`, `platforms/`, `templates/`, the skills, agents, hook, `install.sh` and `README.md`. Before committing, grep for `r8_` and private keys. Commit and push.
3. Run `./install.sh`. It backs up the old `android-projects/CLAUDE.md`, `.mcp.json` and `~/.claude/settings.json`.
4. Strip the token and stale `android-native` entries from `android-projects/.claude/settings.local.json` (unversioned local file).
5. Per-project files (section 2), with scoped commits and pushes.
6. Memory: move the `verify-device-build.md` feedback into the iOS platform rules. Delete that file and update budget-ai's `MEMORY.md`. Keep `budgetai-status.md`. Add a memory pointing at `claude-config` as the place to edit Claude rules.

## 4. Verification

- `./install.sh --check` reports no drift. `ls -la ~/.claude ~/Workspace/{android,ios}-projects` shows the symlinks.
- `claude` in `koin/`: `/memory` lists the user, android-platform, mobile (imported) and koin files, and no iOS file. In `budget-ai/`: iOS instead of Android. In `~/Workspace/ai`: only the user file.
- In calcly, have Claude open `res/values/strings.xml`. `/memory` or `/context` should then show `rules/localization.md` loaded. It should not be loaded before that.
- `/skills` lists the 6 skills and `/agents` lists the 2 agents.
- Hook: asking Claude to write a file containing a fake `r8_…` token is blocked, and so is `git add some.jks`.
- From `android-projects`: `claude mcp list` shows playstore connected. `grep -r "r8_" ~/.claude/settings.json ~/Workspace/claude-config ~/Workspace/android-projects/.mcp.json ~/Workspace/android-projects/.claude` returns nothing.
- Each repo: `git show --stat HEAD` shows only Claude files, `git status` shows earlier uncommitted work unchanged, and `git log origin/<branch> -1` matches HEAD.

## 5. Out of scope: follow-ups found during analysis

- **Rotate the Replicate token.** It's pushed in `koin/mobile/screenshots/{gen5.py,gen_icon.py,retry_screenshot5.py,generate.sh}` and stays in git history.
- Keystores and `keystore.properties` are tracked in koin, led-banner and unseen; keystore passwords are in `unseen/docs/playstore/README.md`; `koin/.../app-release.aab` is tracked.
- `~/Workspace/xcode-key.p12` is loose in the workspace.
- `playstore-mcp` isn't under git, repeats the localization rules, and has no config for calcly.
- Android apps have no terms-of-use page, which the new mobile rule requires (use `legal-pages`). budget-ai has no localization, privacy manifest or fastlane. led-banner and unseen have partial locales.
- Stale `iCalc` references in `calcly/docs/`. salary-calculator-ie is missing `Gemfile.lock`.

## Execution notes (2026-10-20)

Done as planned, with these differences:
- Per-project ignores go in `.claude/.gitignore` (`settings.local.json`) instead of each repo's root `.gitignore`, so repos with uncommitted `.gitignore` edits (budget-ai) weren't touched.
- `platforms/android/.mcp.json` uses `${REPLICATE_API_TOKEN:-}` so the config still parses when the variable is unset.
- No extra "where config lives" memory: `user/CLAUDE.md` already says it in every session.
- Pushed: koin, calcly, led-banner, unseen, android-commons, budget-ai, calculadora-salario, appcraftlabs (`[skip ci]`, so the brand site isn't redeployed).
- **Not pushed: salary-calculator-ie** (committed locally). Pushing `master` also pushes 3 earlier unpushed commits and runs CI → the App Store release workflow.
- `claude-config` has its `origin` set but the GitHub repo still has to be created (`gh` isn't installed).
