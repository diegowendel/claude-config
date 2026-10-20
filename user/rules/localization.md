---
paths:
  - "**/res/values*/strings.xml"
  - "**/*.xcstrings"
  - "**/*.strings"
  - "**/fastlane/metadata/**"
  - "**/tools/l10n/**"
---

# Localization — 15 locales (13 languages)

Every mobile app is localized into these locales unless its `CLAUDE.md` states an override and why.

| Locale | Language | Android folder | Play listing | App Store (fastlane deliver) | Covers |
|---|---|---|---|---|---|
| en-US | English | `values/` (default) | `en-US` | `en-US` | all en-* variants |
| es-419 | Spanish (Latin America) | `values-es/` | `es-419` | `es-MX` | es-MX, es-AR, es-CO, es-CL, es-PE… |
| es-ES | Spanish (Spain) | `values-es-rES/` | `es-ES` | `es-ES` | Spain only — does **not** fall back to es-419 |
| pt-BR | Portuguese (Brazil) | `values-pt-rBR/` | `pt-BR` | `pt-BR` | Brazil |
| pt-PT | Portuguese (Portugal) | `values-pt-rPT/` | `pt-PT` | `pt-PT` | Portugal — does **not** fall back to pt-BR |
| fr-FR | French | `values-fr/` | `fr-FR` | `fr-FR` | all fr-* (fr-CA adequate) |
| de-DE | German | `values-de/` | `de-DE` | `de-DE` | de-AT, de-CH |
| it-IT | Italian | `values-it/` | `it-IT` | `it` | it-CH |
| ja-JP | Japanese | `values-ja/` | `ja-JP` | `ja` | |
| ko-KR | Korean | `values-ko/` | `ko-KR` | `ko` | |
| ru-RU | Russian | `values-ru/` | `ru-RU` | `ru` | |
| hi-IN | Hindi | `values-hi/` | `hi-IN` | `hi` | |
| tr-TR | Turkish | `values-tr/` | `tr-TR` | `tr` | |
| nl-NL | Dutch | `values-nl/` | `nl-NL` | `nl-NL` | nl-BE |
| id | Indonesian | `values-in/` | `id` | `id` | |

In an iOS String Catalog the language codes are the plain ones (`es-419`, `es-ES`, `pt-BR`, `pt-PT`, `fr`, `de`, `it`, `ja`, `ko`, `ru`, `hi`, `tr`, `nl`, `id`). The App Store column is only for `fastlane/metadata/<code>/` folders; verify a code against `fastlane deliver`'s supported list before creating a new folder.

## Regional variants

- **es-ES vs es-419**: different vocabulary ("ordenador/computadora", "móvil/celular"). Write each independently.
- **pt-PT vs pt-BR**: different spelling and grammar ("telemóvel/celular", "percentagem/porcentagem", "ecrã/tela"). Write each independently.
- Use the words people actually type in that market, not dictionary translations.
- Indonesian is `values-in/` on Android (legacy ISO 639 code), `id` everywhere else.

## Excluded (for now)

- Chinese (zh-CN): Google Play limited in China, low ROI.
- Arabic (ar): needs RTL layout work in the app first.

## Workflow

- A new user-facing string gets **all 15 translations in the same commit**. Use the `localize` skill.
- Android: `translatable="false"` for non-translatable strings; keep format arguments identical across locales (lint `StringFormatMatches` is an error).
- iOS: no stale or `needs_review` entries left in the catalog for supported languages.
- Store metadata in `fastlane/metadata/` covers the same locales as the app (or the documented override).
- Projects with generators (`tools/l10n/gen_strings.py`, `gen_store.py` in calcly) edit the generator source, then regenerate — don't hand-edit generated files.
