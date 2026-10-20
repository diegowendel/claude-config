# Personal working agreements (all projects)

> Source of truth: `~/Workspace/claude-config` (symlinked into `~/.claude`). Edit rules there, not in `~/.claude`.

## Who I am

- Name: **Diego Ferreira** (git author: Diego Wendel). GitHub: `diegowendel`.
- Support / contact email for every app, store listing and legal page: **df.dev.ie@gmail.com**.
- Apple Developer team: `86SW527Y9L`.

## How to work with me

- **Don't commit unless I ask.** When I do, stage only the files you changed — never sweep unrelated work into a commit.
- Commit messages: conventional commits (`feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`). Release commits: `release: vX.Y.Z (code)`.
- Before saying something is done: run the tests, then the build. Report failures as they are.
- Don't read personal files (e.g. `~/Downloads`) without asking.
- Ask before outward-facing actions: pushing, publishing to a store, deploying, sending anything to an external service.

## Secrets

- Never write tokens, API keys, passwords or private keys into tracked files, Claude settings or permission rules.
- Read secrets from environment variables or the macOS Keychain (e.g. `$REPLICATE_API_TOKEN`).
- Keystores, `keystore.properties`, `.p12`, `.p8`, `.pem` and service-account JSON files stay outside git.

## Where rules live

| Layer | File |
|---|---|
| Personal (this file) | `claude-config/user/CLAUDE.md` |
| Mobile, both platforms | `claude-config/mobile/CLAUDE.md` |
| Android / iOS | `claude-config/platforms/{android,ios}/CLAUDE.md` |
| Topic rules (load when matching files are touched) | `claude-config/user/rules/*.md` |
| One app | `<repo>/CLAUDE.md` and `<repo>/.claude/` |
