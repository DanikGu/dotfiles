#!/bin/bash
set -e

# 1. Uncomment Ukrainian locale
echo "Uncommenting Ukrainian locale..."
sudo sed -i '/^#uk_UA.UTF-8/s/^#//' /etc/locale.gen

# 2. Generate the locale
echo "Generating locale..."
sudo locale-gen

# 3. Create keyboard config for Hyprland
echo "Creating Hyprland keyboard config..."
HYPR_CUSTOM_DIR="$HOME/.config/hypr-custom"
mkdir -p "$HYPR_CUSTOM_DIR"

cat <<EOT > "$HYPR_CUSTOM_DIR/keyboard.conf"
input {
    kb_layout = us,ua
    kb_options = grp:alt_shift_toggle
}
EOT

# 4. Source the new config file in hypr-user.conf
echo "Sourcing keyboard config in hypr-user.conf..."
HYPR_USER_CONF="$HOME/dotfiles/CaelestiaCustom/hypr-user.conf"

if [ -f "$HYPR_USER_CONF" ]; then
  # Add the source line if it doesn't exist
  if ! grep -q "source=~/.config/hypr-custom/keyboard.conf" "$HYPR_USER_CONF"; then
    echo -e "
# Source keyboard configuration
source=~/.config/hypr-custom/keyboard.conf" >> "$HYPR_USER_CONF"
  fi
else
  echo "Warning: hypr-user.conf not found at $HYPR_USER_CONF. You will need to manually source the keyboard.conf file."
fi

echo "Ukrainian locale and keyboard layout have been added."
echo "You may need to restart your session for the changes to take effect."
