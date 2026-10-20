#!/usr/bin/env bash
# Links this repo into ~/.claude and the platform workspaces.
#
# Usage: ./install.sh           apply (backs up anything it replaces)
#        ./install.sh --check   report drift only, change nothing
#
# Symlinked: user/CLAUDE.md, user/rules, user/agents, user/hooks, each user/skills/<name>,
#            platforms/android/{CLAUDE.md,.mcp.json}, platforms/ios/CLAUDE.md.
# Copied:    user/settings.json (Claude Code rewrites settings.json in place, which would break a symlink).
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"
CLAUDE="$HOME/.claude"
WS="$HOME/Workspace"
CHECK=false
[[ "${1:-}" == "--check" ]] && CHECK=true
BACKUP="$CLAUDE/backups/claude-config-$(date +%Y%m%d-%H%M%S)"
drift=0

links=(
  "user/CLAUDE.md|$CLAUDE/CLAUDE.md"
  "user/rules|$CLAUDE/rules"
  "user/agents|$CLAUDE/agents"
  "user/hooks|$CLAUDE/hooks"
  "platforms/android/CLAUDE.md|$WS/android-projects/CLAUDE.md"
  "platforms/android/.mcp.json|$WS/android-projects/.mcp.json"
  "platforms/ios/CLAUDE.md|$WS/ios-projects/CLAUDE.md"
)
for skill in "$REPO"/user/skills/*/; do
  name="$(basename "$skill")"
  links+=("user/skills/$name|$CLAUDE/skills/$name")
done

backup() {
  local target="$1" rel
  rel="${target#$HOME/}"
  mkdir -p "$BACKUP/$(dirname "$rel")"
  mv "$target" "$BACKUP/$rel"
  echo "  backed up $target -> $BACKUP/$rel"
}

for entry in "${links[@]}"; do
  src="$REPO/${entry%%|*}"
  dst="${entry##*|}"
  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    echo "ok      $dst"
    continue
  fi
  drift=1
  if $CHECK; then
    echo "DRIFT   $dst (expected symlink -> $src)"
    continue
  fi
  mkdir -p "$(dirname "$dst")"
  if [[ -e "$dst" || -L "$dst" ]]; then backup "$dst"; fi
  ln -sfn "$src" "$dst"
  echo "linked  $dst -> $src"
done

# settings.json: copy, never symlink.
src="$REPO/user/settings.json"
dst="$CLAUDE/settings.json"
if [[ -f "$dst" ]] && cmp -s "$src" "$dst"; then
  echo "ok      $dst"
else
  drift=1
  if [[ -f "$dst" ]]; then
    echo "DIFF    $dst (live) vs user/settings.json (repo):"
    diff -u "$dst" "$src" || true
  fi
  if ! $CHECK; then
    if [[ -e "$dst" ]]; then
      mkdir -p "$BACKUP/.claude"
      cp "$dst" "$BACKUP/.claude/settings.json"
      echo "  backed up $dst -> $BACKUP/.claude/settings.json"
    fi
    cp "$src" "$dst"
    echo "copied  $dst"
  fi
fi

chmod +x "$REPO"/user/hooks/*.sh

if [[ -z "${REPLICATE_API_TOKEN:-}" ]]; then
  echo "note    REPLICATE_API_TOKEN is not set in this shell (image generation and the playstore MCP need it; see README)."
fi

if $CHECK; then
  [[ $drift -eq 0 ]] && echo "No drift." || { echo "Drift found. Run ./install.sh to fix (or copy live settings changes back into user/settings.json)."; exit 1; }
fi
