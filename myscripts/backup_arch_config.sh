#!/bin/bash

# This script automates the backup of Arch Linux user configurations (dotfiles),
# specified custom folders, and a list of installed packages into a single zip file.

# --- Configuration ---
# The prefix for the backup filename. A timestamp will be appended.
BACKUP_FILENAME_PREFIX="arch_config_backup"

# The directory where the final zip file will be saved.
# This will be created if it doesn't exist.
BACKUP_DEST_DIR="$HOME/ArchConfigBackups"

# --- Folders to Manually Include in the Backup (Relative to $HOME) ---
# Add paths to any custom folders you want to include in your backup here.
# These should be relative to your home directory (e.g., "my_project_data", "Documents/notes").
# Examples:
# MANUAL_FOLDERS=(
#   "Projects/MySpecificProject"
#   "Scripts/MyCustomTools"
#   "ImportantDocuments"
# )
MANUAL_FOLDERS=(
  "theme"
  "flameshot"
  "hyprstaff"
  "myscripts"
  ".password-store"
)

# --- Exclusions for Dotfiles and Other Home Directory Content ---
# IMPORTANT: These patterns will EXCLUDE files and directories from the backup.
# They are relative to your home directory. Use with caution!
# These typically include large data, caches, temporary files, or highly sensitive files
# that should be handled separately (like SSH/GPG keys if not desired in the main backup).
# If you want to include a path that's currently excluded, remove or comment out its line.
EXCLUDE_PATTERNS=(
  # Common large cache/data directories that are not true configuration
  "*/.cache/*"
  "*/.mozilla/*"     # Firefox profile data (can be very large)
  "*/.thunderbird/*" # Thunderbird profile data (can be very large)
  "*/.config/Docker Desktop/*"
  "*/teams-for-linux/*"
  "*/CacheStorage/*"
  "*/CachedData/*"
  "*/Cache/*"
  "*/Code Cache/*"
  "*/Cache_Data/*"
  "*/Cache-Storage/*"
  "*/.config/Code/*"            # VSCode data (can include large workspace storage)
  "*/.config/discord/*"         # Discord cache
  "*/.local/share/Trash/*"      # Trash bin contents
  "*/.thumbnails/*"             # Image thumbnails cache
  "*/.nv/*"                     # NVIDIA cache
  "*/.steam/*"                  # Steam game data (very large!)
  "*/.vagrant.d/*"              # Vagrant boxes
  "*/.npm/*"                    # Node.js package manager cache
  "*/.yarn/*"                   # Yarn package manager cache
  "*/.bundle/*"                 # Ruby Bundler cache
  "*/.rustup/*"                 # Rust toolchain data
  "*/.vscode/*"                 # VSCode user data (extensions, etc.)
  "*/.local/share/containers/*" # Podman/Buildah containers
  "*/.local/share/flatpak/*"    # Flatpak application data
  "*/.local/share/npm/*"        # npm global packages
  "*/.local/share/pnpm/*"       # pnpm global packages
  "*/.local/share/JetBrains/*"  # JetBrains IDE caches
  "*/.local/share/VirtualBox/*" # VirtualBox VMs
  "*/.local/share/nvim/lazy/*"  # Neovim lazy.nvim plugins/data (can be large)
  "*/.var/*"                    # Flatpak applications user data
  "*/.wine/*"                   # Wine prefixes (can be very large)
  "*/.android/*"                # Android SDK/emulator data
  "*/.m2/*"                     # Maven local repository
  "*/.gradle/*"                 # Gradle caches
  "*/.nuget/*"                  # NuGet caches
  "*/.terraform.d/*"            # Terraform plugin cache
  "*/.ansible/*"                # Ansible caches
  "*/.kube/cache/*"             # Kubernetes cache
  "*/.docker/*"                 # Docker configuration (potentially sensitive/large)
  "*/node_modules/*"            # Node.js project dependencies (reinstallable)
  "*/bin/*"
  "*/obj/*"
  "*/nuget/*"
  "*/packages/*"
  "*/TestResults/*"
  "*/TestRuns/*"
  "*/.vs/*"
  "*/backup-data-of-batch-delete/*"

  # Sensitive files (consider handling these separately, e.g., on an encrypted USB)
  # Uncomment to exclude if you prefer not to include them in the zip
  # "*/.ssh/*"                # SSH keys
  # "*/.gnupg/*"              # GPG keys

  # Temporary/ephemeral system files
  "*/.ICEauthority" # Session authority file
  "*/.Xauthority"   # X server authority file
  "*/.gvfs"         # GNOME virtual file system mount point
  "*/.dbus"         # D-Bus session directory
)

# --- Script Start ---
# Ensure the script exits immediately if any command fails.
set -e

echo "Starting Arch Linux configuration backup..."
echo "---"

