#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source utils.sh from parent directory
source "$SCRIPT_DIR/../utils.sh"

echo "Setting up GNOME theming..."

# Install adw-gtk3 theme
echo "Installing adw-gtk3 theme..."
yay -S --needed --noconfirm adw-gtk-theme

# Set dark theme by default
echo "Setting dark theme..."
gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

# Configure flatpak override for themes
echo "Configuring flatpak theme override..."
sudo flatpak override --filesystem=xdg-data/themes
sudo flatpak mask org.gtk.Gtk3theme.adw-gtk3 || true
sudo flatpak mask org.gtk.Gtk3theme.adw-gtk3-dark || true

# Install Neuwaita icon pack
echo "Installing Neuwaita icon pack..."
NEUWAITA_DIR="$HOME/.local/share/icons/Neuwaita"

# Remove existing installation if present
if [ -d "$NEUWAITA_DIR" ]; then
  echo "Removing existing Neuwaita installation..."
  rm -rf "$NEUWAITA_DIR"
fi

# Clone fresh copy
mkdir -p "$HOME/.local/share/icons"
git clone --depth 1 https://github.com/RusticBard/Neuwaita.git "$NEUWAITA_DIR"

# Set Neuwaita as default icon theme
echo "Setting Neuwaita as default icon theme..."
gsettings set org.gnome.desktop.interface icon-theme 'Neuwaita'

# Set wallpaper if it exists
WALLPAPER_PATH="$SCRIPT_DIR/wallpaper.png"
if [ -f "$WALLPAPER_PATH" ]; then
  echo "Setting wallpaper..."
  gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER_PATH"
  gsettings set org.gnome.desktop.background picture-uri-dark "file://$WALLPAPER_PATH"
else
  echo "Warning: wallpaper.png not found in gnome/ folder"
fi

# Set default monospace font
echo "Setting JetBrains Mono Nerd Font as default monospace font..."
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font 11'

# Configure sleep and lid behavior
echo "Configuring sleep and lid behavior..."

# Configure systemd-logind to ignore lid close
sudo mkdir -p /etc/systemd/logind.conf.d
echo -e "[Login]\nHandleLidSwitch=ignore\nHandleLidSwitchExternalPower=ignore\nHandleLidSwitchDocked=ignore" | sudo tee /etc/systemd/logind.conf.d/lid-ignore.conf >/dev/null

# Restart systemd-logind to apply changes
sudo systemctl restart systemd-logind

echo "GNOME configuration complete!"
