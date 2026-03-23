#!/usr/bin/env bash
# =============================================================================
# finish_setup.sh  —  run once from your Mac terminal
# Initialises git, patches shell config, and pushes to GitHub.
# Safe to re-run: every step is guarded.
# =============================================================================

set -euo pipefail

DOTFILES="$HOME/code/utils/dotfiles"
BASHRC="$HOME/.bashrc"
BASH_PROFILE="$HOME/.bash_profile"
SOURCE_LINE='[ -f "$HOME/code/utils/dotfiles/shell/aliases.sh" ] && source "$HOME/code/utils/dotfiles/shell/aliases.sh"'
PROFILE_LINE='[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"'

# -----------------------------------------------------------------------------
# 1. Git init + commit
# -----------------------------------------------------------------------------
echo "==> Initialising git repo in $DOTFILES ..."
cd "$DOTFILES"

if [ -d ".git" ]; then
  echo "    Already a git repo — skipping init."
else
  git init
  git add .
  git commit -m "Initial commit: add shell aliases"
  echo "    Done."
fi

# -----------------------------------------------------------------------------
# 2. Patch ~/.bashrc
# -----------------------------------------------------------------------------
echo ""
echo "==> Patching $BASHRC ..."
touch "$BASHRC"
if grep -qF 'code/utils/dotfiles/shell/aliases.sh' "$BASHRC"; then
  echo "    Source line already present — no change."
else
  printf '\n# Load shared dotfiles aliases\n%s\n' "$SOURCE_LINE" >> "$BASHRC"
  echo "    Added:  $SOURCE_LINE"
fi

# -----------------------------------------------------------------------------
# 3. Patch ~/.bash_profile (macOS login-shell fix)
# -----------------------------------------------------------------------------
echo ""
echo "==> Patching $BASH_PROFILE (macOS login-shell fix) ..."
touch "$BASH_PROFILE"
if grep -qF '.bashrc' "$BASH_PROFILE"; then
  echo "    .bashrc source already present — no change."
else
  printf '\n# Source ~/.bashrc for interactive login shells (macOS)\n%s\n' "$PROFILE_LINE" >> "$BASH_PROFILE"
  echo "    Added:  $PROFILE_LINE"
fi

# -----------------------------------------------------------------------------
# 4. Push to GitHub
# -----------------------------------------------------------------------------
echo ""
echo "==> Checking GitHub CLI (gh) ..."

if ! command -v gh &>/dev/null; then
  echo ""
  echo "  ❌  gh CLI not found. Install: https://cli.github.com/"
  echo "  Then run from $DOTFILES:"
  echo ""
  echo "      gh repo create dotfiles --public \\"
  echo "        --description \"Personal dotfiles: bash aliases and shell config\" \\"
  echo "        --source . --remote origin --push"
  exit 0
fi

if ! gh auth status &>/dev/null; then
  echo ""
  echo "  ❌  gh not authenticated. Run:  gh auth login"
  echo "  Then re-run this script — all earlier steps will be skipped safely."
  exit 0
fi

cd "$DOTFILES"
if git remote get-url origin &>/dev/null; then
  echo "    Remote 'origin' already set — skipping repo creation."
else
  echo "    Creating GitHub repo and pushing ..."
  gh repo create dotfiles \
    --public \
    --description "Personal dotfiles: bash aliases and shell config" \
    --source . \
    --remote origin \
    --push
fi

echo ""
echo "==> GitHub repo URL:"
gh repo view --json url -q .url

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
echo ""
echo "===== All done ====="
echo "  ~/code/utils/dotfiles/shell/aliases.sh  ✓ (already created)"
echo "  ~/.bashrc                                ✓ patched"
echo "  ~/.bash_profile                          ✓ patched (macOS)"
echo "  git repo                                 ✓ committed"
echo "  GitHub                                   ✓ pushed"
echo ""
echo "Reload your shell:  source ~/.bashrc"
