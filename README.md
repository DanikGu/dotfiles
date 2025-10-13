# Description
My dotfiles to migrate my configuration 

### Install
  On clean build clone and start gigainstall.sh choose what to install 

### Post install step 
  -  Copy google-chrome/vivaldi configuration ~/.config/google-chrome
  -  Copy vimrc for rider ~/
  -  Copy dbeaver configuration ~/.local/share
  -  Copy virtual box configuration ~/.config ~/VirtualBox VMs
  -  Copy ~/Source ~/Downloads
  -  Copy KeePassXc database ~/
  -  Copy zhrc private variables

## Post install cisko configuration 
1) sudo systemctl enable --now vpnagentd.service
2) sudo pacman -S webkit2gtk
3) WEBKIT_DISABLE_DMABUF_RENDERER=1 GDK_BACKEND=x11 /opt/cisco/secureclient/bin/vpnui
