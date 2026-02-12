#!/bin/bash

# Crucible - GNOME Desktop Environment Setup Module
# Configures GNOME Shell with custom themes, extensions, and keybindings
# Only runs on Linux systems with GNOME

# Get script directory
GNOME_ENV_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Main GNOME setup function
# Called by core/main.sh when DESKTOP_ENV=gnome
gnome_setup() {
    log_section "GNOME Desktop Environment Setup"
    
    # Check if GNOME is installed
    if ! command_exists gnome-shell; then
        log_warn "GNOME Shell not detected. Skipping GNOME configuration."
        log_info "Install GNOME first: sudo dnf groupinstall "GNOME Desktop" (Fedora)"
        log_info "                         sudo pacman -S gnome (Arch)"
        return 0
    fi
    
    log_info "Configuring GNOME desktop environment..."
    
    # Install and configure themes
    gnome_setup_themes
    
    # Install extensions
    gnome_setup_extensions
    
    # Configure keyboard shortcuts
    gnome_setup_hotkeys
    
    # Configure general GNOME settings
    gnome_setup_settings
    
    log_success "GNOME configuration complete!"
}

# Setup themes and visual appearance
# Installs adw-gtk3 theme and Neuwaita icons
gnome_setup_themes() {
    log_info "Setting up GNOME theming..."
    
    # Source the config script
    source "$GNOME_ENV_DIR/config.sh"
}

# Setup GNOME extensions
# Installs tiling manager, window tweaks, and utility extensions
gnome_setup_extensions() {
    log_info "Installing GNOME extensions..."
    
    # Source the extensions script
    source "$GNOME_ENV_DIR/extensions.sh"
}

# Setup keyboard shortcuts
# Configures tiling shortcuts and custom keybindings
gnome_setup_hotkeys() {
    log_info "Configuring keyboard shortcuts..."
    
    # Source the hotkeys script
    source "$GNOME_ENV_DIR/hotkeys.sh"
}

# Setup general GNOME settings
# Configures behavior, workspace settings, etc.
gnome_setup_settings() {
    log_info "Configuring GNOME settings..."
    
    # Set dark mode
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    
    # Configure workspaces
    gsettings set org.gnome.desktop.wm.preferences num-workspaces 6
    gsettings set org.gnome.shell.app-switcher current-workspace-only true
    
    # Disable animations (optional - makes things snappier)
    # gsettings set org.gnome.desktop.interface enable-animations false
    
    # Configure lid close behavior
    if [[ "$PLATFORM" == "linux" ]]; then
        log_info "Configuring lid close behavior..."
        sudo mkdir -p /etc/systemd/logind.conf.d
        echo -e "[Login]\nHandleLidSwitch=ignore\nHandleLidSwitchExternalPower=ignore\nHandleLidSwitchDocked=ignore" | \
            sudo tee /etc/systemd/logind.conf.d/lid-ignore.conf >/dev/null
        sudo systemctl restart systemd-logind
    fi
}

# Export functions
export -f gnome_setup
export -f gnome_setup_themes
export -f gnome_setup_extensions
export -f gnome_setup_hotkeys
export -f gnome_setup_settings
export GNOME_ENV_DIR
