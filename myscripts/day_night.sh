#!/bin/bash

DBUS_ADDRESS=$(
  pgrep -u "$(whoami)" |
    xargs -I {} -r cat /proc/{}/environ 2>/dev/null |
    tr '\0' '\n' |
    grep -m 1 '^DBUS_SESSION_BUS_ADDRESS='
)

# Get DISPLAY variable
DISPLAY_VAR=$(
  pgrep -u "$(whoami)" |
    xargs -I {} -r cat /proc/{}/environ 2>/dev/null |
    tr '\0' '\n' |
    grep -m 1 '^DISPLAY='
)

# Export the variables if found
if [ -n "$DBUS_ADDRESS" ]; then
  export "$DBUS_ADDRESS"
  echo "Exported $DBUS_ADDRESS"
fi

if [ -n "$DISPLAY_VAR" ]; then
  export "$DISPLAY_VAR"
  echo "Exported $DISPLAY_VAR"
fi

if [ -z "$DBUS_ADDRESS" ] || [ -z "$DISPLAY_VAR" ]; then
  echo "Warning: Could not find full D-Bus/X11 environment. Attempting to set basic DISPLAY." >&2
  export DISPLAY=:0
fi
# get flags
# isSunrise
# isSunset
# isDay
# isNight
source <($HOME/myscripts/get_solar_flag.sh)
# Check for failure: if the script failed, isSunrise will be empty.
if [ -z "$isSunrise" ]; then
  echo "Error: Failed to get solar flags. Exiting." >&2
  exit 1
fi

echo "isSunrise + $isSunrise"
echo "isSunset + $isSunset"
echo "isDay + $isDay"
echo "isNight + $isNight"

#
#validate and take theme folders
source <($HOME/myscripts/read_theme_folder.sh $HOME/theme/walpapers/)
if [ $? -ne 0 ]; then
  echo "Failed to get theme folders" >&2
  exit 1
fi
echo "--- Day ---"
echo "Path: $day_path"
echo "Count: $day_count"
echo
echo "--- Night ---"
echo "Path: $night_path"
echo "Count: $night_count"
echo
echo "--- Sunrise ---"
echo "Path: $sunrise_path"
echo "Count: $sunrise_count"
echo
echo "--- Sunset ---"
echo "Path: $sunset_path"
echo "Count: $sunset_count"
sleep 2

PRESENT_TIME=$(date +%H)

active_folder_path=""
active_folder_count=0

if [ "$isSunrise" = "true" ]; then
  active_folder_path="$sunrise_path"
  active_folder_count=$sunrise_count
elif [ "$isSunset" = "true" ]; then
  active_folder_path="$sunset_path"
  active_folder_count=$sunset_count
elif [ "$isDay" = "true" ]; then
  active_folder_path="$day_path"
  active_folder_count=$day_count
elif [ "$isNight" = "true" ]; then
  active_folder_path="$night_path"
  active_folder_count=$night_count
fi

if [ -z "$active_folder_path" ]; then
  echo "Error: No active folder path determined." >&2
  exit 1
fi

shopt -s nullglob
files=("$active_folder_path"/*)
shopt -u nullglob

if [ ${#files[@]} -eq 0 ]; then
  echo "Error: Active folder is empty: $active_folder_path" >&2
  exit 1
fi

if [ "$active_folder_count" -eq 0 ]; then
  echo "Error: active_folder_count is zero." >&2
  exit 1
fi

current_minute=$((10#$(date +%M)))
# Use the remainder of division by the count to get a valid index
image_index=$((current_minute % active_folder_count))
wallpaper_to_set="${files[$image_index]}"

echo "curr wallpaper + $wallpaper_to_set"

# Apply the wallpaper to current display. This is where the DISPLAY fix is crucial.
caelestia wallpaper -f "$wallpaper_to_set"
caelestia scheme set -n dynamic

exit 0
