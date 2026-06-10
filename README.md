# Wei-Ting’s dotfiles

This project is a fork of [Mathias Bynens](https://github.com/mathiasbynens/)'s excellent [dotfiles](https://github.com/mathiasbynens/) and modified with my style.

![Screenshot of my shell prompt](http://i.imgur.com/QOq7dNH.png)

## Installation

**Warning:** If you want to give these dotfiles a try, you should first fork this repository, review the code, and remove things you don’t want or need. Don’t blindly use my settings unless you know what that entails. Use at your own risk!

### Ubuntu

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/weitingchou/dotfiles/master/bootstrap.sh)"
```

This runs: `bootstrap.sh` → `install_ubuntu.sh` → `install_dotfiles.sh`

### macOS

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/weitingchou/dotfiles/master/bootstrap.sh)"
```

This runs: `bootstrap.sh` → `install_macos.sh` → `install_dotfiles.sh`

> **Note:** `install_dotfiles.sh` clones this repo from GitHub, so changes must be pushed before running on a new machine.

### User-only (non-admin accounts)

For a **non-admin** account — e.g. a sandbox user used to run agents or for
isolated development — run the user-only installer instead. It sets up
everything under `$HOME` and **never calls `sudo`**:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/weitingchou/dotfiles/master/scripts/install_user.sh)"
```

This runs: `install_user.sh` → `install_dotfiles.sh` (with `DOTFILES_USER_ONLY=1`)

It installs only the per-user pieces (dotfiles, oh-my-zsh + plugins,
Powerlevel10k, vim-plug, nvm + Node, Pyright, Claude Code, Hermes, SSH key, and
on macOS the iTerm2 profile). It does **not** install system packages — those
are shared and must already be installed by an admin via the platform script
above. The installer preflights for the shared toolchain and stops early with
instructions if it's missing.

**Same experience as admin.** System packages are installed once by an admin and
shared with every account, so a non-admin gets the identical CLI toolchain:

- **macOS:** the admin's Homebrew at `/opt/homebrew` is put on every account's
  `PATH` system-wide via `/etc/paths.d/homebrew`, so all brew-installed tools are
  visible automatically — no per-user PATH setup needed.
- **Docker** works per-user: once an admin has installed Colima, the sandbox
  user just runs `colima start` to bring up its own daemon (no sudo, no shared
  socket), then `docker` and `docker compose` work as usual.
- The only thing a non-admin gives up is **installing/updating packages**
  (`brew install`, `apt-get`). Run those from an admin account and they're
  immediately available to the sandbox user.

> If the sandbox account's login shell isn't already `zsh`, the user-only
> installer can't change it without sudo. macOS accounts default to `/bin/zsh`,
> so this is normally a no-op; otherwise an admin runs `sudo chsh -s /bin/zsh <user>`.

## What Gets Installed

### Ubuntu (`install_ubuntu.sh`)
- Build tools: `build-essential`, `g++`
- Shell: `zsh`
- Utilities: `wget`, `curl`, `git`, `rsync`, `autojump`, `silversearcher-ag`, `tmux`, `tree`, `ctags`, `cscope`
- Python: `python3`, `pip`, `venv`
- GitHub CLI (`gh`)
- AWS CLI v2
- Neovim (latest, via unstable PPA)

### macOS (`install_macos.sh`)
- Homebrew
- GNU core utilities, `wget`, `vim`, `zsh`, `git`, `tmux`, `tree`, `ctags`, `cscope`, `autojump`, `the_silver_searcher`
- GitHub CLI (`gh`)
- AWS CLI (`awscli`)
- Docker CLI + Compose + Colima (container runtime; run `colima start` per user)

### Both platforms (`install_dotfiles.sh`)
- oh-my-zsh + plugins: `zsh-autosuggestions`, `zsh-syntax-highlighting`
- Powerlevel10k theme
- vim-plug (for Vim and Neovim)
- nvm + Node.js LTS
- Pyright (Python LSP, installed globally via npm)
- Claude Code CLI

## Key Tools

| Tool | Purpose |
|------|---------|
| zsh + oh-my-zsh | Shell |
| Neovim | Primary editor (native LSP via nvim 0.11+) |
| Vim | Fallback editor |
| tmux | Terminal multiplexer (prefix: `C-a`) |
| nvm | Node version manager |
| Pyright | Python LSP for Neovim |
| AWS CLI v2 | AWS access |
| gh | GitHub CLI |
| Docker + Colima | Containers (macOS); `colima start` brings up a per-user daemon |
| Claude Code | AI coding assistant |

## After Installing

1. Open Neovim — plugins auto-install via headless `PlugInstall` during setup
2. Run `:PlugInstall` manually if any plugins are missing
3. Pyright LSP activates automatically for `.py` files
4. Log out and back in (or open a new login shell) for zsh to become the default shell

## Add Custom Commands

If `~/.extra` exists, it will be sourced along with the other files. Use it to add commands you don’t want to commit to a public repository (e.g. git credentials, private aliases).

### Sensible macOS defaults

When setting up a new Mac, you may want to set some sensible macOS defaults:

```bash
./.macos
```

## Feedback

Suggestions/improvements
[welcome](https://github.com/weitingchou/dotfiles/issues)!

## Author


## Thanks to…

* [Mathias Bynens](https://github.com/mathiasbynens/dotfiles)
* [Zach Holman](https://github.com/holman/dotfiles)
* [Kevin Smets](https://gist.github.com/kevin-smets/8568070)

