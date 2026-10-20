---
name: localize
description: Add, change or translate user-facing strings across the 15 standard locales in an Android (res/values*/strings.xml) or iOS (Localizable.xcstrings) app, including store listing text. Use whenever a new UI string is introduced, an existing one changes, or a project needs its locales filled in.
---

# Localize strings

Locale list, folder names and regional rules: `~/.claude/rules/localization.md`. Read it first.

## 1. Find the project's mechanism

- **Generator present?** (e.g. calcly `tools/l10n/gen_strings.py` with `tools/l10n/locales/*.txt`, `gen_store.py` for listings). Edit the generator's source files, then run the generator. Never hand-edit its output.
- **Android, no generator:** edit `mobile/app/src/main/res/values/strings.xml` and every `values-<locale>/strings.xml`.
- **iOS:** edit `Localizable.xcstrings` (JSON). Add the key with `extractionState` as Xcode would, and a `localizations` entry per language with `"state": "translated"`.
- **Override?** Check the project's `CLAUDE.md` for a documented locale override (e.g. salary-calculator-ie is English-only). Respect it.

## 2. Write the translations

- English first (source of truth), then the 14 others in the same change.
- es-ES and es-419 written separately; pt-PT and pt-BR written separately. Use market vocabulary.
- Keep placeholders identical (`%1$s`, `%d`, `%@`, `%lld`) and in a grammatical order for each language (use positional args when order changes).
- Respect length: buttons and tabs must fit; for long languages (de, ru, hi) prefer shorter synonyms over truncation.
- Plurals: Android `<plurals>`; iOS catalog plural variations. Russian needs one/few/many/other.
- For more than ~20 strings, delegate the translation to the `translator` agent with the English strings, context and length limits, then review its output.

## 3. Verify

- Android (from `mobile/`): `./gradlew lintDebug testDebugUnitTest` — `MissingTranslation`, `ExtraTranslation` and `StringFormatMatches` are errors; `StringResourcesTest` checks formats.
- iOS: build the scheme; confirm no supported language shows the string as untranslated / `needs_review` in the catalog.
- Store text: run the project's listing checker if it has one (calcly `python3 tools/l10n/gen_store.py`), and check limits in `~/.claude/rules/store-listing.md`.

Report which locales were updated and anything left for a native-speaker review.
