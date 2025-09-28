#!/bin/bash
set -e

if [ -d "$HOME/.config/nvim" ]; then
  echo "Nvim aready pulled"
  rm -rf $HOME/.config/nvim/
fi
echo "Pulling NVIM"

rm -rf ~/.config/nvim/.git
git clone https://github.com/LazyVim/starter ~/.config/nvim

cp -r $HOME/dotfiles/nvim ~/.config/
