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
├── brew.sh                # Optional CTF/security tools (NOT in install flow; run manually)
├── scripts/
│   ├── install_macos.sh   # macOS package setup
│   ├── install_ubuntu.sh  # Ubuntu package setup (calls install_dotfiles.sh)
│   └── install_dotfiles.sh # Clone repo, set up zsh/oh-my-zsh, vim-plug, nvm, pyright
└── init/
    ├── oh-my-zsh/
    │   ├── custom/        # aliases.zsh, functions.zsh (copied to ~/.oh-my-zsh/custom/)
    │   └── themes/        # richchou.zsh-theme, powerlevel10k (copied to ~/.oh-my-zsh/themes/)
    └── iterm2/            # macOS-only iTerm2 config
        ├── com.googlecode.iterm2.plist   # prefs (synced to ~/.config/iterm2)
        └── DynamicProfiles/  # *.json profiles (e.g. Solarized Dark Patched)
```

## Install Flow

**On a new Ubuntu server:**
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/weitingchou/dotfiles/master/bootstrap.sh)"
```

This runs: `bootstrap.sh` → `install_ubuntu.sh` → `install_dotfiles.sh`

`install_dotfiles.sh` clones the repo from GitHub, so **changes must be pushed to GitHub before running on a new machine**.

**On a non-admin account (e.g. an agent-sandbox user):**
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/weitingchou/dotfiles/master/scripts/install_user.sh)"
```

This runs: `install_user.sh` → `install_dotfiles.sh` with `DOTFILES_USER_ONLY=1`,
which takes a **sudo-free** path: only `$HOME`-scoped setup, no system packages.
System packages are installed once by an admin (via the platform script) and
shared. On macOS, the admin's Homebrew at `/opt/homebrew` is on every account's
`PATH` via `/etc/paths.d/homebrew`, so a non-admin user gets the same CLI
toolchain automatically — only `brew install`/`apt-get` are unavailable to them.
`install_user.sh` preflights for the shared tools and stops early if an admin
hasn't run the full install yet.

`DOTFILES_USER_ONLY=1` makes `install_dotfiles.sh` skip its `sudo` callers: the
`chsh`/`/etc/shells` shell change (replaced with a sudo-free self-`chsh`
attempt), the Ubuntu-desktop WezTerm apt install, and the macOS headless-server
power policy. Each prints a note telling an admin what to run instead.

On macOS, the admin install *prompts* whether to apply a headless power policy
via `sudo pmset -a sleep 0 autorestart 1` — never system-sleep (so sshd stays
reachable) and auto-restart after a power outage. The prompt defaults to yes when
`PLATFORM_TYPE = server`, no otherwise. Reverse with `sudo pmset -a sleep 1 autorestart 0`.

## Key Tool Choices

- **Shell**: zsh + oh-my-zsh
- **Editor**: Neovim (primary) with vim-plug for plugins
  - Installed during setup: `brew install neovim` (macOS) / `neovim-ppa/unstable` PPA (Ubuntu, for 0.11+)
  - Python LSP: Pyright via nvim 0.11+ native LSP API (no nvim-lspconfig needed)
  - Completion: nvim-cmp + LuaSnip
  - Treesitter for syntax
- **Vim** (fallback): same `.vimrc`, uses python-mode + jedi-vim instead of LSP
- **Terminal multiplexer**: tmux (prefix: `C-a`)
- **Terminal emulator**: iTerm2 (macOS), WezTerm (Ubuntu desktop only)
  - Shared `.wezterm.lua` synced to `$HOME`; Solarized Dark to match the iTerm2 look
  - WezTerm installed via the official apt repo, gated on `PLATFORM_TYPE = desktop`
- **Node**: managed via nvm (LTS)
- **Python**: system python3; pyright installed globally via npm
- **Go** (macOS): toolchain via `brew install go` (admin/shared). Deps and tools
  are per-user — `go get`/`go mod` → `~/go/pkg/mod`, `go install` → `~/go/bin`
  (on PATH via `.zshrc`). `gopls` + `golangci-lint` installed per-user in
  `install_dotfiles.sh`; `gopls` is wired into the nvim native LSP in `.vimrc`.
- **Rust**: `rustup` (per-user, `~/.rustup`/`~/.cargo`) installed in
  `install_dotfiles.sh` — needs no admin, so a non-admin sandbox can install it.
  `.zshrc` sources `~/.cargo/env`.
- **Remote access**: Tailscale (WireGuard mesh VPN). Installed in the admin
  platform scripts (`brew install tailscale` on macOS — CLI formula, not the GUI
  cask, so it runs headless as a system daemon; official installer on Ubuntu).
  Machine-level (one tunnel for the whole box, shared by all accounts), so an
  admin connects it once: `sudo tailscaled install-system-daemon` (macOS) then
  `sudo tailscale up`. Reach the box at its tailnet name and log in as any user.
  On WSL Ubuntu there's no systemd, so the tailscaled service never starts —
  either enable systemd (`systemd=true` under `[boot]` in `/etc/wsl.conf`, then
  `wsl --shutdown`) for a durable fix, or start the daemon by hand
  (`sudo tailscaled > /dev/null 2>&1 &`) before `sudo tailscale up`. See
  `docs/remote-access-setup.md`.
- **Terraform** (IaC): installed in both admin platform scripts. macOS uses
  HashiCorp's tap (`brew install hashicorp/tap/terraform`) — the BUSL relicense
  removed it from homebrew-core; Ubuntu uses HashiCorp's official apt repo.
  `terraform-ls` (the language server) installs from the same tap/repo and is
  wired into the nvim native LSP in `.vimrc`.
- **Containers** (macOS): Docker CLI + Compose + Colima (`brew install docker
  docker-compose colima`). Colima runs a per-user Linux VM, so every account
  (including a non-admin sandbox user) runs its own daemon via `colima start` —
  no shared daemon, no sudo at runtime. The `docker`/`docker-compose` formulae
  are just the client + compose plugin talking to Colima's engine.
- **Bun** (macOS): `brew install bun` in the admin platform script — a fast
  JS/TS runtime. Installed shared (on `/opt/homebrew` PATH) because the Telegram
  Claude Code plugin's MCP server runs on it. See `docs/telegram-plugin-setup.md`.

## Dotfile Conventions

- Files at repo root are synced to `$HOME` via `rsync` (see `install_dotfiles.sh`)
- `.macos`, `bin/`, `init/`, `scripts/`, `docs/`, `bootstrap.sh` are excluded from the rsync
- `docs/` holds repo-only runbooks (e.g. `docs/remote-access-setup.md`), not synced to `$HOME`
- `init/oh-my-zsh/custom/*` → `~/.oh-my-zsh/custom/`
- `init/oh-my-zsh/themes/*` → `~/.oh-my-zsh/themes/`
- `init/iterm2/com.googlecode.iterm2.plist` → `~/.config/iterm2/` (macOS only); install
  then points iTerm2 at that folder via `defaults write com.googlecode.iterm2
  {PrefsCustomFolder,LoadPrefsFromCustomFolder}`. To update the repo after changing
  settings in the iTerm2 GUI, re-export with:
  `defaults export com.googlecode.iterm2 init/iterm2/com.googlecode.iterm2.plist`
  (optionally `plutil -convert xml1` it for a clean diff), then commit.
- `init/iterm2/DynamicProfiles/*.json` → `~/Library/Application Support/iTerm2/DynamicProfiles/`
  (macOS only). iTerm2 loads these as live, named profiles (e.g. "Solarized Dark
  Patched"). Generate one from an `.itermcolors` preset by wrapping its color keys
  in `{"Profiles":[{"Name":...,"Guid":...,<colors>}]}`.

## After Installing on a New Machine

1. Open neovim — plugins auto-install via headless PlugInstall during setup
2. Run `:PlugInstall` manually if any plugins are missing
3. Pyright LSP activates automatically for `.py` files
