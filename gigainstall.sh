#!/bin/bash
set -e
cd ~

if command -c yay >/dev/null 2>&1; then
  echo "yay is already installed"
else
  sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si
fi

cd ..

rm -rf yay
yay -S --needed \
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
  --noconfirm

INSTALL_DIR="${HOME}/.local/share/caelestia"

if [ -d "$INSTALL_DIR" ]; then
  cd "$INSTALL_DIR"
  git pull
else
  git clone https://github.com/DanikGu/caelestia.git "$INSTALL_DIR"
fi

cd "$INSTALL_DIR"

rm -rf ~/.config/hypr
rm -rf ~/.config/btop
aur_helper="yay"
fish ./install.fish $@

curl -L https://dot.net/v1/dotnet-install.sh -o dotnet-install.sh
chmod +x ./dotnet-install.sh
./dotnet-install.sh --version latest
./dotnet-install.sh --version latest --runtime aspnetcore
./dotnet-install.sh --channel 9.0
./dotnet-install.sh --channel 8.0

yay -S --needed \
  visual-studio-code-bin \
  rider \
  google-chrome \
  materialgram-bin \
  discord \
  teams-for-linux \
  vivaldi \
  thunar \
  cargo \
  --noconfirm

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

chsh -s $(which zsh)

# Add cron job
(
  crontab -l 2>/dev/null
  echo "* * * * * $HOME/myscripts/day_night.sh"
) | crontab -

mkdir -p ~/.config
mkdir -p ~/.config/caelestia
mkdir -p ~/.config/hypr-custom
mkdir -p ~/.oh-my-zsh
cp -r "$HOME/dotfiles/nvim" ~/.config/
cp -r "$HOME/dotfiles/kitty" ~/.config/
cp -r "$HOME/dotfiles/.zshrc" "$HOME/"
cp -r "$HOME/dotfiles/hypr-user.conf" ~/.config/caelestia/hypr-user.conf
cp -r "$HOME/dotfiles/CustomHyprConfigs/monitors.conf" ~/.config/hypr-custom/monitors.conf
cp -r "$HOME/dotfiles/CustomHyprConfigs/monitors-alt.conf" ~/.config/hypr-custom/monitors-alt.conf
cp -r "$HOME/dotfiles/theme" ~/theme
cp -r "$HOME/dotfiles/myscripts" ~/myscripts
cp -r $HOME/dotfiles/zsh/* ~/.oh-my-zsh
chmod +x ~/myscripts/*

git config --global user.name "DanikGu"
git config --global user.email "petrikpzto4kin@gmail.com"

yay -S --needed libsecret --noconfirm
CREDENTIAL_HELPER_PATH=$(whereis secret-tool | awk '{print $2}')
git config --global credential.helper "$CREDENTIAL_HELPER_PATH"

git clone https://github.com/Mauitron/NiflVeil.git
cd NiflVeil/niflveil
cargo build --release
sudo cp target/release/niflveil /usr/local/bin/
