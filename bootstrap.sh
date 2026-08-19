#!/usr/bin/env bash
#
# Bootstrap these dotfiles on a fresh machine using the bare-repo technique.
# https://www.ackama.com/what-we-think/the-best-way-to-store-your-dotfiles-a-bare-git-repository-explained/
#
# One-liner:
#   curl -fsSL https://raw.githubusercontent.com/strake7/dotfiles/master/bootstrap.sh | bash
#
# The git database lives in ~/.cfg/.git and the work-tree is $HOME, so tracked
# files (.zshrc.personal.after, .irbrc, .config/doom, ...) land directly in place.
# Files that already exist and would be overwritten are moved to ~/.cfg-backup/.

set -euo pipefail

REPO="${DOTFILES_REPO:-https://github.com/strake7/dotfiles.git}"
GITDIR="$HOME/.cfg/.git"
BACKUP="$HOME/.cfg-backup"

cfg() { git --git-dir="$GITDIR" --work-tree="$HOME" "$@"; }

# 1. Clone the bare repo (idempotent: skip if already present).
if [ ! -d "$GITDIR" ]; then
  echo "Cloning $REPO -> $GITDIR"
  git clone --quiet --bare "$REPO" "$GITDIR"
else
  echo "$GITDIR already exists; fetching latest"
fi

# 2. Standard fetch refspec so `config fetch/pull/push` track origin like a normal repo.
cfg config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
cfg config status.showUntrackedFiles no
cfg fetch --quiet origin

# 3. Check out into $HOME, backing up any file that would be clobbered.
if ! cfg checkout master 2>/tmp/cfg-checkout.$$; then
  echo "Backing up pre-existing dotfiles to $BACKUP/"
  # git prints the offending paths, indented, between two message lines.
  awk '/^\t/ {gsub(/^\t/,""); print}' "/tmp/cfg-checkout.$$" | while IFS= read -r f; do
    [ -e "$HOME/$f" ] || continue
    mkdir -p "$BACKUP/$(dirname "$f")"
    mv "$HOME/$f" "$BACKUP/$f"
  done
  cfg checkout master
fi
rm -f "/tmp/cfg-checkout.$$"

cfg branch --set-upstream-to=origin/master master >/dev/null 2>&1 || true

cat <<'EOF'

Dotfiles deployed.

Next steps:
  1. Make sure your ~/.zshrc sources the personal file (adds the `config` alias):
       if [ -f ~/.zshrc.personal.after ]; then . ~/.zshrc.personal.after; fi
  2. Reload your shell, then manage dotfiles with the `config` alias:
       config status
       config add ~/.somefile
       config commit -m "add somefile"
       config push
EOF
