@~/Workspace/claude-config/mobile/CLAUDE.md

# iOS — rules for every app in `~/Workspace/ios-projects`

> Source: `claude-config/platforms/ios/CLAUDE.md` (symlinked here). App-specific details and deviations go in each repo's `CLAUDE.md`.

## Toolchain and project

- **SwiftUI only.** UIKit/AppKit only inside thin platform wrappers.
- **Swift 6, strict concurrency, zero warnings.**
- **XcodeGen `project.yml` is the source of truth.** Never hand-edit the `.xcodeproj`; run `xcodegen generate` after changing `project.yml` or adding files (unless the project uses `syncedFolder`).
- **xcconfig is the single source** for version, build number, team, bundle ID, support email and website host. Code reads them through Info.plist (e.g. an `AppConfig` type).
- Machine-specific values and secrets go in a git-ignored `Local.xcconfig` or `Config/Secrets/`.

## Architecture

- `@Observable` models; `@State`/`@Environment` in views. `@AppStorage`/`@SceneStorage` for small UI state.
- DI through SwiftUI Environment (`@Entry`) or init injection. **No DI framework.**
- **No third-party packages by default.** Prefer local Swift packages for pure logic (e.g. `Packages/TaxKit`).
- Money as `Decimal` or exact integer cents — never `Double`.

## SwiftData (when used)

- Every relationship declares an explicit `inverse:` and delete rule.
- New stored properties get an inline default or are optional, with a store-migration test against an older fixture.
- **Never synthesize `Hashable`/`Equatable` from `@Model` types** (or enums carrying them) — implement by `id`. This fails only on device builds.

## Localization and privacy

- **String Catalogs** (`Localizable.xcstrings`), `LOCALIZATION_PREFERS_STRING_CATALOGS = YES`. Use `String(localized:)` / `LocalizedStringKey`; no hardcoded user-facing strings.
- App Store locale codes for fastlane metadata: `~/.claude/rules/localization.md`.
- `PrivacyInfo.xcprivacy` is required and must match the APIs and SDKs actually used.

## Testing

- **Swift Testing** for unit tests; **XCTest** for UI tests (including `StoreScreenshotsUITests`).
- In `#expect`, no mutating calls and no `@Model` return values — assign with `_ =` first.
- Test simulator: **iPhone 17**.

## Verify before saying done

1. Tests: `xcodebuild test -scheme <Scheme> -destination 'platform=iOS Simulator,name=iPhone 17'` (and `swift test --package-path Packages/<Pkg>` for local packages).
2. **Signed device build:** `xcodebuild build -scheme <Scheme> -destination 'generic/platform=iOS'`. Simulator builds passing is not enough.

## Release

- fastlane with an **App Store Connect API key** (`ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_PATH` / `ASC_KEY_P8`) — no Apple ID passwords, no match repo.
- Lanes: `beta` (TestFlight) and `release` (TestFlight + metadata + submit for review; release in App Store Connect stays manual).
- Check against Apple's App Store Review Guidelines (run the `store-review` agent) before submitting.
- Team `86SW527Y9L`.

## Don't

- UIKit/AppKit screens, Combine for new state, third-party dependencies without asking.
- Hand edits to `.xcodeproj`, secrets in `Base.xcconfig`, ignoring warnings.
