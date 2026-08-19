# dotfiles

Personal dotfiles, stored as a **bare git repository** whose work-tree is `$HOME`.
There is no separate checkout to keep in sync — the tracked files live directly in
your home directory. See the writeup this setup is based on:
https://www.ackama.com/what-we-think/the-best-way-to-store-your-dotfiles-a-bare-git-repository-explained/

## Fresh machine

```bash
curl -fsSL https://raw.githubusercontent.com/strake7/dotfiles/master/bootstrap.sh | bash
```

`bootstrap.sh` clones the repo into `~/.cfg/.git`, checks the files out into
`$HOME`, and moves any pre-existing dotfiles it would overwrite into `~/.cfg-backup/`.

## The `config` alias

Defined in `.zshrc.personal.after`:

```bash
alias config='/usr/bin/git --git-dir=$HOME/.cfg/.git --work-tree=$HOME'
```

Make sure `~/.zshrc` sources that file so the alias exists:

```bash
if [ -f ~/.zshrc.personal.after ]; then . ~/.zshrc.personal.after; fi
```

## Manual setup (equivalent to bootstrap.sh)

```bash
git init --bare "$HOME/.cfg/.git"
config remote add origin https://github.com/strake7/dotfiles.git
config config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
config config status.showUntrackedFiles no
config fetch origin
config checkout master
config branch --set-upstream-to=origin/master master
```

## Tracked files

- `.config/doom/` — Doom Emacs config (`init.el`, `config.el`, `packages.el`, custom theme)
- `.zshrc.personal.after` — zsh PATH/aliases/functions, sourced after `.zshrc`
- `.irbrc`, `.pryrc` — Ruby REPL configuration
- `.taskrc` — Taskwarrior
- `.osx` — one-shot macOS system-preference script (run manually: `~/.osx`)
