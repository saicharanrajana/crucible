#!/bin/bash

# Crucible - Arch Linux Repository Setup Module
# Configures AUR helper (yay) for Arch Linux
# Arch doesn't need additional repositories like Fedora, but AUR is essential

# Setup AUR helper (yay)
# yay is a popular AUR helper that wraps pacman with AUR support
# It's installed from the AUR itself (bootstrap process)
setup_aur_helper() {
    log_info "Setting up AUR helper (yay)..."
    
    # Check if yay is already installed
    if command_exists yay; then
        log_info "yay is already installed"
        return 0
    fi
    
    # Install dependencies needed to build yay
    log_info "Installing build dependencies..."
    sudo pacman -S --needed --noconfirm git base-devel
    
    # Clone and build yay
    local build_dir="/tmp/yay-build-$$"
    log_info "Cloning yay repository..."
    
    if ! git clone https://aur.archlinux.org/yay.git "$build_dir"; then
        log_error "Failed to clone yay repository"
        return 1
    fi
    
    # Build and install yay
    log_info "Building yay..."
    cd "$build_dir"
    if ! makepkg -si --noconfirm; then
        log_error "Failed to build yay"
        cd - > /dev/null
        rm -rf "$build_dir"
        return 1
    fi
    
    cd - > /dev/null
    rm -rf "$build_dir"
    
    log_success "yay installed successfully"
}

# Export functions
export -f setup_aur_helper
