#!/usr/bin/env bash
set -e

echo "Setting up Docker (Arch Linux)..."

# Install Docker if missing
if ! command -v docker >/dev/null 2>&1; then
  echo "Docker not found. Installing..."
  sudo pacman -S --needed --noconfirm docker
fi

# Docker daemon config
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json >/dev/null <<'EOF'
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "5"
  }
}
EOF

# Enable and start Docker
sudo systemctl enable --now docker

# Verify Docker is running
if ! systemctl is-active --quiet docker; then
  echo "WARNING: Docker service failed to start"
  exit 1
fi

# Add user to docker group
ACTUAL_USER="${SUDO_USER:-$USER}"
if ! groups "$ACTUAL_USER" | grep -q docker; then
  sudo usermod -aG docker "$ACTUAL_USER"
  echo "Added $ACTUAL_USER to docker group (log out/in required)"
fi

echo "Docker setup complete."

