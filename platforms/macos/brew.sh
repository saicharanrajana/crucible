#!/bin/bash

# Crucible - macOS Homebrew Setup Module
# Configures Homebrew package manager for macOS
# Homebrew is the de facto standard package manager for macOS

# Setup Homebrew
# Installs Homebrew if not already present
# Also handles prerequisites and initial configuration
setup_homebrew() {
    log_info "Checking for Homebrew..."
    
    # Check if Homebrew is already installed
    if command_exists brew; then
        log_info "Homebrew is already installed"
        log_info "Updating Homebrew..."
        brew update
        return 0
    fi
    
    # Check for Xcode Command Line Tools
    if ! xcode-select -p &> /dev/null; then
        log_info "Installing Xcode Command Line Tools..."
        xcode-select --install
        log_warn "Please complete the Xcode Command Line Tools installation and re-run this script"
        exit 1
    fi
    
    # Install Homebrew
    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for the current session
    if [[ -f /opt/homebrew/bin/brew ]]; then
        # Apple Silicon Mac
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
        # Intel Mac
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    
    # Verify installation
    if command_exists brew; then
        log_success "Homebrew installed successfully"
    else
        log_error "Homebrew installation failed"
        exit 1
    fi
}

# Install packages using Homebrew (formulas)
# Arguments:
#   $@ - List of formula names to install
brew_install() {
    local formulas=("$@")
    local to_install=()
    
    # Filter out empty entries
    formulas=($(echo "${formulas[@]}" | tr ' ' '\n' | grep -v '^$' | tr '\n' ' '))
    
    if [[ ${#formulas[@]} -eq 0 ]]; then
        return 0
    fi
    
    # Filter out already installed formulas
    for formula in "${formulas[@]}"; do
        if ! brew list "$formula" &> /dev/null; then
            to_install+=("$formula")
        fi
    done
    
    if [[ ${#to_install[@]} -eq 0 ]]; then
        log_success "All formulas already installed"
        return 0
    fi
    
    log_info "Installing: ${to_install[*]}"
    
    if brew install "${to_install[@]}"; then
        log_success "Successfully installed formulas"
    else
        log_error "Failed to install some formulas"
        return 1
    fi
}

# Install applications using Homebrew Casks
# Casks are GUI applications (e.g., Firefox, VS Code)
# Arguments:
#   $@ - List of cask names to install
brew_cask_install() {
    local casks=("$@")
    local to_install=()
    
    # Filter out empty entries
    casks=($(echo "${casks[@]}" | tr ' ' '\n' | grep -v '^$' | tr '\n' ' '))
    
    if [[ ${#casks[@]} -eq 0 ]]; then
        return 0
    fi
    
    # Filter out already installed casks
    for cask in "${casks[@]}"; do
        if ! brew list --cask "$cask" &> /dev/null; then
            to_install+=("$cask")
        fi
    done
    
    if [[ ${#to_install[@]} -eq 0 ]]; then
        log_success "All casks already installed"
        return 0
    fi
    
    log_info "Installing casks: ${to_install[*]}"
    
    if brew install --cask "${to_install[@]}"; then
        log_success "Successfully installed casks"
    else
        log_error "Failed to install some casks"
        return 1
    fi
}

# Tap a Homebrew tap (add a third-party repository)
# Arguments:
#   $1 - Tap name (e.g., "homebrew/cask-fonts")
brew_tap() {
    local tap="$1"
    
    if brew tap | grep -q "^${tap}$"; then
        log_debug "Tap '$tap' already added"
        return 0
    fi
    
    log_info "Adding tap: $tap"
    if brew tap "$tap"; then
        log_success "Successfully tapped $tap"
    else
        log_error "Failed to tap $tap"
        return 1
    fi
}

# Export functions
export -f setup_homebrew
export -f brew_install
export -f brew_cask_install
export -f brew_tap
