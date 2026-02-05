#!/bin/bash

# Check if flatpak is installed, install it if not
if ! command -v flatpak &> /dev/null; then
  echo "Flatpak not found. Installing..."
  sudo pacman -S --needed --noconfirm flatpak
fi

FLATPAKS=(
  "org.onlyoffice.desktopeditors"
  "io.github.diegopvlk.Cine"
  "org.qbittorrent.qBittorrent"
  "us.zoom.Zoom"
)

for pak in "${FLATPAKS[@]}"; do
  if ! flatpak list | grep -i "$pak" &> /dev/null; then
    echo "Installing Flatpak: $pak"
    flatpak install --noninteractive "$pak"
  else
    echo "Flatpak already installed: $pak"
  fi
done
