#!/bin/bash
set -e

if command -v yay >/dev/null 2>&1; then
  echo "yay is already installed"
else
  sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm && cd .. && rm -rf yay
fi
