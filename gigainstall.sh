#!/bin/bash
set -e

# Install gum if not installed
if ! command -v gum &>/dev/null; then
    echo "gum not found, installing..."
    sudo pacman -S --needed gum --noconfirm
fi

# Make all scripts in gigainstall_scripts executable
chmod +x gigainstall_scripts/*.sh

# Get the list of scripts, sorted numerically
scripts=($(ls -v gigainstall_scripts/*.sh))
script_names=()
for script in "${scripts[@]}"; do
  script_names+=("$(basename "$script")")
done

# Add "Exit" option
script_names+=("Exit")

# Function to run a script
run_script() {
  echo "----------------------------------------"
  echo "Running $(basename "$1")..."
  echo "----------------------------------------"
  bash "$1"
  echo "----------------------------------------"
  echo "$(basename "$1") finished."
  echo "----------------------------------------"
  echo
}

# Main loop
while true; do
    echo "Select scripts to run:"
    selected_scripts=$(gum choose --no-limit "${script_names[@]}")

    if [ -z "$selected_scripts" ]; then
      echo "No scripts selected. Please make a selection."
      continue
    fi

    # Check if Exit is selected
    if echo "$selected_scripts" | grep -q "Exit"; then
        echo "Exiting."
        exit 0
    fi

    echo "Selected scripts to run:"
    echo "$selected_scripts"
    echo

    read -p "Proceed with running these script(s)? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      # Convert selected script names back to paths
      for selected in $selected_scripts; do
        for script in "${scripts[@]}"; do
            if [[ "$(basename "$script")" == "$selected" ]]; then
                run_script "$script"
                break
            fi
        done
      done
      break
    else
      echo "Aborted. Re-prompting..."
    fi
done

echo "Install script ended, don't forget to setup keepassxc with your database and update browser exstension with keepassxc and gemini-cli project id"
