#!/bin/bash

cd ~

sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si

cd ..

rm -rf yay
yay -S \
  curl \
  neovim \
  wl-clipboard \
  vivaldi \
  sublime-text \
  hyprpolkitagent \
  caelestia-cli \
  quickshell \
  ddcutil \
  brightnessctl \
  app2unit-git \
  base-devel \
  fftw \
  alsa-lib \
  iniparser \
  pulseaudio \
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
  visual-studio-code-bin \
  rider \
  google-chrome \
  materialgram-bin \
  discord \
  teams-for-linux \
  cisco-anyconnect \
  --noconfirm

INSTALL_DIR="${HOME}/.local/share/caelestia"

if [ -d "$INSTALL_DIR" ]; then
  echo "Error: Directory ${INSTALL_DIR} already exists." >&2
  echo "Please remove it first if you want to reinstall." >&2
  exit 1
fi

git clone https://github.com/DanikGu/caelestia.git "$INSTALL_DIR"
cd "$INSTALL_DIR"

fish ./install.fish "$@"

REPO_URL="https://github.com/DanikGu/dotfiles.git"
git clone "$REPO_URL" "$HOME/dotfiles"
mkdir -p ~/.config
if [ -d "$HOME/dotfiles/nvim" ]; then
  cp -r "$HOME/dotfiles/nvim" ~/.config/
fi

if [ -d "$HOME/dotfiles/kitty" ]; then
  cp -r "$HOME/dotfiles/kitty" ~/.config/
fi
rm -rf "$HOME/dotfiles"

echo "Dotfiles setup complete. ✅"

curl -L https://dot.net/v1/dotnet-install.sh -o dotnet-install.sh
chmod +x ./dotnet-install.sh
./dotnet-install.sh --version latest
./dotnet-install.sh --version latest --runtime aspnetcore
./dotnet-install.sh --channel 9.0
./dotnet-install.sh --channel 8.0
