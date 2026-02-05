#!/bin/bash

# Git and SSH Setup Script
# Configures git user details and generates SSH key for GitHub

set -e

echo ""
echo "=========================================="
echo "  Git Configuration & SSH Key Setup"
echo "=========================================="
echo ""

# Check if git is installed
if ! command -v git &> /dev/null; then
  echo "Error: git is not installed. Please install git first."
  exit 1
fi

# Check if SSH key already exists
SSH_KEY_PATH="$HOME/.ssh/id_ed25519"
if [ -f "$SSH_KEY_PATH" ]; then
  echo "SSH key already exists at $SSH_KEY_PATH"
  echo "Public key content:"
  cat "${SSH_KEY_PATH}.pub"
  echo ""
  read -p "Do you want to generate a new SSH key? This will overwrite the existing one. [y/N] " -n 1 -r
  echo ""
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Skipping SSH key generation."
    GENERATE_KEY=false
  else
    GENERATE_KEY=true
  fi
else
  GENERATE_KEY=true
fi

# Prompt for Git user details
if [ "$GENERATE_KEY" = true ] || [ -z "$(git config --global user.name)" ] || [ -z "$(git config --global user.email)" ]; then
  echo ""
  read -p "Enter your GitHub username: " GITHUB_USER
  read -p "Enter your email address: " USER_EMAIL
  
  if [ -z "$GITHUB_USER" ] || [ -z "$USER_EMAIL" ]; then
    echo "Error: Both username and email are required."
    exit 1
  fi
  
  # Set git config globally
  echo ""
  echo "Setting git configuration..."
  git config --global user.name "$GITHUB_USER"
  git config --global user.email "$USER_EMAIL"
  echo "Git user.name: $(git config --global user.name)"
  echo "Git user.email: $(git config --global user.email)"
  
  # Generate SSH key if needed
  if [ "$GENERATE_KEY" = true ]; then
    echo ""
    echo "Generating SSH key..."
    mkdir -p "$HOME/.ssh"
    ssh-keygen -t ed25519 -C "$USER_EMAIL" -f "$SSH_KEY_PATH" -N ""
    
    echo ""
    echo "=========================================="
    echo "  SSH Public Key (Copy this to GitHub)"
    echo "=========================================="
    echo ""
    cat "${SSH_KEY_PATH}.pub"
    echo ""
    echo "=========================================="
    echo ""
    echo "Instructions:"
    echo "1. Copy the entire key above (starts with 'ssh-ed25519')"
    echo "2. Go to https://github.com/settings/keys"
    echo "3. Click 'New SSH key'"
    echo "4. Paste the key and save"
    echo ""
    
    # Uncomment the following lines to enable ssh-agent
    # echo "Starting ssh-agent and adding key..."
    # eval "$(ssh-agent -s)"
    # ssh-add "$SSH_KEY_PATH"
    # echo "SSH key added to ssh-agent"
  fi
else
  echo "Git is already configured:"
  echo "  user.name: $(git config --global user.name)"
  echo "  user.email: $(git config --global user.email)"
  echo ""
  echo "SSH key already exists. Skipping setup."
fi

echo ""
echo "Git and SSH setup complete!"
echo ""
