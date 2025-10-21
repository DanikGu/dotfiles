#!/bin/bash
set -e

yay -S --needed \
  superfile \
  fzf \
  ripgrep \
  fd \
  cisco-secure-client \
  tree-sitter-cli \
  zsh \
  curl \
  neovim \
  lazygit \
  wl-clipboard \
  sublime-text \
  hyprpolkitagent \
  ddcutil \
  brightnessctl \
  app2unit \
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
  libnotify \
  grim \
  dart-sass \
  slurp \
  gpu-screen-recorder \
  glib1 \
  cliphist \
  fuzzel \
  python-build \
  python-installer \
  python-hatch-vcs \
  caelestia-cli \
  cronie \
  nodejs \
  npm \
  qpwgraph \
  kitty \
  archlinux-xdg-menu \
  dolphin \
  ark \
  --noconfirm

#make dolphin work correctly
XDG_MENU_PREFIX=arch- kbuildsycoca6

mkdir -p ~/.config/superfile
cp -r $HOME/dotfiles/superfile/ ~/.config/
cp -r $HOME/dotfiles/kitty ~/.config/
kitten choose-font
