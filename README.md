# Arch Linux System Crafting Tool

A simple setup script to get my Arch Linux system up and running with all the tools and configs I use.

## What it does

This script automates the boring stuff:

- Updates the system and installs `yay`
- Installs the required packages: dev tools, desktop environment, media, fonts
- Sets up GNOME with necessary extensions, hotkeys, themes, icons
- Configures [dotfiles](https://github.com/saicharanrajana/dotfiles) using stow
- Sets up Git and generates SSH keys
- Installs Docker and Flatpak apps

## Usage

```bash
# Full setup (recommended for fresh installs)
./run.sh

# Dev-only mode (just essentials, skips desktop stuff)
./run.sh --dev-only

# Skip git/SSH setup if it's already configured
./run.sh --skip-git-setup
```

## What's included

- **Desktop**: GNOME with adw-gtk3 theme, Neuwaita icons, custom hotkeys
- **Terminal**: Ghostty with starship prompt
- **Dev tools**: Neovim, tmux, lazygit, mise (for runtime versions management)
- **Fonts**: JetBrains Mono Nerd Font
- **Apps**: Firefox Developer Edition, MPV, Helium Browser, and more

## Structure

- `run.sh` - Main entry point
- `packages.conf` - Lists all packages to install
- `gnome/` - GNOME configuration scripts
- `utils.sh` - Helper functions
- Various `*-setup.sh` scripts for specific setups

## Requirements

- Arch Linux (obviously)
- Internet connection
- Run as regular user (script uses sudo when needed)

## Credits

Forked from [typecraft-dev/crucible](https://github.com/typecraft-dev/crucible) and customized to my liking.
