#!/bin/bash

# Crucible - Linux Distribution Detection Module
# Detects which Linux distribution is running
# Used to determine which package manager and setup scripts to use

# Detect the Linux distribution
# Sets the global DISTRO variable
# Priority: CLI flag > /etc/os-release > fallback methods
detect_distro() {
    # If DISTRO is already set (via CLI flag), use that
    if [[ -n "${DISTRO:-}" ]]; then
        log_debug "Using user-specified distribution: $DISTRO"
        return 0
    fi
    
    # Try to read from /etc/os-release (standard on most modern distros)
    if [[ -f /etc/os-release ]]; then
        # Extract ID field from os-release
        local os_id
        os_id=$(source /etc/os-release && echo "$ID")
        
        case "$os_id" in
            "arch"|"archlinux")
                DISTRO="arch"
                log_debug "Detected distribution: Arch Linux"
                ;;
            "fedora")
                DISTRO="fedora"
                log_debug "Detected distribution: Fedora"
                ;;
            "debian"|"ubuntu")
                DISTRO="debian"
                log_debug "Detected distribution: Debian/Ubuntu (basic support)"
                ;;
            *)
                log_warn "Unknown distribution: $os_id"
                log_info "Attempting to use generic Linux setup..."
                DISTRO="unknown"
                ;;
        esac
    else
        # Fallback: check for specific files
        if [[ -f /etc/arch-release ]]; then
            DISTRO="arch"
            log_debug "Detected distribution: Arch Linux (fallback)"
        elif [[ -f /etc/fedora-release ]]; then
            DISTRO="fedora"
            log_debug "Detected distribution: Fedora (fallback)"
        else
            log_error "Cannot detect Linux distribution"
            log_info "Please specify with --distro=DISTRO"
            exit 1
        fi
    fi
    
    # Validate distro support
    validate_distro_support
}

# Validate that the detected/specified distro is supported
validate_distro_support() {
    case "$DISTRO" in
        "arch"|"fedora"|"debian")
            return 0
            ;;
        "unknown")
            log_warn "Unknown distribution - some features may not work"
            ;;
        *)
            log_error "Invalid distribution specified: $DISTRO"
            log_info "Supported distributions: arch, fedora"
            exit 1
            ;;
    esac
}

# Export functions
export -f detect_distro
export -f validate_distro_support
