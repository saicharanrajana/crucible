#!/bin/bash

# Crucible - Fedora Package Installation Module
# Provides functions for installing packages using dnf
# This module is sourced by setup.sh and provides dnf-specific implementations

# Install packages using dnf
# Handles batch installation with proper error checking
# Arguments:
#   $@ - List of package names to install
install_packages() {
    local packages=("$@")
    dnf_install "${packages[@]}"
}

# Check if a DNF group is installed
# Useful for checking if package groups like "Development Tools" are installed
# Arguments:
#   $1 - Group name
# Returns: 0 if installed, 1 otherwise
dnf_group_installed() {
    local group="$1"
    dnf group list --installed | grep -q "$group"
}

# Install a DNF group
# Used for installing package groups like "Development Tools"
# Arguments:
#   $1 - Group name
dnf_install_group() {
    local group="$1"
    
    if dnf_group_installed "$group"; then
        log_info "Group '$group' already installed"
        return 0
    fi
    
    log_info "Installing group: $group"
    if sudo dnf groupinstall -y "$group"; then
        log_success "Successfully installed group: $group"
    else
        log_error "Failed to install group: $group"
        return 1
    fi
}

# Remove packages using dnf
# Arguments:
#   $@ - List of package names to remove
dnf_remove() {
    local packages=("$@")
    
    log_info "Removing packages: ${packages[*]}"
    if sudo dnf remove -y "${packages[@]}"; then
        log_success "Successfully removed packages"
    else
        log_warn "Some packages could not be removed"
    fi
}

# Search for packages in DNF repositories
# Useful for finding the correct package name
# Arguments:
#   $1 - Search term
dnf_search() {
    local term="$1"
    log_info "Searching for packages matching: $term"
    dnf search "$term"
}

# Export functions
export -f install_packages
export -f dnf_group_installed
export -f dnf_install_group
export -f dnf_remove
export -f dnf_search
