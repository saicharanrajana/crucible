#!/bin/bash
#
# Dotfiles Setup Script
# Backs up existing configs and stows dotfiles from the repo
#

set -euo pipefail

# Configuration
REPO_URL="https://github.com/saicharanrajana/dotfiles"
REPO_NAME="dotfiles"
BACKUP_BASE_DIR="$HOME/.dotfiles-backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$BACKUP_BASE_DIR/$TIMESTAMP"
MANIFEST_FILE="$BACKUP_DIR/restore-manifest.txt"

# List of stow packages (explicit for clarity and safety)
PACKAGES=("bash" "readline" "ghostty" "starship" "git" "opencode")

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

is_stow_installed() {
    pacman -Qi "stow" &> /dev/null
}

# Check if a path is already a correct symlink to our dotfiles
is_already_stowed() {
    local target_path="$1"
    local package="$2"
    
    if [[ -L "$target_path" ]]; then
        local symlink_target
        symlink_target=$(readlink -f "$target_path")
        local expected_target="$HOME/$REPO_NAME/$package${target_path#$HOME}"
        
        if [[ "$symlink_target" == "$expected_target" ]]; then
            return 0  # Already correctly stowed
        fi
    fi
    return 1
}

# Backup a file or directory if it exists and conflicts
backup_if_conflicts() {
    local source_path="$1"  # Path in the stow package
    local target_path="$2"  # Path in $HOME
    local package="$3"
    
    # Skip if already correctly stowed (idempotency)
    if is_already_stowed "$target_path" "$package"; then
        log_info "Skipping (already stowed): $target_path"
        return 0
    fi
    
    # Backup if exists and is not a symlink (or points elsewhere)
    if [[ -e "$target_path" ]] || [[ -L "$target_path" ]]; then
        log_warn "Backing up: $target_path"
        
        # Create backup directory for this package
        local pkg_backup_dir="$BACKUP_DIR/$package"
        mkdir -p "$pkg_backup_dir"
        
        # Preserve directory structure
        local rel_path="${target_path#$HOME/}"
        local backup_path="$pkg_backup_dir/$rel_path"
        local backup_parent
        backup_parent=$(dirname "$backup_path")
        mkdir -p "$backup_parent"
        
        # Move to backup
        mv "$target_path" "$backup_path"
        
        # Record in manifest
        echo "$rel_path -> $backup_path" >> "$MANIFEST_FILE"
        echo "Backed up: $target_path"
    fi
}

# Recursively find all files/directories in a stow package that need to be checked
find_package_targets() {
    local package="$1"
    local package_dir="$HOME/$REPO_NAME/$package"
    
    if [[ ! -d "$package_dir" ]]; then
        log_error "Package directory not found: $package_dir"
        return 1
    fi
    
    # Find all files/directories in the package
    find "$package_dir" -type f -o -type d | while read -r item; do
        # Get relative path from package root
        local rel_path="${item#$package_dir/}"
        
        # Skip the package root itself
        [[ "$rel_path" == "$package_dir" ]] && continue
        
        # Calculate target path in $HOME
        echo "$HOME/$rel_path"
    done
}

# Setup and backup for a single package
prepare_package() {
    local package="$1"
    local package_dir="$HOME/$REPO_NAME/$package"
    
    log_info "Preparing package: $package"
    
    if [[ ! -d "$package_dir" ]]; then
        log_error "Package '$package' not found in repo"
        return 1
    fi
    
    # Backup existing files that would conflict
    local targets
    targets=$(find_package_targets "$package" 2>/dev/null || true)
    
    while IFS= read -r target_path; do
        [[ -z "$target_path" ]] && continue
        backup_if_conflicts "$package_dir" "$target_path" "$package"
    done <<< "$targets"
}

# Clone or update repository
setup_repository() {
    cd "$HOME"
    
    if [[ -d "$REPO_NAME/.git" ]]; then
        log_info "Repository exists. Pulling latest changes..."
        cd "$REPO_NAME"
        if ! git pull; then
            log_error "Failed to pull latest changes"
            return 1
        fi
    elif [[ -d "$REPO_NAME" ]]; then
        log_error "Directory '$REPO_NAME' exists but is not a git repo"
        log_error "Please remove it and run again"
        return 1
    else
        log_info "Cloning repository..."
        if ! git clone "$REPO_URL"; then
            log_error "Failed to clone repository"
            return 1
        fi
        cd "$REPO_NAME"
    fi
}

main() {
    # Check dependencies
    if ! is_stow_installed; then
        log_error "stow is not installed. Install it with: sudo pacman -S stow"
        exit 1
    fi
    
    # Create backup directory
    mkdir -p "$BACKUP_DIR"
    touch "$MANIFEST_FILE"
    echo "Backup created: $TIMESTAMP" >> "$MANIFEST_FILE"
    echo "================================" >> "$MANIFEST_FILE"
    
    log_info "Backup directory: $BACKUP_DIR"
    
    # Setup repository
    if ! setup_repository; then
        exit 1
    fi
    
    # Prepare each package (backup conflicting files)
    log_info "Checking for conflicts and backing up..."
    for package in "${PACKAGES[@]}"; do
        prepare_package "$package" || true
    done
    
    # Stow packages
    log_info "Stowing packages..."
    local failed_packages=()
    
    for package in "${PACKAGES[@]}"; do
        log_info "Stowing: $package"
        if stow "$package"; then
            log_info "Success: $package"
        else
            log_error "Failed to stow: $package"
            failed_packages+=("$package")
        fi
    done
    
    # Summary
    echo ""
    echo "================================"
    log_info "Setup complete!"
    echo ""
    echo "Backup location: $BACKUP_DIR"
    
    if [[ ${#failed_packages[@]} -gt 0 ]]; then
        echo ""
        log_error "Failed packages: ${failed_packages[*]}"
        echo "You may need to manually resolve conflicts for these"
        exit 1
    fi
    
    echo ""
    log_info "To restore from this backup, run:"
    echo "  ./dotfiles-restore.sh $TIMESTAMP"
}

main "$@"
