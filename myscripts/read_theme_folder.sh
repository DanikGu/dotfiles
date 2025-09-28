#!/bin/bash

# --- 1. Input Validation ---
# The script expects one argument: the path to the base directory.
base_dir="$1"

# Exit if no directory path is provided.
if [ -z "$base_dir" ]; then
  echo "Error: No directory path provided." >&2
  echo "Usage: $0 <path_to_directory>" >&2
  exit 1
fi

# Exit if the provided path is not a valid directory.
if [ ! -d "$base_dir" ]; then
  echo "Error: The path '$base_dir' is not a valid directory." >&2
  exit 1
fi

# --- 2. Subfolder Validation & Output ---
# Define the list of required subfolders.
required_folders=("sunrise" "sunset" "day" "night")

# Loop through the required folders and check for existence and content.
for folder_name in "${required_folders[@]}"; do
  subfolder_path="$base_dir/$folder_name"

  # Exit if a required subfolder does not exist.
  if [ ! -d "$subfolder_path" ]; then
    echo "Error: Required subfolder '$folder_name' does not exist in '$base_dir'." >&2
    exit 1
  fi

  # Count the number of items in the directory robustly.
  shopt -s nullglob
  files=("$subfolder_path"/*)
  item_count=${#files[@]}
  shopt -u nullglob

  # Get the full, absolute path to the directory portably.
  absolute_path=$(cd "$subfolder_path" && pwd)

  # Output the path and count as variable assignments.
  # Example: sunrise_path="/path/to/folder/sunrise"
  #          sunrise_count=5
  echo "${folder_name}_path=\"$absolute_path\""
  echo "${folder_name}_count=$item_count"
done

exit 0
