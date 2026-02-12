#!/bin/bash

# Crucible - Docker Setup Module
# Installs and configures Docker across different platforms
# Handles platform-specific installation methods and configuration

setup_docker() {
    log_section "Docker Setup"
    
    case "$PLATFORM" in
        "linux")
            setup_docker_linux
            ;;
        "macos")
            setup_docker_macos
            ;;
        *)
            log_error "Docker setup not implemented for platform: $PLATFORM"
            return 1
            ;;
    esac
}

# Setup Docker on Linux
# Uses distribution-specific package managers
setup_docker_linux() {
    log_info "Setting up Docker for Linux..."
    
    if command_exists docker; then
        log_info "Docker is already installed"
    else
        log_info "Installing Docker..."
        
        case "$DISTRO" in
            "arch")
                sudo pacman -S --noconfirm docker
                ;;
            "fedora")
                sudo dnf install -y docker
                ;;
            *)
                log_error "Docker installation not implemented for distro: $DISTRO"
                return 1
                ;;
        esac
    fi
    
    # Configure Docker daemon
    configure_docker_daemon
    
    # Enable and start Docker service
    log_info "Enabling Docker service..."
    sudo systemctl enable --now docker
    
    # Verify Docker is running
    if ! systemctl is-active --quiet docker; then
        log_error "Docker service failed to start"
        return 1
    fi
    
    # Add user to docker group
    local actual_user
    actual_user=$(get_actual_user)
    if ! groups "$actual_user" | grep -q docker; then
        log_info "Adding $actual_user to docker group..."
        sudo usermod -aG docker "$actual_user"
        log_warn "You need to log out and back in for docker group changes to take effect"
    fi
    
    log_success "Docker setup complete"
}

# Configure Docker daemon settings
# Sets up logging limits and other best practices
configure_docker_daemon() {
    log_info "Configuring Docker daemon..."
    
    sudo mkdir -p /etc/docker
    sudo tee /etc/docker/daemon.json > /dev/null << 'EOF'
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "5"
  }
}
EOF
    
    log_success "Docker daemon configured"
}

# Setup Docker on macOS
# On macOS, Docker Desktop is the recommended approach
setup_docker_macos() {
    log_info "Setting up Docker for macOS..."
    
    if command_exists docker; then
        log_info "Docker is already installed"
        return 0
    fi
    
    if command_exists brew; then
        log_info "Installing Docker Desktop via Homebrew..."
        brew install --cask docker
        
        log_warn "Docker Desktop has been installed. Please start it from Applications."
        log_warn "You may need to accept the license agreement on first run."
    else
        log_error "Homebrew not found. Please install Homebrew first."
        log_info "Visit: https://brew.sh"
        return 1
    fi
}

# Run the setup
setup_docker
