#!/usr/bin/env bash

# User-only dotfiles installer for NON-ADMIN accounts (e.g. an agent-sandbox
# user used for development).
#
# It installs everything that lives under $HOME and never calls sudo:
#   dotfiles, oh-my-zsh + plugins, Powerlevel10k, vim-plug, nvm + Node, Pyright,
#   Claude Code, Hermes, the SSH key, and (on macOS) the iTerm2 profile.
#
# It does NOT install system packages. Those are shared and must already be
# installed once by an admin via the platform script (install_macos.sh /
# install_ubuntu.sh). On macOS the admin's Homebrew at /opt/homebrew is exposed
# to every account through /etc/paths.d/homebrew, so this user automatically sees
# the same CLI tools on PATH — the dev experience matches the admin account.
#
# Usage (run AS the non-admin user):
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/weitingchou/dotfiles/master/scripts/install_user.sh)"

set -e

case "$(uname)" in
  Darwin) OS="macos" ;;
  Linux)  OS="ubuntu" ;;
  *) echo "Unsupported OS: $(uname) (only macos/ubuntu supported)"; exit 1 ;;
esac

# Preflight: the shared toolchain must already be present. A non-admin account
# cannot install it (no write to the Homebrew prefix on macOS, no sudo for apt
# on Ubuntu), so fail early with a clear message instead of part-way through.
missing=""
for tool in zsh git curl rsync nvim; do
  command -v "$tool" >/dev/null 2>&1 || missing="$missing $tool"
done
if [ -n "$missing" ]; then
  echo "Missing shared tools:$missing"
  echo ""
  echo "These are system packages and must be installed by an admin first."
  echo "Have an admin account run the full install once:"
  echo "  bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/weitingchou/dotfiles/master/bootstrap.sh)\""
  echo "then re-run this user-only installer."
  exit 1
fi

# DOTFILES_USER_ONLY tells install_dotfiles.sh to take the sudo-free path.
export DOTFILES_USER_ONLY=1
bash -c "$(curl -fsSL https://raw.githubusercontent.com/weitingchou/dotfiles/master/scripts/install_dotfiles.sh)" "$OS"
