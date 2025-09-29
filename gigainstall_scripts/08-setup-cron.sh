#!/bin/bash
set -e

# Add cron job
(
  crontab -l 2>/dev/null
  echo "* * * * * $HOME/myscripts/day_night.sh"
) | crontab -
sudo systemctl enable cronie.service
sudo systemctl start cronie.service
