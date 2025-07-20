#!/bin/bash

threshhold_none=0
threshhold_green=1
threshhold_yellow=25
threshhold_red=50

if [[ ! -f /etc/arch-release ]]; then
    echo '{"text": "Unsupported platform"}'
    exit 1
fi

aur_helper=$(command -v paru || command -v yay || echo "")
if [[ -z "$aur_helper" ]]; then
    echo '{"text": "No AUR helper"}'
    exit 1
fi

# Check dependencies
if ! command -v checkupdates-with-aur &>/dev/null; then
    echo '{"text": "Missing checkupdates-with-aur"}'
    exit 1
fi

if ! command -v "$aur_helper" &>/dev/null; then
    echo '{"text": "Missing AUR helper: '"$aur_helper"'"}'
    exit 1
fi

aur_updates=$(checkupdates-with-aur 2>/dev/null | wc -l)
flatpak_updates=$(flatpak remote-ls --updates 2>/dev/null | wc -l)
updates=$((aur_updates + flatpak_updates))

# Determine CSS class based on thresholds
if (( updates >= threshhold_red )); then
    css_class="red"
elif (( updates >= threshhold_yellow )); then
    css_class="yellow"
elif (( updates >= threshhold_green )); then
    css_class="green"
else
    css_class="none"
fi

printf '{"text": " %s", "alt": "%s", "tooltip": "System updates: %s", "class": "%s"}' "$updates" "$updates" "$updates" "$css_class"
exit 0
