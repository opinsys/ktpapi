#!/bin/bash

# Alters background image

set -eu

background_current_file=/usr/share/images/digabios-backgrounds/background.svg
background_versiontag_file=/usr/share/images/digabios-backgrounds/background-versiontag.svg
background_backup_file=/usr/share/images/digabios-backgrounds/background-bak.svg

if [[ ! -f "$background_backup_file" ]]; then
  sudo cp "$background_versiontag_file" "$background_backup_file"
fi

sed 's/#385e77/#38775e/' "$background_current_file" \
  | sudo tee "$background_current_file" > /dev/null
sed 's/@VERSION/@VERSION - AUTOMAATTI/; s/#385e77/#38775e/' "$background_versiontag_file" \
  | sudo tee "$background_versiontag_file" > /dev/null
