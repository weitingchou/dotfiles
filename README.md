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
  user just runs `dkup` (a helper aliased to `colima start` with a default dev
  VM profile) to bring up its own daemon — no sudo, no shared socket — then
  `docker` and `docker compose` work as usual. `dkdown` stops the VM. The VM
  size is set by `COLIMA_CPU`/`COLIMA_MEMORY`/`COLIMA_DISK` in `aliases.zsh`.
- **Project dependencies work without admin.** Language package managers install
  into `$HOME`, so the sandbox user can fully develop: `go get`/`go mod`
  (`~/go`), `npm install` (its own `~/.nvm`), `pip` inside a `venv`, `cargo`
  (`~/.cargo`). Only the **toolchains** (`go`, `node`, `python`) are admin-gated,
  and an admin installs those once via the platform script — they're then shared
  on PATH. (Rust is the exception: `rustup` is per-user, so the sandbox can even
  install the toolchain itself.)
- The only thing a non-admin gives up is **installing/updating system packages**
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
- Terraform + terraform-ls (IaC + LSP; HashiCorp apt repo)
- Neovim (latest, via unstable PPA)
- Tailscale (mesh VPN; connect with `sudo tailscale up`)

### macOS (`install_macos.sh`)
- Homebrew
- GNU core utilities, `wget`, `vim`, `zsh`, `git`, `tmux`, `tree`, `ctags`, `cscope`, `autojump`, `the_silver_searcher`
- GitHub CLI (`gh`)
- AWS CLI (`awscli`)
- Terraform + terraform-ls (IaC + LSP; HashiCorp tap)
- Docker CLI + Compose + Colima (container runtime; run `colima start` per user)
- Go toolchain (`go`) — language deps install per-user under `~/go`, no admin
- Tailscale (mesh VPN, CLI formula; headless system daemon for remote SSH)
- Bun (JS/TS runtime; runtime for the Telegram Claude Code plugin's MCP server)
- rtk (LLM token reducer; homebrew-core formula, shared on PATH)
- Codex (OpenAI coding agent; homebrew cask, shared on PATH like the formulae)

### Both platforms (`install_dotfiles.sh`)
- oh-my-zsh + plugins: `zsh-autosuggestions`, `zsh-syntax-highlighting`
- Powerlevel10k theme
- vim-plug (for Vim and Neovim)
- nvm + Node.js LTS
- Pyright (Python LSP, installed globally via npm)
- Rust toolchain via rustup (per-user; `~/.rustup`, `~/.cargo`)
- Go tools: `gopls` (LSP) + `golangci-lint` (per-user, `~/go/bin`; needs Go installed)
- Claude Code CLI
- rtk + its Claude Code hook via `rtk init -g` (binary on Ubuntu only, into
  `~/.local/bin`; macOS gets it from brew above — the hook is wired per-user on both)
- Codex CLI (Ubuntu only — npm global; macOS already has it from the cask above)
- Hermes Agent CLI (Nous Research; bundles its own Python/Node/ripgrep/ffmpeg,
  installed `--skip-setup` so it runs unattended — run `hermes setup` afterwards
  to configure an LLM provider)

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
| Terraform | Infrastructure as code |
| gh | GitHub CLI |
| Docker + Colima | Containers (macOS); `colima start` brings up a per-user daemon |
| Tailscale | Mesh VPN for secure remote access (machine-level; `sudo tailscale up`) |
| Bun | JS/TS runtime (macOS); runs the Telegram Claude Code plugin's MCP server |
| Claude Code | AI coding assistant |
| Codex | OpenAI's terminal coding agent; `codex login` once per account |
| rtk | Compresses verbose command output before it hits an agent's context (~60-90% fewer tokens) |
| Hermes | Nous Research agent CLI; `hermes setup` once to configure an LLM provider |

## After Installing

1. Open Neovim — plugins auto-install via headless `PlugInstall` during setup
2. Run `:PlugInstall` manually if any plugins are missing
3. Pyright LSP activates automatically for `.py` files
4. Log out and back in (or open a new login shell) for zsh to become the default shell

### One-time interactive setup

The installers deliberately skip these: each needs a browser or a prompt, so
scripting them would stall an otherwise unattended run. Skip any tool you don't
use — nothing else depends on them.

**Per account** — run as yourself, on each account that wants the tool:

| Command | What it does |
|---------|--------------|
| `codex login` | Authenticates Codex (browser sign-in or API key) |
| `hermes setup` | Configures an LLM provider for Hermes Agent |

**Machine-level, once per box** — needs admin. Tailscale is one tunnel for the
whole machine, shared by every account, so a single admin connects it and
everyone can then reach the box by its tailnet name:

```bash
sudo tailscaled install-system-daemon   # macOS only: run at boot, no login session needed
sudo tailscale up                       # sign in (opens a browser URL)
```

See `docs/remote-access-setup.md` for the full walkthrough, including the WSL
caveat (no systemd, so the daemon needs starting by hand or systemd enabling).

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

