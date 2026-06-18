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
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

# eksctl
if command -v eksctl &>/dev/null; then
    printf "\r  [ \033[00;32mok\033[0m ] eksctl already installed, skipping.\n"
else
    printf "\r  [ \033[00;34m..\033[0m ] Installing eksctl...\n"
    ARCH=amd64
    PLATFORM=$(uname -s)_$ARCH
    curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_${PLATFORM}.tar.gz"
    tar -xzf "eksctl_${PLATFORM}.tar.gz" -C /tmp && rm "eksctl_${PLATFORM}.tar.gz"
    sudo mv /tmp/eksctl /usr/local/bin
fi

# Terraform (HashiCorp IaC) — installed from HashiCorp's official apt repo.
if command -v terraform &>/dev/null; then
    printf "\r  [ \033[00;32mok\033[0m ] Terraform already installed, skipping.\n"
else
    printf "\r  [ \033[00;34m..\033[0m ] Installing Terraform...\n"
    sudo mkdir -p -m 755 /etc/apt/keyrings
    wget -qO- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/hashicorp-archive-keyring.gpg
    sudo chmod go+r /etc/apt/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/etc/apt/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y terraform
fi

# terraform-ls: Terraform language server, wired into the nvim native LSP (.vimrc).
# Ships from the same HashiCorp apt repo configured above for terraform.
if command -v terraform-ls &>/dev/null; then
    printf "\r  [ \033[00;32mok\033[0m ] terraform-ls already installed, skipping.\n"
else
    printf "\r  [ \033[00;34m..\033[0m ] Installing terraform-ls...\n"
    sudo apt-get install -y terraform-ls
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

# Tailscale (WireGuard mesh VPN) — secure remote access across networks without
# opening any ports. The official installer sets up the apt repo and enables
# tailscaled as a systemd service (starts at boot, headless-friendly). Connecting
# is interactive, so an admin runs `sudo tailscale up` once afterwards.
if command -v tailscale &>/dev/null; then
    printf "\r  [ \033[00;32mok\033[0m ] Tailscale already installed, skipping.\n"
else
    printf "\r  [ \033[00;34m..\033[0m ] Installing Tailscale...\n"
    curl -fsSL https://tailscale.com/install.sh | sh
fi
# Under WSL there's usually no systemd as PID 1, so the tailscaled systemd service
# the installer registers never starts. Start the daemon manually instead, then
# `sudo tailscale up`. (This foreground-less daemon does not survive a WSL restart;
# re-run it, or enable systemd in /etc/wsl.conf, after each `wsl --shutdown`.)
if grep -qiE "microsoft|wsl" /proc/sys/kernel/osrelease 2>/dev/null; then
    printf "\r  [ \033[00;34m..\033[0m ] WSL detected — no systemd; start the daemon manually:\n"
    printf "        sudo tailscaled > /dev/null 2>&1 &\n"
    printf "        sudo tailscale up\n"
else
    printf "\r  [ \033[00;34m..\033[0m ] Tailscale installed. Connect with: sudo tailscale up\n"
fi

bash -c "$(curl -fsSL https://raw.githubusercontent.com/weitingchou/dotfiles/master/scripts/install_dotfiles.sh)" "ubuntu"
