#!/bin/bash

# Crucible - Platform Detection Module
# Handles automatic detection of the operating system platform
# Can be overridden by CLI flags for testing or specific use cases

# Detect the current platform (linux or macos)
# Sets the global PLATFORM variable
# Priority: CLI flag > auto-detection
detect_platform() {
    # If PLATFORM is already set (via CLI flag), use that
    if [[ -n "${PLATFORM:-}" ]]; then
        log_debug "Using user-specified platform: $PLATFORM"
    else
        # Auto-detect platform
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            PLATFORM="linux"
            log_debug "Auto-detected platform: Linux"
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            PLATFORM="macos"
            log_debug "Auto-detected platform: macOS"
        else
            log_error "Unsupported operating system: $OSTYPE"
            log_info "Crucible currently supports Linux and macOS"
            exit 1
        fi
    fi
    
    # For Linux, also detect the distribution
    if [[ "$PLATFORM" == "linux" ]]; then
        detect_distro
    fi
    
    # Validate platform support
    validate_platform_support
}

# Validate that the detected/specified platform is supported
validate_platform_support() {
    case "$PLATFORM" in
        "linux"|"macos")
            return 0
            ;;
        *)
            log_error "Invalid platform specified: $PLATFORM"
            log_info "Supported platforms: linux, macos"
            exit 1
            ;;
    esac
}

# Export the detect_platform function
export -f detect_platform
export -f validate_platform_support