# Check for required commands (zip, pacman, and at least one AUR helper)
# If you don't use 'yay' or 'paru', you can comment out the relevant lines.
REQUIRED_COMMANDS=("zip" "pacman")
AUR_HELPERS=("yay" "paru")
HAS_AUR_HELPER=false

for cmd in "${REQUIRED_COMMANDS[@]}"; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: Required command '$cmd' not found. Please install it."
    exit 1
  fi
done

for helper in "${AUR_HELPERS[@]}"; do
  if command -v "$helper" &>/dev/null; then
    HAS_AUR_HELPER=true
    AUR_HELPER_CMD="$helper"
    break
  fi
done

if [ "$HAS_AUR_HELPER" = false ]; then
  echo "Warning: No common AUR helper (yay or paru) found. AUR package list will not be generated."
fi

# Create the destination directory for the final zip file if it doesn't exist.
mkdir -p "$BACKUP_DEST_DIR"
echo "Backup destination directory: $BACKUP_DEST_DIR"

# Create a unique timestamp for the backup file and temporary directory.
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_ZIP_FILE="$BACKUP_DEST_DIR/${BACKUP_FILENAME_PREFIX}_${TIMESTAMP}.zip"
TEMP_BACKUP_DIR="/tmp/${BACKUP_FILENAME_PREFIX}_${TIMESTAMP}_data"
trap 'echo "Cleaning up temporary directory: $TEMP_BACKUP_DIR" && rm -rf "$TEMP_BACKUP_DIR" &>/dev/null' EXIT INT TERM
echo "Creating temporary backup directory: $TEMP_BACKUP_DIR"
mkdir -p "$TEMP_BACKUP_DIR"

# --- 1. Collect Dotfiles and Common Configuration Directories ---
echo "---"
echo "Collecting dotfiles and common configuration directories..."

# List of common configuration files and directories relative to $HOME.
# These will be explicitly copied if they exist.
CONFIG_ITEMS=(
  ".config"    # Main XDG config directory
  ".local/bin" # Common place for user scripts
  ".fonts"
  ".themes"
  ".icons"
  ".bin"     # Another common place for user scripts
  ".mozilla" # For browser profiles and settings (excluding large caches via EXCLUDE_PATTERNS)
  ".pki"     # Public Key Infrastructure (certificates)
  ".npmrc"   # npm configuration file
  ".kube"    # Kubernetes config
  ".bashrc"
  ".zshrc"
  ".profile"
  ".xinitrc"
  ".Xresources"
  ".vimrc"
  ".gitconfig"
  ".tmux.conf"
  ".inputrc"
  ".dircolors"
  ".fehbg"
  ".gtkrc-2.0"
  ".gtkrc-3.0" # Note: often a symlink, but can be a direct config
  ".selected_editor"
  ".lesskey"
  ".nanorc"
  ".wgetrc"
  ".curlrc"
  ".bash_aliases"
  ".bash_logout"
  ".bash_profile"
  ".password_store"
  ".byobu"
  ".local/share/applications" # Custom .desktop files
  ".local/share/fonts"
  ".local/share/icons"
  ".local/share/themes"
  ".local/share/gnome-shell" # Gnome Shell extensions configuration
  ".local/share/nvim"        # Neovim configuration (ensure plugin data is excluded by patterns)
  ".ssh"                     # SSH keys (if not excluded above)
  ".gnupg"                   # GPG keys (if not excluded above)
  "Source"
)

# Function to robustly copy files/directories with exclusion patterns using rsync.
# rsync is used for its efficiency and robust handling of file permissions and exclusions.
copy_with_exclusions() {
  local source_path="$1"
  local dest_path="$2"
  local exclude_args=()

  # Construct rsync exclude arguments from the EXCLUDE_PATTERNS array.
  for pattern in "${EXCLUDE_PATTERNS[@]}"; do
    exclude_args+=("--exclude=$pattern")
  done

  # Check if the source path exists before attempting to copy.
  if [ -e "$source_path" ]; then
    echo "  Copying: $source_path"
    # rsync -av:
    # -a: archive mode (preserves permissions, ownership, timestamps, symlinks, etc.)
    # -v: verbose output
    # "$source_path"/.: copies the *contents* of source_path into dest_path if source is a directory.
    # If source is a file, it copies the file itself.
    rsync -av "${exclude_args[@]}" "$source_path" "$dest_path"
  else
    echo "  Warning: Source path '$source_path' does not exist, skipping."
  fi
}

# Iterate through the list of configuration items and copy them.
for item in "${CONFIG_ITEMS[@]}"; do
  copy_with_exclusions "$HOME/$item" "$TEMP_BACKUP_DIR/"
done

