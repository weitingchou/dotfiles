#!/usr/bin/env bash

set -e

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Make sure we're using latest Homebrew.
brew update

# Upgrade any already-installed formula.
brew upgrade

# Cleanup out-dated formula.
brew cleanup

# Install iTerm2
if brew list --cask iterm2 &>/dev/null; then
    echo "iTerm2 already installed, skipping."
else
    brew install --cask iterm2
fi

# Install the font used by the "Solarized Dark Patched" iTerm2 profile.
# Nerd Font variant of Source Code Pro: includes Powerline arrows AND the icon
# glyphs that powerlevel10k needs (plain "for Powerline" font shows ? for icons).
if brew list --cask font-sauce-code-pro-nerd-font &>/dev/null; then
    echo "Source Code Pro Nerd Font already installed, skipping."
else
    brew install --cask font-sauce-code-pro-nerd-font
fi

# Install GNU core utilities (those that come with OS X are outdated).
# Don't forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
# XXX: Already added the path in ~/.path
brew install coreutils
echo '# Use GNU core utilities instead of those come with OS X
#
# The Homebrew coreutils formula installs the tools with g appended to their names -
# e.g. gcat instead of cat, etc. This is a workaround in order to use GNU version of tools
# i.e. without prefix "g".
#
# NOTE: Using gnubin will cause Homebrew warning:
#       "Putting non-prefixed coreutils in your path can cause gmp builds to fail."
#       However, I will leave it there since it have not caused me any problem so far.
#
# Reference
# - http://apple.stackexchange.com/questions/69223/how-to-replace-mac-os-x-utilities-with-gnu-core-utilities
# - https://github.com/Homebrew/legacy-homebrew/issues/19238
COREUTILS="$(brew --prefix coreutils)/libexec/gnubin"
export PATH="$COREUTILS:$PATH"' > $HOME/.path


# Install some other useful utilities like `sponge`.
brew install moreutils
# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed.
brew install findutils
# Install GUN `sed`, overwriting the built-in `sed`.
brew install gnu-sed

# Install `wget` with IRI support.
#brew install wget --with-iri
brew install wget

# Install more recent versions of some OS X tools.
# (The homebrew/dupes tap was removed; these now live in homebrew-core.)
brew install vim
brew install neovim
brew install grep
brew install openssh

# Install zsh
brew install zsh

# Install AWS CLI
if command -v aws &>/dev/null; then
    echo "AWS CLI already installed, skipping."
else
    brew install awscli
fi

# Install GitHub CLI
if command -v gh &>/dev/null; then
    echo "GitHub CLI already installed, skipping."
else
    brew install gh
fi

# Install kubectl
if command -v kubectl &>/dev/null; then
    echo "kubectl already installed, skipping."
else
    brew install kubectl
fi

# Install Helm
if command -v helm &>/dev/null; then
    echo "Helm already installed, skipping."
else
    brew install helm
fi

# Install Docker CLI + Compose + Colima (container runtime for macOS).
# macOS can't run containers natively, so Colima provides a lightweight Linux
# VM. It runs PER-USER: each account (including a non-admin sandbox user) starts
# its OWN daemon with `colima start`, so there's no shared daemon and no sudo at
# runtime. The `docker` and `docker-compose` formulae are just the CLI client and
# the compose plugin; they talk to whatever engine Colima brings up.
if command -v colima &>/dev/null; then
    echo "Colima already installed, skipping."
else
    brew install docker docker-compose colima
fi
echo "Docker is ready. Each user runs 'colima start' once per login session to"
echo "bring up the daemon, then 'docker' and 'docker compose' work normally."

# Install my favorite tools
brew install git
brew install autojump
brew install the_silver_searcher
brew install tmux
brew install tree
brew install ctags
brew install cscope

# Install Python 3 (provides pip3). Homebrew no longer ships Python 2.
# Note: Homebrew's Python is an externally-managed environment (PEP 668), so
# don't `pip install --upgrade` against it globally — use a venv instead.
brew install python3

# Install the Go toolchain. This is the only admin-gated part of Go development:
# once `go` is on the shared PATH, every account (incl. a non-admin sandbox user)
# can fetch modules (`go get`/`go mod`), install tools (`go install` -> ~/go/bin),
# and build — all per-user under $HOME, no sudo. Go 1.21+ also auto-downloads
# newer toolchain versions named in a project's go.mod into the per-user cache.
if command -v go &>/dev/null; then
    echo "Go already installed, skipping."
else
    brew install go
fi

# Install Terraform (HashiCorp IaC). Terraform's BUSL license got it removed from
# homebrew-core, so it lives in HashiCorp's own tap, not the default formulae.
if command -v terraform &>/dev/null; then
    echo "Terraform already installed, skipping."
else
    brew tap hashicorp/tap
    brew install hashicorp/tap/terraform
fi
# terraform-ls: Terraform language server, wired into the nvim native LSP (.vimrc).
if command -v terraform-ls &>/dev/null; then
    echo "terraform-ls already installed, skipping."
else
    brew install hashicorp/tap/terraform-ls
fi

# Install Tailscale (WireGuard mesh VPN) for secure remote access across networks
# without opening any router ports. Use the CLI formula (not the GUI cask) so it
# can run headless as a system daemon — right for a Mac you SSH into. Tailscale is
# a MACHINE-LEVEL service: one tunnel for the whole box, shared by every account,
# so it's set up here in the admin install. After install, an admin connects it
# once (interactive, so not scripted):
#   sudo tailscaled install-system-daemon   # run at boot, no login session needed
#   sudo tailscale up                        # sign in (opens a browser URL)
if command -v tailscale &>/dev/null; then
    echo "Tailscale already installed, skipping."
else
    brew install tailscale
fi
echo "Tailscale installed. To connect this machine (admin, one-time):"
echo "  sudo tailscaled install-system-daemon && sudo tailscale up"

# Remove outdated versions from the cellar.
brew cleanup

bash -c "$(curl -fsSL https://raw.githubusercontent.com/weitingchou/dotfiles/master/scripts/install_dotfiles.sh)" "macos"
