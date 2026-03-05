# Dotfiles Repo

Personal dotfiles for macOS and Ubuntu (server/desktop), managed via shell scripts.

## Repo Structure

```
.                          # Dotfiles copied directly to $HOME on install
├── .vimrc                 # Shared vim/neovim config (vim-plug, LSP for neovim)
├── .gitconfig             # Git aliases and settings
├── .tmux.conf             # Tmux config (prefix: C-a, vim-style pane navigation)
├── .editorconfig          # Editor whitespace/indent rules
├── bootstrap.sh           # Entry point: detects OS, calls platform install script
├── brew.sh                # macOS Homebrew package installs
├── scripts/
│   ├── install_macos.sh   # macOS package setup
│   ├── install_ubuntu.sh  # Ubuntu package setup (calls install_dotfiles.sh)
│   └── install_dotfiles.sh # Clone repo, set up zsh/oh-my-zsh, vim-plug, nvm, pyright
└── init/
    └── oh-my-zsh/
        ├── custom/        # aliases.zsh, functions.zsh (copied to ~/.oh-my-zsh/custom/)
        └── themes/        # richchou.zsh-theme, powerlevel10k (copied to ~/.oh-my-zsh/themes/)
```

## Install Flow

**On a new Ubuntu server:**
```bash
bash -c "$(curl -fsSL https://raw.github.com/weitingchou/dotfiles/master/bootstrap.sh)"
```

This runs: `bootstrap.sh` → `install_ubuntu.sh` → `install_dotfiles.sh`

`install_dotfiles.sh` clones the repo from GitHub, so **changes must be pushed to GitHub before running on a new machine**.

## Key Tool Choices

- **Shell**: zsh + oh-my-zsh
- **Editor**: Neovim (primary) with vim-plug for plugins
  - Python LSP: Pyright via nvim 0.11+ native LSP API (no nvim-lspconfig needed)
  - Completion: nvim-cmp + LuaSnip
  - Treesitter for syntax
- **Vim** (fallback): same `.vimrc`, uses python-mode + jedi-vim instead of LSP
- **Terminal multiplexer**: tmux (prefix: `C-a`)
- **Node**: managed via nvm (LTS)
- **Python**: system python3; pyright installed globally via npm

## Dotfile Conventions

- Files at repo root are synced to `$HOME` via `rsync` (see `install_dotfiles.sh`)
- `.macos`, `bin/`, `init/`, `scripts/`, `bootstrap.sh` are excluded from the rsync
- `init/oh-my-zsh/custom/*` → `~/.oh-my-zsh/custom/`
- `init/oh-my-zsh/themes/*` → `~/.oh-my-zsh/themes/`

## After Installing on a New Machine

1. Open neovim — plugins auto-install via headless PlugInstall during setup
2. Run `:PlugInstall` manually if any plugins are missing
3. Pyright LSP activates automatically for `.py` files
