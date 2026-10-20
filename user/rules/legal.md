---
paths:
  - "**/legal/**"
  - "**/privacy*.html"
  - "**/terms*.html"
  - "**/website/**"
  - "**/firebase/public/**"
---

# Legal pages

Every app needs a **privacy policy**, **terms of use** and a **support/contact page**, plus a **disclaimer** when the app gives estimates (tax, finance, health).

## Source and placeholders

- One markdown file per document in `legal/` (templates: `~/Workspace/claude-config/templates/legal/`).
- Placeholders: `{{APP_NAME}}`, `{{DEVELOPER_NAME}}` (Diego Ferreira), `{{SUPPORT_EMAIL}}` (df.dev.ie@gmail.com), `{{WEBSITE_URL}}` (`https://<project>.web.app`).
- A sync script fills placeholders and copies the files into the website (reference: `salary-calculator-ie/scripts/sync-website.sh`; `--strict` fails on placeholder values and runs before release).
- On iOS the same files are bundled in the app and shown in-app.

## Content rules

- Describe what the app **actually** does: every SDK (AdMob, Firebase Analytics/Crashlytics/Performance, billing), what data it sends, where it is stored, retention, user rights (GDPR — the developer is in Ireland).
- Must match the App Store privacy label / `PrivacyInfo.xcprivacy` and the Play Data safety form.
- Update the "Last updated" date on every change.
- The templates are written for an app that collects **no data**; apps with ads/analytics must add those sections, not just fill placeholders.

## Hosting

- Routes `/privacy`, `/terms`, `/support` (+ `/disclaimer`), redirects from `/privacy-policy`, `/terms-of-use`, `/contact`, `/help`, security headers — copy from `salary-calculator-ie/firebase.json`.
- Older Android apps serve a single `firebase/public/privacy.html` (some iubenda-generated) and have **no terms page yet** — add one with the `legal-pages` skill when touching them.
