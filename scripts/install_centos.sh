#!/usr/bin/env bash

# Before we start, make sure user really wants to do this
read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
echo ''
if [[ ! $REPLY =~ ^[Yy]$ ]];then
    exit
fi

printf "\r  [ \033[00;34m..\033[0m ] Installing basic packages...\n""] ]"

info "Installing basic packages..."
sudo yum -y update
sudo yum install -y epel-release
sudo yum groupinstall -y "Development Tools"
sudo yum install -y git
sudo yum install -y language-pack-en
sudo yum install -y curl
sudo yum install -y wget
sudo yum install -y zsh
sudo yum install -y tmux
sudo yum install -y ctags
sudo yum install -y cscope
sudo yum install -y g++
sudo yum install -y tree
sudo yum install -y silversearcher-ag # Need Ubuntu 13.10 or more
sudo yum install -y autojump

sudo yum install -y golang

sudo yum install -y python2.7
sudo yum install -y python3.4
sudo yum install -y python-pip

bash -c "$(curl -fsSL https://raw.github.com/weitingchou/dotfiles/master/scripts/install_dev.sh)"
