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
  nodejs \
  npm \
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
  keepassxc \
  --noconfirm

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

chsh -s $(which zsh)

# Add cron job
(
  crontab -l 2>/dev/null
  echo "* * * * * $HOME/myscripts/day_night.sh"
) | crontab -
sudo systemctl enable cronie.service
sudo systemctl start cronie.service

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
cp -r $HOME/dotfiles/myscripts/* ~/myscripts
cp -r $HOME/dotfiles/zsh/* ~/.oh-my-zsh
cp -r $HOME/dotfiles/shell.json ~/.config/caelestia/shell.json

chmod +x ~/myscripts/*

git config --global user.name "DanikGu"
git config --global user.email "petrikpzto4kin@gmail.com"

yay -S --needed libsecret gnome-keyring github-cli --noconfirm
systemctl --user enable gcr-ssh-agent.socket
systemctl --user start gcr-ssh-agent.socket
git config --global credential.helper /usr/lib/git-core/git-credential-libsecret
printf "aPassword" | secret-tool store --label="test" foo bar
read -p "Do you want to log in to GitHub? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  gh auth login
fi

if command -c niflveil >/dev/null 2>&1; then
  echo "niflveil already installed"
else
  if [ -d "NiflVeil" ]; then
    echo "NiflVeil directory already exists, pulling latest changes"
    cd NiflVeil
    git pull
    cd niflveil
  else
    git clone https://github.com/Mauitron/NiflVeil.git
    cd NiflVeil/niflveil
  fi
  cargo build --release
  sudo cp target/release/niflveil /usr/local/bin/
fi

sh -c "$(curl -fsSL https://raw.githubusercontent.com/keyitdev/sddm-astronaut-theme/master/setup.sh)"
sudo npm install -g @google/gemini-cli

echo "Install script ended, don't forget to setup keepassxc with your database and update browser exstension with keepassxc and gemini-cli project id"
