#!/bin/bash

# Crucible - Universal System Setup Manager
# Main entry point for the setup tool
# 
# This script sets up a complete development environment across multiple platforms:
# - Linux (Arch, Fedora, with extensibility for Debian/Ubuntu)
# - macOS (with Homebrew)
#
# Usage:
#   ./run.sh                    # Full setup (auto-detect platform)
#   ./run.sh --distro=fedora    # Force specific distribution
#   ./run.sh --minimal          # Essential packages only
#   ./run.sh --skip-docker      # Skip specific modules
#
# For detailed help:
#   ./run.sh --help

# Get the directory where this script is located
CRUCIBLE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the core main orchestration script
source "$CRUCIBLE_ROOT/core/main.sh"

# Parse command-line flags
# This populates global variables controlling the setup process
parse_flags "$@"

# Run the main crucible setup function
# This coordinates all platform detection and setup phases
crucible_main

exit 0
