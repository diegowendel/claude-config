#!/usr/bin/env bash
# PreToolUse guard for Write, Edit, MultiEdit and Bash.
# Blocks (exit 2) content that contains secrets, and `git add` of signing/credential files.
# Registered in ~/.claude/settings.json (source: claude-config/user/settings.json).
set -uo pipefail

input="$(cat)"

# Text the tool would write or run.
payload="$(printf '%s' "$input" | python3 -c '
import json, sys
try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)
t = d.get("tool_input", {}) or {}
parts = [t.get(k, "") for k in ("content", "new_string", "command")]
for e in t.get("edits", []) or []:
    parts.append(e.get("new_string", ""))
print("\n".join(p for p in parts if isinstance(p, str)))
')"

block() {
  echo "Blocked by guard-secrets: $1. Read secrets from env/Keychain instead and keep credential files out of git." >&2
  exit 2
}

# Secret values.
printf '%s' "$payload" | grep -Eq 'r8_[A-Za-z0-9]{30,}' && block "Replicate API token"
printf '%s' "$payload" | grep -Eq -- '-----BEGIN ([A-Z]+ )?PRIVATE KEY-----' && block "private key"
printf '%s' "$payload" | grep -Eq '"private_key"[[:space:]]*:[[:space:]]*"-----' && block "service-account private key"
printf '%s' "$payload" | grep -Eq '(sk-ant-|ghp_|github_pat_)[A-Za-z0-9_]{20,}' && block "API token"

# Staging credential files.
if printf '%s' "$payload" | grep -Eq '(^|[;&|[:space:]])git[[:space:]]+add'; then
  printf '%s' "$payload" | grep -Eq '\.(jks|keystore|p12|p8|pem)([[:space:]"'"'"']|$)|keystore\.properties|service[-_]account[^[:space:]]*\.json|AuthKey_[A-Z0-9]+\.p8' \
    && block "staging a keystore, certificate or credential file"
  printf '%s' "$payload" | grep -Eq 'git[[:space:]]+add[[:space:]]+(-A|--all|\.)([[:space:]]|$)' \
    && echo "guard-secrets: 'git add -A/.' — make sure no credential files are untracked in this repo." >&2
fi

exit 0
