#!/bin/bash
# ABOUTME: Base VM setup script for Lima devbox
# ABOUTME: Installs system packages, configures git, and sets up bash_profile for SSH

set -euo pipefail

GIT_NAME="${1:-}"
GIT_EMAIL="${2:-}"

echo "==> Updating package lists..."
sudo apt-get update

echo "==> Upgrading existing packages..."
sudo apt-get upgrade -y

echo "==> Installing essential packages..."
sudo apt-get install -y \
    build-essential \
    ca-certificates \
    ccze \
    curl \
    git \
    htop \
    iotop \
    jq \
    libssl-dev \
    pkg-config \
    screen \
    smem \
    sysstat \
    tree \
    unzip \
    vim \
    wget

echo "==> Creating .bash_profile for SSH sessions..."
echo 'if [ -f ~/.bashrc ]; then . ~/.bashrc; fi' >> ~/.bash_profile

echo "==> Configuring git..."
if [[ -n "$GIT_NAME" ]]; then
    git config --global user.name "$GIT_NAME"
    echo "    Set git user.name to: $GIT_NAME"
fi

if [[ -n "$GIT_EMAIL" ]]; then
    git config --global user.email "$GIT_EMAIL"
    echo "    Set git user.email to: $GIT_EMAIL"
fi

# Set sensible git defaults
git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global core.editor vim
git config --global core.untrackedCache false

echo "==> Base setup complete!"
