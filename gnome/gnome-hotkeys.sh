# Use 6 fixed workspaces instead of dynamic mode
gsettings set org.gnome.mutter dynamic-workspaces false
gsettings set org.gnome.desktop.wm.preferences num-workspaces 6

# Unset super+number becuase for some reason gnome silenty changes them?
gsettings set org.gnome.shell.keybindings switch-to-application-1 "[]"
gsettings set org.gnome.shell.keybindings switch-to-application-2 "[]"
gsettings set org.gnome.shell.keybindings switch-to-application-3 "[]"
gsettings set org.gnome.shell.keybindings switch-to-application-4 "[]"
gsettings set org.gnome.shell.keybindings switch-to-application-5 "[]"
gsettings set org.gnome.shell.keybindings switch-to-application-6 "[]"
gsettings set org.gnome.shell.keybindings switch-to-application-7 "[]"
gsettings set org.gnome.shell.keybindings switch-to-application-8 "[]"
gsettings set org.gnome.shell.keybindings switch-to-application-9 "[]"

# Use super for workspaces
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-1 "['<Super>1']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-2 "['<Super>2']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-3 "['<Super>3']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-4 "['<Super>4']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-5 "['<Super>5']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-6 "['<Super>6']"

# Alt+F4 is very cumbersome
gsettings set org.gnome.desktop.wm.keybindings close "['<Super>w', '<Super><Shift>q']"

# Move windows to workspaces with Super+Shift+number
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-1 "['<Super><Shift>1']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-2 "['<Super><Shift>2']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-3 "['<Super><Shift>3']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-4 "['<Super><Shift>4']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-5 "['<Super><Shift>5']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-6 "['<Super><Shift>6']"

# WM-style window management shortcuts
gsettings set org.gnome.desktop.wm.keybindings toggle-fullscreen "['<Super>f']"
gsettings set org.gnome.desktop.wm.keybindings toggle-maximized "['<Super>m']"
gsettings set org.gnome.desktop.wm.keybindings minimize "['<Super>n']"

# Focus windows directionally (hyprland/sway style)
gsettings set org.gnome.desktop.wm.keybindings focus-left "['<Super>h', '<Super>Left']"
gsettings set org.gnome.desktop.wm.keybindings focus-down "['<Super>j', '<Super>Down']"
gsettings set org.gnome.desktop.wm.keybindings focus-up "['<Super>k', '<Super>Up']"
gsettings set org.gnome.desktop.wm.keybindings focus-right "['<Super>l', '<Super>Right']"

# Move windows directionally
gsettings set org.gnome.desktop.wm.keybindings move-left "['<Super><Shift>h', '<Super><Shift>Left']"
gsettings set org.gnome.desktop.wm.keybindings move-down "['<Super><Shift>j', '<Super><Shift>Down']"
gsettings set org.gnome.desktop.wm.keybindings move-up "['<Super><Shift>k', '<Super><Shift>Up']"
gsettings set org.gnome.desktop.wm.keybindings move-right "['<Super><Shift>l', '<Super><Shift>Right']"

# Launch terminal and app launcher
gsettings set org.gnome.settings-daemon.plugins.media-keys terminal "['<Super>Return']"
gsettings set org.gnome.desktop.wm.keybindings show-desktop "['<Super>d']"
gsettings set org.gnome.shell.keybindings toggle-overview "['<Super>Space']"

