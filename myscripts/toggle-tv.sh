#!/bin/bash

# This script swaps the names of two files:
# ~/.config/hypr/monitors.conf and ~/.config/hypr/monitors-alt.conf

# Exit immediately if a command exits with a non-zero status.
set -e

# Define the file paths
CONF_DIR="$HOME/.config/hypr-custom"
FILE1="$CONF_DIR/monitors.conf"
FILE2="$CONF_DIR/monitors-alt.conf"
TEMP_FILE="$CONF_DIR/monitors.tmp"

# Check if both files exist before attempting to swap
if [ ! -f "$FILE1" ]; then
  echo "Error: Main configuration file not found at $FILE1"
  exit 1
fi

if [ ! -f "$FILE2" ]; then
  echo "Error: Alternate configuration file not found at $FILE2"
  exit 1
fi

echo "Swapping configuration files..."

# Perform the swap using a temporary file name
mv "$FILE1" "$TEMP_FILE"
mv "$FILE2" "$FILE1"
mv "$TEMP_FILE" "$FILE2"

echo "Swap complete."
echo "  - '$FILE1' is now the previous '$FILE2'"
echo "  - '$FILE2' is now the previous '$FILE1'"
hyprctl reload
