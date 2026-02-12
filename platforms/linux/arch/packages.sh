#!/bin/bash

# Crucible - Arch Linux Package Installation Module
# Provides functions for installing packages using pacman and yay
# This module is sourced by setup.sh and provides pacman/yay-specific implementations

# Install packages from official repositories using pacman
# Arguments:
#   $@ - List of package names to install
pacman_install() {
    local packages=("$@")
    
    # Filter out empty entries
    packages=($(echo "${packages[@]}" | tr ' ' '\n' | grep -v '^$' | tr '\n' ' '))
    
    if [[ ${#packages[@]} -eq 0 ]]; then
        return 0
    fi
    
    local to_install=()
    
    # Filter out already installed packages
    for pkg in "${packages[@]}"; do
        if ! pacman -Qi "$pkg" &> /dev/null && ! pacman -Qg "$pkg" &> /dev/null; then
            to_install+=("$pkg")
        fi
    done
    
    if [[ ${#to_install[@]} -eq 0 ]]; then
        log_success "All official packages already installed"
        return 0
    fi
    
    log_info "Installing (pacman): ${to_install[*]}"
    
    if sudo pacman -S --noconfirm "${to_install[@]}"; then
        log_success "Successfully installed packages"
    else
        log_error "Failed to install some packages"
        return 1
    fi
}

# Install packages from AUR using yay
# Arguments:
#   $@ - List of AUR package names to install
yay_install() {
    local packages=("$@")
    
    # Filter out empty entries
    packages=($(echo "${packages[@]}" | tr ' ' '\n' | grep -v '^$' | tr '\n' ' '))
    
    if [[ ${#packages[@]} -eq 0 ]]; then
        return 0
    fi
    
    # Ensure yay is available
    if ! command_exists yay; then
        log_error "yay is not installed. Cannot install AUR packages."
        return 1
    fi
    
    local to_install=()
    
    # Filter out already installed packages
    for pkg in "${packages[@]}"; do
        if ! pacman -Qi "$pkg" &> /dev/null; then
            to_install+=("$pkg")
        fi
    done
    
    if [[ ${#to_install[@]} -eq 0 ]]; then
        log_success "All AUR packages already installed"
        return 0
    fi
    
    log_info "Installing (AUR): ${to_install[*]}"
    
    if yay -S --noconfirm "${to_install[@]}"; then
        log_success "Successfully installed AUR packages"
    else
        log_error "Failed to install some AUR packages"
        return 1
    fi
}

# Install package group using pacman
# Arguments:
#   $1 - Group name (e.g., "base-devel")
pacman_install_group() {
    local group="$1"
    
    if pacman -Qg "$group" &> /dev/null; then
        log_info "Group '$group' already installed"
        return 0
    fi
    
    log_info "Installing group: $group"
    if sudo pacman -S --noconfirm "$group"; then
        log_success "Successfully installed group: $group"
    else
        log_error "Failed to install group: $group"
        return 1
    fi
}

# Remove packages using pacman
# Arguments:
#   $@ - List of package names to remove
pacman_remove() {
    local packages=("$@")
    
    log_info "Removing packages: ${packages[*]}"
    if sudo pacman -R --noconfirm "${packages[@]}"; then
        log_success "Successfully removed packages"
    else
        log_warn "Some packages could not be removed"
    fi
}

# Export functions
export -f pacman_install
export -f yay_install
export -f pacman_install_group
export -f pacman_remove
