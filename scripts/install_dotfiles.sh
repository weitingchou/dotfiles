#!/usr/bin/env bash

set -e

# Use colors, but only if connected to a terminal, and that terminal
# supports them.
tput=$(which tput)
if [ -n "$tput"  ]; then
  ncolors=$($tput colors)
fi
if [ -t 1  ] && [ -n "$ncolors"  ] && [ "$ncolors" -ge 8  ]; then
  RED="$(tput setaf 1)"
  GREEN="$(tput setaf 2)"
  YELLOW="$(tput setaf 3)"
  BLUE="$(tput setaf 4)"
  BOLD="$(tput bold)"
  NORMAL="$(tput sgr0)"
else
  RED=""
  GREEN=""
  YELLOW=""
  BLUE=""
  BOLD=""
  NORMAL=""
fi

# Utility functions
info () {
  printf "\r  [ \033[00;34m..\033[0m ] $1\n"
}

user () {
  printf "\r  [ \033[0;33m??\033[0m ] $1\n"
}

success () {
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

fail () {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
  echo ''
  exit
}

version_gte () {
  if [[ $1 == $2  ]]
  then
    return 0
  fi
  local IFS=.
  local i ver1=($1) ver2=($2)
  # fill empty fields in ver1 with zeros
  for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
  do
    ver1[i]=0
  done
  for ((i=0; i<${#ver1[@]}; i++))
  do
    if [[ -z ${ver2[i]}  ]]; then
      # fill empty fields in ver2 with zeros
      ver2[i]=0
    fi
    if ((10#${ver1[i]} > 10#${ver2[i]})); then
      return 0
    fi
    if ((10#${ver1[i]} < 10#${ver2[i]})); then
      return 1
    fi
  done
  return 0
}

# Get the OS type
case "$0" in
  ubuntu|macos)
    OSTYPE=$0
    ;;
  *)
    fail "Unknown parameter: $0, should be one of ubuntu/macos"
    ;;
esac

read -p "Please select the platform type you are installing: server/desktop (default: server) "
echo ''
case "$REPLY" in
  "")
    # Default platform type
    PLATFORM_TYPE="server"
    ;;
  server|desktop)
    PLATFORM_TYPE="$REPLY"
    ;;
  *)
    fail "Unknown parameter: $REPLY"
    ;;
esac

# Prevent the cloned repository from having insecure permissions. Failing to do
# so causes compinit() calls to fail with "command not found: compdef" errors
# for users with insecure umasks (e.g., "002", allowing group writability). Note
# that this will be ignored under Cygwin by default, as Windows ACLs take
# precedence over umasks except for filesystems mounted with option "noacl".
umask g-w,o-w

info "${BLUE}Cloning dotfiles...${NORMAL}\n"
# Per-user temp dir. A shared, fixed path like /tmp/dotfiles breaks on a
# multi-user machine: /tmp has the sticky bit, so a second account (e.g. a
# non-admin sandbox user) can't delete a clone left by the first and the install
# fails with "Permission denied". Namespacing by UID gives each account its own.
REPODIR="${TMPDIR:-/tmp}/dotfiles-$(id -u)"
if [ -d "$REPODIR" ]; then # Delete the repodir if exists
  rm -rf "$REPODIR"
fi
hash git >/dev/null 2>&1 || fail "Error: git clone of dotfiles repo failed"
env git clone --depth=1 https://github.com/weitingchou/dotfiles.git $REPODIR || fail "Error: git clone of dotfiles repo failed"

info "${BLUE}Checking zsh installation..."
command -v zsh > /dev/null 2>&1 || fail "${YELLOW}Zsh is not installed!${NORMAL} Please install zsh first!"
version_gte "$(zsh --version | cut -d' ' -f 2)" "4.3.9" || fail "zsh version should be v4.3.9 or more"

info "${BLUE}Making default shell to zsh...${NORMAL}"
ZSH_PATH="$(command -v zsh)"
if [ "$SHELL" = "$ZSH_PATH" ]; then
  success "Default shell is already zsh, skipping."
elif [ "${DOTFILES_USER_ONLY:-0}" = "1" ]; then
  # Non-admin (user-only) install: never call sudo. A user may change their OWN
  # login shell with chsh, but only to a shell already listed in /etc/shells
  # (only an admin can add one there). On macOS /bin/zsh is already the default
  # and listed, so this branch is normally a no-op.
  if grep -q "^$ZSH_PATH$" /etc/shells; then
    if chsh -s "$ZSH_PATH" >/dev/null 2>&1; then
      success "Default shell changed to zsh."
    else
      user "Could not change login shell automatically. Ask an admin to run: sudo chsh -s $ZSH_PATH $USER"
    fi
  else
    user "$ZSH_PATH is not in /etc/shells. Ask an admin to add it, then run: sudo chsh -s $ZSH_PATH $USER"
  fi
else
  if [ ! $(grep "$ZSH_PATH" /etc/shells | wc -l) -ge 1 ]; then
    echo "$ZSH_PATH" | sudo tee -a /etc/shells
  fi
  sudo chsh -s "$ZSH_PATH" $USER
fi

info "${BLUE}Installing oh-my-zsh...${NORMAL}"
# Remove existing installation so the installer doesn't abort on re-runs
if [ -d "$HOME/.oh-my-zsh" ]; then
  rm -rf "$HOME/.oh-my-zsh"
fi
# Run unattended (RUNZSH=no prevents oh-my-zsh from launching zsh immediately)
RUNZSH=no CHSH=no bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

info "${BLUE}Copying custom settings to oh-my-zsh...${NORMAL}"
cp -r $REPODIR/init/oh-my-zsh/themes/* $HOME/.oh-my-zsh/themes/
cp -r $REPODIR/init/oh-my-zsh/custom/* $HOME/.oh-my-zsh/custom/

info "${BLUE}Installing oh-my-zsh plugins...${NORMAL}"
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
[ -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ] || \
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions
[ -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ] || \
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting
[ -d "${ZSH_CUSTOM}/themes/powerlevel10k" ] || \
  git clone --depth=1 https://github.com/romkatv/powerlevel10k ${ZSH_CUSTOM}/themes/powerlevel10k

info "${BLUE}Copying dotfiles...${NORMAL}"
cd $REPODIR
rsync --exclude ".git/" \
  --exclude ".DS_Store" \
  --exclude ".macos" \
  --exclude "bin/" \
  --exclude "init/" \
  --exclude "scripts/" \
  --exclude "bootstrap.sh" \
  --exclude "README.md" \
  --exclude "LICENSE-MIT.txt" \
  -avh --no-perms . $HOME;

# iTerm2 is macOS-only; sync its profile from the repo and point iTerm at it.
# init/ is excluded from the rsync above, so copy the plist explicitly to a
# persistent folder and tell iTerm2 to load (and save) its prefs from there.
if [ "$OSTYPE" = "macos" ]; then
  info "${BLUE}Configuring iTerm2 profile sync...${NORMAL}"
  ITERM_PREFS_DIR="$HOME/.config/iterm2"
  mkdir -p "$ITERM_PREFS_DIR"
  cp "$REPODIR/init/iterm2/com.googlecode.iterm2.plist" "$ITERM_PREFS_DIR/"
  defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$ITERM_PREFS_DIR"
  defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
  # Dynamic Profiles (e.g. "Solarized Dark Patched") — iTerm2 loads these live.
  ITERM_DYNAMIC_DIR="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
  mkdir -p "$ITERM_DYNAMIC_DIR"
  cp "$REPODIR"/init/iterm2/DynamicProfiles/*.json "$ITERM_DYNAMIC_DIR/"
  success "iTerm2 will load prefs from $ITERM_PREFS_DIR (restart iTerm2 to apply)."

  # Homebrew installs the Docker Compose plugin under its own prefix, which the
  # Docker CLI does not search by default — so `docker compose` (subcommand)
  # would not resolve. Symlink it into the per-user plugin dir to fix that. This
  # is per-user, so every account (incl. a non-admin sandbox user) gets it once
  # the shared `docker-compose` formula is installed by an admin. No-ops if the
  # plugin isn't present yet.
  COMPOSE_PLUGIN="$(brew --prefix 2>/dev/null)/lib/docker/cli-plugins/docker-compose"
  if [ -x "$COMPOSE_PLUGIN" ]; then
    mkdir -p "$HOME/.docker/cli-plugins"
    ln -sf "$COMPOSE_PLUGIN" "$HOME/.docker/cli-plugins/docker-compose"
    success "Linked Docker Compose plugin into ~/.docker/cli-plugins (docker compose works)."
  fi
fi

# Headless-server power policy (macOS). For a box you SSH into, the machine must
# not system-sleep (sshd stops accepting connections while asleep) and should
# power back on after an outage. pmset is admin-only, so the sudo-free user-only
# path can't change it and just prints a note; the admin install asks first
# (defaulting to yes on a server). Reverse with: sudo pmset -a sleep 1 autorestart 0.
if [ "$OSTYPE" = "macos" ]; then
  if [ "${DOTFILES_USER_ONLY:-0}" = "1" ]; then
    user "To keep this machine reachable over SSH, an admin can apply a headless power policy: sudo pmset -a sleep 0 autorestart 1"
  else
    # Default to yes for a server platform, no otherwise.
    if [ "$PLATFORM_TYPE" = "server" ]; then PWR_DEFAULT="Y"; PWR_HINT="[Y/n]"; else PWR_DEFAULT="N"; PWR_HINT="[y/N]"; fi
    read -p "Enable headless power policy (never sleep + auto-restart after power loss)? Recommended for an always-on server. $PWR_HINT "
    echo ''
    REPLY="${REPLY:-$PWR_DEFAULT}"
    if [[ "$REPLY" =~ ^[Yy]$ ]]; then
      info "${BLUE}Configuring headless power policy (never sleep, auto-restart)...${NORMAL}"
      if sudo pmset -a sleep 0 autorestart 1; then
        success "Power: system sleep disabled, auto-restart after power failure enabled."
      else
        user "Could not set power policy. Run manually: sudo pmset -a sleep 0 autorestart 1"
      fi
    else
      info "Skipping power policy. Apply later with: sudo pmset -a sleep 0 autorestart 1"
    fi
  fi
fi

# WezTerm is the advanced GUI terminal for Ubuntu desktop (the macOS analog is
# iTerm2, configured above). Only meaningful with a GUI, so skip on servers.
# The shared .wezterm.lua rsynced to $HOME above is read once WezTerm exists.
if [ "$OSTYPE" = "ubuntu" ] && [ "$PLATFORM_TYPE" = "desktop" ]; then
  if [ "${DOTFILES_USER_ONLY:-0}" = "1" ]; then
    user "Skipping WezTerm install (system package, needs sudo). Ask an admin to install it."
  elif command -v wezterm >/dev/null 2>&1; then
    success "WezTerm already installed, skipping."
  else
    info "${BLUE}Installing WezTerm (Ubuntu desktop terminal)...${NORMAL}"
    # Official WezTerm apt repo (Gemfury). Distribution and component are both '*'.
    curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
    sudo chmod 644 /usr/share/keyrings/wezterm-fury.gpg
    echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y wezterm
  fi
fi

info "${BLUE}Installing vim-plug for Vim...${NORMAL}"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

info "${BLUE}Installing vim-plug for Neovim...${NORMAL}"
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

info "${BLUE}Installing nodejs environment via nvm...${NORMAL}"
if [[ ! "$NVM_DIR" == "" ]]; then
  rm -rf $NVM_DIR
fi
# Install nvm (latest)
bash -c "$(curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh)"
# Load nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
# Install nodejs (long-term support version)
nvm install --lts

info "${BLUE}Installing pyright (Python LSP for Neovim)...${NORMAL}"
npm install -g pyright

# Rust toolchain via rustup. rustup is a PER-USER installer (everything lands in
# ~/.rustup and ~/.cargo), so this needs no admin and works the same on a
# non-admin sandbox account. --no-modify-path: PATH is handled by .zshrc, which
# sources ~/.cargo/env.
info "${BLUE}Installing Rust toolchain via rustup...${NORMAL}"
if command -v rustup >/dev/null 2>&1 || [ -x "$HOME/.cargo/bin/rustup" ]; then
  success "rustup already installed, skipping."
else
  curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs | sh -s -- -y --no-modify-path
fi

# Go developer tools (gopls = LSP for Neovim, golangci-lint = linter). These
# install per-user into $GOPATH/bin (~/go/bin) via `go install`, so no admin is
# needed — but they require the shared Go toolchain, which an admin installs via
# the platform script. Skip with a note if `go` isn't on PATH yet.
if command -v go >/dev/null 2>&1; then
  info "${BLUE}Installing Go tools (gopls, golangci-lint)...${NORMAL}"
  go install golang.org/x/tools/gopls@latest
  go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
  success "Go tools installed into $(go env GOBIN 2>/dev/null || echo "$(go env GOPATH)/bin")."
else
  user "Go is not installed — skipping gopls/golangci-lint. Ask an admin to run 'brew install go', then re-run this installer."
fi

info "${BLUE}Installing Claude Code CLI...${NORMAL}"
curl -fsSL https://claude.ai/install.sh | bash

info "${BLUE}Installing Hermes Agent...${NORMAL}"
# Hermes Agent (Nous Research) CLI. Only Git is required (present by now); the
# installer pulls in its own Python/Node/ripgrep/ffmpeg. --skip-setup skips the
# interactive setup wizard so the install runs unattended; with no API keys
# configured the gateway stage also self-skips. Run `hermes setup` manually
# afterwards to configure an LLM provider.
if command -v hermes >/dev/null 2>&1; then
  success "Hermes Agent already installed, skipping."
else
  curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash -s -- --skip-setup
fi

info "${BLUE}Installing Neovim plugins...${NORMAL}"
nvim --headless +PlugInstall +qall 2>/dev/null || true

info "${BLUE}Generating SSH key...${NORMAL}"
SSH_KEY="$HOME/.ssh/id_ed25519"
if [ -f "$SSH_KEY" ]; then
  info "SSH key already exists at $SSH_KEY, skipping."
else
  read -p "Enter email for SSH key comment (leave blank to skip): " SSH_EMAIL
  echo ''
  if [ -n "$SSH_EMAIL" ]; then
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    ssh-keygen -t ed25519 -C "$SSH_EMAIL" -f "$SSH_KEY" -N ""
    chmod 600 "$SSH_KEY"
    chmod 644 "${SSH_KEY}.pub"
    success "SSH key generated: $SSH_KEY"
    echo ''
    echo "Your public key (add this to GitHub or authorized_keys):"
    echo ''
    cat "${SSH_KEY}.pub"
    echo ''
  else
    info "Skipping SSH key generation."
  fi
fi

success "Installation completed without errors."
success "Open Neovim and run :PlugInstall if any plugins are missing."
success "Log out and log back in (or open a new login shell) for zsh to become the default shell."

# Reminder of the interactive/auth steps the installer intentionally left for you
# to run by hand (they can't be scripted unattended).
echo ''
echo "${BOLD}== Manual steps to finish setup ==${NORMAL}"
echo "  - Configure Hermes Agent (LLM provider):  hermes setup"
if [ "${DOTFILES_USER_ONLY:-0}" != "1" ]; then
  if [ "$OSTYPE" = "macos" ]; then
    echo "  - Connect this machine to Tailscale (admin, one-time):"
    echo "      sudo tailscaled install-system-daemon && sudo tailscale up"
  elif [ "$OSTYPE" = "ubuntu" ]; then
    echo "  - Connect this machine to Tailscale (admin, one-time):  sudo tailscale up"
  fi
fi
echo ''

env zsh
