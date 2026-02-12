#!/bin/bash

# Crucible - Git and SSH Setup Module
# Configures Git user settings and generates SSH keys
# This is a one-time setup that should be customized per user

setup_git_ssh() {
    log_section "Git and SSH Setup"
    
    setup_git
    setup_ssh
    
    log_success "Git and SSH setup complete!"
}

# Configure Git user settings
# These should be customized with your actual name and email
setup_git() {
    log_info "Configuring Git..."
    
    # Check if git is installed
    if ! command_exists git; then
        log_warn "Git is not installed. Skipping Git configuration."
        return 1
    fi
    
    # Configure git defaults
    # These are sensible defaults, but user should customize name/email
    
    # Set default branch name
    git config --global init.defaultBranch main
    
    # Set default editor
    git config --global core.editor vim
    
    # Enable color output
    git config --global color.ui auto
    
    # Set pull strategy to rebase (cleaner history)
    git config --global pull.rebase true
    
    # Set push strategy to simple
    git config --global push.default simple
    
    # Check if user name and email are already set
    local git_name
    local git_email
    git_name=$(git config --global user.name 2>/dev/null || echo "")
    git_email=$(git config --global user.email 2>/dev/null || echo "")
    
    if [[ -z "$git_name" || -z "$git_email" ]]; then
        log_warn "Git user name and/or email not configured"
        log_info "Please run:"
        log_info "  git config --global user.name \"Your Name\""
        log_info "  git config --global user.email \"your.email@example.com\""
    else
        log_info "Git already configured for: $git_name <$git_email>"
    fi
    
    log_success "Git defaults configured"
}

# Generate SSH key pair
# Creates an ed25519 key for modern, secure authentication
setup_ssh() {
    log_info "Setting up SSH keys..."
    
    # Ensure .ssh directory exists
    ensure_dir "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    
    # Check if SSH key already exists
    if [[ -f "$HOME/.ssh/id_ed25519" ]]; then
        log_info "SSH key already exists: ~/.ssh/id_ed25519"
        log_info "Public key:"
        cat "$HOME/.ssh/id_ed25519.pub"
    else
        log_info "Generating new SSH key pair..."
        
        # Generate ed25519 key (modern, secure, compact)
        # User should set a passphrase when prompted
        ssh-keygen -t ed25519 -C "$(whoami)@$(hostname)" -f "$HOME/.ssh/id_ed25519"
        
        log_success "SSH key generated successfully"
        log_info "Public key (add to GitHub, GitLab, etc.):"
        cat "$HOME/.ssh/id_ed25519.pub"
    fi
    
    # Ensure correct permissions
    chmod 600 "$HOME/.ssh/id_ed25519" 2>/dev/null || true
    chmod 644 "$HOME/.ssh/id_ed25519.pub" 2>/dev/null || true
    
    # Start ssh-agent if not running
    if [[ -z "${SSH_AUTH_SOCK:-}" ]]; then
        log_info "Starting ssh-agent..."
        eval "$(ssh-agent -s)"
        ssh-add "$HOME/.ssh/id_ed25519" 2>/dev/null || true
    fi
}

# Run the setup
setup_git_ssh
