#!/usr/bin/env bash
set -euo pipefail

# Installs Ansible on Arch/Manjaro using pacman. Adds some common helpers.
# Run: ./scripts/install-ansible-arch.sh

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root (it will use pacman). Try: sudo $0" >&2
  exit 1
fi

pacman -Sy --needed --noconfirm \
  ansible \
  python \
  python-pipx \
  git \
  curl \
  rsync

# Optional: install community.general collection (used by some playbooks)
# Using ansible-galaxy requires a non-root user; we temporarily allow root.
sudo -u "$SUDO_USER" ansible-galaxy collection install kewlfft.aur

echo "Ansible installed. Version: $(ansible --version | head -n1)"
