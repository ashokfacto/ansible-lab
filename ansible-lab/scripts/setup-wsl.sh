#!/usr/bin/env bash
# Installs Ansible + helpers inside WSL2 Ubuntu. Run:  bash scripts/setup-wsl.sh
set -euo pipefail
echo ">> Updating apt and installing prerequisites"
sudo apt-get update -y
sudo apt-get install -y pipx python3-venv sshpass openssh-client git
pipx ensurepath
export PATH="$HOME/.local/bin:$PATH"
echo ">> Installing Ansible (full package, includes collections like ansible.posix)"
pipx install --include-deps ansible || pipx upgrade --include-injected ansible
echo ">> Installing ansible-lint"
pipx install ansible-lint || true
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
  echo ">> Creating an SSH key pair for the lab"
  mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
  ssh-keygen -t ed25519 -f "$HOME/.ssh/id_ed25519" -N "" -C "ansible-lab"
fi
echo ">> Versions"
ansible --version | head -1
ansible-lint --version 2>/dev/null | head -1 || true
docker --version 2>/dev/null || echo "!! docker not found in WSL - enable WSL integration in Docker Desktop (Settings > Resources > WSL integration)"
echo ">> Done. Open a NEW terminal (or run: source ~/.bashrc) so PATH changes apply."
