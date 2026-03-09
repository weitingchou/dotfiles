#!/usr/bin/env bash

set -e

# Before we start, make sure user really wants to do this
read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
echo ''
if [[ ! $REPLY =~ ^[Yy]$ ]];then
    exit
fi

printf "\r  [ \033[00;34m..\033[0m ] Installing basic packages...\n"

# Make sure we're using latest packages.
sudo apt-get update

# Install basic building tools
sudo apt-get install -y language-pack-en
sudo apt-get install -y build-essential

# Install zsh
sudo apt-get install -y zsh
sudo apt-get install -y zsh-doc

# Install favorite tools
sudo apt-get install -y wget curl git rsync
sudo apt-get install -y autojump
sudo apt-get install -y silversearcher-ag
sudo apt-get install -y tmux
sudo apt-get install -y tree
sudo apt-get install -y exuberant-ctags
sudo apt-get install -y cscope
sudo apt-get install -y g++

# Python 3
sudo apt-get install -y python3 python3-pip python3-venv

# Neovim (0.11+ required for native LSP API - use unstable PPA)
sudo add-apt-repository -y ppa:neovim-ppa/unstable
sudo apt-get update
sudo apt-get install -y neovim

bash -c "$(curl -fsSL https://raw.githubusercontent.com/weitingchou/dotfiles/master/scripts/install_dotfiles.sh)" "ubuntu"
