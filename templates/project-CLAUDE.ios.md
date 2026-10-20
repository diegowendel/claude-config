# <App name> — iOS

<!-- Project layer. Platform and mobile rules load automatically from ~/Workspace/ios-projects/CLAUDE.md.
     Only write what is specific to this app or deviates from the baseline. Keep it under ~80 lines. -->

## Overview

- What it is: <one line>
- Bundle ID `<com.example>` · platforms <iOS 18+ | iOS 26+, iPhone only | + macOS 15> · branch `<master|main>`
- Scheme `<Scheme>` · project from XcodeGen `project.yml` (`.xcodeproj` <committed | git-ignored>)
- Firebase / website: <project id → https://<id>.web.app | none>
- Persistence: <UserDefaults + Codable | SwiftData> · Ads: <none | behind ADS_ENABLED>

## Deviations from the iOS baseline

- None.

## Architecture notes

<!-- Feature folders, local packages, key types, where config comes from. -->

## Locales

- Standard 15. <!-- or: Override — <locales> because <reason>. -->

## Commands

```bash
xcodebuild test -scheme <Scheme> -destination 'platform=iOS Simulator,name=iPhone 17'
xcodebuild build -scheme <Scheme> -destination 'generic/platform=iOS'
```

## Release

<!-- Local fastlane lanes or CI workflow; tags; what stays manual. -->

## Gotchas
