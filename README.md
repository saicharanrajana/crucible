# Crucible - Universal System Setup Manager

A flexible, extensible system setup automation tool that works across multiple platforms and distributions. Originally forked from Arch-specific setup, now evolved into a universal manager.

## Features

- **Multi-Platform Support**: Linux (Arch, Fedora) and macOS
- **Modular Architecture**: Skip any module with command-line flags
- **Desktop Environment Support**: GNOME configuration with tiling features
- **Extensible**: Easy to add new platforms, distributions, or desktop environments
- **Well-Documented**: Every function and configuration is documented inline

## Quick Start

```bash
# Full setup (auto-detects your platform)
./run.sh

# Minimal setup (essential packages only)
./run.sh --minimal

# Skip specific modules
./run.sh --skip-docker --skip-flatpak

# Force specific platform/distro
./run.sh --platform=linux --distro=fedora

# Show all options
./run.sh --help
```

## Architecture

Crucible is organized into a modular structure:

```
crucible/
├── run.sh                    # Main entry point
├── core/                     # Core orchestration logic
│   ├── main.sh              # Main setup coordination
│   ├── platform.sh          # Platform detection (linux/macos)
│   ├── distro.sh            # Linux distribution detection
│   └── flags.sh             # CLI argument parsing
├── lib/                      # Shared utilities
│   └── utils.sh             # Logging, helper functions
├── platforms/                # Platform-specific modules
│   ├── linux/
│   │   ├── arch/            # Arch Linux setup
│   │   └── fedora/          # Fedora setup
│   └── macos/               # macOS setup
├── environments/             # Desktop environment & tools
│   ├── gnome/               # GNOME configuration
│   └── common/              # Cross-platform modules
└── config/                   # Configuration files
    └── packages/            # Package lists per platform
```

## Supported Platforms

### Linux Distributions

#### Fedora
- **Repositories**: RPM Fusion (free/non-free), Terra
- **Package Manager**: DNF
- **Desktop**: GNOME with full theming and extensions
- **Special Packages**: Ghostty, Helium browser, JetBrains Mono Nerd Fonts (from Terra)

#### Arch Linux
- **Repositories**: Official repos + AUR (via yay)
- **Package Manager**: Pacman + AUR helper
- **Desktop**: GNOME with full theming and extensions
- **AUR Packages**: Ghostty, Helium browser, JetBrains Mono Nerd Fonts

#### macOS
- **Package Manager**: Homebrew (auto-installed)
- **No Desktop Environment**: Uses native macOS interface
- **Features**: Homebrew formulas, casks, fonts

## Command-Line Options

### Platform Selection
```bash
--platform=PLATFORM       Specify platform (linux, macos)
--distro=DISTRO          Specify Linux distribution (arch, fedora)
```

### Desktop Environment
```bash
--desktop=DE             Set desktop environment (gnome, none)
--no-desktop             Skip desktop environment setup
```

### Skip Modules
```bash
--skip-repos             Skip repository configuration
--skip-packages          Skip all package installation
--skip-packages=GROUPS   Skip specific package groups (comma-separated)
--skip-desktop           Skip desktop environment configuration
--skip-flatpak           Skip flatpak application installation
--skip-docker            Skip docker setup
--skip-dotfiles          Skip dotfiles clone and stow
--skip-git               Skip git and SSH key setup
```

### Modes
```bash
--minimal                Minimal setup (essential packages only)
--dev-only              Alias for --minimal
```

### Help
```bash
-h, --help              Show help message
-v, --verbose           Enable verbose output
--debug                 Enable debug output
```

## Package Categories

Packages are organized into categories that can be skipped individually:

| Category | Description | Example Packages |
|----------|-------------|------------------|
| `system` | System utilities | htop, btop, fzf, zoxide |
| `dev` | Development tools | vim, neovim, git, starship, mise |
| `desktop` | Desktop applications | GNOME tweaks, browsers |
| `media` | Media tools | mpv, flameshot, gimp |
| `fonts` | Typography | JetBrains Mono Nerd Fonts |

