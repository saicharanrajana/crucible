#!/bin/bash

# Crucible - Flatpak Setup Module
# Installs Flatpak applications across Linux platforms
# Uses the flathub repository for cross-distro compatibility

setup_flatpak() {
    log_section "Flatpak Applications"
    
    # Flatpak is only available on Linux
    if [[ "$PLATFORM" != "linux" ]]; then
        log_info "Flatpak is not available on macOS. Skipping."
        return 0
    fi
    
    # Ensure flatpak is installed
    if ! command_exists flatpak; then
        log_info "Installing flatpak..."
        
        case "$DISTRO" in
            "arch")
                sudo pacman -S --noconfirm flatpak
                ;;
            "fedora")
                sudo dnf install -y flatpak
                ;;
            *)
                log_error "Flatpak installation not implemented for distro: $DISTRO"
                return 1
                ;;
        esac
    fi
    
    # Setup flathub repository (if not already configured)
    # This should have been done in repo setup, but we ensure it here
    if ! flatpak remotes | grep -q "flathub"; then
        log_info "Adding Flathub repository..."
        sudo flatpak remote-add --if-not-exists flathub \
            https://flathub.org/repo/flathub.flatpakrepo
    fi
    
    # Install configured flatpaks
    install_flatpaks
}

# Install flatpak applications
# Reads from FLATPAKS array defined below
install_flatpaks() {
    log_info "Installing flatpak applications..."
    
    # Array of flatpaks to install
    # These are applications that work better or are only available as flatpaks
    local FLATPAKS=(
        "org.onlyoffice.desktopeditors"      # Office suite
        "io.github.diegopvlk.Cine"           # Media player
        "org.qbittorrent.qBittorrent"        # Torrent client
        "us.zoom.Zoom"                       # Video conferencing
    )
    
    local installed=0
    local skipped=0
    
    for pak in "${FLATPAKS[@]}"; do
        if flatpak list | grep -i "$pak" &> /dev/null; then
            log_debug "Flatpak already installed: $pak"
            ((skipped++))
        else
            log_info "Installing: $pak"
            if flatpak install --noninteractive flathub "$pak"; then
                ((installed++))
            else
                log_warn "Failed to install: $pak"
            fi
        fi
    done
    
    log_success "Flatpaks installed: $installed, Skipped: $skipped"
}

# Run the setup
setup_flatpak
