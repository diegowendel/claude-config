---
paths:
  - "**/fastlane/metadata/**"
  - "**/playstore/**"
  - "**/tools/l10n/listing/**"
  - "**/docs/ASO.md"
---

# Store listings (ASO)

Reference write-up: `~/Workspace/android-projects/calcly/docs/ASO.md`.

## Field limits

| Google Play | Limit | | App Store | Limit |
|---|---|---|---|---|
| Title | 30 | | Name | 30 |
| Short description | 80 | | Subtitle | 30 |
| Full description | 4000 | | Keywords (comma-separated, not shown) | 100 |
| What's new | 500 | | Promotional text | 170 |
| | | | Description | 4000 |
| | | | What's New | 4000 |

- Play has no hidden keyword field: only title, short and full description are indexed. The first ~170 characters show before "More", so the opening sentence names the core features.
- App Store: don't repeat words from the name/subtitle in keywords; no spaces after commas.

## Rules

- **Accurate claims only.** Never "no ads" / "no tracking" if the app shows ads or uses analytics. Don't list features the app lacks.
- **No other brands** or platforms ("iPhone style", competitor names) — metadata policy violation.
- **Title / short description / subtitle:** no "free", "best", "top", "#1", "new", "sale", calls to action or emoji.
- **Localize, don't translate.** Pick titles and keywords per market from local search vocabulary; es-ES ≠ es-419, pt-PT ≠ pt-BR.
- **What's new:** lead with what the user notices first.
- Keep listing text, screenshots captions and the privacy declarations consistent with what the app actually does.
- Run the `store-review` agent before submitting.