### Skipping Categories

```bash
# Skip multiple categories
./run.sh --skip-packages=desktop,media,fonts

# Install only development tools
./run.sh --minimal
```

## Desktop Environment: GNOME

When `--desktop=gnome` (default on Linux):

### Extensions Installed
- **Tactile**: i3-like window tiling
- **Lock Keys**: Show Caps/Num lock status
- **No Overview**: Disable overview on startup
- **Dock NG**: Enhanced dock
- **Rounded Window Corners**: Consistent window styling
- **Space Bar**: Workspace indicator
- **TopHat**: System monitor in top bar
- ... and more

### Themes
- **GTK Theme**: adw-gtk3-dark
- **Icons**: Neuwaita
- **Font**: JetBrains Mono Nerd Font 11pt

### Keyboard Shortcuts
- `Super + 1-6`: Switch to workspace 1-6
- `Super + Shift + 1-6`: Move window to workspace 1-6
- `Super + W`: Close window
- `Super + F`: Toggle fullscreen
- `Super + M`: Toggle maximize

## Extending Crucible

### Adding a New Linux Distribution

1. Create directory: `platforms/linux/newdistro/`
2. Create files:
   - `setup.sh`: Main orchestration (implement `platform_setup_repos()` and `platform_install_packages()`)
   - `repos.sh`: Repository setup
   - `packages.sh`: Package installation functions

3. Update `core/distro.sh` to detect the new distribution
4. Create `config/packages/newdistro.conf`

Example `platforms/linux/newdistro/setup.sh`:
```bash
#!/bin/bash
source "$CRUCIBLE_ROOT/platforms/linux/newdistro/repos.sh"
source "$CRUCIBLE_ROOT/platforms/linux/newdistro/packages.sh"

platform_setup_repos() {
    log_info "Setting up NewDistro repositories..."
    # Add your repos here
}

platform_install_packages() {
    log_info "Installing NewDistro packages..."
    source "$CRUCIBLE_ROOT/config/packages/newdistro.conf"
    # Install packages
}

is_package_installed() {
    # Check if package is installed
}
```

### Adding a New Desktop Environment

1. Create directory: `environments/newde/`
2. Create files:
   - `setup.sh`: Main DE setup (implement `newde_setup()`)
   - Additional config files as needed

3. Update `DESKTOP_ENV` handling in `core/main.sh`

### Adding a New Common Module

1. Create script: `environments/common/newmodule.sh`
2. Implement setup function (e.g., `setup_newmodule()`)
3. Add skip flag to `core/flags.sh`
4. Add execution in `execute_setup()` in `core/main.sh`

## Package Configuration

Package lists are defined in `config/packages/`:

### Fedora (`fedora.conf`)
```bash
FEDORA_SYSTEM_UTILS=(htop btop fzf zoxide ...)
FEDORA_DEV_TOOLS=(vim neovim git starship ...)
FEDORA_DESKTOP=(gnome-tweaks ...)
FEDORA_MEDIA=(mpv flameshot gimp ...)
FEDORA_FONTS=(jetbrains-mono-nerd-fonts ...)
```

### Terra Repository (Fedora)

Special packages from Terra (Fyra Labs):
- `ghostty` - Modern terminal emulator
- `helium` - Helium web browser
- `jetbrains-mono-nerd-fonts` - Developer font with icons

To install Terra packages separately:
```bash
sudo dnf install --repo=terra ghostty
```

### Arch (`arch.conf`)

Packages are split between official repos and AUR:
```bash
# Official packages
ARCH_SYSTEM_UTILS=(htop btop ...)
ARCH_DEV_TOOLS=(vim neovim ...)

# AUR packages
ARCH_SYSTEM_UTILS_AUR=(nerdfetch ...)
ARCH_DEV_TOOLS_AUR=(ghostty ...)
```

### macOS (`macos.conf`)

Split between formulas (CLI) and casks (GUI):
```bash
# CLI tools (formulas)
MACOS_SYSTEM_UTILS=(htop btop fzf ...)

# GUI apps (casks)
MACOS_DESKTOP=(firefox visual-studio-code ...)
```

