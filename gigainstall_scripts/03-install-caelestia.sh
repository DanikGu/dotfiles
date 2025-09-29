#!/bin/bash
set -e

INSTALL_DIR="${HOME}/.local/share/caelestia"

if [ -d "$INSTALL_DIR" ]; then
  cd "$INSTALL_DIR"
  git pull
else
  git clone https://github.com/caelestia-dots/caelestia.git "$INSTALL_DIR"
fi

cd "$INSTALL_DIR"

./install.fish --noconfirm

mkdir -p ~/.config/caelestia
mkdir -p ~/.config/hypr-custom
cp -r $HOME/dotfiles/CustomHyprConfigs/* ~/.config/hypr-custom/
cp -r $HOME/dotfiles/CaelestiaCustom/* ~/.config/caelestia/
