#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Source utils.sh from parent directory
source "$SCRIPT_DIR/../utils.sh"

install_packages python-pipx gnome-shell-extensions

# Install gnome-extensions-cli only if not already installed
if ! command -v ~/.local/bin/gext &> /dev/null; then
  pipx install gnome-extensions-cli --system-site-packages
fi

EXTENSIONS=(
  "tactile@lundal.io"
  "lockkeys@vaina.lt"
  "no-overview@fthx"
  "dock-ng@ochi12.github.com"
  "windowIsReady_Remover@nunofarruca@gmail.com"
  "rounded-window-corners@fxgn"
  "AlphabeticalAppGrid@stuarthayhurst"
  "vertical-app-grid@lublst.github.io"
  "pinned-apps-in-appgrid@brunosilva.io"
  "legacyschemeautoswitcher@joshimukul29.gmail.com"
  "gnome-ui-tune@itstime.tech"
  "space-bar@luchrioh"
  "tophat@fflewddur.github.io"
  "appindicatorsupport@rgcjonas.gmail.com"
  "vicinae@dagimg-dot"
)

for ext in "${EXTENSIONS[@]}"; do
  if ! ~/.local/bin/gext list | grep "$ext" &> /dev/null; then
    echo "Installing extension: $ext"
    ~/.local/bin/gext install "$ext"
  else
    echo "Extension already installed: $ext"
  fi
done

