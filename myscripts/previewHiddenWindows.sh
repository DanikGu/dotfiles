#!/bin/bash

FZF_TERMINAL_TITLE="HyprWindowSwitcherFZF"

if [[ -z "$1" ]]; then
  hyprctl dispatch exec "kitty --class xlipse --title \"$FZF_TERMINAL_TITLE\" bash -c \"\\\"$0\\\" --fzf-mode\"" &
  exit 0
fi

active_workspace_id=$(hyprctl activeworkspace -j | jq ".id")

scratchpad_workspace_id=$((10 + active_workspace_id))

window_list=$(hyprctl -j clients |
  jq -r '.[] | select(.workspace.name == "special:minimum") | "\(.address)\t\(.title)\t(.workspace.id)"')

selected_window_address=$(echo "$window_list" | fzf \
  --wrap \
  --delimiter=$'\t' \
  --with-nth=2 \
  --layout=reverse | awk -F"\t" "{print \$1}")

if [ -n "$selected_window_address" ]; then
  hyprctl dispatch movetoworkspacesilent "$active_workspace_id,address:$selected_window_address"
  hyprctl dispatch focuswindow "address:$selected_window_address"
fi

exit 0
