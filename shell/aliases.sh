# Shell aliases
# Source this file from ~/.bashrc or ~/.bash_profile

# Auto-update dotfiles silently in the background on every shell start
_df_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [ -d "$_df_dir/.git" ]; then
  (git -C "$_df_dir" pull --quiet --ff-only 2>/dev/null &)
fi
unset _df_dir

# Navigation
alias ll='ls -lah'

# Git shortcuts
alias gs='git status'
alias gp='git pull'
alias gitup='git add . && git commit -m "update" && git push'
