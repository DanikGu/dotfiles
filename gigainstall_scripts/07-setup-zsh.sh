#!/bin/bash
set -e

chsh -s $(which zsh)

mkdir -p ~/.oh-my-zsh
cp -r $HOME/dotfiles/.zshrc "$HOME/"
cp -r $HOME/dotfiles/zsh/* ~/.oh-my-zsh/

# Create .secret-env.zsh if it doesn't exist
if [ ! -f "$HOME/.secret-env.zsh" ]; then
  touch "$HOME/.secret-env.zsh"
fi
