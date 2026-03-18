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
sudo apt-get install -y wget curl git rsync unzip
sudo apt-get install -y autojump
sudo apt-get install -y silversearcher-ag
sudo apt-get install -y tmux
sudo apt-get install -y tree
sudo apt-get install -y exuberant-ctags
sudo apt-get install -y cscope
sudo apt-get install -y g++

# Python 3
sudo apt-get install -y python3 python3-pip python3-venv

# GitHub CLI
if command -v gh &>/dev/null; then
    printf "\r  [ \033[00;32mok\033[0m ] GitHub CLI already installed, skipping.\n"
else
    printf "\r  [ \033[00;34m..\033[0m ] Installing GitHub CLI...\n"
    sudo mkdir -p -m 755 /etc/apt/keyrings
    wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
    sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y gh
fi

# AWS CLI v2
if command -v aws &>/dev/null; then
    printf "\r  [ \033[00;32mok\033[0m ] AWS CLI already installed, skipping.\n"
else
    printf "\r  [ \033[00;34m..\033[0m ] Installing AWS CLI v2...\n"
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
    unzip -q /tmp/awscliv2.zip -d /tmp/awscliv2
    sudo /tmp/awscliv2/aws/install --update
    rm -rf /tmp/awscliv2.zip /tmp/awscliv2
fi

# kubectl
if command -v kubectl &>/dev/null; then
    printf "\r  [ \033[00;32mok\033[0m ] kubectl already installed, skipping.\n"
else
    printf "\r  [ \033[00;34m..\033[0m ] Installing kubectl...\n"
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y kubectl
fi

# Helm
if command -v helm &>/dev/null; then
    printf "\r  [ \033[00;32mok\033[0m ] Helm already installed, skipping.\n"
else
    printf "\r  [ \033[00;34m..\033[0m ] Installing Helm...\n"
    curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y helm
fi

# Neovim (0.11+ required for native LSP API - use unstable PPA)
if command -v nvim &>/dev/null; then
    printf "\r  [ \033[00;32mok\033[0m ] Neovim already installed, skipping.\n"
else
    printf "\r  [ \033[00;34m..\033[0m ] Installing Neovim...\n"
    sudo add-apt-repository -y ppa:neovim-ppa/unstable
    sudo apt-get update
    sudo apt-get install -y neovim
fi

bash -c "$(curl -fsSL https://raw.githubusercontent.com/weitingchou/dotfiles/master/scripts/install_dotfiles.sh)" "ubuntu"
