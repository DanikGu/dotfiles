#!/bin/bash
set -e

if command -c niflveil >/dev/null 2>&1; then
  echo "niflveil already installed"
else
  if [ -d "NiflVeil" ]; then
    echo "NiflVeil directory already exists, pulling latest changes"
    cd NiflVeil
    git pull
    cd niflveil
  else
    git clone https://github.com/Mauitron/NiflVeil.git
    cd NiflVeil/niflveil
  fi
  cargo build --release
  sudo cp target/release/niflveil /usr/local/bin/
fi
