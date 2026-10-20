# claude-config

My Claude Code setup for iOS and Android app development: the rules that apply across projects, the shared skills, agents and hooks, and templates for new apps. Each app's own Claude setup (`CLAUDE.md`, `.claude/`) lives in that app's repo.

See [PLAN.md](PLAN.md) for the reasoning behind this layout.

## Layers

| Layer | File in this repo | Installed at | Loaded |
|---|---|---|---|
| Personal | `user/CLAUDE.md` | `~/.claude/CLAUDE.md` | every session |
| Mobile (both platforms) | `mobile/CLAUDE.md` | imported by both platform files | inside `android-projects/` or `ios-projects/` |
| Android | `platforms/android/CLAUDE.md` | `~/Workspace/android-projects/CLAUDE.md` | sessions under that folder |
| iOS | `platforms/ios/CLAUDE.md` | `~/Workspace/ios-projects/CLAUDE.md` | sessions under that folder |
| Topic rules | `user/rules/*.md` | `~/.claude/rules/` | when a file matching the rule's `paths:` is touched |
| Skills | `user/skills/<name>/SKILL.md` | `~/.claude/skills/<name>` | on demand |
| Agents | `user/agents/*.md` | `~/.claude/agents/` | on demand |
| Hooks | `user/hooks/*.sh` | `~/.claude/hooks/` | registered in `user/settings.json` |
| User settings | `user/settings.json` | `~/.claude/settings.json` (copied) | every session |
| Project | — | `<app repo>/CLAUDE.md`, `<app repo>/.claude/settings.json` | sessions in that repo |

Claude Code reads `CLAUDE.md` files from the working directory up to `/`, so a session in `~/Workspace/android-projects/koin` gets: personal → Android (→ mobile) → koin.

### Rules

| Rule | Loads for |
|---|---|
| `localization.md` | `strings.xml`, `.xcstrings`, `fastlane/metadata`, `tools/l10n` |
| `store-listing.md` | store metadata and listing sources |
| `fastlane.md` | `fastlane/`, `Gemfile` |
| `firebase.md` | `firebase/`, `firebase.json`, `functions/` |
| `legal.md` | `legal/`, privacy/terms HTML, `website/` |

### Skills and agents

| Name | Kind | Use |
|---|---|---|
| `localize` | skill | add/translate strings across the 15 locales |
| `new-mobile-app` | skill | bootstrap or upgrade an app to the standard setup |
| `store-screenshots` | skill | regenerate store screenshots with the project's harness |
| `release` | skill | fastlane release, both platforms |
| `generate-image` | skill | Replicate `google/nano-banana-pro` |
| `legal-pages` | skill | privacy/terms/support pages on Firebase Hosting |
| `store-review` | agent | pre-submission audit against store policies |
| `translator` | agent | bulk translation with regional variants |

The `guard-secrets.sh` hook blocks writing tokens/private keys and `git add` of keystores, certificates and service-account files.

## Install

```bash
cd ~/Workspace/claude-config
./install.sh --check   # see what would change
./install.sh           # link everything; replaced files go to ~/.claude/backups/claude-config-<timestamp>/
```

Re-run `./install.sh` after adding a skill. `settings.json` is copied rather than linked: if you approve a permission "always" at user level, Claude Code writes it to `~/.claude/settings.json` — `./install.sh --check` shows the diff so you can copy it back here.

## Replicate token

Image generation and the playstore MCP server read `REPLICATE_API_TOKEN` from the environment. Keep the token in the Keychain, never in a file:

```bash
security add-generic-password -a "$USER" -s replicate-api-token -w   # prompts for the token
echo 'export REPLICATE_API_TOKEN="$(security find-generic-password -s replicate-api-token -w 2>/dev/null)"' >> ~/.zshenv
```

Restart the terminal / VS Code afterwards so Claude Code inherits it.

## Adding a project

1. Copy `templates/project-CLAUDE.<android|ios>.md` to `<repo>/CLAUDE.md` and fill it in — only what's specific to that app.
2. Copy `templates/project-settings.json` to `<repo>/.claude/settings.json` and list the app's build/test commands.
3. Add `.claude/settings.local.json` and `CLAUDE.local.md` to the repo's `.gitignore`.

Or run the `new-mobile-app` skill.

## Changing a rule

Edit it here, commit, push. Symlinks make the change live immediately. Put a rule at the widest layer where it's true: personal → mobile → platform → project.
# claude-config
