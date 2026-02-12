#!/bin/bash

# Crucible - Universal System Setup Manager
# Main orchestration logic
# This file coordinates all setup operations across platforms

set -e

# Get the root directory (parent of this script's directory)
# This script is in core/, so we need to go up one level
CRUCIBLE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Source all core modules
source "$CRUCIBLE_ROOT/core/flags.sh"
source "$CRUCIBLE_ROOT/core/platform.sh"
source "$CRUCIBLE_ROOT/core/distro.sh"
source "$CRUCIBLE_ROOT/lib/utils.sh"

# Main setup function
# Coordinates the entire setup process based on detected/mandated platform
crucible_main() {
    print_logo
    
    # Step 1: Detect platform (or use user-specified)
    # Uses PLATFORM and DISTRO variables (can be set by CLI flags or auto-detected)
    detect_platform
    
    log_info "Starting Crucible setup..."
    log_info "Platform: $PLATFORM"
    if [[ "$PLATFORM" == "linux" ]]; then
        log_info "Distribution: $DISTRO"
    fi
    
    # Step 2: Load platform-specific setup module
    # Each platform module exports functions that handle their specific setup
    crucible_load_platform_module
    
    # Step 3: Execute setup based on user preferences
    # Skipped modules are controlled by CLI flags
    execute_setup
    
    log_success "Setup complete! You may want to reboot your system."
}

# Load the appropriate platform module
# Sources the setup.sh file for the detected platform
crucible_load_platform_module() {
    local module_path=""
    
    case "$PLATFORM" in
        "linux")
            case "$DISTRO" in
                "arch")
                    module_path="$CRUCIBLE_ROOT/platforms/linux/arch/setup.sh"
                    ;;
                "fedora")
                    module_path="$CRUCIBLE_ROOT/platforms/linux/fedora/setup.sh"
                    ;;
                *)
                    log_error "Unsupported Linux distribution: $DISTRO"
                    log_info "Currently supported: arch, fedora"
                    exit 1
                    ;;
            esac
            ;;
        "macos")
            module_path="$CRUCIBLE_ROOT/platforms/macos/setup.sh"
            ;;
        *)
            log_error "Unsupported platform: $PLATFORM"
            log_info "Currently supported: linux, macos"
            exit 1
            ;;
    esac
    
    if [[ -f "$module_path" ]]; then
        log_debug "Loading platform module: $module_path"
        source "$module_path"
    else
        log_error "Platform module not found: $module_path"
        exit 1
    fi
}

# Execute the full setup workflow
# Respects skip flags to conditionally run modules
execute_setup() {
    log_section "Repository Setup"
    if [[ "$SKIP_REPOS" != true ]]; then
        platform_setup_repos
    else
        log_skip "Skipping repository setup (--skip-repos)"
    fi
    
    log_section "Package Installation"
    if [[ "$SKIP_PACKAGES" != true ]]; then
        platform_install_packages
    else
        log_skip "Skipping package installation (--skip-packages)"
    fi
    
    log_section "Desktop Environment"
    if [[ "$SKIP_DESKTOP" != true ]]; then
        setup_desktop_environment
    else
        log_skip "Skipping desktop environment setup (--skip-desktop)"
    fi
    
    log_section "Common Modules"
    
    if [[ "$SKIP_FLATPAK" != true ]]; then
        run_module "flatpak" "$CRUCIBLE_ROOT/environments/common/flatpak.sh"
    else
        log_skip "Skipping flatpak installation (--skip-flatpak)"
    fi
    
    if [[ "$SKIP_DOCKER" != true ]]; then
        run_module "docker" "$CRUCIBLE_ROOT/environments/common/docker.sh"
    else
        log_skip "Skipping docker setup (--skip-docker)"
    fi
    
    if [[ "$SKIP_DOTFILES" != true ]]; then
        run_module "dotfiles" "$CRUCIBLE_ROOT/environments/common/dotfiles.sh"
    else
        log_skip "Skipping dotfiles setup (--skip-dotfiles)"
    fi
    
    if [[ "$SKIP_GIT" != true ]]; then
        run_module "git/ssh" "$CRUCIBLE_ROOT/environments/common/git.sh"
    else
        log_skip "Skipping git/ssh setup (--skip-git)"
    fi
}

# Setup desktop environment
# Currently only supports GNOME on Linux
setup_desktop_environment() {
    if [[ "$PLATFORM" == "macos" ]]; then
        log_info "Desktop environment setup not applicable on macOS"
        return 0
    fi
    
    case "$DESKTOP_ENV" in
        "gnome")
            log_info "Setting up GNOME desktop environment..."
            source "$CRUCIBLE_ROOT/environments/gnome/setup.sh"
            gnome_setup
            ;;
        "none")
            log_info "No desktop environment requested (--no-desktop)"
            ;;
        *)
            log_warn "Unknown desktop environment: $DESKTOP_ENV"
            log_info "Supported options: gnome"
            ;;
    esac
}

# Run a common module (dotfiles, docker, etc.)
# Arguments:
#   $1 - Module name (for logging)
#   $2 - Path to module script
run_module() {
    local module_name="$1"
    local module_path="$2"
    
    if [[ -f "$module_path" ]]; then
        log_info "Running $module_name module..."
        source "$module_path"
    else
        log_warn "Module not found: $module_path"
    fi
}

# Export functions for use in platform modules
export -f execute_setup
export -f setup_desktop_environment
export -f run_module
export CRUCIBLE_ROOT
