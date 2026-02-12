#!/bin/bash

# Crucible - GNOME Hotkeys Module
# Configures keyboard shortcuts for window management
# These shortcuts make GNOME work more like a tiling window manager

echo "Configuring GNOME keyboard shortcuts..."

# Workspace navigation with Super + Number
# Jump directly to workspaces 1-6
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-1 "['<Super>1']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-2 "['<Super>2']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-3 "['<Super>3']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-4 "['<Super>4']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-5 "['<Super>5']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-6 "['<Super>6']"

# Move window to workspace with Super + Shift + Number
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-1 "['<Super><Shift>1']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-2 "['<Super><Shift>2']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-3 "['<Super><Shift>3']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-4 "['<Super><Shift>4']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-5 "['<Super><Shift>5']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-6 "['<Super><Shift>6']"

# Close window with Super + W (like vim)
gsettings set org.gnome.desktop.wm.keybindings close "['<Super>W', '<Alt>F4']"

# Toggle fullscreen with Super + F
gsettings set org.gnome.desktop.wm.keybindings toggle-fullscreen "['<Super>F']"

# Toggle maximized with Super + M
gsettings set org.gnome.desktop.wm.keybindings toggle-maximized "['<Super>M']"

# Show all applications with Super + A (default)
# This is already the default, but we ensure it
# gsettings set org.gnome.shell.keybindings toggle-application-view "['<Super>A']"

# Disable some default shortcuts that conflict
# Remove Alt+F4 binding from close (keep only Super+W)
# gsettings set org.gnome.desktop.wm.keybindings close "['<Super>W']"

# Configure Tactile extension shortcuts (if installed)
# These provide i3-like tiling window management
if gsettings list-schemas | grep -q "org.gnome.shell.extensions.tactile"; then
    echo "Configuring Tactile tiling shortcuts..."
    
    # Main Tactile shortcut
    gsettings set org.gnome.shell.extensions.tactile monitor-switcher-enabled false
    gsettings set org.gnome.shell.extensions.tactile use-maximize false
    gsettings set org.gnome.shell.extensions.tactile gap-size 8
fi

# Disable Alt+Tab showing all workspaces (show only current)
gsettings set org.gnome.shell.app-switcher current-workspace-only true

echo "Keyboard shortcuts configured!"
echo ""
echo "Key bindings summary:"
echo "  Super + 1-6       : Switch to workspace 1-6"
echo "  Super + Shift + 1-6 : Move window to workspace 1-6"
echo "  Super + W         : Close window"
echo "  Super + F         : Toggle fullscreen"
echo "  Super + M         : Toggle maximize"
