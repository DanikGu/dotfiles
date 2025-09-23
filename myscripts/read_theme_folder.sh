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

# --- 2. Subfolder Validation ---
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

  # Exit if a subfolder is empty.
  # 'ls -A' lists all entries except for . and ..
  if [ -z "$(ls -A "$subfolder_path")" ]; then
    echo "Error: Subfolder '$subfolder_path' cannot be empty." >&2
    exit 1
  fi
done

# --- 3. Output Machine-Readable Data ---
# If all validations pass, output the data for another script to use.
for folder_name in "${required_folders[@]}"; do
  subfolder_path="$base_dir/$folder_name"
  # Count the number of items in the directory.
  item_count=$(ls -A "$subfolder_path" | wc -l)
  # Get the full, absolute path to the directory.
  absolute_path=$(readlink -f "$subfolder_path")

  # Output the path and count as variable assignments.
  # Example: sunrise_path="/path/to/folder/sunrise"
  #          sunrise_count=5
  echo "${folder_name}_path=\"$absolute_path\""
  echo "${folder_name}_count=$item_count"
done

exit 0
