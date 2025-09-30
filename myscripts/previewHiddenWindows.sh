#!/bin/bash

# Get the active workspace ID
active_workspace_id=$(hyprctl activeworkspace -j | jq ".id")

# Build list of windows with unique display names
declare -A title_to_address
declare -A display_name_to_address
declare -A title_count

# Fetch clients from special workspace
clients=$(hyprctl -j clients | jq -c '.[] | select(.workspace.name == "special:minimum")')

while read -r client; do
  title=$(echo "$client" | jq -r '.title')
  address=$(echo "$client" | jq -r '.address')

  # Handle duplicate titles
  count=${title_count["$title"]}
  if [[ -n "$count" ]]; then
    count=$((count + 1))
    display_title="${title} (${count})"
  else
    count=1
    display_title="$title"
  fi

  title_count["$title"]=$count
  display_name_to_address["$display_title"]="$address"
done <<<"$clients"

# Build the menu input list
menu_list=$(printf "%s\n" "${!display_name_to_address[@]}" | sort)

# Show menu
selected_title=$(echo "$menu_list" | fuzzel --dmenu --placeholder "Select a window")

# Handle selection
if [[ -n "$selected_title" ]]; then
  selected_address="${display_name_to_address["$selected_title"]}"
  hyprctl dispatch movetoworkspacesilent "$active_workspace_id,address:$selected_address"
  hyprctl dispatch focuswindow "address:$selected_address"
fi

exit 0
