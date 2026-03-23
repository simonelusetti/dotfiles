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
# macOS only
# ---------------------------------------------------------------------------
if [ "$(uname)" = "Darwin" ]; then
  alias brewup='brew update && brew upgrade && brew cleanup'
  alias cineca-login='eval "$(ssh-agent)" && ssh-keygen -R login.leonardo.cineca.it && step ssh login "simone.lusetti@unimore.it" --provisioner cineca-hpc && code --profile Cineca'
fi
