#!/bin/bash

# Get clipboard content
clipboard_content=$(wl-paste)

# Trim leading whitespace to find the first non-blank character
trimmed_content=$(echo "$clipboard_content" | sed -e 's/^[[:space:]]*//')

# Get the first character
first_char="${trimmed_content:0:1}"

# Check the first character and process accordingly
if [[ "$first_char" == "{" || "$first_char" == "[" ]]; then
  echo "Detected JSON, processing with jq and opening in nvim..."
  echo "$clipboard_content" | jq | nvim -
elif [[ "$first_char" == "<" ]]; then
  echo "Detected XML, processing with xmllint and opening in nvim..."
  echo "$clipboard_content" | xmllint --format - | nvim -
else
  echo "Clipboard content does not start with '{' or '<'. Opening directly in nvim..."
  echo "$clipboard_content" | nvim -
fi
