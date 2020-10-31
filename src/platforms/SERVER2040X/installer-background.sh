#!/bin/bash
# Alters background image
background_current_file=/usr/share/images/digabios-backgrounds/background.svg
background_versiontag_file=/usr/share/images/digabios-backgrounds/background-versiontag.svg
background_backup_file=/usr/share/images/digabios-backgrounds/background-bak.svg

[[ ! -f "$background_backup_file" ]] && sudo cp "$background_versiontag_file" "$background_backup_file"
sudo cat "$background_current_file" | awk '{ sub(/#385e77/,"#38775e")}' > "$background_current_file"
sudo cat "$background_versiontag_file" | awk '{ sub(/@VERSION/,"@VERSION - AUTOMAATTI"); print }' | awk '{ sub(/#385e77/,"#38775e")}' > "$background_versiontag_file"
