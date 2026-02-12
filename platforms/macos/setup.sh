#!/bin/bash

# Crucible - macOS Platform Setup Module
# Main orchestration for macOS systems
# Handles Homebrew setup, package installation, and system configuration

# Import macOS-specific sub-modules
source "$CRUCIBLE_ROOT/platforms/macos/brew.sh"

# Main setup function for macOS
# Called by core/main.sh to execute macOS-specific setup
platform_setup_repos() {
    log_info "Setting up macOS package manager (Homebrew)..."
    
    # Setup Homebrew if not already installed
    setup_homebrew
}

# Install all packages for macOS
# Reads from config/packages/macos.conf
platform_install_packages() {
    log_info "Installing macOS packages..."
    
    # Load package definitions
    source "$CRUCIBLE_ROOT/config/packages/macos.conf"
    
    # Ensure Homebrew is available
    if ! command_exists brew; then
        log_error "Homebrew is not available. Cannot install packages."
        return 1
    fi
    
    # Update Homebrew
    log_info "Updating Homebrew..."
    brew update
    
    # Install packages by category
    
    # System utilities
    if ! should_skip_package_group "system"; then
        log_info "Installing system utilities..."
        brew_install "${MACOS_SYSTEM_UTILS[@]}"
    else
        log_skip "Skipping system utilities"
    fi
    
    # Development tools
    if ! should_skip_package_group "dev"; then
        log_info "Installing development tools..."
        brew_install "${MACOS_DEV_TOOLS[@]}"
    else
        log_skip "Skipping development tools"
    fi
    
    # Desktop applications (casks)
    if [[ "$MINIMAL" != true ]] && ! should_skip_package_group "desktop"; then
        log_info "Installing desktop applications..."
        brew_cask_install "${MACOS_DESKTOP[@]}"
    else
        log_skip "Skipping desktop applications"
    fi
    
    # Media applications
    if [[ "$MINIMAL" != true ]] && ! should_skip_package_group "media"; then
        log_info "Installing media applications..."
        brew_cask_install "${MACOS_MEDIA[@]}"
    else
        log_skip "Skipping media applications"
    fi
    
    # Fonts (using homebrew-cask-fonts)
    if [[ "$MINIMAL" != true ]] && ! should_skip_package_group "fonts"; then
        log_info "Installing fonts..."
        brew_tap "homebrew/cask-fonts"
        brew_cask_install "${MACOS_FONTS[@]}"
    else
        log_skip "Skipping fonts"
    fi
}

# Override the generic is_package_installed for macOS
# Uses brew list to check if a package/formula is installed
# Arguments:
#   $1 - Package name (formula)
# Returns: 0 if installed, 1 otherwise
is_package_installed() {
    local pkg="$1"
    brew list "$pkg" &> /dev/null
}

# Check if a Homebrew cask is installed
# Arguments:
#   $1 - Cask name
# Returns: 0 if installed, 1 otherwise
is_cask_installed() {
    local cask="$1"
    brew list --cask "$cask" &> /dev/null
}

# Export platform-specific functions
export -f platform_setup_repos
export -f platform_install_packages
export -f is_package_installed
export -f is_cask_installed
