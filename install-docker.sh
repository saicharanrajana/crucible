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

# Add user to docker group
if ! groups "$USER" | grep -q docker; then
  sudo usermod -aG docker "$USER"
  echo "Added $USER to docker group (log out/in required)"
fi

echo "Docker setup complete."

