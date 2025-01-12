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
sudo apt-get install -y ncurses-dev   # for building vim

# Install zsh
sudo apt-get install -y zsh
sudo apt-get install -y zsh-doc

# Install my favorite tools
sudo apt-get install -y wget
sudo apt-get install -y git
sudo apt-get install -y autojump
sudo apt-get install -y silversearcher-ag # Need Ubuntu 13.10 or more
sudo apt-get install -y tmux
sudo apt-get install -y tree
sudo apt-get install -y exuberant-ctags
sudo apt-get install -y cscope
sudo apt-get install -y g++

# Install packages for later installation use
sudo apt-get install -y python2.7
sudo apt-get install -y python3.4
sudo apt-get install -y python-pip
pip install --upgrade pip   # upgrade pip

bash -c "$(curl -fsSL https://raw.github.com/weitingchou/dotfiles/master/scripts/install_dotfiles.sh)" "ubuntu"
