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
# ---------------------------------------------------------------------------
# Quartz aliases — add these to ~/.zshrc
# ---------------------------------------------------------------------------
# quartz-base lives here locally (clone of simonelusetti/quartz-base)
_QUARTZ_BASE="$HOME/code/quartz/quartz-base"

# ---------------------------------------------------------------------------
# notes-quartz
# ---------------------------------------------------------------------------
qnotes() {
  set -e
  # 1. Sync content from Obsidian vault
  rsync -av --delete \
    "$HOME/Documents/obsidian/phd/notes/shared/" \
    "$HOME/notes-quartz/content/"
  # 2. Push to GitHub — Actions will build and deploy automatically
  (
    cd "$HOME/notes-quartz" || exit 1
    git add .
    git diff --cached --quiet && echo "Nothing to commit." && return 0
    git commit -m "update"
    git push
  )
}

qnotes-preview() {
  # Build and serve locally using the quartz-base engine
  rsync -av --delete \
    "$HOME/notes-quartz/content/" \
    "$_QUARTZ_BASE/content/"
  cp "$HOME/notes-quartz/quartz.config.ts" "$_QUARTZ_BASE/quartz.config.ts"
  cp "$HOME/notes-quartz/quartz.layout.ts" "$_QUARTZ_BASE/quartz.layout.ts"
  (
    cd "$_QUARTZ_BASE" || exit 1
    npx quartz build --serve
  )
}

# ---------------------------------------------------------------------------
# rpg-quartz
# ---------------------------------------------------------------------------
qrpg() {
  set -e
  # 1. Sync content from Obsidian vault
  rsync -av --delete \
    "$HOME/Documents/obsidian/ttrpg/published/" \
    "$HOME/rpg-quartz/content/"
  # 2. Format and push
  (
    cd "$HOME/rpg-quartz" || exit 1
    git add .
    git diff --cached --quiet && echo "Nothing to commit." && return 0
    git commit -m "update"
    git push
  )
}

qrpg-preview() {
  # Build and serve locally using the quartz-base engine
  rsync -av --delete \
    "$HOME/rpg-quartz/content/" \
    "$_QUARTZ_BASE/content/"
  cp "$HOME/rpg-quartz/quartz.config.ts" "$_QUARTZ_BASE/quartz.config.ts"
  cp "$HOME/rpg-quartz/quartz.layout.ts" "$_QUARTZ_BASE/quartz.layout.ts"
  (
    cd "$_QUARTZ_BASE" || exit 1
    npx quartz build --serve
  )
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
