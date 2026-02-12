#!/bin/bash

# Crucible - Fedora Platform Setup Module
# Main orchestration for Fedora Linux systems
# Handles repository setup, package installation, and system configuration

# Import Fedora-specific sub-modules
source "$CRUCIBLE_ROOT/platforms/linux/fedora/repos.sh"
source "$CRUCIBLE_ROOT/platforms/linux/fedora/packages.sh"

# Main setup function for Fedora
# Called by core/main.sh to execute Fedora-specific setup
platform_setup_repos() {
    log_info "Setting up Fedora repositories..."
    
    # Update system first
    log_info "Updating system packages..."
    sudo dnf upgrade --refresh -y
    
    # Setup RPM Fusion repositories
    setup_rpmfusion
    
    # Setup Terra repository
    setup_terra
    
    # Configure flatpak
    setup_flatpak_repos
}

# Install all packages for Fedora
# Reads from config/packages/fedora.conf
platform_install_packages() {
    log_info "Installing Fedora packages..."
    
    # Load package definitions
    source "$CRUCIBLE_ROOT/config/packages/fedora.conf"
    
    # Install packages by category
    # Categories can be skipped with --skip-packages=category
    
    # System utilities
    if ! should_skip_package_group "system"; then
        log_info "Installing system utilities..."
        dnf_install "${FEDORA_SYSTEM_UTILS[@]}"
    else
        log_skip "Skipping system utilities (--skip-packages=system)"
    fi
    
    # Development tools
    if ! should_skip_package_group "dev"; then
        log_info "Installing development tools..."
        dnf_install "${FEDORA_DEV_TOOLS[@]}"
    else
        log_skip "Skipping development tools (--skip-packages=dev)"
    fi
    
    # Desktop packages
    if [[ "$MINIMAL" != true ]] && ! should_skip_package_group "desktop"; then
        if [[ "$DESKTOP_ENV" != "none" ]]; then
            log_info "Installing desktop packages..."
            dnf_install "${FEDORA_DESKTOP[@]}"
        fi
    else
        log_skip "Skipping desktop packages"
    fi
    
    # Media packages
    if [[ "$MINIMAL" != true ]] && ! should_skip_package_group "media"; then
        log_info "Installing media packages..."
        dnf_install "${FEDORA_MEDIA[@]}"
    else
        log_skip "Skipping media packages"
    fi
    
    # Fonts
    if [[ "$MINIMAL" != true ]] && ! should_skip_package_group "fonts"; then
        log_info "Installing fonts..."
        dnf_install "${FEDORA_FONTS[@]}"
    else
        log_skip "Skipping fonts"
    fi
}

# Override the generic is_package_installed for Fedora
# Uses dnf list installed to check package status
# Arguments:
#   $1 - Package name
# Returns: 0 if installed, 1 otherwise
is_package_installed() {
    local pkg="$1"
    dnf list installed "$pkg" &> /dev/null
}

# Override the generic install_packages for Fedora
# Uses dnf install with proper error handling
# Arguments:
#   $@ - List of package names to install
dnf_install() {
    local packages=("$@")
    local to_install=()
    
    # Filter out already installed packages
    for pkg in "${packages[@]}"; do
        if ! is_package_installed "$pkg"; then
            to_install+=("$pkg")
        fi
    done
    
    if [[ ${#to_install[@]} -eq 0 ]]; then
        log_success "All packages already installed"
        return 0
    fi
    
    log_info "Installing: ${to_install[*]}"
    
    # Install packages with dnf
    if sudo dnf install -y "${to_install[@]}"; then
        log_success "Successfully installed packages"
    else
        log_error "Failed to install some packages"
        return 1
    fi
}

# Export platform-specific functions
export -f platform_setup_repos
export -f platform_install_packages
export -f is_package_installed
export -f dnf_install
