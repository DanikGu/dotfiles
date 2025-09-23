#!/bin/sh

MY_SCRIPTS_DIR="$HOME/myscripts"
TEST_FILE_PATH="$MY_SCRIPTS_DIR/zenison"

if [ -f "$TEST_FILE_PATH" ]; then
  rm "$TEST_FILE_PATH"
else
  touch "$TEST_FILE_PATH"
fi
