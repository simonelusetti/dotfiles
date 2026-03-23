# Shell aliases — compatible with bash and zsh
# Source this file from ~/.bashrc (Linux) or ~/.zshrc / ~/.bash_profile (macOS)

# Auto-update dotfiles silently in the background on every shell start
_df_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)"
if [ -d "$_df_dir/.git" ]; then
  (git -C "$_df_dir" pull --quiet --ff-only 2>/dev/null &)
fi
unset _df_dir

# ---------------------------------------------------------------------------
# Navigation
# ---------------------------------------------------------------------------
alias ll='ls -lah'

# ---------------------------------------------------------------------------
# Python
# ---------------------------------------------------------------------------
alias python='python3'
alias pip='python -m pip'

# ---------------------------------------------------------------------------
# Git
# ---------------------------------------------------------------------------
alias gs='git status'
alias gp='git pull'
alias gitup='git add . && git commit -m "update" && git push'

# ---------------------------------------------------------------------------
# Dotfiles: pull latest and reload shell
# ---------------------------------------------------------------------------
dotup() {
  local _df
  [ "$(uname)" = "Darwin" ] && _df="$HOME/code/utils/dotfiles" || _df="$HOME/utils/dotfiles"
  git -C "$_df" pull --ff-only && source ~/.bashrc && echo "Dotfiles updated and shell reloaded."
}

# ---------------------------------------------------------------------------
# macOS only
# ---------------------------------------------------------------------------
if [ "$(uname)" = "Darwin" ]; then
  alias brewup='brew update && brew upgrade && brew cleanup'
  alias cineca-login='eval "$(ssh-agent)" && ssh-keygen -R login.leonardo.cineca.it && step ssh login "simone.lusetti@unimore.it" --provisioner cineca-hpc && code --profile Cineca'
fi

# ---------------------------------------------------------------------------
# Quartz
# ---------------------------------------------------------------------------
_QUARTZ_ROOT="$HOME/code/quartz"
_QUARTZ_BASE="$_QUARTZ_ROOT/quartz-base"
_QUARTZ_NOTES_REPO="$_QUARTZ_ROOT/notes"
_QUARTZ_RPG_REPO="$_QUARTZ_ROOT/rpg"
_QUARTZ_NOTES_SOURCE="$HOME/Documents/obsidian/phd/notes/shared"
_QUARTZ_RPG_SOURCE="$HOME/Documents/obsidian/ttrpg/published"

_quartz_require_dir() {
  [ -d "$1" ] || {
    echo "Missing directory: $1" >&2
    return 1
  }
}

_quartz_require_file() {
  [ -f "$1" ] || {
    echo "Missing file: $1" >&2
    return 1
  }
}

_quartz_sync_content() {
  local src="$1"
  local dst="$2"
  local preserve_rel="${3:-}"
  local preserve_source="${4:-}"
  local tmp=""

  _quartz_require_dir "$src" || return 1
  mkdir -p "$dst" || return 1

  if [ -n "$preserve_rel" ]; then
    [ -n "$preserve_source" ] || preserve_source="$dst/$preserve_rel"
    if [ -f "$preserve_source" ] && [ ! -f "$src/$preserve_rel" ]; then
      tmp="$(mktemp -d "${TMPDIR:-/tmp}/quartz-preserve.XXXXXX")" || return 1
      mkdir -p "$tmp/$(dirname "$preserve_rel")" || {
        rm -rf "$tmp"
        return 1
      }
      cp "$preserve_source" "$tmp/$preserve_rel" || {
        rm -rf "$tmp"
        return 1
      }
    fi
  fi

  rsync -av --delete "$src/" "$dst/" || {
    [ -n "$tmp" ] && rm -rf "$tmp"
    return 1
  }

  if [ -n "$tmp" ]; then
    mkdir -p "$dst/$(dirname "$preserve_rel")" || {
      rm -rf "$tmp"
      return 1
    }
    cp "$tmp/$preserve_rel" "$dst/$preserve_rel" || {
      rm -rf "$tmp"
      return 1
    }
    rm -rf "$tmp"
  fi
}

_quartz_push_site() {
  local repo="$1"
  local src="$2"
  local message="$3"
  local preserve_rel="${4:-}"

  _quartz_require_dir "$repo" || return 1
  _quartz_sync_content "$src" "$repo/content" "$preserve_rel" || return 1

  (
    cd "$repo" || exit 1
    git add -A
    if git diff --cached --quiet; then
      git commit --allow-empty -m "$message" || exit 1
    else
      git commit -m "$message" || exit 1
    fi
    git push
  )
}

_quartz_preview_site() {
  local repo="$1"
  local src="$2"
  local preserve_rel="${3:-}"

  _quartz_require_dir "$_QUARTZ_BASE" || return 1
  _quartz_require_dir "$repo" || return 1
  _quartz_require_file "$repo/quartz.config.ts" || return 1
  _quartz_require_file "$repo/quartz.layout.ts" || return 1

  _quartz_sync_content "$src" "$_QUARTZ_BASE/content" "$preserve_rel" "$repo/content/$preserve_rel" || return 1
  cp "$repo/quartz.config.ts" "$_QUARTZ_BASE/quartz.config.ts" || return 1
  cp "$repo/quartz.layout.ts" "$_QUARTZ_BASE/quartz.layout.ts" || return 1

  cd "$_QUARTZ_BASE" || return 1
  npx quartz build --serve
}

qnotes() {
  local message="${*:-update notes}"
  _quartz_push_site "$_QUARTZ_NOTES_REPO" "$_QUARTZ_NOTES_SOURCE" "$message" "index.md"
}

qrpg() {
  local message="${*:-update rpg}"
  _quartz_push_site "$_QUARTZ_RPG_REPO" "$_QUARTZ_RPG_SOURCE" "$message"
}

qnotes-preview() {
  _quartz_preview_site "$_QUARTZ_NOTES_REPO" "$_QUARTZ_NOTES_SOURCE" "index.md"
}

qrpg-preview() {
  _quartz_preview_site "$_QUARTZ_RPG_REPO" "$_QUARTZ_RPG_SOURCE"
}

# ---------------------------------------------------------------------------
# Template for new sites — copy-paste and adapt
# ---------------------------------------------------------------------------
# qMYSITE() {
#   set -e
#   rsync -av --delete \
#     "$HOME/Documents/obsidian/VAULT/FOLDER/" \
#     "$HOME/MYSITE-quartz/content/"
#   (
#     cd "$HOME/MYSITE-quartz" || exit 1
#     git add .
#     git diff --cached --quiet && echo "Nothing to commit." && return 0
#     git commit -m "update"
#     git push
#   )
# }
#
# qMYSITE-preview() {
#   rsync -av --delete \
#     "$HOME/MYSITE-quartz/content/" \
#     "$_QUARTZ_BASE/content/"
#   cp "$HOME/MYSITE-quartz/quartz.config.ts" "$_QUARTZ_BASE/quartz.config.ts"
#   cp "$HOME/MYSITE-quartz/quartz.layout.ts" "$_QUARTZ_BASE/quartz.layout.ts"
#   (
#     cd "$_QUARTZ_BASE" || exit 1
#     npx quartz build --serve
#   )
# }
