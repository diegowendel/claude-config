---
paths:
  - "**/firebase/**"
  - "**/firebase.json"
  - "**/.firebaserc"
  - "**/functions/**"
---

# Firebase

## Why Firebase, and Functions first

- Solo-developer apps: no servers to patch, pay-per-use, free tier covers most apps.
- **Cloud Functions over any dedicated server/VM/container.** If a feature seems to need a server, design it as Functions + Firestore/Storage first and only propose something else with a concrete reason (long-running work, unsupported runtime, cost at scale).
- Cross-app or brand-level backend code goes in `~/Workspace/appcraftlabs/firebase/functions`.

## Hosting (every app)

- One Firebase project per app; site at `https://<project>.web.app`.
- Serves the privacy policy, terms and support pages (see `~/.claude/rules/legal.md`).
- Android apps: `<app>/firebase/` with `firebase.json`, `.firebaserc`, `deploy-hosting.sh`, `public/`.
- iOS apps: `firebase.json` at repo root with `public: website` and a `predeploy` sync script (salary-calculator-ie).
- Template for redirects and security headers: `~/Workspace/ios-projects/salary-calculator-ie/firebase.json`.

## Functions

- TypeScript, current Node LTS supported by Firebase, latest `firebase-functions` major. Reference: `~/Workspace/android-projects/koin/firebase/functions`.
- Callable/HTTPS functions; validate input; never trust the client.
- Secrets via Firebase Secret Manager (`defineSecret`), never in source or `.env` committed.
- Keep cold starts and cost in mind: set region and `minInstances: 0` unless there's a reason.
- Deploy with the project's `deploy-functions.sh` / `firebase deploy --only functions`. **Ask before deploying.**

## Client config

- `google-services.json` (Android) / `GoogleService-Info.plist` (iOS) identify the project; they are not secret but keep them out of public templates.
- Collection flags off in debug builds.
