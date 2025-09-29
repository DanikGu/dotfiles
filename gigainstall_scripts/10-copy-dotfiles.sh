#!/bin/bash
set -e

mkdir -p ~/.config
mkdir -p ~/myscripts

cp -r $HOME/dotfiles/theme ~/theme
cp -r $HOME/dotfiles/myscripts/* ~/myscripts

chmod +x ~/myscripts/*