## Modules Reference

### Docker Module (`environments/common/docker.sh`)
- Installs Docker Engine (Linux) or Docker Desktop (macOS)
- Configures daemon with log rotation
- Adds user to docker group
- Can be skipped with `--skip-docker`

### Flatpak Module (`environments/common/flatpak.sh`)
- Configures Flathub repository
- Installs applications:
  - ONLYOFFICE Desktop Editors
  - Cine (media player)
  - qBittorrent
  - Zoom
- Can be skipped with `--skip-flatpak`

### Dotfiles Module (`environments/common/dotfiles.sh`)
- Clones from `https://github.com/saicharanrajana/dotfiles`
- Uses GNU Stow to manage configs
- Applies packages: bash, readline, ghostty, starship, git, opencode
- Can be skipped with `--skip-dotfiles`

### Git/SSH Module (`environments/common/git.sh`)
- Configures Git defaults (editor, color, pull strategy)
- Generates ed25519 SSH key pair
- Can be skipped with `--skip-git`

## Utility Functions

Located in `lib/utils.sh`:

### Logging
```bash
log_info "Message"      # Blue [INFO]
log_success "Message"   # Green [OK]
log_warn "Message"      # Yellow [WARN]
log_error "Message"     # Red [ERROR]
log_debug "Message"     # Cyan [DEBUG] (only with --debug)
log_section "Title"     # Header separator
```

### System Checks
```bash
command_exists "cmd"           # Check if command exists
is_root                        # Check if running as root
get_actual_user                # Get real user (handles sudo)
is_package_installed "pkg"     # Check if package installed
```

### Helpers
```bash
backup_file "path"             # Backup with timestamp
ensure_dir "path"              # Create directory if needed
confirm "Prompt"               # Ask user yes/no
should_skip_package_group "grp" # Check skip flags
```

## Examples

### Full Fedora Setup with GNOME
```bash
./run.sh --distro=fedora --desktop=gnome
```

### Minimal Arch Server Setup
```bash
./run.sh --distro=arch --minimal
```

### macOS Development Environment
```bash
./run.sh --platform=macos --skip-docker
```

### Update Existing System (skip repos)
```bash
./run.sh --skip-repos --skip-dotfiles --skip-git
```

### Customize Package Installation
```bash
# Install only dev tools and fonts, skip media
./run.sh --skip-packages=media
```

## Requirements

### All Platforms
- Internet connection
- Bash 4.0+
- Git (for dotfiles)

### Linux
- Root access (for package installation)
- systemd (for service management)

### macOS
- macOS 10.14+
- Xcode Command Line Tools (auto-installed)

## Troubleshooting

### "Permission denied" when running run.sh
```bash
chmod +x run.sh
```

### "Command not found: gsettings" (GNOME setup)
GNOME is not installed. Install it first:
- Fedora: `sudo dnf groupinstall "GNOME Desktop"`
- Arch: `sudo pacman -S gnome`

### Docker service won't start
Check if another container runtime (podman) is conflicting:
```bash
sudo systemctl status docker
```

### Flatpak apps not themed
Flatpak theme override should handle this. If not:
```bash
sudo flatpak override --filesystem=xdg-data/themes
```

### macOS: "Homebrew not found"
The script will auto-install Homebrew. If it fails:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## Contributing

When adding new features:

1. **Document everything**: Add comments explaining what each function does
2. **Follow existing patterns**: Look at existing platform modules
3. **Test on target platform**: Ensure it works on the intended OS
4. **Update this README**: Add new flags, modules, or platforms

## License

Forked from [typecraft-dev/crucible](https://github.com/typecraft-dev/crucible) and heavily modified.

## Credits

- Original: [typecraft-dev/crucible](https://github.com/typecraft-dev/crucible)
- Terra Repository: [Fyra Labs](https://terra.fyralabs.com/)
- GNOME Extensions: Various authors on extensions.gnome.org
- Themes: adw-gtk3, Neuwaita
