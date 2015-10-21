#!/usr/bin/env bash

# Before we start, make sure user really wants to do this
read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
echo ''
if [[ ! $REPLY =~ ^[Yy]$ ]];then
    exit
fi

printf "\r  [ \033[00;34m..\033[0m ] Installing basic packages...\n"

sudo apt-get update
sudo apt-get install -y git
sudo apt-get install -y language-pack-en
sudo apt-get install -y build-essential
sudo apt-get install -y curl
sudo apt-get install -y wget
sudo apt-get install -y zsh
sudo apt-get install -y tmux
sudo apt-get install -y ctags
sudo apt-get install -y cscope
sudo apt-get install -y g++
sudo apt-get install -y tree
sudo apt-get install -y silversearcher-ag # Need Ubuntu 13.10 or more
sudo apt-get install -y autojump

sudo apt-get install -y golang
sudo apt-get install -y python2.7
sudo apt-get install -y python3.4
sudo apt-get install -y python-pip

bash -c "$(curl -fsSL https://raw.github.com/weitingchou/dotfiles/master/scripts/install_dev.sh)"
