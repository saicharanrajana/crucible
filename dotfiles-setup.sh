#!/bin/bash

set -e

ORIGINAL_DIR=$(pwd)
REPO_URL="https://github.com/saicharanrajana/dotfiles"
REPO_NAME="dotfiles"


is_stow_installed() {
  pacman -Qi "stow" &> /dev/null
}

if ! is_stow_installed; then
  echo "Install stow first"
  exit 1
fi

cd ~

# Check if the repository already exists
if [ -d "$REPO_NAME" ]; then
  echo "Repository '$REPO_NAME' already exists. Skipping clone"
  CLONE_SUCCESS=true
else
  if git clone "$REPO_URL"; then
    CLONE_SUCCESS=true
  else
    CLONE_SUCCESS=false
  fi
fi

# Check if the clone was successful
if [ "$CLONE_SUCCESS" = true ]; then
  [ -f ~/.bashrc ] && mv ~/.bashrc ~/.bashrc.bak
  [ -f ~/.inputrc ] && mv ~/.inputrc ~/.inputrc.bak
  
  cd "$REPO_NAME"
  stow bash
  stow readline
  stow ghostty
  stow starship
  stow git
  stow opencode
else
  echo "Failed to clone the repository."
  exit 1
fi

