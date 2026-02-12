#!/bin/bash

# Crucible - GNOME Extensions Module
# Installs and configures GNOME Shell extensions
# Extensions enhance GNOME with tiling features and productivity tools

# Get script directory
SCRIPT_DIR="${GNOME_ENV_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"

# Install required dependencies for extension management
install_extension_dependencies() {
    log_info "Installing extension management dependencies..."
    
    if [[ "$DISTRO" == "arch" ]]; then
        sudo pacman -S --noconfirm python-pipx gnome-shell-extensions
    elif [[ "$DISTRO" == "fedora" ]]; then
        sudo dnf install -y pipx gnome-shell-extension-tool
    fi
}

# Install gnome-extensions-cli (gext)
# This tool allows installing extensions from the command line
install_gext() {
    if ! command_exists ~/.local/bin/gext; then
        log_info "Installing gnome-extensions-cli..."
        pipx install gnome-extensions-cli --system-site-packages
    else
        log_info "gnome-extensions-cli already installed"
    fi
}

# Main extension installation
echo "Setting up GNOME extensions..."

# Install dependencies
install_extension_dependencies
install_gext

# Array of extensions to install
# Each extension is identified by its UUID from extensions.gnome.org
EXTENSIONS=(
    "tactile@lundal.io"                          # Window tiling manager
    "lockkeys@vaina.lt"                          # Show Caps/Num lock status
    "no-overview@fthx"                           # Disable overview on startup
    "dock-ng@ochi12.github.com"                  # Enhanced dock
    "windowIsReady_Remover@nunofarruca@gmail.com" # Remove "Window is Ready" notifications
    "rounded-window-corners@fxgn"                # Rounded corners for all windows
    "AlphabeticalAppGrid@stuarthayhurst"         # Sort app grid alphabetically
    "vertical-app-grid@lublst.github.io"         # Vertical app grid layout
    "pinned-apps-in-appgrid@brunosilva.io"       # Pin apps in app grid
    "legacyschemeautoswitcher@joshimukul29.gmail.com" # Auto-switch color schemes
    "gnome-ui-tune@itstime.tech"                 # UI tweaks and adjustments
    "touchpad-gesture-customization@coooolapps.com" # Custom touchpad gestures
    "space-bar@luchrioh"                         # Workspace indicator in top bar
    "tophat@fflewddur.github.io"                 # System monitor in top bar
)

# Install each extension
for ext in "${EXTENSIONS[@]}"; do
    if ! ~/.local/bin/gext list | grep "$ext" &> /dev/null; then
        echo "Installing extension: $ext"
        ~/.local/bin/gext install "$ext" || log_warn "Failed to install $ext"
    else
        echo "Extension already installed: $ext"
    fi
done

echo "GNOME extensions setup complete!"
echo "Note: You may need to log out and back in for all extensions to activate."
