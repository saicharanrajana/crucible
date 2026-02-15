#!/bin/bash
#
# Dotfiles Restore Script
# Restores backed up configuration files
#
# Usage:
#   ./dotfiles-restore.sh              # List available backups
#   ./dotfiles-restore.sh <timestamp>  # Restore from specific backup
#

set -euo pipefail

BACKUP_BASE_DIR="$HOME/.dotfiles-backups"
REPO_NAME="dotfiles"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

list_backups() {
    if [[ ! -d "$BACKUP_BASE_DIR" ]]; then
        log_error "No backups found (backup directory doesn't exist)"
        exit 1
    fi
    
    local backups
    backups=$(ls -1 "$BACKUP_BASE_DIR" 2>/dev/null | sort -r)
    
    if [[ -z "$backups" ]]; then
        log_error "No backups found in $BACKUP_BASE_DIR"
        exit 1
    fi
    
    echo "Available backups:"
    echo ""
    
    local i=1
    while IFS= read -r backup; do
        local manifest="$BACKUP_BASE_DIR/$backup/restore-manifest.txt"
        local count=0
        
        if [[ -f "$manifest" ]]; then
            # Count backed up items (lines with "->")
            count=$(grep -c "->" "$manifest" 2>/dev/null || echo "0")
        fi
        
        echo "  $i. $backup ($count items backed up)"
        
        # Show first line of manifest if it exists (usually the backup timestamp)
        if [[ -f "$manifest" ]]; then
            local header
            header=$(head -n1 "$manifest")
            echo "     $header"
        fi
        
        ((i++))
    done <<< "$backups"
    
    echo ""
    echo "Usage: ./dotfiles-restore.sh <timestamp>"
    echo "       ./dotfiles-restore.sh $(echo "$backups" | head -n1)"
}

unstow_packages() {
    local backup_dir="$1"
    
    log_step "Removing stow symlinks..."
    
    cd "$HOME/$REPO_NAME"
    
    # Get list of packages from backup directory
    for pkg_dir in "$backup_dir"/*/; do
        [[ ! -d "$pkg_dir" ]] && continue
        
        local package
        package=$(basename "$pkg_dir")
        
        log_info "Unstowing: $package"
        stow -D "$package" 2>/dev/null || true
    done
}

restore_backup() {
    local timestamp="$1"
    local backup_dir="$BACKUP_BASE_DIR/$timestamp"
    local manifest="$backup_dir/restore-manifest.txt"
    
    if [[ ! -d "$backup_dir" ]]; then
        log_error "Backup not found: $backup_dir"
        echo "Run without arguments to see available backups"
        exit 1
    fi
    
    if [[ ! -f "$manifest" ]]; then
        log_error "Backup manifest not found: $manifest"
        exit 1
    fi
    
    log_info "Restoring from backup: $timestamp"
    log_info "Backup location: $backup_dir"
    echo ""
    
    # First, unstow the packages
    unstow_packages "$backup_dir"
    
    echo ""
    log_step "Restoring backed up files..."
    
    # Restore each backed up item
    local restored=0
    local skipped=0
    
    # Parse manifest - format: "relative_path -> backup_path"
    grep "->" "$manifest" | while IFS= read -r line; do
        local rel_path="${line%% -> *}"
        local backup_path="${line##* -> }"
        local target_path="$HOME/$rel_path"
        
        # Check if target already exists (not a symlink we just removed)
        if [[ -e "$target_path" ]] && [[ ! -L "$target_path" ]]; then
            log_warn "Target exists (not restoring): $target_path"
            ((skipped++))
            continue
        fi
        
        if [[ -e "$backup_path" ]]; then
            # Ensure parent directory exists
            mkdir -p "$(dirname "$target_path")"
            
            # Restore the backup
            mv "$backup_path" "$target_path"
            log_info "Restored: $rel_path"
            ((restored++))
        else
            log_warn "Backup not found: $backup_path"
            ((skipped++))
        fi
    done
    
    echo ""
    log_info "Restore complete!"
    log_info "Items restored: $restored"
    [[ $skipped -gt 0 ]] && log_warn "Items skipped: $skipped"
    
    echo ""
    log_info "Your dotfiles have been restored to their state before the setup."
    log_info "Stow symlinks have been removed."
}

main() {
    local timestamp="${1:-}"
    
    if [[ -z "$timestamp" ]]; then
        list_backups
        exit 0
    fi
    
    # Validate timestamp format (YYYYMMDD_HHMMSS)
    if [[ ! "$timestamp" =~ ^[0-9]{8}_[0-9]{6}$ ]]; then
        log_error "Invalid timestamp format. Expected: YYYYMMDD_HHMMSS"
        echo "Run without arguments to see available backups"
        exit 1
    fi
    
    # Confirm with user
    echo "This will restore your configuration from backup: $timestamp"
    echo "Current stow symlinks will be removed first."
    echo ""
    read -p "Are you sure? [y/N] " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Restore cancelled"
        exit 0
    fi
    
    restore_backup "$timestamp"
}

main "$@"
