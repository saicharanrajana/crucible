#!/bin/bash

# Crucible - Fedora Repository Setup Module
# Configures third-party repositories for Fedora
# Includes: RPM Fusion (free/non-free), Terra, and Flatpak

# Setup RPM Fusion repositories
# RPM Fusion provides additional software not included in Fedora by default
# We enable both free (open source) and non-free repositories
setup_rpmfusion() {
    log_info "Setting up RPM Fusion repositories..."
    
    # Check if RPM Fusion is already enabled
    if dnf repolist | grep -q "rpmfusion-free"; then
        log_info "RPM Fusion already enabled"
        return 0
    fi
    
    # Get Fedora version
    local fedora_version
    fedora_version=$(rpm -E %fedora)
    
    # Install RPM Fusion free repository
    log_info "Enabling RPM Fusion Free repository..."
    sudo dnf install -y \
        "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${fedora_version}.noarch.rpm"
    
    # Install RPM Fusion non-free repository
    log_info "Enabling RPM Fusion Non-Free repository..."
    sudo dnf install -y \
        "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${fedora_version}.noarch.rpm"
    
    # Update package cache after adding repos
    log_info "Updating package cache..."
    sudo dnf makecache
    
    log_success "RPM Fusion repositories enabled"
}

# Setup Terra repository
# Terra is a third-party repository that packages software like Ghostty, Helium browser
# and JetBrains Mono Nerd Fonts for Fedora
setup_terra() {
    log_info "Setting up Terra repository..."
    
    # Check if Terra is already enabled
    if dnf repolist | grep -q "terra"; then
        log_info "Terra repository already enabled"
        return 0
    fi
    
    # Add Terra repository
    # Terra is maintained by Fyra Labs and provides cutting-edge packages
    log_info "Adding Terra repository..."
    sudo dnf install -y terra-release
    
    # Alternative: Manual repo file installation if terra-release not available
    # This creates the repo file directly
    if ! dnf repolist | grep -q "terra"; then
        log_info "Installing Terra repository manually..."
        sudo tee /etc/yum.repos.d/terra.repo > /dev/null << 'EOF'
[terra]
name=Terra
baseurl=https://repos.fyralabs.com/terra$releasever
enabled=1
gpgcheck=1
gpgkey=https://repos.fyralabs.com/terra$releasever/key.asc
EOF
    fi
    
    log_success "Terra repository enabled"
}

# Configure Flatpak repositories
# Fedora comes with its own flatpak repo by default, but we replace it with
# the official Flathub repository for a broader selection of applications
setup_flatpak_repos() {
    log_info "Configuring Flatpak repositories..."
    
    # Check if flatpak is installed
    if ! command_exists flatpak; then
        log_info "Installing flatpak..."
        sudo dnf install -y flatpak
    fi
    
    # Remove Fedora's default flatpak remote (optional)
    # This ensures we use the official Flathub instead
    if flatpak remotes | grep -q "fedora"; then
        log_info "Removing Fedora flatpak remote..."
        sudo flatpak remote-delete fedora --force || true
    fi
    
    # Add Flathub repository (official Flatpak repository)
    if ! flatpak remotes | grep -q "flathub"; then
        log_info "Adding Flathub repository..."
        sudo flatpak remote-add --if-not-exists flathub \
            https://flathub.org/repo/flathub.flatpakrepo
    else
        log_info "Flathub already configured"
    fi
    
    log_success "Flatpak repositories configured"
}

# Export functions
export -f setup_rpmfusion
export -f setup_terra
export -f setup_flatpak_repos
