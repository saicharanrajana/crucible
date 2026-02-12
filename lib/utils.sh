#!/bin/bash

# Crucible - Utility Functions Library
# Shared utility functions used across all platform and environment modules
# All functions are platform-agnostic

# Color codes for terminal output
# These are only used if stdout is a terminal
if [[ -t 1 ]]; then
    readonly COLOR_RESET='\033[0m'
    readonly COLOR_RED='\033[0;31m'
    readonly COLOR_GREEN='\033[0;32m'
    readonly COLOR_YELLOW='\033[0;33m'
    readonly COLOR_BLUE='\033[0;34m'
    readonly COLOR_CYAN='\033[0;36m'
else
    readonly COLOR_RESET=''
    readonly COLOR_RED=''
    readonly COLOR_GREEN=''
    readonly COLOR_YELLOW=''
    readonly COLOR_BLUE=''
    readonly COLOR_CYAN=''
fi

# Print the Crucible ASCII logo
# Called at the start of the main script
print_logo() {
    # Only print logo on fresh start or verbose mode
    if [[ "${CRUCIBLE_LOGO_PRINTED:-}" != "true" ]]; then
        cat << 'EOF'
    ______                _ __    __     
   / ____/______  _______(_) /_  / /__   
  / /   / ___/ / / / ___/ / __ \/ / _ \  
 / /___/ /  / /_/ / /__/ / /_/ / /  __/  Universal System Setup Manager
 \____/_/   \__,_/\___/_/_.___/_/\___/   

EOF
        export CRUCIBLE_LOGO_PRINTED=true
    fi
}

# Logging functions
# All log functions support the same format: log_level "message"

# Log an informational message (blue)
log_info() {
    echo -e "${COLOR_BLUE}[INFO]${COLOR_RESET} $1"
}

# Log a success message (green)
log_success() {
    echo -e "${COLOR_GREEN}[OK]${COLOR_RESET} $1"
}

# Log a warning message (yellow)
log_warn() {
    echo -e "${COLOR_YELLOW}[WARN]${COLOR_RESET} $1" >&2
}

# Log an error message (red)
log_error() {
    echo -e "${COLOR_RED}[ERROR]${COLOR_RESET} $1" >&2
}

# Log a debug message (only shown with --debug flag)
log_debug() {
    if [[ "${DEBUG:-}" == "true" ]]; then
        echo -e "${COLOR_CYAN}[DEBUG]${COLOR_RESET} $1" >&2
    fi
}

# Log a section header
# Used to separate major setup phases
log_section() {
    echo ""
    echo -e "${COLOR_CYAN}════════════════════════════════════════════════${COLOR_RESET}"
    echo -e "${COLOR_CYAN}  $1${COLOR_RESET}"
    echo -e "${COLOR_CYAN}════════════════════════════════════════════════${COLOR_RESET}"
    echo ""
}

# Log a skipped operation
log_skip() {
    echo -e "${COLOR_YELLOW}[SKIP]${COLOR_RESET} $1"
}

# Check if a command exists in PATH
# Arguments:
#   $1 - Command name to check
# Returns: 0 if command exists, 1 otherwise
command_exists() {
    command -v "$1" &> /dev/null
}

# Check if running as root
# Many operations require sudo, but the script itself should not run as root
# Returns: 0 if root, 1 otherwise
is_root() {
    [[ $EUID -eq 0 ]]
}

# Get the actual user (handles sudo)
# Returns: The username of the non-root user running the script
get_actual_user() {
    echo "${SUDO_USER:-$USER}"
}

# Check if a package is installed
# Platform-specific implementations in platform modules
# Arguments:
#   $1 - Package name
# Returns: 0 if installed, 1 otherwise
is_package_installed() {
    # This is a placeholder - platform modules override this
    log_error "is_package_installed not implemented for this platform"
    return 1
}

# Install packages using the platform's package manager
# Platform-specific implementations in platform modules
# Arguments:
#   $@ - List of package names to install
install_packages() {
    # This is a placeholder - platform modules override this
    log_error "install_packages not implemented for this platform"
    return 1
}

# Check if a package group should be skipped
# Based on the --skip-packages=GROUPS flag
# Arguments:
#   $1 - Package group name (e.g., "desktop", "media", "fonts")
# Returns: 0 if should skip, 1 otherwise
should_skip_package_group() {
    local group="$1"
    
    if [[ -z "${SKIP_PACKAGE_GROUPS:-}" ]]; then
        return 1
    fi
    
    # Convert comma-separated list to array and check
    IFS=',' read -ra groups <<< "$SKIP_PACKAGE_GROUPS"
    for g in "${groups[@]}"; do
        if [[ "$g" == "$group" ]]; then
            return 0
        fi
    done
    
    return 1
}

# Backup a file before modifying it
# Creates a .bak file with timestamp
# Arguments:
#   $1 - Path to file to backup
backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        local timestamp
        timestamp=$(date +%Y%m%d_%H%M%S)
        cp "$file" "${file}.bak.${timestamp}"
        log_info "Backed up $file to ${file}.bak.${timestamp}"
    fi
}

# Ensure a directory exists
# Creates it if it doesn't exist
# Arguments:
#   $1 - Directory path
ensure_dir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        log_debug "Created directory: $dir"
    fi
}

# Ask user for confirmation
# Arguments:
#   $1 - Prompt message
# Returns: 0 if yes, 1 if no
confirm() {
    local prompt="$1"
    read -p "$prompt [y/N]: " response
    case "$response" in
        [yY][eE][sS]|[yY])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Export all functions
export -f print_logo
export -f log_info log_success log_warn log_error log_debug log_section log_skip
export -f command_exists is_root get_actual_user
export -f is_package_installed install_packages
export -f should_skip_package_group
export -f backup_file ensure_dir confirm
