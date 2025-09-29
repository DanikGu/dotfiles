#!/bin/bash

# Get the active workspace ID
active_workspace_id=$(hyprctl activeworkspace -j | jq ".id")

# Get the list of windows from the special workspace
window_list=$(hyprctl -j clients |
  jq -r '.[] | select(.workspace.name == "special:minimum") | "\(.title)\t"')

# Use fuzzel to select a window
selected_window_line=$(echo -e "$window_list" | fuzzel --dmenu --placeholder "Select a window")

# If a window is selected, move it to the active workspace and focus it
if [ -n "$selected_window_line" ]; then
  selected_window_address=$(echo "$selected_window_line" | awk -F"\t" '{print $1}')
  hyprctl dispatch movetoworkspacesilent "$active_workspace_id,title:$selected_window_address"
  hyprctl dispatch focuswindow "title:$selected_window_address"
fi

exit 0
