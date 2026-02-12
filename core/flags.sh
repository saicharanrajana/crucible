#!/bin/bash

# Crucible - CLI Flags Module
# Parses command-line arguments and sets global configuration variables
# All flags are optional and have sensible defaults

# Initialize all flag variables with defaults
# These control which parts of the setup are executed

# Platform selection
PLATFORM=""           # auto-detect by default
DISTRO=""             # auto-detect by default

# Skip flags - set to true to skip specific modules
SKIP_REPOS=false      # Skip repository setup (RPM Fusion, Terra, AUR, etc.)
SKIP_PACKAGES=false   # Skip all package installation
SKIP_DESKTOP=false    # Skip desktop environment setup
SKIP_FLATPAK=false    # Skip flatpak applications
SKIP_DOCKER=false     # Skip docker setup
SKIP_DOTFILES=false   # Skip dotfiles setup
SKIP_GIT=false        # Skip git/ssh configuration

# Desktop environment selection
DESKTOP_ENV="gnome"   # Default desktop environment
                      # Set to "none" to skip DE setup

# Package categories to skip (comma-separated list)
# e.g., --skip-package-groups=desktop,media
SKIP_PACKAGE_GROUPS=""

# Minimal mode - only essential packages
MINIMAL=false

# Print help message
print_help() {
    cat << 'EOF'
Crucible - Universal System Setup Manager

Usage: ./run.sh [OPTIONS]

Platform Selection:
  --platform=PLATFORM       Specify platform (linux, macos)
  --distro=DISTRO          Specify Linux distribution (arch, fedora)

Desktop Environment:
  --desktop=DE             Set desktop environment (gnome, none)
  --no-desktop             Skip desktop environment setup

Skip Modules:
  --skip-repos             Skip repository configuration
  --skip-packages          Skip all package installation
  --skip-packages=GROUPS   Skip specific package groups (comma-separated)
  --skip-desktop           Skip desktop environment configuration
  --skip-flatpak           Skip flatpak application installation
  --skip-docker            Skip docker setup
  --skip-dotfiles          Skip dotfiles clone and stow
  --skip-git               Skip git and SSH key setup

Modes:
  --minimal                Minimal setup (essential packages only)
  --dev-only              Alias for --minimal (deprecated, use --minimal)

Other:
  -h, --help              Show this help message
  -v, --verbose           Enable verbose output
  --debug                 Enable debug output

Examples:
  ./run.sh                                    # Full setup (auto-detect)
  ./run.sh --distro=fedora                    # Force Fedora setup
  ./run.sh --minimal                          # Essential packages only
  ./run.sh --no-desktop                       # Skip GNOME setup
  ./run.sh --skip-packages=desktop,media      # Skip specific groups
  ./run.sh --skip-docker --skip-flatpak       # Skip docker and flatpak

EOF
}

# Parse command-line arguments
# Populates global flag variables
parse_flags() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            # Platform selection
            --platform=*)
                PLATFORM="${1#*=}"
                shift
                ;;
            --distro=*)
                DISTRO="${1#*=}"
                shift
                ;;
            
            # Desktop environment
            --desktop=*)
                DESKTOP_ENV="${1#*=}"
                shift
                ;;
            --no-desktop)
                DESKTOP_ENV="none"
                shift
                ;;
            
            # Skip flags
            --skip-repos)
                SKIP_REPOS=true
                shift
                ;;
            --skip-packages)
                SKIP_PACKAGES=true
                shift
                ;;
            --skip-packages=*)
                SKIP_PACKAGE_GROUPS="${1#*=}"
                SKIP_PACKAGES=true
                shift
                ;;
            --skip-desktop)
                SKIP_DESKTOP=true
                shift
                ;;
            --skip-flatpak)
                SKIP_FLATPAK=true
                shift
                ;;
            --skip-docker)
                SKIP_DOCKER=true
                shift
                ;;
            --skip-dotfiles)
                SKIP_DOTFILES=true
                shift
                ;;
            --skip-git)
                SKIP_GIT=true
                shift
                ;;
            --skip-git-setup)
                # Legacy alias
                SKIP_GIT=true
                shift
                ;;
            
            # Modes
            --minimal|--dev-only)
                MINIMAL=true
                shift
                ;;
            
            # Help
            -h|--help)
                print_help
                exit 0
                ;;
            
            # Debug/verbose
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            --debug)
                DEBUG=true
                shift
                ;;
            
            # Unknown option
            *)
                log_error "Unknown option: $1"
                print_help
                exit 1
                ;;
        esac
    done
    
    # Export all variables
    export PLATFORM DISTRO DESKTOP_ENV
    export SKIP_REPOS SKIP_PACKAGES SKIP_DESKTOP
    export SKIP_FLATPAK SKIP_DOCKER SKIP_DOTFILES SKIP_GIT
    export SKIP_PACKAGE_GROUPS MINIMAL VERBOSE DEBUG
}

# Export the parse function
export -f parse_flags
export -f print_help
