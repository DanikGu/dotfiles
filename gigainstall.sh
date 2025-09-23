#!/bin/bash
set -e
cd ~

sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si

cd ..

rm -rf yay
yay -S \
  zsh \
  curl \
  neovim \
  wl-clipboard \
  sublime-text \
  hyprpolkitagent \
  quickshell \
  ddcutil \
  brightnessctl \
  app2unit-git \
  base-devel \
  fftw \
  alsa-lib \
  iniparser \
  pkgconf \
  networkmanager \
  lm-sensors \
  fish \
  pipewire \
  aubio \
  glibc-locales lib32-glibc \
  qt6-declarative \
  gcc \
  material-symbols-git \
  ttf-caskaydia-cove-nerd \
  swappy \
  libqalculate \
  qt6-base \
  --noconfirm

INSTALL_DIR="${HOME}/.local/share/caelestia"

if [ -d "$INSTALL_DIR" ]; then
  cd "$INSTALL_DIR"
  git pull
else
  git clone https://github.com/DanikGu/caelestia.git "$INSTALL_DIR"
fi

cd "$INSTALL_DIR"

fish ./install.fish aur-helper=--yay "$@"

REPO_URL="https://github.com/DanikGu/dotfiles.git"
git clone "$REPO_URL" "$HOME/dotfiles"
mkdir -p ~/.config
if [ -d "$HOME/dotfiles/nvim" ]; then
  cp -r "$HOME/dotfiles/nvim" ~/.config/
fi

if [ -d "$HOME/dotfiles/kitty" ]; then
  cp -r "$HOME/dotfiles/kitty" ~/.config/
fi

cp "$HOME/dotfiles/.zshrc" "$HOME/"

echo "Dotfiles setup complete. ✅"

curl -L https://dot.net/v1/dotnet-install.sh -o dotnet-install.sh
chmod +x ./dotnet-install.sh
./dotnet-install.sh --version latest
./dotnet-install.sh --version latest --runtime aspnetcore
./dotnet-install.sh --channel 9.0
./dotnet-install.sh --channel 8.0

yay -S \
  visual-studio-code-bin \
  rider \
  google-chrome \
  materialgram-bin \
  discord \
  teams-for-linux \
  vivaldi \
  cisco-anyconnect

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

chsh -s /usr/bin/zsh

