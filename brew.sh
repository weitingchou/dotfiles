#!/usr/bin/env bash

# Optional grab-bag of CTF/security tools and extra command-line binaries.
# NOTE: This script is NOT part of the install flow (bootstrap.sh only runs
# scripts/install_macos.sh). Run it manually if you want these extras.

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Install GNU core utilities (those that come with OS X are outdated).
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
brew install coreutils
# Expose an un-prefixed `sha256sum` (Intel and Apple Silicon safe; re-run safe).
ln -sf "$(brew --prefix coreutils)/libexec/gnubin/sha256sum" "$(brew --prefix)/bin/sha256sum"

# Install `wget` (IRI support is now built in; the old --with-iri flag is gone).
brew install wget

# Install RingoJS (a JVM-based JavaScript runtime).
brew install ringojs

# Install some CTF tools; see https://github.com/ctfs/write-ups.
brew install aircrack-ng
brew install bfg
brew install binutils
brew install binwalk
brew install cifer
brew install dex2jar
brew install dns2tcp
brew install fcrackzip
brew install foremost
brew install hydra
brew install john
brew install knock
brew install netpbm
brew install nmap
brew install pngcheck
brew install socat
brew install sqlmap
brew install tcpflow
brew install tcpreplay
brew install ucspi-tcp # `tcpserver` etc.
brew install xpdf
brew install xz

# Install other useful binaries.
brew install ack
brew install dark-mode
brew install git-lfs
brew install imagemagick
brew install lua
brew install lynx
brew install p7zip
brew install pigz
brew install pv
brew install rename
brew install rhino
brew install speedtest_cli
brew install ssh-copy-id
brew install tree
brew install webkit2png
brew install zopfli

brew install eksctl

# Remove outdated versions from the cellar.
brew cleanup
