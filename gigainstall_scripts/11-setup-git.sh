#!/bin/bash
set -e

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
