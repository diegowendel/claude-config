---
name: legal-pages
description: Create or update an app's privacy policy, terms of use, support page and disclaimer from the standard templates and publish them on the app's Firebase Hosting site. Use when an app lacks one of these pages, when its SDKs/data practices change, or before a store submission.
---

# Legal pages

Rules: `~/.claude/rules/legal.md`. Templates: `~/Workspace/claude-config/templates/legal/`.

## 1. Inventory what the app really does

Before writing anything, list from the code and build files:
- SDKs: AdMob/UMP, Firebase Analytics/Crashlytics/Performance/Messaging/Functions, billing, others.
- Data sent off the device, where it goes, why; data stored on device.
- Accounts? Payments? Children's audience?

## 2. Write the documents

- Copy the templates into `legal/` (iOS) or the project's legal source folder (Android: create `legal/` at the repo root and generate `firebase/public/` pages from it).
- The templates describe an app that collects nothing. Add sections for every SDK found in step 1 (what it collects, purpose, legal basis under GDPR, retention, provider's policy link, opt-out/consent).
- Placeholders: `{{APP_NAME}}`, `{{DEVELOPER_NAME}}` = Diego Ferreira, `{{SUPPORT_EMAIL}}` = df.dev.ie@gmail.com, `{{WEBSITE_URL}}` = `https://<project>.web.app`.
- Set "Last updated" to today.
- Support page: contact via the user's own mail app (`mailto:`), no third-party form services.

## 3. Host

- Pages at `/privacy`, `/terms`, `/support` (+ `/disclaimer`), redirects and security headers as in `~/Workspace/ios-projects/salary-calculator-ie/firebase.json`.
- Android apps currently serve only `firebase/public/privacy.html` with a catch-all rewrite: replace the rewrite with explicit pages and keep `/` pointing to the privacy policy so the existing store/app URL still works.
- Preview with `firebase hosting:channel:deploy preview` or `firebase emulators:start --only hosting`.
- **Ask before** `firebase deploy --only hosting`.

## 4. Wire up

- In-app About screen links (Android string `app_privacy_policy_url` and a terms URL; iOS bundled markdown).
- Store listing privacy URL; iOS privacy label / `PrivacyInfo.xcprivacy`; Play Data safety — flag to the user anything that must change in the consoles.
