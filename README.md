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

