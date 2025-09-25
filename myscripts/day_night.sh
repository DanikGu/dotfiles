#!/bin/bash
# get flags
# isSunrise
# isSunset
# isDay
# isNight
source <(~/myscripts/get_solar_flag.sh)
echo "isSunrise" + $isSunrise
echo "isSunset" + $isSunset
echo "isDay" + $isDay
echo "isNight" + $isNight
if [ $? -ne 0 ]; then
  echo "Failed to get solar flags"
  exit 1
fi
#
#
#validate and take theme folders
#validate and take theme folders
#validate and take theme folders
source <(~/myscripts/read_theme_folder.sh ~/theme/walpapers/)
if [ $? -ne 0 ]; then
  echo "Failed to get theme folders"
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

if [ "$isSunrise" = true ]; then
  active_folder_path=$sunrise_path
  active_folder_count=$sunrise_count
elif [ "$isSunset" = true ]; then
  active_folder_path=$sunset_path
  active_folder_count=$sunset_count
elif [ "$isDay" = true ]; then
  active_folder_path=$day_path
  active_folder_count=$day_count
elif [ "$isNight" = true ]; then
  active_folder_path=$night_path
  active_folder_count=$night_count
fi

if [ -z "$active_folder_path" ]; then
  exit 1
fi

shopt -s nullglob
files=("$active_folder_path"/*)
shopt -u nullglob

if [ ${#files[@]} -eq 0 ]; then
  exit 1
fi

current_minute=$((10#$(date +%M)))
image_index=$((current_minute % active_folder_count))
wallpaper_to_set="${files[$image_index]}"

echo "cuur wallpaper" + $wallpaper_to_set

# Apply the wallpaper to current display.
caelestia wallpaper -f "$wallpaper_to_set"
caelestia scheme set -n dynamic
exit 0
