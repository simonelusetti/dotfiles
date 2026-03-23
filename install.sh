#!/usr/bin/env bash
# =============================================================================
# install.sh — run once on any machine to set up dotfiles
# Usage:
#   bash <(curl -fsSL https://raw.githubusercontent.com/simonelusetti/dotfiles/main/install.sh)
# Or after cloning manually:
#   bash ~/utils/dotfiles/install.sh
# Safe to re-run: all steps are guarded.
# =============================================================================

set -euo pipefail

REPO="git@github.com:simonelusetti/dotfiles.git"
OS="$(uname -s)"

# Install path differs by machine type
if [ "$OS" = "Darwin" ]; then
  DOTFILES="$HOME/code/utils/dotfiles"
else
  DOTFILES="$HOME/utils/dotfiles"
fi

BASHRC="$HOME/.bashrc"
BASH_PROFILE="$HOME/.bash_profile"
SOURCE_LINE="[ -f \"$DOTFILES/shell/aliases.sh\" ] && source \"$DOTFILES/shell/aliases.sh\""
PROFILE_LINE='[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"'

echo "==> OS: $OS"
echo "==> Dotfiles location: $DOTFILES"
echo ""

# -----------------------------------------------------------------------------
# 1. Clone repo if not already present
# -----------------------------------------------------------------------------
echo "==> Checking dotfiles repo ..."
if [ -d "$DOTFILES/.git" ]; then
  echo "    Already cloned — pulling latest ..."
  git -C "$DOTFILES" pull --ff-only
else
  echo "    Cloning from GitHub ..."
  mkdir -p "$(dirname "$DOTFILES")"
  git clone "$REPO" "$DOTFILES"
  echo "    Cloned."
fi

# -----------------------------------------------------------------------------
# 2. Patch ~/.bashrc
# -----------------------------------------------------------------------------
echo ""
echo "==> Patching $BASHRC ..."
touch "$BASHRC"
if grep -qF 'dotfiles/shell/aliases.sh' "$BASHRC"; then
  echo "    Source line already present — no change."
else
  printf '\n# Load shared dotfiles aliases\n%s\n' "$SOURCE_LINE" >> "$BASHRC"
  echo "    Added:  $SOURCE_LINE"
fi

# -----------------------------------------------------------------------------
# 3. Patch ~/.bash_profile (macOS login-shell fix only)
# -----------------------------------------------------------------------------
if [ "$OS" = "Darwin" ]; then
  echo ""
  echo "==> Patching $BASH_PROFILE (macOS login-shell fix) ..."
  touch "$BASH_PROFILE"
  if grep -qF '.bashrc' "$BASH_PROFILE"; then
    echo "    .bashrc source already present — no change."
  else
    printf '\n# Source ~/.bashrc for interactive login shells (macOS)\n%s\n' "$PROFILE_LINE" >> "$BASH_PROFILE"
    echo "    Added:  $PROFILE_LINE"
  fi
fi

# -----------------------------------------------------------------------------
# Done
# -----------------------------------------------------------------------------
echo ""
echo "===== Done ====="
echo ""
echo "Reload your shell:  source ~/.bashrc"
echo ""
echo "On every new shell, aliases.sh will auto-pull updates from GitHub in the background."
