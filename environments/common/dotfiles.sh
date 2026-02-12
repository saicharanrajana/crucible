#!/bin/bash

# Crucible - Dotfiles Setup Module
# Clones and applies dotfiles repository using GNU Stow
# Dotfiles are managed at: https://github.com/saicharanrajana/dotfiles

setup_dotfiles() {
    log_section "Dotfiles Setup"
    
    # Ensure git is installed
    if ! command_exists git; then
        log_error "Git is not installed. Cannot clone dotfiles."
        return 1
    fi
    
    # Ensure stow is installed
    if ! command_exists stow; then
        log_error "GNU Stow is not installed. Cannot apply dotfiles."
        log_info "Install with: sudo dnf install stow (Fedora)"
        log_info "             sudo pacman -S stow (Arch)"
        log_info "             brew install stow (macOS)"
        return 1
    fi
    
    local repo_url="https://github.com/saicharanrajana/dotfiles"
    local repo_name="dotfiles"
    local original_dir
    original_dir=$(pwd)
    
    log_info "Setting up dotfiles from $repo_url..."
    
    # Navigate to home directory
    cd ~
    
    # Check if the repository already exists
    if [ -d "$repo_name" ]; then
        log_info "Dotfiles repository already exists. Updating..."
        cd "$repo_name"
        if ! git pull; then
            log_warn "Failed to update dotfiles repository"
        fi
    else
        log_info "Cloning dotfiles repository..."
        if ! git clone "$repo_url"; then
            log_error "Failed to clone dotfiles repository"
            cd "$original_dir"
            return 1
        fi
        cd "$repo_name"
    fi
    
    # Backup existing config files before stowing
    backup_existing_configs
    
    # Apply dotfiles using stow
    log_info "Applying dotfiles with stow..."
    
    # Define stow packages to apply
    # These should match directory names in the dotfiles repo
    local STOW_PACKAGES=(
        "bash"
        "readline"
        "ghostty"
        "starship"
        "git"
        "opencode"
    )
    
    for pkg in "${STOW_PACKAGES[@]}"; do
        if [ -d "$pkg" ]; then
            log_info "Stowing $pkg..."
            if stow -R "$pkg"; then
                log_success "$pkg applied successfully"
            else
                log_warn "Failed to stow $pkg"
            fi
        else
            log_warn "Package directory not found: $pkg"
        fi
    done
    
    cd "$original_dir"
    log_success "Dotfiles setup complete!"
}

# Backup existing configuration files before stowing
# This prevents data loss when stow would overwrite files
backup_existing_configs() {
    log_info "Backing up existing config files..."
    
    # Files to backup (common ones that dotfiles will replace)
    local configs=(
        "$HOME/.bashrc"
        "$HOME/.inputrc"
        "$HOME/.gitconfig"
    )
    
    for config in "${configs[@]}"; do
        if [ -f "$config" ] && [ ! -L "$config" ]; then
            backup_file "$config"
        fi
    done
}

# Run the setup
setup_dotfiles
