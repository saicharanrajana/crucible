#!/bin/bash

# Crucible - Arch Linux Platform Setup Module
# Main orchestration for Arch Linux systems
# Handles repository setup (AUR), package installation, and system configuration

# Import Arch-specific sub-modules
source "$CRUCIBLE_ROOT/platforms/linux/arch/repos.sh"
source "$CRUCIBLE_ROOT/platforms/linux/arch/packages.sh"

# Main setup function for Arch
# Called by core/main.sh to execute Arch-specific setup
platform_setup_repos() {
    log_info "Setting up Arch Linux repositories..."
    
    # Update system first
    log_info "Updating system packages..."
    sudo pacman -Syu --noconfirm
    
    # Setup AUR helper (yay)
    setup_aur_helper
}

# Install all packages for Arch
# Reads from config/packages/arch.conf
platform_install_packages() {
    log_info "Installing Arch packages..."
    
    # Load package definitions
    source "$CRUCIBLE_ROOT/config/packages/arch.conf"
    
    # Install packages by category
    # Categories can be skipped with --skip-packages=category
    
    # System utilities (includes some AUR packages)
    if ! should_skip_package_group "system"; then
        log_info "Installing system utilities..."
        pacman_install "${ARCH_SYSTEM_UTILS[@]}"
        yay_install "${ARCH_SYSTEM_UTILS_AUR[@]}"
    else
        log_skip "Skipping system utilities (--skip-packages=system)"
    fi
    
    # Development tools
    if ! should_skip_package_group "dev"; then
        log_info "Installing development tools..."
        pacman_install "${ARCH_DEV_TOOLS[@]}"
        yay_install "${ARCH_DEV_TOOLS_AUR[@]}"
    else
        log_skip "Skipping development tools (--skip-packages=dev)"
    fi
    
    # Desktop packages
    if [[ "$MINIMAL" != true ]] && ! should_skip_package_group "desktop"; then
        if [[ "$DESKTOP_ENV" != "none" ]]; then
            log_info "Installing desktop packages..."
            pacman_install "${ARCH_DESKTOP[@]}"
            yay_install "${ARCH_DESKTOP_AUR[@]}"
        fi
    else
        log_skip "Skipping desktop packages"
    fi
    
    # Media packages
    if [[ "$MINIMAL" != true ]] && ! should_skip_package_group "media"; then
        log_info "Installing media packages..."
        pacman_install "${ARCH_MEDIA[@]}"
    else
        log_skip "Skipping media packages"
    fi
    
    # Fonts
    if [[ "$MINIMAL" != true ]] && ! should_skip_package_group "fonts"; then
        log_info "Installing fonts..."
        pacman_install "${ARCH_FONTS[@]}"
        yay_install "${ARCH_FONTS_AUR[@]}"
    else
        log_skip "Skipping fonts"
    fi
}

# Override the generic is_package_installed for Arch
# Checks both official repos (pacman) and AUR (yay)
# Arguments:
#   $1 - Package name
# Returns: 0 if installed, 1 otherwise
is_package_installed() {
    local pkg="$1"
    pacman -Qi "$pkg" &> /dev/null || pacman -Qg "$pkg" &> /dev/null
}

# Override the generic install_packages for Arch
# Uses pacman for official repo packages
# Arguments:
#   $@ - List of package names to install
install_packages() {
    local packages=("$@")
    pacman_install "${packages[@]}"
}

# Export platform-specific functions
export -f platform_setup_repos
export -f platform_install_packages
export -f is_package_installed
export -f install_packages
