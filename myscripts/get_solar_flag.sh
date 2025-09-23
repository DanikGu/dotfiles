#!/bin/bash

# Ensure jq is installed
if ! command -v jq &>/dev/null; then
  echo "Error: jq is not installed. Please install it to run this script." >&2
  exit 1
fi

# Fetch and Parse Data
json_response=$(curl -s "https://api.sunrisesunset.io/json?lat=50.27&lng=30.53")
api_status=$(echo "$json_response" | jq -r '.status')

if [ "$api_status" != "OK" ]; then
  echo "Error: Failed to retrieve valid data from API. Response: $json_response" >&2
  exit 1
fi

api_date=$(echo "$json_response" | jq -r '.results.date')
sunrise_time=$(echo "$json_response" | jq -r '.results.sunrise')
sunset_time=$(echo "$json_response" | jq -r '.results.sunset')

# Convert Times to Unix Timestamps
current_ts=$(date +%s)
sunrise_ts=$(date -d "$api_date $sunrise_time" +%s)
sunset_ts=$(date -d "$api_date $sunset_time" +%s)
hour_in_seconds=3600

# Determine Boolean Flags
isSunrise=false
isSunset=false
isDay=false
isNight=false

if ((current_ts >= sunrise_ts - hour_in_seconds && current_ts <= sunrise_ts + hour_in_seconds)); then
  isSunrise=true
fi

if ((current_ts >= sunset_ts - hour_in_seconds && current_ts <= sunset_ts + hour_in_seconds)); then
  isSunset=true
fi

if ((current_ts > sunrise_ts + hour_in_seconds && current_ts < sunset_ts - hour_in_seconds)); then
  isDay=true
fi

if ((current_ts > sunset_ts + hour_in_seconds || current_ts < sunrise_ts - hour_in_seconds)); then
  isNight=true
fi

# Output the results as variable assignments
echo "isSunrise=$isSunrise"
echo "isSunset=$isSunset"
echo "isDay=$isDay"
echo "isNight=$isNight"
