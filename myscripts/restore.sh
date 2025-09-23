#!/bin/bash

# This script automates the restoration of Arch Linux user configurations,
# custom folders, and package installations from a backup zip file created
# by the 'arch_config_backup.sh' script.

# --- Configuration ---
# Path to your backup zip file.
# IMPORTANT: Before running, ensure this file is accessible (e.g., in your home directory).
BACKUP_ZIP_FILE="$HOME/arch_config_backup_YYYYMMDD_HHMMSS.zip" # <<<--- !! IMPORTANT: UPDATE THIS PATH !!

# Temporary directory for extracting the backup content.
RESTORE_TEMP_DIR="/tmp/arch_restore_temp_$(date +"%Y%m%d_%H%M%S")"

# --- Script Start ---
# Exit immediately if a command exits with a non-zero status.
set -e

echo "Starting Arch Linux configuration restoration..."
echo "---"

# --- Trap for robust cleanup ---
# This ensures the temporary extraction directory is removed even if the script exits unexpectedly.
trap 'echo "Cleaning up temporary restoration directory: $RESTORE_TEMP_DIR" && rm -rf "$RESTORE_TEMP_DIR" &>/dev/null' EXIT INT TERM

# Check for required commands
REQUIRED_COMMANDS=("unzip" "git" "pacman")
for cmd in "${REQUIRED_COMMANDS[@]}"; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: Required command '$cmd' not found. Please install it."
    exit 1
  fi
done

# --- 1. Validate Backup File ---
if [ ! -f "$BACKUP_ZIP_FILE" ]; then
  echo "Error: Backup zip file not found at '$BACKUP_ZIP_FILE'."
  echo "Please update the 'BACKUP_ZIP_FILE' variable in the script with the correct path."
  exit 1
fi

echo "Using backup file: $BACKUP_ZIP_FILE"
echo "Creating temporary restoration directory: $RESTORE_TEMP_DIR"
mkdir -p "$RESTORE_TEMP_DIR"

# --- 2. Unpack the Backup Archive ---
echo "---"
echo "Unpacking the backup archive..."
unzip "$BACKUP_ZIP_FILE" -d "$RESTORE_TEMP_DIR"
# Find the actual extracted directory name (e.g., arch_config_backup_YYYYMMDD_HHMMSS_data)
EXTRACTED_DATA_DIR=$(find "$RESTORE_TEMP_DIR" -maxdepth 1 -type d -name "*_data" -print -quit)

if [ -z "$EXTRACTED_DATA_DIR" ]; then
  echo "Error: Could not find the extracted data directory within '$RESTORE_TEMP_DIR'."
  echo "Backup zip file might be corrupted or in an unexpected format."
  exit 1
fi
echo "Backup successfully unpacked to: $EXTRACTED_DATA_DIR"

# --- 3. Install Yay (AUR Helper) ---
echo "---"
echo "Installing Yay (AUR helper)..."

# Ensure base-devel and git are installed, as they are needed to build AUR packages
sudo pacman -Syu --needed --noconfirm base-devel git

# Clone, build, and install Yay
YAY_DIR="/tmp/yay_build" # Temporary directory for yay build
git clone https://aur.archlinux.org/yay.git "$YAY_DIR"
cd "$YAY_DIR"
makepkg -si --noconfirm
if [ $? -ne 0 ]; then
  echo "Error: Failed to install Yay. Please check the output above."
  exit 1
fi
cd - # Go back to the previous directory
echo "Yay installed successfully."

# --- 4. Install Packages Using Yay ---
echo "---"
echo "Installing packages (native and AUR) using Yay..."

# Install native packages first
NATIVE_PKGLIST="$EXTRACTED_DATA_DIR/pkglist_native.txt"
if [ -f "$NATIVE_PKGLIST" ]; then
  echo "Installing native packages from $NATIVE_PKGLIST..."
  yay -S --needed --noconfirm - <"$NATIVE_PKGLIST"
  if [ $? -ne 0 ]; then
    echo "Warning: Some native packages might have failed to install. Continuing..."
  fi
else
  echo "Warning: Native package list '$NATIVE_PKGLIST' not found. Skipping native package installation."
fi

# Install AUR packages
AUR_PKGLIST="$EXTRACTED_DATA_DIR/pkglist_aur.txt"
if [ -f "$AUR_PKGLIST" ]; then
  echo "Installing AUR packages from $AUR_PKGLIST..."
  yay -S --needed --noconfirm - <"$AUR_PKGLIST"
  if [ $? -ne 0 ]; then
    echo "Warning: Some AUR packages might have failed to install. Continuing..."
  fi
else
  echo "Warning: AUR package list '$AUR_PKGLIST' not found. Skipping AUR package installation."
fi

echo "Package installation phase complete."

# --- 5. Restore Dotfiles and Configuration Directories ---
echo "---"
echo "Restoring dotfiles and configuration directories to your home folder..."
echo "WARNING: This will overwrite existing files/directories in your home folder."
echo "         Proceed with caution. Consider manually reviewing first if unsure."
echo "         rsync -av --dry-run \"$EXTRACTED_DATA_DIR/.\" \"$HOME/\""
echo "         (Run the above command without --dry-run to perform the actual copy)"

# Use rsync to copy contents (including hidden files/dirs) from extracted backup to home.
# -a: archive mode (preserves permissions, timestamps, etc.)
# -v: verbose (shows files being copied)
# --delete: WARNING! This will delete files in the destination that are NOT in the source.
#           Consider removing --delete if you want to merge rather than mirror.
#           For a clean restore mimicking the source, it's often desired.
# "$EXTRACTED_DATA_DIR/." : The trailing '/.' ensures the *contents* of the directory are copied, not the directory itself.
rsync -av --progress "$EXTRACTED_DATA_DIR/." "$HOME/"

echo "Dotfiles and configuration directories restoration complete."

# --- Final Notes and Next Steps ---
echo "---"
echo "Restoration process finished. Please note the following important steps:"
echo "1.  **System-wide Configuration (/etc):** This script does NOT touch /etc files."
echo "    You will need to manually restore or re-configure any critical system-wide files"
echo "    (e.g., /etc/fstab, /etc/locale.gen, /etc/mkinitcpio.conf, GRUB settings, network configs)."
echo "2.  **Sensitive Files:** If you excluded sensitive files like SSH keys or GPG keys from the backup,"
echo "    you'll need to restore them from their dedicated secure backups."
echo "3.  **Permissions:** You may need to verify or correct file permissions for some restored files."
echo "4.  **Reboot:** It is highly recommended to reboot your system to ensure all changes (especially services, display managers) take effect."
echo "    sudo reboot"
echo "---"

echo "Restoration script complete. Enjoy your re-configured Arch Linux!"
