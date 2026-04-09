#!/usr/bin/env bash

# File to track caffeine state
STATE_FILE="/tmp/caffeine_on"

enable_caffeine() {
  if [[ ! -f "$STATE_FILE" ]]; then
    touch "$STATE_FILE"
    # Kill hypridle if it is running
    pkill hypridle
    notify-send "Caffeine Enabled" "Idle management suspended" -i coffee
  fi
}

disable_caffeine() {
  if [[ -f "$STATE_FILE" ]]; then
    rm -f "$STATE_FILE"
    # Restart hypridle if it isn't already running
    pgrep hypridle >/dev/null || hypridle &
    notify-send "Caffeine Disabled" "Idle management resumed" -i coffee
  fi
}

toggle_caffeine() {
  if [[ -f "$STATE_FILE" ]]; then
    disable_caffeine
  else
    enable_caffeine
  fi
}

case "$1" in
"on")
  enable_caffeine
  ;;
"off")
  disable_caffeine
  ;;
"toggle")
  toggle_caffeine
  ;;
"waybar")
  if [[ -f "$STATE_FILE" ]]; then
    # Nerd Font: nf-md-coffee (󰅶)
    echo '{"text": "󰅶", "class": "active", "tooltip": "Caffeine: ON"}'
  else
    # Nerd Font: nf-md-flask (󰛊) - shows Caffeine is inactive
    echo '{"text": "󰛊", "class": "inactive", "tooltip": "Caffeine: OFF"}'
  fi
  ;;
*)
  echo "Usage: $0 {on|off|toggle|waybar}"
  exit 1
  ;;
esac