# --- 2. Add Manually Specified Folders ---
echo "---"
echo "Adding manually specified folders from the 'MANUAL_FOLDERS' list..."
for folder_path in "${MANUAL_FOLDERS[@]}"; do
  # Construct the full path to the source folder.
  FULL_SOURCE_PATH="$HOME/$folder_path"
  # Construct the destination path, preserving the relative structure.
  # (e.g., "Documents/Notes" will be copied to "$TEMP_BACKUP_DIR/Documents/Notes")
  FULL_DEST_PATH="$TEMP_BACKUP_DIR/$folder_path"

  if [ -d "$FULL_SOURCE_PATH" ]; then
    echo "  Adding manual folder: $FULL_SOURCE_PATH"
    # Ensure the parent directory structure exists in the temp backup directory.
    mkdir -p "$(dirname "$FULL_DEST_PATH")"
    # Copy the folder recursively.
    cp -R "$FULL_SOURCE_PATH" "$FULL_DEST_PATH"
  else
    echo "  Warning: Manual folder '$FULL_SOURCE_PATH' does not exist, skipping."
  fi
done

# --- 3. Generate Package Lists ---
echo "---"
echo "Generating package lists..."

# Native packages (installed from official Arch repositories)
if command -v pacman &>/dev/null; then
  pacman -Qqen >"$TEMP_BACKUP_DIR/pkglist_native.txt"
  echo "  Native package list saved to pkglist_native.txt"
else
  echo "  Error: pacman not found. Cannot generate native package list."
fi

# AUR packages (if an AUR helper is found)
if [ "$HAS_AUR_HELPER" = true ]; then
  "$AUR_HELPER_CMD" -Qqem >"$TEMP_BACKUP_DIR/pkglist_aur.txt"
  echo "  AUR package list ($AUR_HELPER_CMD) saved to pkglist_aur.txt"
else
  echo "  No AUR helper found. Skipping AUR package list generation."
fi

# --- 4. Create the Zip Archive ---
echo "---"
echo "Creating zip archive: $BACKUP_ZIP_FILE"

# Navigate to the parent directory of the temporary backup directory
# and then zip its content. This ensures the zip file contains
# the contents of $TEMP_BACKUP_DIR directly, not the full /tmp path.
(cd "$(dirname "$TEMP_BACKUP_DIR")" && zip -r "$BACKUP_ZIP_FILE" "$(basename "$TEMP_BACKUP_DIR")")

# --- 5. Clean Up ---
echo "---"
echo "Cleaning up temporary files..."
rm -rf "$TEMP_BACKUP_DIR"

echo ""
echo "--- Backup Complete! ---"
echo "Your Arch Linux configuration and package lists have been successfully backed up to:"
echo "$BACKUP_ZIP_FILE"
echo ""
echo "--- Important Notes for Restoration ---"
echo "To restore these on a fresh Arch Linux installation, follow these general steps:"
echo "1.  **Transfer the zip file** to your new system."
echo "2.  **Unzip the archive:**"
echo "    unzip \"$BACKUP_ZIP_FILE\" -d /tmp/arch_restore_temp"
echo "    # The extracted content will be in /tmp/arch_restore_temp/arch_config_backup_YYYYMMDD_HHMMSS_data"
echo "3.  **Restore Dotfiles and Configs:**"
echo "    # BE CAREFUL: This will overwrite existing files in your home directory."
echo "    # Consider using 'rsync -av --dry-run /tmp/arch_restore_temp/arch_config_backup_YYYYMMDD_HHMMSS_data/* ~/' first to see what will be copied."
echo "    # For a safer and more manageable approach, consider the Git bare repository method"
echo "    # described in the previous guide, using these files as your source."
echo "    # Example direct copy (use with extreme caution after reviewing!):"
echo "    # cp -Rv /tmp/arch_restore_temp/arch_config_backup_YYYYMMDD_HHMMSS_data/.* ~/"
echo "    # cp -Rv /tmp/arch_restore_temp/arch_config_backup_YYYYMMDD_HHMMSS_data/.config ~/ "
echo "4.  **Install Native Packages:**"
echo "    sudo pacman -S --needed - < /tmp/arch_restore_temp/arch_config_backup_YYYYMMDD_HHMMSS_data/pkglist_native.txt"
echo "5.  **Install AUR Helper & AUR Packages:**"
echo "    # First, install a common AUR helper (e.g., yay) if you don't have one:"
echo "    #   sudo pacman -S --needed base-devel git"
echo "    #   git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm && cd .."
echo "    # Then install AUR packages:"
echo "    #   yay -S --needed - < /tmp/arch_restore_temp/arch_config_backup_YYYYMMDD_HHMMSS_data/pkglist_aur.txt"
echo "6.  **Manually handle sensitive files** (like SSH keys, GPG keys) that were excluded or require special setup."
echo "7.  **Manually re-configure /etc files** (system-wide configurations) as they are not included in this user-specific backup."
echo "8.  **Clean up** the temporary restore directory after you are done: rm -rf /tmp/arch_restore_temp"
echo "---"
